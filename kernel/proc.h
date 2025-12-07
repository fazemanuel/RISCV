// kernel/proc.h - Estructuras de datos para gestión de procesos
//
// Este archivo define las estructuras fundamentales para:
// 1. Representar procesos (struct proc)
// 2. Representar CPUs (struct cpu)
// 3. Contexto de ejecución (struct context)
// 4. Trapframe para transiciones kernel/user (struct trapframe)

// ============================================================================
// CONTEXTO DE EJECUCIÓN
// ============================================================================

// struct context - Registros guardados para context switching
//
// Cuando un proceso cede la CPU (via sched()), estos son los registros
// que se guardan/restauran para cambiar entre contextos.
//
// RISC-V CALLING CONVENTION:
// - Registros "callee-saved" (s0-s11): la función llamada debe preservarlos
// - Registros "caller-saved" (t0-t6, a0-a7): el caller debe guardarlos si los necesita
//
// Solo guardamos callee-saved porque el compilador ya guardó los caller-saved
// antes de llamar a swtch()
struct context {
  uint64 ra;  // Return address - dirección de retorno
  uint64 sp;  // Stack pointer - puntero a la pila
  
  // Callee-saved registers (registros que deben preservarse)
  uint64 s0;
  uint64 s1;
  uint64 s2;
  uint64 s3;
  uint64 s4;
  uint64 s5;
  uint64 s6;
  uint64 s7;
  uint64 s8;
  uint64 s9;
  uint64 s10;
  uint64 s11;
};

// ============================================================================
// DESCRIPTOR DE CPU
// ============================================================================

// struct cpu - Descriptor de una CPU física
//
// Cada CPU del sistema tiene su propia entrada en cpus[NCPU].
// Almacena información específica de esa CPU: qué proceso ejecuta,
// su contexto de scheduler, estado de interrupciones, etc.
struct cpu {
  // ──────────────────────────────────────────────────────────────────
  // PROCESO ACTUAL
  // ──────────────────────────────────────────────────────────────────
  struct proc *proc;     // Proceso ejecutando en esta CPU (o NULL)
                         // NULL = CPU ejecutando scheduler
                         // !NULL = CPU ejecutando ese proceso

  // ──────────────────────────────────────────────────────────────────
  // CONTEXTO DEL SCHEDULER
  // ──────────────────────────────────────────────────────────────────
  struct context context;  // Contexto del scheduler de esta CPU
                           // Cuando un proceso llama sched(), se guarda
                           // su contexto y se restaura este para volver
                           // al loop del scheduler()

  // ──────────────────────────────────────────────────────────────────
  // GESTIÓN DE INTERRUPCIONES Y LOCKS
  // ──────────────────────────────────────────────────────────────────
  int noff;              // Profundidad de push_off() anidados
                         // Contador de cuántos locks tiene esta CPU
                         // noff > 0 → interrupciones deshabilitadas
  
  int intena;            // ¿Estaban las interrupciones habilitadas antes
                         // del primer push_off()?
                         // Se preserva al hacer context switch
};

extern struct cpu cpus[NCPU];      // Arreglo de todas las CPUs

// ============================================================================
// TRAPFRAME - TRANSICIÓN KERNEL/USER
// ============================================================================

// struct trapframe - Estado completo del procesador para trampoline.S
//
// Esta estructura se encuentra en una página separada justo debajo de la
// página trampoline en el espacio de direcciones del usuario. NO está
// mapeada en el kernel page table.
//
// PROPÓSITO:
// ═════════════════════════════════════════════════════════════════════
// Cuando ocurre una trap (syscall, excepción, interrupción):
// 1. uservec (en trampoline.S) guarda TODOS los registros del usuario aquí
// 2. Inicializa registros desde kernel_sp, kernel_hartid, kernel_satp
// 3. Salta a kernel_trap (usertrap)
//
// Al retornar a usuario (usertrapret):
// 1. Configura kernel_* en el trapframe
// 2. userret (en trampoline.S) restaura TODOS los registros desde aquí
// 3. Cambia a user page table
// 4. Entra a espacio de usuario
//
// ¿POR QUÉ INCLUYE CALLEE-SAVED (s0-s11)?
// ═════════════════════════════════════════════════════════════════════
// Porque usertrapret() no retorna a través del call stack normal del kernel.
// Va directamente de kernel → user space, así que debe guardar/restaurar
// TODOS los registros, no solo los caller-saved.
//
// LAYOUT EN MEMORIA:
// ═════════════════════════════════════════════════════════════════════
// Los offsets están documentados para facilitar acceso desde assembly
struct trapframe {
  // ──────────────────────────────────────────────────────────────────
  // INFORMACIÓN DEL KERNEL (configurada por kernel antes de retornar)
  // ──────────────────────────────────────────────────────────────────
  /*   0 */ uint64 kernel_satp;   // Kernel page table
                                   // SATP = Supervisor Address Translation
                                   // Registro que apunta a la page table
  
  /*   8 */ uint64 kernel_sp;     // Top of process's kernel stack
                                   // Stack pointer del kernel para este proceso
  
  /*  16 */ uint64 kernel_trap;   // Dirección de usertrap()
                                   // Función a la que salta cuando hay trap
  
  /*  24 */ uint64 epc;            // Saved user program counter
                                   // EPC = Exception Program Counter
                                   // PC del usuario cuando ocurrió la trap
  
  /*  32 */ uint64 kernel_hartid; // Saved kernel tp (thread pointer)
                                   // ID del hardware thread (CPU ID)

  // ──────────────────────────────────────────────────────────────────
  // REGISTROS DEL USUARIO (guardados/restaurados en cada trap)
  // ──────────────────────────────────────────────────────────────────
  
  // Registros de propósito general
  /*  40 */ uint64 ra;             // Return address
  /*  48 */ uint64 sp;             // Stack pointer (user stack)
  /*  56 */ uint64 gp;             // Global pointer
  /*  64 */ uint64 tp;             // Thread pointer
  
  // Registros temporales (caller-saved)
  /*  72 */ uint64 t0;
  /*  80 */ uint64 t1;
  /*  88 */ uint64 t2;
  
  // Registros guardados (callee-saved)
  /*  96 */ uint64 s0;             // También conocido como fp (frame pointer)
  /* 104 */ uint64 s1;
  
  // Registros de argumentos/retorno de funciones
  /* 112 */ uint64 a0;             // Primer argumento / valor de retorno
  /* 120 */ uint64 a1;             // Segundo argumento / segundo valor retorno
  /* 128 */ uint64 a2;             // Argumentos 3-8
  /* 136 */ uint64 a3;
  /* 144 */ uint64 a4;
  /* 152 */ uint64 a5;
  /* 160 */ uint64 a6;
  /* 168 */ uint64 a7;
  
  // Más registros guardados (callee-saved)
  /* 176 */ uint64 s2;
  /* 184 */ uint64 s3;
  /* 192 */ uint64 s4;
  /* 200 */ uint64 s5;
  /* 208 */ uint64 s6;
  /* 216 */ uint64 s7;
  /* 224 */ uint64 s8;
  /* 232 */ uint64 s9;
  /* 240 */ uint64 s10;
  /* 248 */ uint64 s11;
  
  // Más registros temporales (caller-saved)
  /* 256 */ uint64 t3;
  /* 264 */ uint64 t4;
  /* 272 */ uint64 t5;
  /* 280 */ uint64 t6;
};
// TAMAÑO TOTAL: 288 bytes (36 registros × 8 bytes)

// ============================================================================
// ESTADOS DE UN PROCESO
// ============================================================================

// Los procesos transicionan entre estos estados según el diagrama:
//
//   UNUSED → USED → RUNNABLE ⇄ RUNNING → ZOMBIE → UNUSED
//                        ↕
//                    SLEEPING
//
// UNUSED:   Slot libre en la tabla de procesos
// USED:     Proceso siendo creado (transitorio)
// RUNNABLE: Proceso listo para ejecutar (en cola del scheduler)
// RUNNING:  Proceso ejecutando actualmente en una CPU
// SLEEPING: Proceso bloqueado esperando un evento (I/O, lock, etc.)
// ZOMBIE:   Proceso terminado, esperando que el padre haga wait()

enum procstate { UNUSED, USED, SLEEPING, RUNNABLE, RUNNING, ZOMBIE };

// ============================================================================
// ESTRUCTURA DE UN PROCESO
// ============================================================================

// struct proc - Descriptor de proceso (PCB - Process Control Block)
//
// Cada proceso tiene una entrada en el arreglo global proc[NPROC].
// Esta estructura contiene TODA la información necesaria para gestionar
// el proceso: estado, memoria, archivos abiertos, contexto, etc.
struct proc {
  // ──────────────────────────────────────────────────────────────────
  // SINCRONIZACIÓN
  // ──────────────────────────────────────────────────────────────────
  struct spinlock lock;  // Lock para proteger campos de este proceso
                         // DEBE adquirirse antes de leer/modificar estado

  // ──────────────────────────────────────────────────────────────────
  // INFORMACIÓN BÁSICA (protegidos por p->lock)
  // ──────────────────────────────────────────────────────────────────
  enum procstate state;  // Estado actual del proceso (RUNNABLE, RUNNING, etc.)
  void *chan;            // Canal en el que duerme (si state == SLEEPING)
                         // Usado por sleep/wakeup para sincronización
  int killed;            // Flag: proceso marcado para terminar
  int xstate;            // Exit status (guardado cuando el proceso termina)
  int pid;               // Process ID único

  // ──────────────────────────────────────────────────────────────────
  // RELACIONES ENTRE PROCESOS (protegidos por wait_lock)
  // ──────────────────────────────────────────────────────────────────
  struct proc *parent;   // Puntero al proceso padre
                         // Necesario para wait() y manejo de huérfanos

  // ──────────────────────────────────────────────────────────────────
  // MEMORIA (privados del proceso, no requieren p->lock)
  // ──────────────────────────────────────────────────────────────────
  uint64 kstack;         // Dirección virtual del kernel stack
                         // Cada proceso tiene su propia pila del kernel (4KB)
  uint64 sz;             // Tamaño de la memoria del proceso (bytes)
  pagetable_t pagetable; // Tabla de páginas de usuario (MMU)
                         // Mapea direcciones virtuales → físicas
  struct trapframe *trapframe;  // Página que guarda registros de usuario
                                // Se usa al entrar/salir del kernel
                                // Página para trampoline.S

  // ──────────────────────────────────────────────────────────────────
  // CONTEXTO DE EJECUCIÓN (para context switching)
  // ──────────────────────────────────────────────────────────────────
  struct context context;  // Registros guardados del proceso
                           // swtch() guarda/restaura esto al cambiar procesos
                           // Contiene ra, sp, s0-s11

  // ──────────────────────────────────────────────────────────────────
  // ARCHIVOS Y FILESYSTEM
  // ──────────────────────────────────────────────────────────────────
  struct file *ofile[NOFILE];  // Archivos abiertos (file descriptors)
                               // ofile[0] = stdin, ofile[1] = stdout, etc.
  struct inode *cwd;           // Directorio de trabajo actual (current working directory)

  // ──────────────────────────────────────────────────────────────────
  // INFORMACIÓN DE DEBUGGING
  // ──────────────────────────────────────────────────────────────────
  char name[16];         // Nombre del proceso (para debugging)
};

extern struct proc proc[NPROC];    // Tabla de todos los procesos

// ============================================================================
// NOTAS SOBRE EL ALGORITMO DE PLANIFICACIÓN
// ============================================================================

/*
 * ALGORITMO: Round-Robin Simple
 * ═════════════════════════════════════════════════════════════════════
 * 
 * ESTRUCTURAS CLAVE:
 * 
 * 1. proc[NPROC] - Tabla global de procesos
 *    - Arreglo estático de 64 procesos máximo
 *    - El scheduler recorre este arreglo buscando RUNNABLE
 *    - NO hay cola separada de procesos ejecutables
 * 
 * 2. proc->state - Estado del proceso
 *    - UNUSED: slot libre
 *    - RUNNABLE: listo para ejecutar (elegible por scheduler)
 *    - RUNNING: ejecutando actualmente en una CPU
 *    - SLEEPING: bloqueado esperando evento
 *    - ZOMBIE: terminado pero no recogido por el padre
 * 
 * 3. proc->context - Contexto guardado
 *    - Registros ra, sp, s0-s11
 *    - Se guarda cuando el proceso cede la CPU (sched)
 *    - Se restaura cuando el scheduler lo vuelve a ejecutar
 * 
 * 4. proc->trapframe - Estado completo del usuario
 *    - TODOS los registros del procesador (32 registros)
 *    - Se guarda en CADA trap (syscall, interrupción, excepción)
 *    - Permite al kernel modificar estado del usuario
 * 
 * 5. cpu->context - Contexto del scheduler
 *    - Cada CPU tiene su propio scheduler context
 *    - Cuando scheduler ejecuta swtch(), guarda aquí su estado
 * 
 * 6. cpu->proc - Proceso actual de la CPU
 *    - NULL cuando la CPU ejecuta scheduler()
 *    - !NULL cuando ejecuta un proceso
 * 
 * FLUJO DE SCHEDULING:
 * ═════════════════════════════════════════════════════════════════════
 * 
 * 1. scheduler() busca proceso RUNNABLE
 *    - Recorre proc[] desde el inicio (O(n))
 *    - Encuentra p con p->state == RUNNABLE
 * 
 * 2. scheduler() selecciona el proceso
 *    - p->state = RUNNING
 *    - c->proc = p
 *    - swtch(&c->context, &p->context)
 * 
 * 3. Proceso ejecuta...
 *    - Timer interrupt después de ~10ms
 *    - usertrap() → yield() → sched()
 * 
 * 4. sched() devuelve control al scheduler
 *    - p->state = RUNNABLE
 *    - swtch(&p->context, &c->context)
 * 
 * 5. scheduler() retorna de swtch()
 *    - c->proc = 0
 *    - Continúa buscando siguiente proceso
 * 
 * DIFERENCIA: context vs trapframe
 * ═════════════════════════════════════════════════════════════════════
 * 
 * context (13 registros):
 *   - Se usa en context switch ENTRE PROCESOS
 *   - Solo callee-saved (ra, sp, s0-s11)
 *   - Guardado por swtch() en kernel space
 *   - Cambio: proceso → scheduler → proceso
 * 
 * trapframe (36 registros):
 *   - Se usa en transición USER ↔ KERNEL
 *   - TODOS los registros del procesador
 *   - Guardado por trampoline.S en cada trap
 *   - Cambio: user space → kernel space → user space
 * 
 * CAMPOS IMPORTANTES PARA EL SCHEDULER:
 * ═════════════════════════════════════════════════════════════════════
 * 
 * - proc->state: determina si es elegible
 * - proc->context: para guardar/restaurar estado
 * - proc->trapframe: para entrar/salir de kernel
 * - proc->lock: sincronización al cambiar estado
 * - cpu->proc: qué proceso ejecuta esta CPU
 * - cpu->context: estado del scheduler
 * 
 * 
 */