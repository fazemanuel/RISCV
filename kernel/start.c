#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "defs.h"

/*
  Nota de cambios respecto al "original" start.c:

  Cambios detectados:
  - Timer: la implementación actual configura directamente el CLINT/mtimecmp
    y usa un handler en machine mode (timervec + mscratch) en lugar de depender
    de stimecmp/stime (supervisor stimecmp extension) como en el original.
  - Se añadió un arreglo timer_scratch[NCPU][5] usado por timervec para guardar
    contexto temporal y pasar información (addr de MTIMECMP, intervalo).
  - El intervalo por defecto aquí es 100000 ciclos (antes en el original era
    1000000). Además se usa w_mtvec/w_mscratch y se habilitan interrupciones
    de máquina (MIE) en lugar de solamente configurar STIE.
  - Se cambió la máscara de SIE al escribir w_sie(...) incluyendo SIE_SSIE en
    la versión actual.

  Motivo / por qué:
  - Uso de MTIMECMP/CLINT y un handler en máquina permite control por-hart de
    los timers desde el arranque (útil en plataformas qemu/virt). Evita depender
    de la extensión supervisor stimecmp (sstc) que puede no estar disponible o
    comportarse distinto según la plataforma.
  - Permite programar el timer en M-mode y transformar la interrupción a S-mode
    (trampoline/kernelvec) de forma controlada, además de tener un scratch
    por-CPU para la rutina en assembly que se ejecuta en M-mode.
  - El intervalo reducido facilita experimentos con quantums más cortos.

  
*/

void main();
void timerinit();

// entry.S needs one stack per CPU.
__attribute__ ((aligned (16))) char stack0[4096 * NCPU];

// a scratch area per CPU for machine-mode timer interrupts.
uint64 timer_scratch[NCPU][5];

// assembly code in kernelvec.S for machine-mode timer interrupt.
extern void timervec();

// entry.S jumps here in machine mode on stack0.
void
start()
{
  // set M Previous Privilege mode to Supervisor, for mret.
  unsigned long x = r_mstatus();
  x &= ~MSTATUS_MPP_MASK;
  x |= MSTATUS_MPP_S;
  w_mstatus(x);

  // set M Exception Program Counter to main, for mret.
  // requires gcc -mcmodel=medany
  w_mepc((uint64)main);

  // disable paging for now.
  w_satp(0);

  // delegate all interrupts and exceptions to supervisor mode.
  w_medeleg(0xffff);
  w_mideleg(0xffff);
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);

  // configure Physical Memory Protection to give supervisor mode
  // access to all of physical memory.
  w_pmpaddr0(0x3fffffffffffffull);
  w_pmpcfg0(0xf);

  // ask for clock interrupts.
  timerinit();

  // keep each CPU's hartid in its tp register, for cpuid().
  int id = r_mhartid();
  w_tp(id);

  // switch to supervisor mode and jump to main().
  asm volatile("mret");
}

// arrange to receive timer interrupts.
// they will arrive in machine mode at
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();

  // ask the CLINT for a timer interrupt.
  int interval = 100000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
  scratch[3] = CLINT_MTIMECMP(id);
  scratch[4] = interval;
  w_mscratch((uint64)scratch);

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
}
