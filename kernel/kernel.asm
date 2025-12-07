
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	a1010113          	addi	sp,sp,-1520 # 80008a10 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	074000ef          	jal	8000008a <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 100000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	1761                	addi	a4,a4,-8 # 200bff8 <_entry-0x7dff4008>
    8000003a:	6318                	ld	a4,0(a4)
    8000003c:	6661                	lui	a2,0x18
    8000003e:	6a060613          	addi	a2,a2,1696 # 186a0 <_entry-0x7ffe7960>
    80000042:	9732                	add	a4,a4,a2
    80000044:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000046:	00259693          	slli	a3,a1,0x2
    8000004a:	96ae                	add	a3,a3,a1
    8000004c:	068e                	slli	a3,a3,0x3
    8000004e:	00009717          	auipc	a4,0x9
    80000052:	88270713          	addi	a4,a4,-1918 # 800088d0 <timer_scratch>
    80000056:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    80000058:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005a:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005c:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000060:	00006797          	auipc	a5,0x6
    80000064:	d2078793          	addi	a5,a5,-736 # 80005d80 <timervec>
    80000068:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006c:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000070:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000074:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000078:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007c:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000080:	30479073          	csrw	mie,a5
}
    80000084:	6422                	ld	s0,8(sp)
    80000086:	0141                	addi	sp,sp,16
    80000088:	8082                	ret

000000008000008a <start>:
{
    8000008a:	1141                	addi	sp,sp,-16
    8000008c:	e406                	sd	ra,8(sp)
    8000008e:	e022                	sd	s0,0(sp)
    80000090:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000092:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000096:	7779                	lui	a4,0xffffe
    80000098:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc8bf>
    8000009c:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009e:	6705                	lui	a4,0x1
    800000a0:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a4:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a6:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000aa:	00001797          	auipc	a5,0x1
    800000ae:	e2678793          	addi	a5,a5,-474 # 80000ed0 <main>
    800000b2:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b6:	4781                	li	a5,0
    800000b8:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000bc:	67c1                	lui	a5,0x10
    800000be:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c0:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c4:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000c8:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000cc:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d0:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d4:	57fd                	li	a5,-1
    800000d6:	83a9                	srli	a5,a5,0xa
    800000d8:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000dc:	47bd                	li	a5,15
    800000de:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e2:	00000097          	auipc	ra,0x0
    800000e6:	f3a080e7          	jalr	-198(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ea:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000ee:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f0:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f2:	30200073          	mret
}
    800000f6:	60a2                	ld	ra,8(sp)
    800000f8:	6402                	ld	s0,0(sp)
    800000fa:	0141                	addi	sp,sp,16
    800000fc:	8082                	ret

00000000800000fe <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000fe:	715d                	addi	sp,sp,-80
    80000100:	e486                	sd	ra,72(sp)
    80000102:	e0a2                	sd	s0,64(sp)
    80000104:	f84a                	sd	s2,48(sp)
    80000106:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000108:	04c05663          	blez	a2,80000154 <consolewrite+0x56>
    8000010c:	fc26                	sd	s1,56(sp)
    8000010e:	f44e                	sd	s3,40(sp)
    80000110:	f052                	sd	s4,32(sp)
    80000112:	ec56                	sd	s5,24(sp)
    80000114:	8a2a                	mv	s4,a0
    80000116:	84ae                	mv	s1,a1
    80000118:	89b2                	mv	s3,a2
    8000011a:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011c:	5afd                	li	s5,-1
    8000011e:	4685                	li	a3,1
    80000120:	8626                	mv	a2,s1
    80000122:	85d2                	mv	a1,s4
    80000124:	fbf40513          	addi	a0,s0,-65
    80000128:	00002097          	auipc	ra,0x2
    8000012c:	48e080e7          	jalr	1166(ra) # 800025b6 <either_copyin>
    80000130:	03550463          	beq	a0,s5,80000158 <consolewrite+0x5a>
      break;
    uartputc(c);
    80000134:	fbf44503          	lbu	a0,-65(s0)
    80000138:	00000097          	auipc	ra,0x0
    8000013c:	7e4080e7          	jalr	2020(ra) # 8000091c <uartputc>
  for(i = 0; i < n; i++){
    80000140:	2905                	addiw	s2,s2,1
    80000142:	0485                	addi	s1,s1,1
    80000144:	fd299de3          	bne	s3,s2,8000011e <consolewrite+0x20>
    80000148:	894e                	mv	s2,s3
    8000014a:	74e2                	ld	s1,56(sp)
    8000014c:	79a2                	ld	s3,40(sp)
    8000014e:	7a02                	ld	s4,32(sp)
    80000150:	6ae2                	ld	s5,24(sp)
    80000152:	a039                	j	80000160 <consolewrite+0x62>
    80000154:	4901                	li	s2,0
    80000156:	a029                	j	80000160 <consolewrite+0x62>
    80000158:	74e2                	ld	s1,56(sp)
    8000015a:	79a2                	ld	s3,40(sp)
    8000015c:	7a02                	ld	s4,32(sp)
    8000015e:	6ae2                	ld	s5,24(sp)
  }

  return i;
}
    80000160:	854a                	mv	a0,s2
    80000162:	60a6                	ld	ra,72(sp)
    80000164:	6406                	ld	s0,64(sp)
    80000166:	7942                	ld	s2,48(sp)
    80000168:	6161                	addi	sp,sp,80
    8000016a:	8082                	ret

000000008000016c <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000016c:	711d                	addi	sp,sp,-96
    8000016e:	ec86                	sd	ra,88(sp)
    80000170:	e8a2                	sd	s0,80(sp)
    80000172:	e4a6                	sd	s1,72(sp)
    80000174:	e0ca                	sd	s2,64(sp)
    80000176:	fc4e                	sd	s3,56(sp)
    80000178:	f852                	sd	s4,48(sp)
    8000017a:	f456                	sd	s5,40(sp)
    8000017c:	f05a                	sd	s6,32(sp)
    8000017e:	1080                	addi	s0,sp,96
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000186:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018a:	00011517          	auipc	a0,0x11
    8000018e:	88650513          	addi	a0,a0,-1914 # 80010a10 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	aa4080e7          	jalr	-1372(ra) # 80000c36 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	87648493          	addi	s1,s1,-1930 # 80010a10 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	90690913          	addi	s2,s2,-1786 # 80010aa8 <cons+0x98>
  while(n > 0){
    800001aa:	0d305763          	blez	s3,80000278 <consoleread+0x10c>
    while(cons.r == cons.w){
    800001ae:	0984a783          	lw	a5,152(s1)
    800001b2:	09c4a703          	lw	a4,156(s1)
    800001b6:	0af71c63          	bne	a4,a5,8000026e <consoleread+0x102>
      if(killed(myproc())){
    800001ba:	00002097          	auipc	ra,0x2
    800001be:	88e080e7          	jalr	-1906(ra) # 80001a48 <myproc>
    800001c2:	00002097          	auipc	ra,0x2
    800001c6:	23e080e7          	jalr	574(ra) # 80002400 <killed>
    800001ca:	e52d                	bnez	a0,80000234 <consoleread+0xc8>
      sleep(&cons.r, &cons.lock);
    800001cc:	85a6                	mv	a1,s1
    800001ce:	854a                	mv	a0,s2
    800001d0:	00002097          	auipc	ra,0x2
    800001d4:	f88080e7          	jalr	-120(ra) # 80002158 <sleep>
    while(cons.r == cons.w){
    800001d8:	0984a783          	lw	a5,152(s1)
    800001dc:	09c4a703          	lw	a4,156(s1)
    800001e0:	fcf70de3          	beq	a4,a5,800001ba <consoleread+0x4e>
    800001e4:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001e6:	00011717          	auipc	a4,0x11
    800001ea:	82a70713          	addi	a4,a4,-2006 # 80010a10 <cons>
    800001ee:	0017869b          	addiw	a3,a5,1
    800001f2:	08d72c23          	sw	a3,152(a4)
    800001f6:	07f7f693          	andi	a3,a5,127
    800001fa:	9736                	add	a4,a4,a3
    800001fc:	01874703          	lbu	a4,24(a4)
    80000200:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    80000204:	4691                	li	a3,4
    80000206:	04db8a63          	beq	s7,a3,8000025a <consoleread+0xee>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    8000020a:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000020e:	4685                	li	a3,1
    80000210:	faf40613          	addi	a2,s0,-81
    80000214:	85d2                	mv	a1,s4
    80000216:	8556                	mv	a0,s5
    80000218:	00002097          	auipc	ra,0x2
    8000021c:	348080e7          	jalr	840(ra) # 80002560 <either_copyout>
    80000220:	57fd                	li	a5,-1
    80000222:	04f50a63          	beq	a0,a5,80000276 <consoleread+0x10a>
      break;

    dst++;
    80000226:	0a05                	addi	s4,s4,1
    --n;
    80000228:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    8000022a:	47a9                	li	a5,10
    8000022c:	06fb8163          	beq	s7,a5,8000028e <consoleread+0x122>
    80000230:	6be2                	ld	s7,24(sp)
    80000232:	bfa5                	j	800001aa <consoleread+0x3e>
        release(&cons.lock);
    80000234:	00010517          	auipc	a0,0x10
    80000238:	7dc50513          	addi	a0,a0,2012 # 80010a10 <cons>
    8000023c:	00001097          	auipc	ra,0x1
    80000240:	aae080e7          	jalr	-1362(ra) # 80000cea <release>
        return -1;
    80000244:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000246:	60e6                	ld	ra,88(sp)
    80000248:	6446                	ld	s0,80(sp)
    8000024a:	64a6                	ld	s1,72(sp)
    8000024c:	6906                	ld	s2,64(sp)
    8000024e:	79e2                	ld	s3,56(sp)
    80000250:	7a42                	ld	s4,48(sp)
    80000252:	7aa2                	ld	s5,40(sp)
    80000254:	7b02                	ld	s6,32(sp)
    80000256:	6125                	addi	sp,sp,96
    80000258:	8082                	ret
      if(n < target){
    8000025a:	0009871b          	sext.w	a4,s3
    8000025e:	01677a63          	bgeu	a4,s6,80000272 <consoleread+0x106>
        cons.r--;
    80000262:	00011717          	auipc	a4,0x11
    80000266:	84f72323          	sw	a5,-1978(a4) # 80010aa8 <cons+0x98>
    8000026a:	6be2                	ld	s7,24(sp)
    8000026c:	a031                	j	80000278 <consoleread+0x10c>
    8000026e:	ec5e                	sd	s7,24(sp)
    80000270:	bf9d                	j	800001e6 <consoleread+0x7a>
    80000272:	6be2                	ld	s7,24(sp)
    80000274:	a011                	j	80000278 <consoleread+0x10c>
    80000276:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000278:	00010517          	auipc	a0,0x10
    8000027c:	79850513          	addi	a0,a0,1944 # 80010a10 <cons>
    80000280:	00001097          	auipc	ra,0x1
    80000284:	a6a080e7          	jalr	-1430(ra) # 80000cea <release>
  return target - n;
    80000288:	413b053b          	subw	a0,s6,s3
    8000028c:	bf6d                	j	80000246 <consoleread+0xda>
    8000028e:	6be2                	ld	s7,24(sp)
    80000290:	b7e5                	j	80000278 <consoleread+0x10c>

0000000080000292 <consputc>:
{
    80000292:	1141                	addi	sp,sp,-16
    80000294:	e406                	sd	ra,8(sp)
    80000296:	e022                	sd	s0,0(sp)
    80000298:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000029a:	10000793          	li	a5,256
    8000029e:	00f50a63          	beq	a0,a5,800002b2 <consputc+0x20>
    uartputc_sync(c);
    800002a2:	00000097          	auipc	ra,0x0
    800002a6:	59c080e7          	jalr	1436(ra) # 8000083e <uartputc_sync>
}
    800002aa:	60a2                	ld	ra,8(sp)
    800002ac:	6402                	ld	s0,0(sp)
    800002ae:	0141                	addi	sp,sp,16
    800002b0:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	58a080e7          	jalr	1418(ra) # 8000083e <uartputc_sync>
    800002bc:	02000513          	li	a0,32
    800002c0:	00000097          	auipc	ra,0x0
    800002c4:	57e080e7          	jalr	1406(ra) # 8000083e <uartputc_sync>
    800002c8:	4521                	li	a0,8
    800002ca:	00000097          	auipc	ra,0x0
    800002ce:	574080e7          	jalr	1396(ra) # 8000083e <uartputc_sync>
    800002d2:	bfe1                	j	800002aa <consputc+0x18>

00000000800002d4 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002d4:	1101                	addi	sp,sp,-32
    800002d6:	ec06                	sd	ra,24(sp)
    800002d8:	e822                	sd	s0,16(sp)
    800002da:	e426                	sd	s1,8(sp)
    800002dc:	1000                	addi	s0,sp,32
    800002de:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002e0:	00010517          	auipc	a0,0x10
    800002e4:	73050513          	addi	a0,a0,1840 # 80010a10 <cons>
    800002e8:	00001097          	auipc	ra,0x1
    800002ec:	94e080e7          	jalr	-1714(ra) # 80000c36 <acquire>

  switch(c){
    800002f0:	47d5                	li	a5,21
    800002f2:	0af48563          	beq	s1,a5,8000039c <consoleintr+0xc8>
    800002f6:	0297c963          	blt	a5,s1,80000328 <consoleintr+0x54>
    800002fa:	47a1                	li	a5,8
    800002fc:	0ef48c63          	beq	s1,a5,800003f4 <consoleintr+0x120>
    80000300:	47c1                	li	a5,16
    80000302:	10f49f63          	bne	s1,a5,80000420 <consoleintr+0x14c>
  case C('P'):  // Print process list.
    procdump();
    80000306:	00002097          	auipc	ra,0x2
    8000030a:	306080e7          	jalr	774(ra) # 8000260c <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    8000030e:	00010517          	auipc	a0,0x10
    80000312:	70250513          	addi	a0,a0,1794 # 80010a10 <cons>
    80000316:	00001097          	auipc	ra,0x1
    8000031a:	9d4080e7          	jalr	-1580(ra) # 80000cea <release>
}
    8000031e:	60e2                	ld	ra,24(sp)
    80000320:	6442                	ld	s0,16(sp)
    80000322:	64a2                	ld	s1,8(sp)
    80000324:	6105                	addi	sp,sp,32
    80000326:	8082                	ret
  switch(c){
    80000328:	07f00793          	li	a5,127
    8000032c:	0cf48463          	beq	s1,a5,800003f4 <consoleintr+0x120>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000330:	00010717          	auipc	a4,0x10
    80000334:	6e070713          	addi	a4,a4,1760 # 80010a10 <cons>
    80000338:	0a072783          	lw	a5,160(a4)
    8000033c:	09872703          	lw	a4,152(a4)
    80000340:	9f99                	subw	a5,a5,a4
    80000342:	07f00713          	li	a4,127
    80000346:	fcf764e3          	bltu	a4,a5,8000030e <consoleintr+0x3a>
      c = (c == '\r') ? '\n' : c;
    8000034a:	47b5                	li	a5,13
    8000034c:	0cf48d63          	beq	s1,a5,80000426 <consoleintr+0x152>
      consputc(c);
    80000350:	8526                	mv	a0,s1
    80000352:	00000097          	auipc	ra,0x0
    80000356:	f40080e7          	jalr	-192(ra) # 80000292 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000035a:	00010797          	auipc	a5,0x10
    8000035e:	6b678793          	addi	a5,a5,1718 # 80010a10 <cons>
    80000362:	0a07a683          	lw	a3,160(a5)
    80000366:	0016871b          	addiw	a4,a3,1
    8000036a:	0007061b          	sext.w	a2,a4
    8000036e:	0ae7a023          	sw	a4,160(a5)
    80000372:	07f6f693          	andi	a3,a3,127
    80000376:	97b6                	add	a5,a5,a3
    80000378:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000037c:	47a9                	li	a5,10
    8000037e:	0cf48b63          	beq	s1,a5,80000454 <consoleintr+0x180>
    80000382:	4791                	li	a5,4
    80000384:	0cf48863          	beq	s1,a5,80000454 <consoleintr+0x180>
    80000388:	00010797          	auipc	a5,0x10
    8000038c:	7207a783          	lw	a5,1824(a5) # 80010aa8 <cons+0x98>
    80000390:	9f1d                	subw	a4,a4,a5
    80000392:	08000793          	li	a5,128
    80000396:	f6f71ce3          	bne	a4,a5,8000030e <consoleintr+0x3a>
    8000039a:	a86d                	j	80000454 <consoleintr+0x180>
    8000039c:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    8000039e:	00010717          	auipc	a4,0x10
    800003a2:	67270713          	addi	a4,a4,1650 # 80010a10 <cons>
    800003a6:	0a072783          	lw	a5,160(a4)
    800003aa:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003ae:	00010497          	auipc	s1,0x10
    800003b2:	66248493          	addi	s1,s1,1634 # 80010a10 <cons>
    while(cons.e != cons.w &&
    800003b6:	4929                	li	s2,10
    800003b8:	02f70a63          	beq	a4,a5,800003ec <consoleintr+0x118>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003bc:	37fd                	addiw	a5,a5,-1
    800003be:	07f7f713          	andi	a4,a5,127
    800003c2:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003c4:	01874703          	lbu	a4,24(a4)
    800003c8:	03270463          	beq	a4,s2,800003f0 <consoleintr+0x11c>
      cons.e--;
    800003cc:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003d0:	10000513          	li	a0,256
    800003d4:	00000097          	auipc	ra,0x0
    800003d8:	ebe080e7          	jalr	-322(ra) # 80000292 <consputc>
    while(cons.e != cons.w &&
    800003dc:	0a04a783          	lw	a5,160(s1)
    800003e0:	09c4a703          	lw	a4,156(s1)
    800003e4:	fcf71ce3          	bne	a4,a5,800003bc <consoleintr+0xe8>
    800003e8:	6902                	ld	s2,0(sp)
    800003ea:	b715                	j	8000030e <consoleintr+0x3a>
    800003ec:	6902                	ld	s2,0(sp)
    800003ee:	b705                	j	8000030e <consoleintr+0x3a>
    800003f0:	6902                	ld	s2,0(sp)
    800003f2:	bf31                	j	8000030e <consoleintr+0x3a>
    if(cons.e != cons.w){
    800003f4:	00010717          	auipc	a4,0x10
    800003f8:	61c70713          	addi	a4,a4,1564 # 80010a10 <cons>
    800003fc:	0a072783          	lw	a5,160(a4)
    80000400:	09c72703          	lw	a4,156(a4)
    80000404:	f0f705e3          	beq	a4,a5,8000030e <consoleintr+0x3a>
      cons.e--;
    80000408:	37fd                	addiw	a5,a5,-1
    8000040a:	00010717          	auipc	a4,0x10
    8000040e:	6af72323          	sw	a5,1702(a4) # 80010ab0 <cons+0xa0>
      consputc(BACKSPACE);
    80000412:	10000513          	li	a0,256
    80000416:	00000097          	auipc	ra,0x0
    8000041a:	e7c080e7          	jalr	-388(ra) # 80000292 <consputc>
    8000041e:	bdc5                	j	8000030e <consoleintr+0x3a>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000420:	ee0487e3          	beqz	s1,8000030e <consoleintr+0x3a>
    80000424:	b731                	j	80000330 <consoleintr+0x5c>
      consputc(c);
    80000426:	4529                	li	a0,10
    80000428:	00000097          	auipc	ra,0x0
    8000042c:	e6a080e7          	jalr	-406(ra) # 80000292 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000430:	00010797          	auipc	a5,0x10
    80000434:	5e078793          	addi	a5,a5,1504 # 80010a10 <cons>
    80000438:	0a07a703          	lw	a4,160(a5)
    8000043c:	0017069b          	addiw	a3,a4,1
    80000440:	0006861b          	sext.w	a2,a3
    80000444:	0ad7a023          	sw	a3,160(a5)
    80000448:	07f77713          	andi	a4,a4,127
    8000044c:	97ba                	add	a5,a5,a4
    8000044e:	4729                	li	a4,10
    80000450:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000454:	00010797          	auipc	a5,0x10
    80000458:	64c7ac23          	sw	a2,1624(a5) # 80010aac <cons+0x9c>
        wakeup(&cons.r);
    8000045c:	00010517          	auipc	a0,0x10
    80000460:	64c50513          	addi	a0,a0,1612 # 80010aa8 <cons+0x98>
    80000464:	00002097          	auipc	ra,0x2
    80000468:	d58080e7          	jalr	-680(ra) # 800021bc <wakeup>
    8000046c:	b54d                	j	8000030e <consoleintr+0x3a>

000000008000046e <consoleinit>:

void
consoleinit(void)
{
    8000046e:	1141                	addi	sp,sp,-16
    80000470:	e406                	sd	ra,8(sp)
    80000472:	e022                	sd	s0,0(sp)
    80000474:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000476:	00008597          	auipc	a1,0x8
    8000047a:	b8a58593          	addi	a1,a1,-1142 # 80008000 <etext>
    8000047e:	00010517          	auipc	a0,0x10
    80000482:	59250513          	addi	a0,a0,1426 # 80010a10 <cons>
    80000486:	00000097          	auipc	ra,0x0
    8000048a:	720080e7          	jalr	1824(ra) # 80000ba6 <initlock>

  uartinit();
    8000048e:	00000097          	auipc	ra,0x0
    80000492:	354080e7          	jalr	852(ra) # 800007e2 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000496:	00021797          	auipc	a5,0x21
    8000049a:	91278793          	addi	a5,a5,-1774 # 80020da8 <devsw>
    8000049e:	00000717          	auipc	a4,0x0
    800004a2:	cce70713          	addi	a4,a4,-818 # 8000016c <consoleread>
    800004a6:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    800004a8:	00000717          	auipc	a4,0x0
    800004ac:	c5670713          	addi	a4,a4,-938 # 800000fe <consolewrite>
    800004b0:	ef98                	sd	a4,24(a5)
}
    800004b2:	60a2                	ld	ra,8(sp)
    800004b4:	6402                	ld	s0,0(sp)
    800004b6:	0141                	addi	sp,sp,16
    800004b8:	8082                	ret

00000000800004ba <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004ba:	7179                	addi	sp,sp,-48
    800004bc:	f406                	sd	ra,40(sp)
    800004be:	f022                	sd	s0,32(sp)
    800004c0:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004c2:	c219                	beqz	a2,800004c8 <printint+0xe>
    800004c4:	08054963          	bltz	a0,80000556 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004c8:	2501                	sext.w	a0,a0
    800004ca:	4881                	li	a7,0
    800004cc:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004d0:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004d2:	2581                	sext.w	a1,a1
    800004d4:	00008617          	auipc	a2,0x8
    800004d8:	25460613          	addi	a2,a2,596 # 80008728 <digits>
    800004dc:	883a                	mv	a6,a4
    800004de:	2705                	addiw	a4,a4,1
    800004e0:	02b577bb          	remuw	a5,a0,a1
    800004e4:	1782                	slli	a5,a5,0x20
    800004e6:	9381                	srli	a5,a5,0x20
    800004e8:	97b2                	add	a5,a5,a2
    800004ea:	0007c783          	lbu	a5,0(a5)
    800004ee:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004f2:	0005079b          	sext.w	a5,a0
    800004f6:	02b5553b          	divuw	a0,a0,a1
    800004fa:	0685                	addi	a3,a3,1
    800004fc:	feb7f0e3          	bgeu	a5,a1,800004dc <printint+0x22>

  if(sign)
    80000500:	00088c63          	beqz	a7,80000518 <printint+0x5e>
    buf[i++] = '-';
    80000504:	fe070793          	addi	a5,a4,-32
    80000508:	00878733          	add	a4,a5,s0
    8000050c:	02d00793          	li	a5,45
    80000510:	fef70823          	sb	a5,-16(a4)
    80000514:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80000518:	02e05b63          	blez	a4,8000054e <printint+0x94>
    8000051c:	ec26                	sd	s1,24(sp)
    8000051e:	e84a                	sd	s2,16(sp)
    80000520:	fd040793          	addi	a5,s0,-48
    80000524:	00e784b3          	add	s1,a5,a4
    80000528:	fff78913          	addi	s2,a5,-1
    8000052c:	993a                	add	s2,s2,a4
    8000052e:	377d                	addiw	a4,a4,-1
    80000530:	1702                	slli	a4,a4,0x20
    80000532:	9301                	srli	a4,a4,0x20
    80000534:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000538:	fff4c503          	lbu	a0,-1(s1)
    8000053c:	00000097          	auipc	ra,0x0
    80000540:	d56080e7          	jalr	-682(ra) # 80000292 <consputc>
  while(--i >= 0)
    80000544:	14fd                	addi	s1,s1,-1
    80000546:	ff2499e3          	bne	s1,s2,80000538 <printint+0x7e>
    8000054a:	64e2                	ld	s1,24(sp)
    8000054c:	6942                	ld	s2,16(sp)
}
    8000054e:	70a2                	ld	ra,40(sp)
    80000550:	7402                	ld	s0,32(sp)
    80000552:	6145                	addi	sp,sp,48
    80000554:	8082                	ret
    x = -xx;
    80000556:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000055a:	4885                	li	a7,1
    x = -xx;
    8000055c:	bf85                	j	800004cc <printint+0x12>

000000008000055e <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000055e:	1101                	addi	sp,sp,-32
    80000560:	ec06                	sd	ra,24(sp)
    80000562:	e822                	sd	s0,16(sp)
    80000564:	e426                	sd	s1,8(sp)
    80000566:	1000                	addi	s0,sp,32
    80000568:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000056a:	00010797          	auipc	a5,0x10
    8000056e:	5607a323          	sw	zero,1382(a5) # 80010ad0 <pr+0x18>
  printf("panic: ");
    80000572:	00008517          	auipc	a0,0x8
    80000576:	a9650513          	addi	a0,a0,-1386 # 80008008 <etext+0x8>
    8000057a:	00000097          	auipc	ra,0x0
    8000057e:	02e080e7          	jalr	46(ra) # 800005a8 <printf>
  printf(s);
    80000582:	8526                	mv	a0,s1
    80000584:	00000097          	auipc	ra,0x0
    80000588:	024080e7          	jalr	36(ra) # 800005a8 <printf>
  printf("\n");
    8000058c:	00008517          	auipc	a0,0x8
    80000590:	a8450513          	addi	a0,a0,-1404 # 80008010 <etext+0x10>
    80000594:	00000097          	auipc	ra,0x0
    80000598:	014080e7          	jalr	20(ra) # 800005a8 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000059c:	4785                	li	a5,1
    8000059e:	00008717          	auipc	a4,0x8
    800005a2:	2ef72923          	sw	a5,754(a4) # 80008890 <panicked>
  for(;;)
    800005a6:	a001                	j	800005a6 <panic+0x48>

00000000800005a8 <printf>:
{
    800005a8:	7131                	addi	sp,sp,-192
    800005aa:	fc86                	sd	ra,120(sp)
    800005ac:	f8a2                	sd	s0,112(sp)
    800005ae:	e8d2                	sd	s4,80(sp)
    800005b0:	f06a                	sd	s10,32(sp)
    800005b2:	0100                	addi	s0,sp,128
    800005b4:	8a2a                	mv	s4,a0
    800005b6:	e40c                	sd	a1,8(s0)
    800005b8:	e810                	sd	a2,16(s0)
    800005ba:	ec14                	sd	a3,24(s0)
    800005bc:	f018                	sd	a4,32(s0)
    800005be:	f41c                	sd	a5,40(s0)
    800005c0:	03043823          	sd	a6,48(s0)
    800005c4:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005c8:	00010d17          	auipc	s10,0x10
    800005cc:	508d2d03          	lw	s10,1288(s10) # 80010ad0 <pr+0x18>
  if(locking)
    800005d0:	040d1463          	bnez	s10,80000618 <printf+0x70>
  if (fmt == 0)
    800005d4:	040a0b63          	beqz	s4,8000062a <printf+0x82>
  va_start(ap, fmt);
    800005d8:	00840793          	addi	a5,s0,8
    800005dc:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005e0:	000a4503          	lbu	a0,0(s4)
    800005e4:	18050b63          	beqz	a0,8000077a <printf+0x1d2>
    800005e8:	f4a6                	sd	s1,104(sp)
    800005ea:	f0ca                	sd	s2,96(sp)
    800005ec:	ecce                	sd	s3,88(sp)
    800005ee:	e4d6                	sd	s5,72(sp)
    800005f0:	e0da                	sd	s6,64(sp)
    800005f2:	fc5e                	sd	s7,56(sp)
    800005f4:	f862                	sd	s8,48(sp)
    800005f6:	f466                	sd	s9,40(sp)
    800005f8:	ec6e                	sd	s11,24(sp)
    800005fa:	4981                	li	s3,0
    if(c != '%'){
    800005fc:	02500b13          	li	s6,37
    switch(c){
    80000600:	07000b93          	li	s7,112
  consputc('x');
    80000604:	4cc1                	li	s9,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000606:	00008a97          	auipc	s5,0x8
    8000060a:	122a8a93          	addi	s5,s5,290 # 80008728 <digits>
    switch(c){
    8000060e:	07300c13          	li	s8,115
    80000612:	06400d93          	li	s11,100
    80000616:	a0b1                	j	80000662 <printf+0xba>
    acquire(&pr.lock);
    80000618:	00010517          	auipc	a0,0x10
    8000061c:	4a050513          	addi	a0,a0,1184 # 80010ab8 <pr>
    80000620:	00000097          	auipc	ra,0x0
    80000624:	616080e7          	jalr	1558(ra) # 80000c36 <acquire>
    80000628:	b775                	j	800005d4 <printf+0x2c>
    8000062a:	f4a6                	sd	s1,104(sp)
    8000062c:	f0ca                	sd	s2,96(sp)
    8000062e:	ecce                	sd	s3,88(sp)
    80000630:	e4d6                	sd	s5,72(sp)
    80000632:	e0da                	sd	s6,64(sp)
    80000634:	fc5e                	sd	s7,56(sp)
    80000636:	f862                	sd	s8,48(sp)
    80000638:	f466                	sd	s9,40(sp)
    8000063a:	ec6e                	sd	s11,24(sp)
    panic("null fmt");
    8000063c:	00008517          	auipc	a0,0x8
    80000640:	9e450513          	addi	a0,a0,-1564 # 80008020 <etext+0x20>
    80000644:	00000097          	auipc	ra,0x0
    80000648:	f1a080e7          	jalr	-230(ra) # 8000055e <panic>
      consputc(c);
    8000064c:	00000097          	auipc	ra,0x0
    80000650:	c46080e7          	jalr	-954(ra) # 80000292 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000654:	2985                	addiw	s3,s3,1
    80000656:	013a07b3          	add	a5,s4,s3
    8000065a:	0007c503          	lbu	a0,0(a5)
    8000065e:	10050563          	beqz	a0,80000768 <printf+0x1c0>
    if(c != '%'){
    80000662:	ff6515e3          	bne	a0,s6,8000064c <printf+0xa4>
    c = fmt[++i] & 0xff;
    80000666:	2985                	addiw	s3,s3,1
    80000668:	013a07b3          	add	a5,s4,s3
    8000066c:	0007c783          	lbu	a5,0(a5)
    80000670:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000674:	10078b63          	beqz	a5,8000078a <printf+0x1e2>
    switch(c){
    80000678:	05778a63          	beq	a5,s7,800006cc <printf+0x124>
    8000067c:	02fbf663          	bgeu	s7,a5,800006a8 <printf+0x100>
    80000680:	09878863          	beq	a5,s8,80000710 <printf+0x168>
    80000684:	07800713          	li	a4,120
    80000688:	0ce79563          	bne	a5,a4,80000752 <printf+0x1aa>
      printint(va_arg(ap, int), 16, 1);
    8000068c:	f8843783          	ld	a5,-120(s0)
    80000690:	00878713          	addi	a4,a5,8
    80000694:	f8e43423          	sd	a4,-120(s0)
    80000698:	4605                	li	a2,1
    8000069a:	85e6                	mv	a1,s9
    8000069c:	4388                	lw	a0,0(a5)
    8000069e:	00000097          	auipc	ra,0x0
    800006a2:	e1c080e7          	jalr	-484(ra) # 800004ba <printint>
      break;
    800006a6:	b77d                	j	80000654 <printf+0xac>
    switch(c){
    800006a8:	09678f63          	beq	a5,s6,80000746 <printf+0x19e>
    800006ac:	0bb79363          	bne	a5,s11,80000752 <printf+0x1aa>
      printint(va_arg(ap, int), 10, 1);
    800006b0:	f8843783          	ld	a5,-120(s0)
    800006b4:	00878713          	addi	a4,a5,8
    800006b8:	f8e43423          	sd	a4,-120(s0)
    800006bc:	4605                	li	a2,1
    800006be:	45a9                	li	a1,10
    800006c0:	4388                	lw	a0,0(a5)
    800006c2:	00000097          	auipc	ra,0x0
    800006c6:	df8080e7          	jalr	-520(ra) # 800004ba <printint>
      break;
    800006ca:	b769                	j	80000654 <printf+0xac>
      printptr(va_arg(ap, uint64));
    800006cc:	f8843783          	ld	a5,-120(s0)
    800006d0:	00878713          	addi	a4,a5,8
    800006d4:	f8e43423          	sd	a4,-120(s0)
    800006d8:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006dc:	03000513          	li	a0,48
    800006e0:	00000097          	auipc	ra,0x0
    800006e4:	bb2080e7          	jalr	-1102(ra) # 80000292 <consputc>
  consputc('x');
    800006e8:	07800513          	li	a0,120
    800006ec:	00000097          	auipc	ra,0x0
    800006f0:	ba6080e7          	jalr	-1114(ra) # 80000292 <consputc>
    800006f4:	84e6                	mv	s1,s9
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006f6:	03c95793          	srli	a5,s2,0x3c
    800006fa:	97d6                	add	a5,a5,s5
    800006fc:	0007c503          	lbu	a0,0(a5)
    80000700:	00000097          	auipc	ra,0x0
    80000704:	b92080e7          	jalr	-1134(ra) # 80000292 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80000708:	0912                	slli	s2,s2,0x4
    8000070a:	34fd                	addiw	s1,s1,-1
    8000070c:	f4ed                	bnez	s1,800006f6 <printf+0x14e>
    8000070e:	b799                	j	80000654 <printf+0xac>
      if((s = va_arg(ap, char*)) == 0)
    80000710:	f8843783          	ld	a5,-120(s0)
    80000714:	00878713          	addi	a4,a5,8
    80000718:	f8e43423          	sd	a4,-120(s0)
    8000071c:	6384                	ld	s1,0(a5)
    8000071e:	cc89                	beqz	s1,80000738 <printf+0x190>
      for(; *s; s++)
    80000720:	0004c503          	lbu	a0,0(s1)
    80000724:	d905                	beqz	a0,80000654 <printf+0xac>
        consputc(*s);
    80000726:	00000097          	auipc	ra,0x0
    8000072a:	b6c080e7          	jalr	-1172(ra) # 80000292 <consputc>
      for(; *s; s++)
    8000072e:	0485                	addi	s1,s1,1
    80000730:	0004c503          	lbu	a0,0(s1)
    80000734:	f96d                	bnez	a0,80000726 <printf+0x17e>
    80000736:	bf39                	j	80000654 <printf+0xac>
        s = "(null)";
    80000738:	00008497          	auipc	s1,0x8
    8000073c:	8e048493          	addi	s1,s1,-1824 # 80008018 <etext+0x18>
      for(; *s; s++)
    80000740:	02800513          	li	a0,40
    80000744:	b7cd                	j	80000726 <printf+0x17e>
      consputc('%');
    80000746:	855a                	mv	a0,s6
    80000748:	00000097          	auipc	ra,0x0
    8000074c:	b4a080e7          	jalr	-1206(ra) # 80000292 <consputc>
      break;
    80000750:	b711                	j	80000654 <printf+0xac>
      consputc('%');
    80000752:	855a                	mv	a0,s6
    80000754:	00000097          	auipc	ra,0x0
    80000758:	b3e080e7          	jalr	-1218(ra) # 80000292 <consputc>
      consputc(c);
    8000075c:	8526                	mv	a0,s1
    8000075e:	00000097          	auipc	ra,0x0
    80000762:	b34080e7          	jalr	-1228(ra) # 80000292 <consputc>
      break;
    80000766:	b5fd                	j	80000654 <printf+0xac>
    80000768:	74a6                	ld	s1,104(sp)
    8000076a:	7906                	ld	s2,96(sp)
    8000076c:	69e6                	ld	s3,88(sp)
    8000076e:	6aa6                	ld	s5,72(sp)
    80000770:	6b06                	ld	s6,64(sp)
    80000772:	7be2                	ld	s7,56(sp)
    80000774:	7c42                	ld	s8,48(sp)
    80000776:	7ca2                	ld	s9,40(sp)
    80000778:	6de2                	ld	s11,24(sp)
  if(locking)
    8000077a:	020d1263          	bnez	s10,8000079e <printf+0x1f6>
}
    8000077e:	70e6                	ld	ra,120(sp)
    80000780:	7446                	ld	s0,112(sp)
    80000782:	6a46                	ld	s4,80(sp)
    80000784:	7d02                	ld	s10,32(sp)
    80000786:	6129                	addi	sp,sp,192
    80000788:	8082                	ret
    8000078a:	74a6                	ld	s1,104(sp)
    8000078c:	7906                	ld	s2,96(sp)
    8000078e:	69e6                	ld	s3,88(sp)
    80000790:	6aa6                	ld	s5,72(sp)
    80000792:	6b06                	ld	s6,64(sp)
    80000794:	7be2                	ld	s7,56(sp)
    80000796:	7c42                	ld	s8,48(sp)
    80000798:	7ca2                	ld	s9,40(sp)
    8000079a:	6de2                	ld	s11,24(sp)
    8000079c:	bff9                	j	8000077a <printf+0x1d2>
    release(&pr.lock);
    8000079e:	00010517          	auipc	a0,0x10
    800007a2:	31a50513          	addi	a0,a0,794 # 80010ab8 <pr>
    800007a6:	00000097          	auipc	ra,0x0
    800007aa:	544080e7          	jalr	1348(ra) # 80000cea <release>
}
    800007ae:	bfc1                	j	8000077e <printf+0x1d6>

00000000800007b0 <printfinit>:
    ;
}

void
printfinit(void)
{
    800007b0:	1101                	addi	sp,sp,-32
    800007b2:	ec06                	sd	ra,24(sp)
    800007b4:	e822                	sd	s0,16(sp)
    800007b6:	e426                	sd	s1,8(sp)
    800007b8:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800007ba:	00010497          	auipc	s1,0x10
    800007be:	2fe48493          	addi	s1,s1,766 # 80010ab8 <pr>
    800007c2:	00008597          	auipc	a1,0x8
    800007c6:	86e58593          	addi	a1,a1,-1938 # 80008030 <etext+0x30>
    800007ca:	8526                	mv	a0,s1
    800007cc:	00000097          	auipc	ra,0x0
    800007d0:	3da080e7          	jalr	986(ra) # 80000ba6 <initlock>
  pr.locking = 1;
    800007d4:	4785                	li	a5,1
    800007d6:	cc9c                	sw	a5,24(s1)
}
    800007d8:	60e2                	ld	ra,24(sp)
    800007da:	6442                	ld	s0,16(sp)
    800007dc:	64a2                	ld	s1,8(sp)
    800007de:	6105                	addi	sp,sp,32
    800007e0:	8082                	ret

00000000800007e2 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007e2:	1141                	addi	sp,sp,-16
    800007e4:	e406                	sd	ra,8(sp)
    800007e6:	e022                	sd	s0,0(sp)
    800007e8:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007ea:	100007b7          	lui	a5,0x10000
    800007ee:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007f2:	10000737          	lui	a4,0x10000
    800007f6:	f8000693          	li	a3,-128
    800007fa:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007fe:	468d                	li	a3,3
    80000800:	10000637          	lui	a2,0x10000
    80000804:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000808:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000080c:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80000810:	10000737          	lui	a4,0x10000
    80000814:	461d                	li	a2,7
    80000816:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    8000081a:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    8000081e:	00008597          	auipc	a1,0x8
    80000822:	81a58593          	addi	a1,a1,-2022 # 80008038 <etext+0x38>
    80000826:	00010517          	auipc	a0,0x10
    8000082a:	2b250513          	addi	a0,a0,690 # 80010ad8 <uart_tx_lock>
    8000082e:	00000097          	auipc	ra,0x0
    80000832:	378080e7          	jalr	888(ra) # 80000ba6 <initlock>
}
    80000836:	60a2                	ld	ra,8(sp)
    80000838:	6402                	ld	s0,0(sp)
    8000083a:	0141                	addi	sp,sp,16
    8000083c:	8082                	ret

000000008000083e <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000083e:	1101                	addi	sp,sp,-32
    80000840:	ec06                	sd	ra,24(sp)
    80000842:	e822                	sd	s0,16(sp)
    80000844:	e426                	sd	s1,8(sp)
    80000846:	1000                	addi	s0,sp,32
    80000848:	84aa                	mv	s1,a0
  push_off();
    8000084a:	00000097          	auipc	ra,0x0
    8000084e:	3a0080e7          	jalr	928(ra) # 80000bea <push_off>

  if(panicked){
    80000852:	00008797          	auipc	a5,0x8
    80000856:	03e7a783          	lw	a5,62(a5) # 80008890 <panicked>
    8000085a:	eb85                	bnez	a5,8000088a <uartputc_sync+0x4c>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000085c:	10000737          	lui	a4,0x10000
    80000860:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000862:	00074783          	lbu	a5,0(a4)
    80000866:	0207f793          	andi	a5,a5,32
    8000086a:	dfe5                	beqz	a5,80000862 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000086c:	0ff4f513          	zext.b	a0,s1
    80000870:	100007b7          	lui	a5,0x10000
    80000874:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000878:	00000097          	auipc	ra,0x0
    8000087c:	412080e7          	jalr	1042(ra) # 80000c8a <pop_off>
}
    80000880:	60e2                	ld	ra,24(sp)
    80000882:	6442                	ld	s0,16(sp)
    80000884:	64a2                	ld	s1,8(sp)
    80000886:	6105                	addi	sp,sp,32
    80000888:	8082                	ret
    for(;;)
    8000088a:	a001                	j	8000088a <uartputc_sync+0x4c>

000000008000088c <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000088c:	00008797          	auipc	a5,0x8
    80000890:	00c7b783          	ld	a5,12(a5) # 80008898 <uart_tx_r>
    80000894:	00008717          	auipc	a4,0x8
    80000898:	00c73703          	ld	a4,12(a4) # 800088a0 <uart_tx_w>
    8000089c:	06f70f63          	beq	a4,a5,8000091a <uartstart+0x8e>
{
    800008a0:	7139                	addi	sp,sp,-64
    800008a2:	fc06                	sd	ra,56(sp)
    800008a4:	f822                	sd	s0,48(sp)
    800008a6:	f426                	sd	s1,40(sp)
    800008a8:	f04a                	sd	s2,32(sp)
    800008aa:	ec4e                	sd	s3,24(sp)
    800008ac:	e852                	sd	s4,16(sp)
    800008ae:	e456                	sd	s5,8(sp)
    800008b0:	e05a                	sd	s6,0(sp)
    800008b2:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008b4:	10000937          	lui	s2,0x10000
    800008b8:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008ba:	00010a97          	auipc	s5,0x10
    800008be:	21ea8a93          	addi	s5,s5,542 # 80010ad8 <uart_tx_lock>
    uart_tx_r += 1;
    800008c2:	00008497          	auipc	s1,0x8
    800008c6:	fd648493          	addi	s1,s1,-42 # 80008898 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008ca:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008ce:	00008997          	auipc	s3,0x8
    800008d2:	fd298993          	addi	s3,s3,-46 # 800088a0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008d6:	00094703          	lbu	a4,0(s2)
    800008da:	02077713          	andi	a4,a4,32
    800008de:	c705                	beqz	a4,80000906 <uartstart+0x7a>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008e0:	01f7f713          	andi	a4,a5,31
    800008e4:	9756                	add	a4,a4,s5
    800008e6:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    800008ea:	0785                	addi	a5,a5,1
    800008ec:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    800008ee:	8526                	mv	a0,s1
    800008f0:	00002097          	auipc	ra,0x2
    800008f4:	8cc080e7          	jalr	-1844(ra) # 800021bc <wakeup>
    WriteReg(THR, c);
    800008f8:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    800008fc:	609c                	ld	a5,0(s1)
    800008fe:	0009b703          	ld	a4,0(s3)
    80000902:	fcf71ae3          	bne	a4,a5,800008d6 <uartstart+0x4a>
  }
}
    80000906:	70e2                	ld	ra,56(sp)
    80000908:	7442                	ld	s0,48(sp)
    8000090a:	74a2                	ld	s1,40(sp)
    8000090c:	7902                	ld	s2,32(sp)
    8000090e:	69e2                	ld	s3,24(sp)
    80000910:	6a42                	ld	s4,16(sp)
    80000912:	6aa2                	ld	s5,8(sp)
    80000914:	6b02                	ld	s6,0(sp)
    80000916:	6121                	addi	sp,sp,64
    80000918:	8082                	ret
    8000091a:	8082                	ret

000000008000091c <uartputc>:
{
    8000091c:	7179                	addi	sp,sp,-48
    8000091e:	f406                	sd	ra,40(sp)
    80000920:	f022                	sd	s0,32(sp)
    80000922:	ec26                	sd	s1,24(sp)
    80000924:	e84a                	sd	s2,16(sp)
    80000926:	e44e                	sd	s3,8(sp)
    80000928:	e052                	sd	s4,0(sp)
    8000092a:	1800                	addi	s0,sp,48
    8000092c:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    8000092e:	00010517          	auipc	a0,0x10
    80000932:	1aa50513          	addi	a0,a0,426 # 80010ad8 <uart_tx_lock>
    80000936:	00000097          	auipc	ra,0x0
    8000093a:	300080e7          	jalr	768(ra) # 80000c36 <acquire>
  if(panicked){
    8000093e:	00008797          	auipc	a5,0x8
    80000942:	f527a783          	lw	a5,-174(a5) # 80008890 <panicked>
    80000946:	e7c9                	bnez	a5,800009d0 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000948:	00008717          	auipc	a4,0x8
    8000094c:	f5873703          	ld	a4,-168(a4) # 800088a0 <uart_tx_w>
    80000950:	00008797          	auipc	a5,0x8
    80000954:	f487b783          	ld	a5,-184(a5) # 80008898 <uart_tx_r>
    80000958:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    8000095c:	00010997          	auipc	s3,0x10
    80000960:	17c98993          	addi	s3,s3,380 # 80010ad8 <uart_tx_lock>
    80000964:	00008497          	auipc	s1,0x8
    80000968:	f3448493          	addi	s1,s1,-204 # 80008898 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000096c:	00008917          	auipc	s2,0x8
    80000970:	f3490913          	addi	s2,s2,-204 # 800088a0 <uart_tx_w>
    80000974:	00e79f63          	bne	a5,a4,80000992 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000978:	85ce                	mv	a1,s3
    8000097a:	8526                	mv	a0,s1
    8000097c:	00001097          	auipc	ra,0x1
    80000980:	7dc080e7          	jalr	2012(ra) # 80002158 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000984:	00093703          	ld	a4,0(s2)
    80000988:	609c                	ld	a5,0(s1)
    8000098a:	02078793          	addi	a5,a5,32
    8000098e:	fee785e3          	beq	a5,a4,80000978 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000992:	00010497          	auipc	s1,0x10
    80000996:	14648493          	addi	s1,s1,326 # 80010ad8 <uart_tx_lock>
    8000099a:	01f77793          	andi	a5,a4,31
    8000099e:	97a6                	add	a5,a5,s1
    800009a0:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009a4:	0705                	addi	a4,a4,1
    800009a6:	00008797          	auipc	a5,0x8
    800009aa:	eee7bd23          	sd	a4,-262(a5) # 800088a0 <uart_tx_w>
  uartstart();
    800009ae:	00000097          	auipc	ra,0x0
    800009b2:	ede080e7          	jalr	-290(ra) # 8000088c <uartstart>
  release(&uart_tx_lock);
    800009b6:	8526                	mv	a0,s1
    800009b8:	00000097          	auipc	ra,0x0
    800009bc:	332080e7          	jalr	818(ra) # 80000cea <release>
}
    800009c0:	70a2                	ld	ra,40(sp)
    800009c2:	7402                	ld	s0,32(sp)
    800009c4:	64e2                	ld	s1,24(sp)
    800009c6:	6942                	ld	s2,16(sp)
    800009c8:	69a2                	ld	s3,8(sp)
    800009ca:	6a02                	ld	s4,0(sp)
    800009cc:	6145                	addi	sp,sp,48
    800009ce:	8082                	ret
    for(;;)
    800009d0:	a001                	j	800009d0 <uartputc+0xb4>

00000000800009d2 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009d2:	1141                	addi	sp,sp,-16
    800009d4:	e422                	sd	s0,8(sp)
    800009d6:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009d8:	100007b7          	lui	a5,0x10000
    800009dc:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009de:	0007c783          	lbu	a5,0(a5)
    800009e2:	8b85                	andi	a5,a5,1
    800009e4:	cb81                	beqz	a5,800009f4 <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    800009e6:	100007b7          	lui	a5,0x10000
    800009ea:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009ee:	6422                	ld	s0,8(sp)
    800009f0:	0141                	addi	sp,sp,16
    800009f2:	8082                	ret
    return -1;
    800009f4:	557d                	li	a0,-1
    800009f6:	bfe5                	j	800009ee <uartgetc+0x1c>

00000000800009f8 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009f8:	1101                	addi	sp,sp,-32
    800009fa:	ec06                	sd	ra,24(sp)
    800009fc:	e822                	sd	s0,16(sp)
    800009fe:	e426                	sd	s1,8(sp)
    80000a00:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a02:	54fd                	li	s1,-1
    80000a04:	a029                	j	80000a0e <uartintr+0x16>
      break;
    consoleintr(c);
    80000a06:	00000097          	auipc	ra,0x0
    80000a0a:	8ce080e7          	jalr	-1842(ra) # 800002d4 <consoleintr>
    int c = uartgetc();
    80000a0e:	00000097          	auipc	ra,0x0
    80000a12:	fc4080e7          	jalr	-60(ra) # 800009d2 <uartgetc>
    if(c == -1)
    80000a16:	fe9518e3          	bne	a0,s1,80000a06 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a1a:	00010497          	auipc	s1,0x10
    80000a1e:	0be48493          	addi	s1,s1,190 # 80010ad8 <uart_tx_lock>
    80000a22:	8526                	mv	a0,s1
    80000a24:	00000097          	auipc	ra,0x0
    80000a28:	212080e7          	jalr	530(ra) # 80000c36 <acquire>
  uartstart();
    80000a2c:	00000097          	auipc	ra,0x0
    80000a30:	e60080e7          	jalr	-416(ra) # 8000088c <uartstart>
  release(&uart_tx_lock);
    80000a34:	8526                	mv	a0,s1
    80000a36:	00000097          	auipc	ra,0x0
    80000a3a:	2b4080e7          	jalr	692(ra) # 80000cea <release>
}
    80000a3e:	60e2                	ld	ra,24(sp)
    80000a40:	6442                	ld	s0,16(sp)
    80000a42:	64a2                	ld	s1,8(sp)
    80000a44:	6105                	addi	sp,sp,32
    80000a46:	8082                	ret

0000000080000a48 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a48:	1101                	addi	sp,sp,-32
    80000a4a:	ec06                	sd	ra,24(sp)
    80000a4c:	e822                	sd	s0,16(sp)
    80000a4e:	e426                	sd	s1,8(sp)
    80000a50:	e04a                	sd	s2,0(sp)
    80000a52:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a54:	03451793          	slli	a5,a0,0x34
    80000a58:	ebb9                	bnez	a5,80000aae <kfree+0x66>
    80000a5a:	84aa                	mv	s1,a0
    80000a5c:	00021797          	auipc	a5,0x21
    80000a60:	4e478793          	addi	a5,a5,1252 # 80021f40 <end>
    80000a64:	04f56563          	bltu	a0,a5,80000aae <kfree+0x66>
    80000a68:	47c5                	li	a5,17
    80000a6a:	07ee                	slli	a5,a5,0x1b
    80000a6c:	04f57163          	bgeu	a0,a5,80000aae <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a70:	6605                	lui	a2,0x1
    80000a72:	4585                	li	a1,1
    80000a74:	00000097          	auipc	ra,0x0
    80000a78:	2be080e7          	jalr	702(ra) # 80000d32 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a7c:	00010917          	auipc	s2,0x10
    80000a80:	09490913          	addi	s2,s2,148 # 80010b10 <kmem>
    80000a84:	854a                	mv	a0,s2
    80000a86:	00000097          	auipc	ra,0x0
    80000a8a:	1b0080e7          	jalr	432(ra) # 80000c36 <acquire>
  r->next = kmem.freelist;
    80000a8e:	01893783          	ld	a5,24(s2)
    80000a92:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a94:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a98:	854a                	mv	a0,s2
    80000a9a:	00000097          	auipc	ra,0x0
    80000a9e:	250080e7          	jalr	592(ra) # 80000cea <release>
}
    80000aa2:	60e2                	ld	ra,24(sp)
    80000aa4:	6442                	ld	s0,16(sp)
    80000aa6:	64a2                	ld	s1,8(sp)
    80000aa8:	6902                	ld	s2,0(sp)
    80000aaa:	6105                	addi	sp,sp,32
    80000aac:	8082                	ret
    panic("kfree");
    80000aae:	00007517          	auipc	a0,0x7
    80000ab2:	59250513          	addi	a0,a0,1426 # 80008040 <etext+0x40>
    80000ab6:	00000097          	auipc	ra,0x0
    80000aba:	aa8080e7          	jalr	-1368(ra) # 8000055e <panic>

0000000080000abe <freerange>:
{
    80000abe:	7179                	addi	sp,sp,-48
    80000ac0:	f406                	sd	ra,40(sp)
    80000ac2:	f022                	sd	s0,32(sp)
    80000ac4:	ec26                	sd	s1,24(sp)
    80000ac6:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ac8:	6785                	lui	a5,0x1
    80000aca:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ace:	00e504b3          	add	s1,a0,a4
    80000ad2:	777d                	lui	a4,0xfffff
    80000ad4:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ad6:	94be                	add	s1,s1,a5
    80000ad8:	0295e463          	bltu	a1,s1,80000b00 <freerange+0x42>
    80000adc:	e84a                	sd	s2,16(sp)
    80000ade:	e44e                	sd	s3,8(sp)
    80000ae0:	e052                	sd	s4,0(sp)
    80000ae2:	892e                	mv	s2,a1
    kfree(p);
    80000ae4:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ae6:	6985                	lui	s3,0x1
    kfree(p);
    80000ae8:	01448533          	add	a0,s1,s4
    80000aec:	00000097          	auipc	ra,0x0
    80000af0:	f5c080e7          	jalr	-164(ra) # 80000a48 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000af4:	94ce                	add	s1,s1,s3
    80000af6:	fe9979e3          	bgeu	s2,s1,80000ae8 <freerange+0x2a>
    80000afa:	6942                	ld	s2,16(sp)
    80000afc:	69a2                	ld	s3,8(sp)
    80000afe:	6a02                	ld	s4,0(sp)
}
    80000b00:	70a2                	ld	ra,40(sp)
    80000b02:	7402                	ld	s0,32(sp)
    80000b04:	64e2                	ld	s1,24(sp)
    80000b06:	6145                	addi	sp,sp,48
    80000b08:	8082                	ret

0000000080000b0a <kinit>:
{
    80000b0a:	1141                	addi	sp,sp,-16
    80000b0c:	e406                	sd	ra,8(sp)
    80000b0e:	e022                	sd	s0,0(sp)
    80000b10:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b12:	00007597          	auipc	a1,0x7
    80000b16:	53658593          	addi	a1,a1,1334 # 80008048 <etext+0x48>
    80000b1a:	00010517          	auipc	a0,0x10
    80000b1e:	ff650513          	addi	a0,a0,-10 # 80010b10 <kmem>
    80000b22:	00000097          	auipc	ra,0x0
    80000b26:	084080e7          	jalr	132(ra) # 80000ba6 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b2a:	45c5                	li	a1,17
    80000b2c:	05ee                	slli	a1,a1,0x1b
    80000b2e:	00021517          	auipc	a0,0x21
    80000b32:	41250513          	addi	a0,a0,1042 # 80021f40 <end>
    80000b36:	00000097          	auipc	ra,0x0
    80000b3a:	f88080e7          	jalr	-120(ra) # 80000abe <freerange>
}
    80000b3e:	60a2                	ld	ra,8(sp)
    80000b40:	6402                	ld	s0,0(sp)
    80000b42:	0141                	addi	sp,sp,16
    80000b44:	8082                	ret

0000000080000b46 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b46:	1101                	addi	sp,sp,-32
    80000b48:	ec06                	sd	ra,24(sp)
    80000b4a:	e822                	sd	s0,16(sp)
    80000b4c:	e426                	sd	s1,8(sp)
    80000b4e:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b50:	00010497          	auipc	s1,0x10
    80000b54:	fc048493          	addi	s1,s1,-64 # 80010b10 <kmem>
    80000b58:	8526                	mv	a0,s1
    80000b5a:	00000097          	auipc	ra,0x0
    80000b5e:	0dc080e7          	jalr	220(ra) # 80000c36 <acquire>
  r = kmem.freelist;
    80000b62:	6c84                	ld	s1,24(s1)
  if(r)
    80000b64:	c885                	beqz	s1,80000b94 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b66:	609c                	ld	a5,0(s1)
    80000b68:	00010517          	auipc	a0,0x10
    80000b6c:	fa850513          	addi	a0,a0,-88 # 80010b10 <kmem>
    80000b70:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b72:	00000097          	auipc	ra,0x0
    80000b76:	178080e7          	jalr	376(ra) # 80000cea <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b7a:	6605                	lui	a2,0x1
    80000b7c:	4595                	li	a1,5
    80000b7e:	8526                	mv	a0,s1
    80000b80:	00000097          	auipc	ra,0x0
    80000b84:	1b2080e7          	jalr	434(ra) # 80000d32 <memset>
  return (void*)r;
}
    80000b88:	8526                	mv	a0,s1
    80000b8a:	60e2                	ld	ra,24(sp)
    80000b8c:	6442                	ld	s0,16(sp)
    80000b8e:	64a2                	ld	s1,8(sp)
    80000b90:	6105                	addi	sp,sp,32
    80000b92:	8082                	ret
  release(&kmem.lock);
    80000b94:	00010517          	auipc	a0,0x10
    80000b98:	f7c50513          	addi	a0,a0,-132 # 80010b10 <kmem>
    80000b9c:	00000097          	auipc	ra,0x0
    80000ba0:	14e080e7          	jalr	334(ra) # 80000cea <release>
  if(r)
    80000ba4:	b7d5                	j	80000b88 <kalloc+0x42>

0000000080000ba6 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000ba6:	1141                	addi	sp,sp,-16
    80000ba8:	e422                	sd	s0,8(sp)
    80000baa:	0800                	addi	s0,sp,16
  lk->name = name;
    80000bac:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000bae:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bb2:	00053823          	sd	zero,16(a0)
}
    80000bb6:	6422                	ld	s0,8(sp)
    80000bb8:	0141                	addi	sp,sp,16
    80000bba:	8082                	ret

0000000080000bbc <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bbc:	411c                	lw	a5,0(a0)
    80000bbe:	e399                	bnez	a5,80000bc4 <holding+0x8>
    80000bc0:	4501                	li	a0,0
  return r;
}
    80000bc2:	8082                	ret
{
    80000bc4:	1101                	addi	sp,sp,-32
    80000bc6:	ec06                	sd	ra,24(sp)
    80000bc8:	e822                	sd	s0,16(sp)
    80000bca:	e426                	sd	s1,8(sp)
    80000bcc:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bce:	6904                	ld	s1,16(a0)
    80000bd0:	00001097          	auipc	ra,0x1
    80000bd4:	e5c080e7          	jalr	-420(ra) # 80001a2c <mycpu>
    80000bd8:	40a48533          	sub	a0,s1,a0
    80000bdc:	00153513          	seqz	a0,a0
}
    80000be0:	60e2                	ld	ra,24(sp)
    80000be2:	6442                	ld	s0,16(sp)
    80000be4:	64a2                	ld	s1,8(sp)
    80000be6:	6105                	addi	sp,sp,32
    80000be8:	8082                	ret

0000000080000bea <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bea:	1101                	addi	sp,sp,-32
    80000bec:	ec06                	sd	ra,24(sp)
    80000bee:	e822                	sd	s0,16(sp)
    80000bf0:	e426                	sd	s1,8(sp)
    80000bf2:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bf4:	100024f3          	csrr	s1,sstatus
    80000bf8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bfc:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bfe:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c02:	00001097          	auipc	ra,0x1
    80000c06:	e2a080e7          	jalr	-470(ra) # 80001a2c <mycpu>
    80000c0a:	5d3c                	lw	a5,120(a0)
    80000c0c:	cf89                	beqz	a5,80000c26 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c0e:	00001097          	auipc	ra,0x1
    80000c12:	e1e080e7          	jalr	-482(ra) # 80001a2c <mycpu>
    80000c16:	5d3c                	lw	a5,120(a0)
    80000c18:	2785                	addiw	a5,a5,1
    80000c1a:	dd3c                	sw	a5,120(a0)
}
    80000c1c:	60e2                	ld	ra,24(sp)
    80000c1e:	6442                	ld	s0,16(sp)
    80000c20:	64a2                	ld	s1,8(sp)
    80000c22:	6105                	addi	sp,sp,32
    80000c24:	8082                	ret
    mycpu()->intena = old;
    80000c26:	00001097          	auipc	ra,0x1
    80000c2a:	e06080e7          	jalr	-506(ra) # 80001a2c <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c2e:	8085                	srli	s1,s1,0x1
    80000c30:	8885                	andi	s1,s1,1
    80000c32:	dd64                	sw	s1,124(a0)
    80000c34:	bfe9                	j	80000c0e <push_off+0x24>

0000000080000c36 <acquire>:
{
    80000c36:	1101                	addi	sp,sp,-32
    80000c38:	ec06                	sd	ra,24(sp)
    80000c3a:	e822                	sd	s0,16(sp)
    80000c3c:	e426                	sd	s1,8(sp)
    80000c3e:	1000                	addi	s0,sp,32
    80000c40:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c42:	00000097          	auipc	ra,0x0
    80000c46:	fa8080e7          	jalr	-88(ra) # 80000bea <push_off>
  if(holding(lk))
    80000c4a:	8526                	mv	a0,s1
    80000c4c:	00000097          	auipc	ra,0x0
    80000c50:	f70080e7          	jalr	-144(ra) # 80000bbc <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c54:	4705                	li	a4,1
  if(holding(lk))
    80000c56:	e115                	bnez	a0,80000c7a <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c58:	87ba                	mv	a5,a4
    80000c5a:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c5e:	2781                	sext.w	a5,a5
    80000c60:	ffe5                	bnez	a5,80000c58 <acquire+0x22>
  __sync_synchronize();
    80000c62:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c66:	00001097          	auipc	ra,0x1
    80000c6a:	dc6080e7          	jalr	-570(ra) # 80001a2c <mycpu>
    80000c6e:	e888                	sd	a0,16(s1)
}
    80000c70:	60e2                	ld	ra,24(sp)
    80000c72:	6442                	ld	s0,16(sp)
    80000c74:	64a2                	ld	s1,8(sp)
    80000c76:	6105                	addi	sp,sp,32
    80000c78:	8082                	ret
    panic("acquire");
    80000c7a:	00007517          	auipc	a0,0x7
    80000c7e:	3d650513          	addi	a0,a0,982 # 80008050 <etext+0x50>
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	8dc080e7          	jalr	-1828(ra) # 8000055e <panic>

0000000080000c8a <pop_off>:

void
pop_off(void)
{
    80000c8a:	1141                	addi	sp,sp,-16
    80000c8c:	e406                	sd	ra,8(sp)
    80000c8e:	e022                	sd	s0,0(sp)
    80000c90:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c92:	00001097          	auipc	ra,0x1
    80000c96:	d9a080e7          	jalr	-614(ra) # 80001a2c <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c9a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c9e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000ca0:	e78d                	bnez	a5,80000cca <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000ca2:	5d3c                	lw	a5,120(a0)
    80000ca4:	02f05b63          	blez	a5,80000cda <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000ca8:	37fd                	addiw	a5,a5,-1
    80000caa:	0007871b          	sext.w	a4,a5
    80000cae:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000cb0:	eb09                	bnez	a4,80000cc2 <pop_off+0x38>
    80000cb2:	5d7c                	lw	a5,124(a0)
    80000cb4:	c799                	beqz	a5,80000cc2 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cb6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000cba:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cbe:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000cc2:	60a2                	ld	ra,8(sp)
    80000cc4:	6402                	ld	s0,0(sp)
    80000cc6:	0141                	addi	sp,sp,16
    80000cc8:	8082                	ret
    panic("pop_off - interruptible");
    80000cca:	00007517          	auipc	a0,0x7
    80000cce:	38e50513          	addi	a0,a0,910 # 80008058 <etext+0x58>
    80000cd2:	00000097          	auipc	ra,0x0
    80000cd6:	88c080e7          	jalr	-1908(ra) # 8000055e <panic>
    panic("pop_off");
    80000cda:	00007517          	auipc	a0,0x7
    80000cde:	39650513          	addi	a0,a0,918 # 80008070 <etext+0x70>
    80000ce2:	00000097          	auipc	ra,0x0
    80000ce6:	87c080e7          	jalr	-1924(ra) # 8000055e <panic>

0000000080000cea <release>:
{
    80000cea:	1101                	addi	sp,sp,-32
    80000cec:	ec06                	sd	ra,24(sp)
    80000cee:	e822                	sd	s0,16(sp)
    80000cf0:	e426                	sd	s1,8(sp)
    80000cf2:	1000                	addi	s0,sp,32
    80000cf4:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000cf6:	00000097          	auipc	ra,0x0
    80000cfa:	ec6080e7          	jalr	-314(ra) # 80000bbc <holding>
    80000cfe:	c115                	beqz	a0,80000d22 <release+0x38>
  lk->cpu = 0;
    80000d00:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d04:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000d08:	0f50000f          	fence	iorw,ow
    80000d0c:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000d10:	00000097          	auipc	ra,0x0
    80000d14:	f7a080e7          	jalr	-134(ra) # 80000c8a <pop_off>
}
    80000d18:	60e2                	ld	ra,24(sp)
    80000d1a:	6442                	ld	s0,16(sp)
    80000d1c:	64a2                	ld	s1,8(sp)
    80000d1e:	6105                	addi	sp,sp,32
    80000d20:	8082                	ret
    panic("release");
    80000d22:	00007517          	auipc	a0,0x7
    80000d26:	35650513          	addi	a0,a0,854 # 80008078 <etext+0x78>
    80000d2a:	00000097          	auipc	ra,0x0
    80000d2e:	834080e7          	jalr	-1996(ra) # 8000055e <panic>

0000000080000d32 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d32:	1141                	addi	sp,sp,-16
    80000d34:	e422                	sd	s0,8(sp)
    80000d36:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d38:	ca19                	beqz	a2,80000d4e <memset+0x1c>
    80000d3a:	87aa                	mv	a5,a0
    80000d3c:	1602                	slli	a2,a2,0x20
    80000d3e:	9201                	srli	a2,a2,0x20
    80000d40:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d44:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d48:	0785                	addi	a5,a5,1
    80000d4a:	fee79de3          	bne	a5,a4,80000d44 <memset+0x12>
  }
  return dst;
}
    80000d4e:	6422                	ld	s0,8(sp)
    80000d50:	0141                	addi	sp,sp,16
    80000d52:	8082                	ret

0000000080000d54 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d54:	1141                	addi	sp,sp,-16
    80000d56:	e422                	sd	s0,8(sp)
    80000d58:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d5a:	ca05                	beqz	a2,80000d8a <memcmp+0x36>
    80000d5c:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d60:	1682                	slli	a3,a3,0x20
    80000d62:	9281                	srli	a3,a3,0x20
    80000d64:	0685                	addi	a3,a3,1
    80000d66:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d68:	00054783          	lbu	a5,0(a0)
    80000d6c:	0005c703          	lbu	a4,0(a1)
    80000d70:	00e79863          	bne	a5,a4,80000d80 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d74:	0505                	addi	a0,a0,1
    80000d76:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d78:	fed518e3          	bne	a0,a3,80000d68 <memcmp+0x14>
  }

  return 0;
    80000d7c:	4501                	li	a0,0
    80000d7e:	a019                	j	80000d84 <memcmp+0x30>
      return *s1 - *s2;
    80000d80:	40e7853b          	subw	a0,a5,a4
}
    80000d84:	6422                	ld	s0,8(sp)
    80000d86:	0141                	addi	sp,sp,16
    80000d88:	8082                	ret
  return 0;
    80000d8a:	4501                	li	a0,0
    80000d8c:	bfe5                	j	80000d84 <memcmp+0x30>

0000000080000d8e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d8e:	1141                	addi	sp,sp,-16
    80000d90:	e422                	sd	s0,8(sp)
    80000d92:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d94:	c205                	beqz	a2,80000db4 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d96:	02a5e263          	bltu	a1,a0,80000dba <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d9a:	1602                	slli	a2,a2,0x20
    80000d9c:	9201                	srli	a2,a2,0x20
    80000d9e:	00c587b3          	add	a5,a1,a2
{
    80000da2:	872a                	mv	a4,a0
      *d++ = *s++;
    80000da4:	0585                	addi	a1,a1,1
    80000da6:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdd0c1>
    80000da8:	fff5c683          	lbu	a3,-1(a1)
    80000dac:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000db0:	feb79ae3          	bne	a5,a1,80000da4 <memmove+0x16>

  return dst;
}
    80000db4:	6422                	ld	s0,8(sp)
    80000db6:	0141                	addi	sp,sp,16
    80000db8:	8082                	ret
  if(s < d && s + n > d){
    80000dba:	02061693          	slli	a3,a2,0x20
    80000dbe:	9281                	srli	a3,a3,0x20
    80000dc0:	00d58733          	add	a4,a1,a3
    80000dc4:	fce57be3          	bgeu	a0,a4,80000d9a <memmove+0xc>
    d += n;
    80000dc8:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000dca:	fff6079b          	addiw	a5,a2,-1
    80000dce:	1782                	slli	a5,a5,0x20
    80000dd0:	9381                	srli	a5,a5,0x20
    80000dd2:	fff7c793          	not	a5,a5
    80000dd6:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000dd8:	177d                	addi	a4,a4,-1
    80000dda:	16fd                	addi	a3,a3,-1
    80000ddc:	00074603          	lbu	a2,0(a4)
    80000de0:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000de4:	fef71ae3          	bne	a4,a5,80000dd8 <memmove+0x4a>
    80000de8:	b7f1                	j	80000db4 <memmove+0x26>

0000000080000dea <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000dea:	1141                	addi	sp,sp,-16
    80000dec:	e406                	sd	ra,8(sp)
    80000dee:	e022                	sd	s0,0(sp)
    80000df0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000df2:	00000097          	auipc	ra,0x0
    80000df6:	f9c080e7          	jalr	-100(ra) # 80000d8e <memmove>
}
    80000dfa:	60a2                	ld	ra,8(sp)
    80000dfc:	6402                	ld	s0,0(sp)
    80000dfe:	0141                	addi	sp,sp,16
    80000e00:	8082                	ret

0000000080000e02 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e02:	1141                	addi	sp,sp,-16
    80000e04:	e422                	sd	s0,8(sp)
    80000e06:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e08:	ce11                	beqz	a2,80000e24 <strncmp+0x22>
    80000e0a:	00054783          	lbu	a5,0(a0)
    80000e0e:	cf89                	beqz	a5,80000e28 <strncmp+0x26>
    80000e10:	0005c703          	lbu	a4,0(a1)
    80000e14:	00f71a63          	bne	a4,a5,80000e28 <strncmp+0x26>
    n--, p++, q++;
    80000e18:	367d                	addiw	a2,a2,-1
    80000e1a:	0505                	addi	a0,a0,1
    80000e1c:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e1e:	f675                	bnez	a2,80000e0a <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e20:	4501                	li	a0,0
    80000e22:	a801                	j	80000e32 <strncmp+0x30>
    80000e24:	4501                	li	a0,0
    80000e26:	a031                	j	80000e32 <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000e28:	00054503          	lbu	a0,0(a0)
    80000e2c:	0005c783          	lbu	a5,0(a1)
    80000e30:	9d1d                	subw	a0,a0,a5
}
    80000e32:	6422                	ld	s0,8(sp)
    80000e34:	0141                	addi	sp,sp,16
    80000e36:	8082                	ret

0000000080000e38 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e38:	1141                	addi	sp,sp,-16
    80000e3a:	e422                	sd	s0,8(sp)
    80000e3c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e3e:	87aa                	mv	a5,a0
    80000e40:	86b2                	mv	a3,a2
    80000e42:	367d                	addiw	a2,a2,-1
    80000e44:	02d05563          	blez	a3,80000e6e <strncpy+0x36>
    80000e48:	0785                	addi	a5,a5,1
    80000e4a:	0005c703          	lbu	a4,0(a1)
    80000e4e:	fee78fa3          	sb	a4,-1(a5)
    80000e52:	0585                	addi	a1,a1,1
    80000e54:	f775                	bnez	a4,80000e40 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e56:	873e                	mv	a4,a5
    80000e58:	9fb5                	addw	a5,a5,a3
    80000e5a:	37fd                	addiw	a5,a5,-1
    80000e5c:	00c05963          	blez	a2,80000e6e <strncpy+0x36>
    *s++ = 0;
    80000e60:	0705                	addi	a4,a4,1
    80000e62:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e66:	40e786bb          	subw	a3,a5,a4
    80000e6a:	fed04be3          	bgtz	a3,80000e60 <strncpy+0x28>
  return os;
}
    80000e6e:	6422                	ld	s0,8(sp)
    80000e70:	0141                	addi	sp,sp,16
    80000e72:	8082                	ret

0000000080000e74 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e74:	1141                	addi	sp,sp,-16
    80000e76:	e422                	sd	s0,8(sp)
    80000e78:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e7a:	02c05363          	blez	a2,80000ea0 <safestrcpy+0x2c>
    80000e7e:	fff6069b          	addiw	a3,a2,-1
    80000e82:	1682                	slli	a3,a3,0x20
    80000e84:	9281                	srli	a3,a3,0x20
    80000e86:	96ae                	add	a3,a3,a1
    80000e88:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e8a:	00d58963          	beq	a1,a3,80000e9c <safestrcpy+0x28>
    80000e8e:	0585                	addi	a1,a1,1
    80000e90:	0785                	addi	a5,a5,1
    80000e92:	fff5c703          	lbu	a4,-1(a1)
    80000e96:	fee78fa3          	sb	a4,-1(a5)
    80000e9a:	fb65                	bnez	a4,80000e8a <safestrcpy+0x16>
    ;
  *s = 0;
    80000e9c:	00078023          	sb	zero,0(a5)
  return os;
}
    80000ea0:	6422                	ld	s0,8(sp)
    80000ea2:	0141                	addi	sp,sp,16
    80000ea4:	8082                	ret

0000000080000ea6 <strlen>:

int
strlen(const char *s)
{
    80000ea6:	1141                	addi	sp,sp,-16
    80000ea8:	e422                	sd	s0,8(sp)
    80000eaa:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000eac:	00054783          	lbu	a5,0(a0)
    80000eb0:	cf91                	beqz	a5,80000ecc <strlen+0x26>
    80000eb2:	0505                	addi	a0,a0,1
    80000eb4:	87aa                	mv	a5,a0
    80000eb6:	86be                	mv	a3,a5
    80000eb8:	0785                	addi	a5,a5,1
    80000eba:	fff7c703          	lbu	a4,-1(a5)
    80000ebe:	ff65                	bnez	a4,80000eb6 <strlen+0x10>
    80000ec0:	40a6853b          	subw	a0,a3,a0
    80000ec4:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000ec6:	6422                	ld	s0,8(sp)
    80000ec8:	0141                	addi	sp,sp,16
    80000eca:	8082                	ret
  for(n = 0; s[n]; n++)
    80000ecc:	4501                	li	a0,0
    80000ece:	bfe5                	j	80000ec6 <strlen+0x20>

0000000080000ed0 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000ed0:	1141                	addi	sp,sp,-16
    80000ed2:	e406                	sd	ra,8(sp)
    80000ed4:	e022                	sd	s0,0(sp)
    80000ed6:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000ed8:	00001097          	auipc	ra,0x1
    80000edc:	b44080e7          	jalr	-1212(ra) # 80001a1c <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000ee0:	00008717          	auipc	a4,0x8
    80000ee4:	9c870713          	addi	a4,a4,-1592 # 800088a8 <started>
  if(cpuid() == 0){
    80000ee8:	c139                	beqz	a0,80000f2e <main+0x5e>
    while(started == 0)
    80000eea:	431c                	lw	a5,0(a4)
    80000eec:	2781                	sext.w	a5,a5
    80000eee:	dff5                	beqz	a5,80000eea <main+0x1a>
      ;
    __sync_synchronize();
    80000ef0:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000ef4:	00001097          	auipc	ra,0x1
    80000ef8:	b28080e7          	jalr	-1240(ra) # 80001a1c <cpuid>
    80000efc:	85aa                	mv	a1,a0
    80000efe:	00007517          	auipc	a0,0x7
    80000f02:	19a50513          	addi	a0,a0,410 # 80008098 <etext+0x98>
    80000f06:	fffff097          	auipc	ra,0xfffff
    80000f0a:	6a2080e7          	jalr	1698(ra) # 800005a8 <printf>
    kvminithart();    // turn on paging
    80000f0e:	00000097          	auipc	ra,0x0
    80000f12:	0d8080e7          	jalr	216(ra) # 80000fe6 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f16:	00002097          	auipc	ra,0x2
    80000f1a:	838080e7          	jalr	-1992(ra) # 8000274e <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f1e:	00005097          	auipc	ra,0x5
    80000f22:	ea6080e7          	jalr	-346(ra) # 80005dc4 <plicinithart>
  }

  scheduler();        
    80000f26:	00001097          	auipc	ra,0x1
    80000f2a:	01a080e7          	jalr	26(ra) # 80001f40 <scheduler>
    consoleinit();
    80000f2e:	fffff097          	auipc	ra,0xfffff
    80000f32:	540080e7          	jalr	1344(ra) # 8000046e <consoleinit>
    printfinit();
    80000f36:	00000097          	auipc	ra,0x0
    80000f3a:	87a080e7          	jalr	-1926(ra) # 800007b0 <printfinit>
    printf("\n");
    80000f3e:	00007517          	auipc	a0,0x7
    80000f42:	0d250513          	addi	a0,a0,210 # 80008010 <etext+0x10>
    80000f46:	fffff097          	auipc	ra,0xfffff
    80000f4a:	662080e7          	jalr	1634(ra) # 800005a8 <printf>
    printf("xv6 kernel is booting\n");
    80000f4e:	00007517          	auipc	a0,0x7
    80000f52:	13250513          	addi	a0,a0,306 # 80008080 <etext+0x80>
    80000f56:	fffff097          	auipc	ra,0xfffff
    80000f5a:	652080e7          	jalr	1618(ra) # 800005a8 <printf>
    printf("\n");
    80000f5e:	00007517          	auipc	a0,0x7
    80000f62:	0b250513          	addi	a0,a0,178 # 80008010 <etext+0x10>
    80000f66:	fffff097          	auipc	ra,0xfffff
    80000f6a:	642080e7          	jalr	1602(ra) # 800005a8 <printf>
    kinit();         // physical page allocator
    80000f6e:	00000097          	auipc	ra,0x0
    80000f72:	b9c080e7          	jalr	-1124(ra) # 80000b0a <kinit>
    kvminit();       // create kernel page table
    80000f76:	00000097          	auipc	ra,0x0
    80000f7a:	326080e7          	jalr	806(ra) # 8000129c <kvminit>
    kvminithart();   // turn on paging
    80000f7e:	00000097          	auipc	ra,0x0
    80000f82:	068080e7          	jalr	104(ra) # 80000fe6 <kvminithart>
    procinit();      // process table
    80000f86:	00001097          	auipc	ra,0x1
    80000f8a:	9d4080e7          	jalr	-1580(ra) # 8000195a <procinit>
    trapinit();      // trap vectors
    80000f8e:	00001097          	auipc	ra,0x1
    80000f92:	798080e7          	jalr	1944(ra) # 80002726 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f96:	00001097          	auipc	ra,0x1
    80000f9a:	7b8080e7          	jalr	1976(ra) # 8000274e <trapinithart>
    plicinit();      // set up interrupt controller
    80000f9e:	00005097          	auipc	ra,0x5
    80000fa2:	e0c080e7          	jalr	-500(ra) # 80005daa <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fa6:	00005097          	auipc	ra,0x5
    80000faa:	e1e080e7          	jalr	-482(ra) # 80005dc4 <plicinithart>
    binit();         // buffer cache
    80000fae:	00002097          	auipc	ra,0x2
    80000fb2:	ee8080e7          	jalr	-280(ra) # 80002e96 <binit>
    iinit();         // inode table
    80000fb6:	00002097          	auipc	ra,0x2
    80000fba:	59e080e7          	jalr	1438(ra) # 80003554 <iinit>
    fileinit();      // file table
    80000fbe:	00003097          	auipc	ra,0x3
    80000fc2:	54e080e7          	jalr	1358(ra) # 8000450c <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fc6:	00005097          	auipc	ra,0x5
    80000fca:	f06080e7          	jalr	-250(ra) # 80005ecc <virtio_disk_init>
    userinit();      // first user process
    80000fce:	00001097          	auipc	ra,0x1
    80000fd2:	d52080e7          	jalr	-686(ra) # 80001d20 <userinit>
    __sync_synchronize();
    80000fd6:	0ff0000f          	fence
    started = 1;
    80000fda:	4785                	li	a5,1
    80000fdc:	00008717          	auipc	a4,0x8
    80000fe0:	8cf72623          	sw	a5,-1844(a4) # 800088a8 <started>
    80000fe4:	b789                	j	80000f26 <main+0x56>

0000000080000fe6 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000fe6:	1141                	addi	sp,sp,-16
    80000fe8:	e422                	sd	s0,8(sp)
    80000fea:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fec:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000ff0:	00008797          	auipc	a5,0x8
    80000ff4:	8c07b783          	ld	a5,-1856(a5) # 800088b0 <kernel_pagetable>
    80000ff8:	83b1                	srli	a5,a5,0xc
    80000ffa:	577d                	li	a4,-1
    80000ffc:	177e                	slli	a4,a4,0x3f
    80000ffe:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001000:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80001004:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80001008:	6422                	ld	s0,8(sp)
    8000100a:	0141                	addi	sp,sp,16
    8000100c:	8082                	ret

000000008000100e <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    8000100e:	7139                	addi	sp,sp,-64
    80001010:	fc06                	sd	ra,56(sp)
    80001012:	f822                	sd	s0,48(sp)
    80001014:	f426                	sd	s1,40(sp)
    80001016:	f04a                	sd	s2,32(sp)
    80001018:	ec4e                	sd	s3,24(sp)
    8000101a:	e852                	sd	s4,16(sp)
    8000101c:	e456                	sd	s5,8(sp)
    8000101e:	e05a                	sd	s6,0(sp)
    80001020:	0080                	addi	s0,sp,64
    80001022:	84aa                	mv	s1,a0
    80001024:	89ae                	mv	s3,a1
    80001026:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001028:	57fd                	li	a5,-1
    8000102a:	83e9                	srli	a5,a5,0x1a
    8000102c:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    8000102e:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001030:	04b7f263          	bgeu	a5,a1,80001074 <walk+0x66>
    panic("walk");
    80001034:	00007517          	auipc	a0,0x7
    80001038:	07c50513          	addi	a0,a0,124 # 800080b0 <etext+0xb0>
    8000103c:	fffff097          	auipc	ra,0xfffff
    80001040:	522080e7          	jalr	1314(ra) # 8000055e <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001044:	060a8663          	beqz	s5,800010b0 <walk+0xa2>
    80001048:	00000097          	auipc	ra,0x0
    8000104c:	afe080e7          	jalr	-1282(ra) # 80000b46 <kalloc>
    80001050:	84aa                	mv	s1,a0
    80001052:	c529                	beqz	a0,8000109c <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001054:	6605                	lui	a2,0x1
    80001056:	4581                	li	a1,0
    80001058:	00000097          	auipc	ra,0x0
    8000105c:	cda080e7          	jalr	-806(ra) # 80000d32 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001060:	00c4d793          	srli	a5,s1,0xc
    80001064:	07aa                	slli	a5,a5,0xa
    80001066:	0017e793          	ori	a5,a5,1
    8000106a:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000106e:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdd0b7>
    80001070:	036a0063          	beq	s4,s6,80001090 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001074:	0149d933          	srl	s2,s3,s4
    80001078:	1ff97913          	andi	s2,s2,511
    8000107c:	090e                	slli	s2,s2,0x3
    8000107e:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001080:	00093483          	ld	s1,0(s2)
    80001084:	0014f793          	andi	a5,s1,1
    80001088:	dfd5                	beqz	a5,80001044 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000108a:	80a9                	srli	s1,s1,0xa
    8000108c:	04b2                	slli	s1,s1,0xc
    8000108e:	b7c5                	j	8000106e <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001090:	00c9d513          	srli	a0,s3,0xc
    80001094:	1ff57513          	andi	a0,a0,511
    80001098:	050e                	slli	a0,a0,0x3
    8000109a:	9526                	add	a0,a0,s1
}
    8000109c:	70e2                	ld	ra,56(sp)
    8000109e:	7442                	ld	s0,48(sp)
    800010a0:	74a2                	ld	s1,40(sp)
    800010a2:	7902                	ld	s2,32(sp)
    800010a4:	69e2                	ld	s3,24(sp)
    800010a6:	6a42                	ld	s4,16(sp)
    800010a8:	6aa2                	ld	s5,8(sp)
    800010aa:	6b02                	ld	s6,0(sp)
    800010ac:	6121                	addi	sp,sp,64
    800010ae:	8082                	ret
        return 0;
    800010b0:	4501                	li	a0,0
    800010b2:	b7ed                	j	8000109c <walk+0x8e>

00000000800010b4 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800010b4:	57fd                	li	a5,-1
    800010b6:	83e9                	srli	a5,a5,0x1a
    800010b8:	00b7f463          	bgeu	a5,a1,800010c0 <walkaddr+0xc>
    return 0;
    800010bc:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010be:	8082                	ret
{
    800010c0:	1141                	addi	sp,sp,-16
    800010c2:	e406                	sd	ra,8(sp)
    800010c4:	e022                	sd	s0,0(sp)
    800010c6:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010c8:	4601                	li	a2,0
    800010ca:	00000097          	auipc	ra,0x0
    800010ce:	f44080e7          	jalr	-188(ra) # 8000100e <walk>
  if(pte == 0)
    800010d2:	c105                	beqz	a0,800010f2 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800010d4:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800010d6:	0117f693          	andi	a3,a5,17
    800010da:	4745                	li	a4,17
    return 0;
    800010dc:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010de:	00e68663          	beq	a3,a4,800010ea <walkaddr+0x36>
}
    800010e2:	60a2                	ld	ra,8(sp)
    800010e4:	6402                	ld	s0,0(sp)
    800010e6:	0141                	addi	sp,sp,16
    800010e8:	8082                	ret
  pa = PTE2PA(*pte);
    800010ea:	83a9                	srli	a5,a5,0xa
    800010ec:	00c79513          	slli	a0,a5,0xc
  return pa;
    800010f0:	bfcd                	j	800010e2 <walkaddr+0x2e>
    return 0;
    800010f2:	4501                	li	a0,0
    800010f4:	b7fd                	j	800010e2 <walkaddr+0x2e>

00000000800010f6 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010f6:	715d                	addi	sp,sp,-80
    800010f8:	e486                	sd	ra,72(sp)
    800010fa:	e0a2                	sd	s0,64(sp)
    800010fc:	fc26                	sd	s1,56(sp)
    800010fe:	f84a                	sd	s2,48(sp)
    80001100:	f44e                	sd	s3,40(sp)
    80001102:	f052                	sd	s4,32(sp)
    80001104:	ec56                	sd	s5,24(sp)
    80001106:	e85a                	sd	s6,16(sp)
    80001108:	e45e                	sd	s7,8(sp)
    8000110a:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    8000110c:	c639                	beqz	a2,8000115a <mappages+0x64>
    8000110e:	8aaa                	mv	s5,a0
    80001110:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    80001112:	777d                	lui	a4,0xfffff
    80001114:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001118:	fff58993          	addi	s3,a1,-1
    8000111c:	99b2                	add	s3,s3,a2
    8000111e:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80001122:	893e                	mv	s2,a5
    80001124:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001128:	6b85                	lui	s7,0x1
    8000112a:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    8000112e:	4605                	li	a2,1
    80001130:	85ca                	mv	a1,s2
    80001132:	8556                	mv	a0,s5
    80001134:	00000097          	auipc	ra,0x0
    80001138:	eda080e7          	jalr	-294(ra) # 8000100e <walk>
    8000113c:	cd1d                	beqz	a0,8000117a <mappages+0x84>
    if(*pte & PTE_V)
    8000113e:	611c                	ld	a5,0(a0)
    80001140:	8b85                	andi	a5,a5,1
    80001142:	e785                	bnez	a5,8000116a <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001144:	80b1                	srli	s1,s1,0xc
    80001146:	04aa                	slli	s1,s1,0xa
    80001148:	0164e4b3          	or	s1,s1,s6
    8000114c:	0014e493          	ori	s1,s1,1
    80001150:	e104                	sd	s1,0(a0)
    if(a == last)
    80001152:	05390063          	beq	s2,s3,80001192 <mappages+0x9c>
    a += PGSIZE;
    80001156:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001158:	bfc9                	j	8000112a <mappages+0x34>
    panic("mappages: size");
    8000115a:	00007517          	auipc	a0,0x7
    8000115e:	f5e50513          	addi	a0,a0,-162 # 800080b8 <etext+0xb8>
    80001162:	fffff097          	auipc	ra,0xfffff
    80001166:	3fc080e7          	jalr	1020(ra) # 8000055e <panic>
      panic("mappages: remap");
    8000116a:	00007517          	auipc	a0,0x7
    8000116e:	f5e50513          	addi	a0,a0,-162 # 800080c8 <etext+0xc8>
    80001172:	fffff097          	auipc	ra,0xfffff
    80001176:	3ec080e7          	jalr	1004(ra) # 8000055e <panic>
      return -1;
    8000117a:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000117c:	60a6                	ld	ra,72(sp)
    8000117e:	6406                	ld	s0,64(sp)
    80001180:	74e2                	ld	s1,56(sp)
    80001182:	7942                	ld	s2,48(sp)
    80001184:	79a2                	ld	s3,40(sp)
    80001186:	7a02                	ld	s4,32(sp)
    80001188:	6ae2                	ld	s5,24(sp)
    8000118a:	6b42                	ld	s6,16(sp)
    8000118c:	6ba2                	ld	s7,8(sp)
    8000118e:	6161                	addi	sp,sp,80
    80001190:	8082                	ret
  return 0;
    80001192:	4501                	li	a0,0
    80001194:	b7e5                	j	8000117c <mappages+0x86>

0000000080001196 <kvmmap>:
{
    80001196:	1141                	addi	sp,sp,-16
    80001198:	e406                	sd	ra,8(sp)
    8000119a:	e022                	sd	s0,0(sp)
    8000119c:	0800                	addi	s0,sp,16
    8000119e:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800011a0:	86b2                	mv	a3,a2
    800011a2:	863e                	mv	a2,a5
    800011a4:	00000097          	auipc	ra,0x0
    800011a8:	f52080e7          	jalr	-174(ra) # 800010f6 <mappages>
    800011ac:	e509                	bnez	a0,800011b6 <kvmmap+0x20>
}
    800011ae:	60a2                	ld	ra,8(sp)
    800011b0:	6402                	ld	s0,0(sp)
    800011b2:	0141                	addi	sp,sp,16
    800011b4:	8082                	ret
    panic("kvmmap");
    800011b6:	00007517          	auipc	a0,0x7
    800011ba:	f2250513          	addi	a0,a0,-222 # 800080d8 <etext+0xd8>
    800011be:	fffff097          	auipc	ra,0xfffff
    800011c2:	3a0080e7          	jalr	928(ra) # 8000055e <panic>

00000000800011c6 <kvmmake>:
{
    800011c6:	1101                	addi	sp,sp,-32
    800011c8:	ec06                	sd	ra,24(sp)
    800011ca:	e822                	sd	s0,16(sp)
    800011cc:	e426                	sd	s1,8(sp)
    800011ce:	e04a                	sd	s2,0(sp)
    800011d0:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800011d2:	00000097          	auipc	ra,0x0
    800011d6:	974080e7          	jalr	-1676(ra) # 80000b46 <kalloc>
    800011da:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800011dc:	6605                	lui	a2,0x1
    800011de:	4581                	li	a1,0
    800011e0:	00000097          	auipc	ra,0x0
    800011e4:	b52080e7          	jalr	-1198(ra) # 80000d32 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011e8:	4719                	li	a4,6
    800011ea:	6685                	lui	a3,0x1
    800011ec:	10000637          	lui	a2,0x10000
    800011f0:	100005b7          	lui	a1,0x10000
    800011f4:	8526                	mv	a0,s1
    800011f6:	00000097          	auipc	ra,0x0
    800011fa:	fa0080e7          	jalr	-96(ra) # 80001196 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011fe:	4719                	li	a4,6
    80001200:	6685                	lui	a3,0x1
    80001202:	10001637          	lui	a2,0x10001
    80001206:	100015b7          	lui	a1,0x10001
    8000120a:	8526                	mv	a0,s1
    8000120c:	00000097          	auipc	ra,0x0
    80001210:	f8a080e7          	jalr	-118(ra) # 80001196 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001214:	4719                	li	a4,6
    80001216:	004006b7          	lui	a3,0x400
    8000121a:	0c000637          	lui	a2,0xc000
    8000121e:	0c0005b7          	lui	a1,0xc000
    80001222:	8526                	mv	a0,s1
    80001224:	00000097          	auipc	ra,0x0
    80001228:	f72080e7          	jalr	-142(ra) # 80001196 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000122c:	00007917          	auipc	s2,0x7
    80001230:	dd490913          	addi	s2,s2,-556 # 80008000 <etext>
    80001234:	4729                	li	a4,10
    80001236:	80007697          	auipc	a3,0x80007
    8000123a:	dca68693          	addi	a3,a3,-566 # 8000 <_entry-0x7fff8000>
    8000123e:	4605                	li	a2,1
    80001240:	067e                	slli	a2,a2,0x1f
    80001242:	85b2                	mv	a1,a2
    80001244:	8526                	mv	a0,s1
    80001246:	00000097          	auipc	ra,0x0
    8000124a:	f50080e7          	jalr	-176(ra) # 80001196 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000124e:	46c5                	li	a3,17
    80001250:	06ee                	slli	a3,a3,0x1b
    80001252:	4719                	li	a4,6
    80001254:	412686b3          	sub	a3,a3,s2
    80001258:	864a                	mv	a2,s2
    8000125a:	85ca                	mv	a1,s2
    8000125c:	8526                	mv	a0,s1
    8000125e:	00000097          	auipc	ra,0x0
    80001262:	f38080e7          	jalr	-200(ra) # 80001196 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001266:	4729                	li	a4,10
    80001268:	6685                	lui	a3,0x1
    8000126a:	00006617          	auipc	a2,0x6
    8000126e:	d9660613          	addi	a2,a2,-618 # 80007000 <_trampoline>
    80001272:	040005b7          	lui	a1,0x4000
    80001276:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001278:	05b2                	slli	a1,a1,0xc
    8000127a:	8526                	mv	a0,s1
    8000127c:	00000097          	auipc	ra,0x0
    80001280:	f1a080e7          	jalr	-230(ra) # 80001196 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001284:	8526                	mv	a0,s1
    80001286:	00000097          	auipc	ra,0x0
    8000128a:	630080e7          	jalr	1584(ra) # 800018b6 <proc_mapstacks>
}
    8000128e:	8526                	mv	a0,s1
    80001290:	60e2                	ld	ra,24(sp)
    80001292:	6442                	ld	s0,16(sp)
    80001294:	64a2                	ld	s1,8(sp)
    80001296:	6902                	ld	s2,0(sp)
    80001298:	6105                	addi	sp,sp,32
    8000129a:	8082                	ret

000000008000129c <kvminit>:
{
    8000129c:	1141                	addi	sp,sp,-16
    8000129e:	e406                	sd	ra,8(sp)
    800012a0:	e022                	sd	s0,0(sp)
    800012a2:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800012a4:	00000097          	auipc	ra,0x0
    800012a8:	f22080e7          	jalr	-222(ra) # 800011c6 <kvmmake>
    800012ac:	00007797          	auipc	a5,0x7
    800012b0:	60a7b223          	sd	a0,1540(a5) # 800088b0 <kernel_pagetable>
}
    800012b4:	60a2                	ld	ra,8(sp)
    800012b6:	6402                	ld	s0,0(sp)
    800012b8:	0141                	addi	sp,sp,16
    800012ba:	8082                	ret

00000000800012bc <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800012bc:	715d                	addi	sp,sp,-80
    800012be:	e486                	sd	ra,72(sp)
    800012c0:	e0a2                	sd	s0,64(sp)
    800012c2:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800012c4:	03459793          	slli	a5,a1,0x34
    800012c8:	e39d                	bnez	a5,800012ee <uvmunmap+0x32>
    800012ca:	f84a                	sd	s2,48(sp)
    800012cc:	f44e                	sd	s3,40(sp)
    800012ce:	f052                	sd	s4,32(sp)
    800012d0:	ec56                	sd	s5,24(sp)
    800012d2:	e85a                	sd	s6,16(sp)
    800012d4:	e45e                	sd	s7,8(sp)
    800012d6:	8a2a                	mv	s4,a0
    800012d8:	892e                	mv	s2,a1
    800012da:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012dc:	0632                	slli	a2,a2,0xc
    800012de:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800012e2:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012e4:	6b05                	lui	s6,0x1
    800012e6:	0935fb63          	bgeu	a1,s3,8000137c <uvmunmap+0xc0>
    800012ea:	fc26                	sd	s1,56(sp)
    800012ec:	a8a9                	j	80001346 <uvmunmap+0x8a>
    800012ee:	fc26                	sd	s1,56(sp)
    800012f0:	f84a                	sd	s2,48(sp)
    800012f2:	f44e                	sd	s3,40(sp)
    800012f4:	f052                	sd	s4,32(sp)
    800012f6:	ec56                	sd	s5,24(sp)
    800012f8:	e85a                	sd	s6,16(sp)
    800012fa:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    800012fc:	00007517          	auipc	a0,0x7
    80001300:	de450513          	addi	a0,a0,-540 # 800080e0 <etext+0xe0>
    80001304:	fffff097          	auipc	ra,0xfffff
    80001308:	25a080e7          	jalr	602(ra) # 8000055e <panic>
      panic("uvmunmap: walk");
    8000130c:	00007517          	auipc	a0,0x7
    80001310:	dec50513          	addi	a0,a0,-532 # 800080f8 <etext+0xf8>
    80001314:	fffff097          	auipc	ra,0xfffff
    80001318:	24a080e7          	jalr	586(ra) # 8000055e <panic>
      panic("uvmunmap: not mapped");
    8000131c:	00007517          	auipc	a0,0x7
    80001320:	dec50513          	addi	a0,a0,-532 # 80008108 <etext+0x108>
    80001324:	fffff097          	auipc	ra,0xfffff
    80001328:	23a080e7          	jalr	570(ra) # 8000055e <panic>
      panic("uvmunmap: not a leaf");
    8000132c:	00007517          	auipc	a0,0x7
    80001330:	df450513          	addi	a0,a0,-524 # 80008120 <etext+0x120>
    80001334:	fffff097          	auipc	ra,0xfffff
    80001338:	22a080e7          	jalr	554(ra) # 8000055e <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    8000133c:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001340:	995a                	add	s2,s2,s6
    80001342:	03397c63          	bgeu	s2,s3,8000137a <uvmunmap+0xbe>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001346:	4601                	li	a2,0
    80001348:	85ca                	mv	a1,s2
    8000134a:	8552                	mv	a0,s4
    8000134c:	00000097          	auipc	ra,0x0
    80001350:	cc2080e7          	jalr	-830(ra) # 8000100e <walk>
    80001354:	84aa                	mv	s1,a0
    80001356:	d95d                	beqz	a0,8000130c <uvmunmap+0x50>
    if((*pte & PTE_V) == 0)
    80001358:	6108                	ld	a0,0(a0)
    8000135a:	00157793          	andi	a5,a0,1
    8000135e:	dfdd                	beqz	a5,8000131c <uvmunmap+0x60>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001360:	3ff57793          	andi	a5,a0,1023
    80001364:	fd7784e3          	beq	a5,s7,8000132c <uvmunmap+0x70>
    if(do_free){
    80001368:	fc0a8ae3          	beqz	s5,8000133c <uvmunmap+0x80>
      uint64 pa = PTE2PA(*pte);
    8000136c:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000136e:	0532                	slli	a0,a0,0xc
    80001370:	fffff097          	auipc	ra,0xfffff
    80001374:	6d8080e7          	jalr	1752(ra) # 80000a48 <kfree>
    80001378:	b7d1                	j	8000133c <uvmunmap+0x80>
    8000137a:	74e2                	ld	s1,56(sp)
    8000137c:	7942                	ld	s2,48(sp)
    8000137e:	79a2                	ld	s3,40(sp)
    80001380:	7a02                	ld	s4,32(sp)
    80001382:	6ae2                	ld	s5,24(sp)
    80001384:	6b42                	ld	s6,16(sp)
    80001386:	6ba2                	ld	s7,8(sp)
  }
}
    80001388:	60a6                	ld	ra,72(sp)
    8000138a:	6406                	ld	s0,64(sp)
    8000138c:	6161                	addi	sp,sp,80
    8000138e:	8082                	ret

0000000080001390 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001390:	1101                	addi	sp,sp,-32
    80001392:	ec06                	sd	ra,24(sp)
    80001394:	e822                	sd	s0,16(sp)
    80001396:	e426                	sd	s1,8(sp)
    80001398:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000139a:	fffff097          	auipc	ra,0xfffff
    8000139e:	7ac080e7          	jalr	1964(ra) # 80000b46 <kalloc>
    800013a2:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800013a4:	c519                	beqz	a0,800013b2 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800013a6:	6605                	lui	a2,0x1
    800013a8:	4581                	li	a1,0
    800013aa:	00000097          	auipc	ra,0x0
    800013ae:	988080e7          	jalr	-1656(ra) # 80000d32 <memset>
  return pagetable;
}
    800013b2:	8526                	mv	a0,s1
    800013b4:	60e2                	ld	ra,24(sp)
    800013b6:	6442                	ld	s0,16(sp)
    800013b8:	64a2                	ld	s1,8(sp)
    800013ba:	6105                	addi	sp,sp,32
    800013bc:	8082                	ret

00000000800013be <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    800013be:	7179                	addi	sp,sp,-48
    800013c0:	f406                	sd	ra,40(sp)
    800013c2:	f022                	sd	s0,32(sp)
    800013c4:	ec26                	sd	s1,24(sp)
    800013c6:	e84a                	sd	s2,16(sp)
    800013c8:	e44e                	sd	s3,8(sp)
    800013ca:	e052                	sd	s4,0(sp)
    800013cc:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800013ce:	6785                	lui	a5,0x1
    800013d0:	04f67863          	bgeu	a2,a5,80001420 <uvmfirst+0x62>
    800013d4:	8a2a                	mv	s4,a0
    800013d6:	89ae                	mv	s3,a1
    800013d8:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800013da:	fffff097          	auipc	ra,0xfffff
    800013de:	76c080e7          	jalr	1900(ra) # 80000b46 <kalloc>
    800013e2:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800013e4:	6605                	lui	a2,0x1
    800013e6:	4581                	li	a1,0
    800013e8:	00000097          	auipc	ra,0x0
    800013ec:	94a080e7          	jalr	-1718(ra) # 80000d32 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800013f0:	4779                	li	a4,30
    800013f2:	86ca                	mv	a3,s2
    800013f4:	6605                	lui	a2,0x1
    800013f6:	4581                	li	a1,0
    800013f8:	8552                	mv	a0,s4
    800013fa:	00000097          	auipc	ra,0x0
    800013fe:	cfc080e7          	jalr	-772(ra) # 800010f6 <mappages>
  memmove(mem, src, sz);
    80001402:	8626                	mv	a2,s1
    80001404:	85ce                	mv	a1,s3
    80001406:	854a                	mv	a0,s2
    80001408:	00000097          	auipc	ra,0x0
    8000140c:	986080e7          	jalr	-1658(ra) # 80000d8e <memmove>
}
    80001410:	70a2                	ld	ra,40(sp)
    80001412:	7402                	ld	s0,32(sp)
    80001414:	64e2                	ld	s1,24(sp)
    80001416:	6942                	ld	s2,16(sp)
    80001418:	69a2                	ld	s3,8(sp)
    8000141a:	6a02                	ld	s4,0(sp)
    8000141c:	6145                	addi	sp,sp,48
    8000141e:	8082                	ret
    panic("uvmfirst: more than a page");
    80001420:	00007517          	auipc	a0,0x7
    80001424:	d1850513          	addi	a0,a0,-744 # 80008138 <etext+0x138>
    80001428:	fffff097          	auipc	ra,0xfffff
    8000142c:	136080e7          	jalr	310(ra) # 8000055e <panic>

0000000080001430 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001430:	1101                	addi	sp,sp,-32
    80001432:	ec06                	sd	ra,24(sp)
    80001434:	e822                	sd	s0,16(sp)
    80001436:	e426                	sd	s1,8(sp)
    80001438:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000143a:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000143c:	00b67d63          	bgeu	a2,a1,80001456 <uvmdealloc+0x26>
    80001440:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001442:	6785                	lui	a5,0x1
    80001444:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001446:	00f60733          	add	a4,a2,a5
    8000144a:	76fd                	lui	a3,0xfffff
    8000144c:	8f75                	and	a4,a4,a3
    8000144e:	97ae                	add	a5,a5,a1
    80001450:	8ff5                	and	a5,a5,a3
    80001452:	00f76863          	bltu	a4,a5,80001462 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001456:	8526                	mv	a0,s1
    80001458:	60e2                	ld	ra,24(sp)
    8000145a:	6442                	ld	s0,16(sp)
    8000145c:	64a2                	ld	s1,8(sp)
    8000145e:	6105                	addi	sp,sp,32
    80001460:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001462:	8f99                	sub	a5,a5,a4
    80001464:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001466:	4685                	li	a3,1
    80001468:	0007861b          	sext.w	a2,a5
    8000146c:	85ba                	mv	a1,a4
    8000146e:	00000097          	auipc	ra,0x0
    80001472:	e4e080e7          	jalr	-434(ra) # 800012bc <uvmunmap>
    80001476:	b7c5                	j	80001456 <uvmdealloc+0x26>

0000000080001478 <uvmalloc>:
  if(newsz < oldsz)
    80001478:	0ab66b63          	bltu	a2,a1,8000152e <uvmalloc+0xb6>
{
    8000147c:	7139                	addi	sp,sp,-64
    8000147e:	fc06                	sd	ra,56(sp)
    80001480:	f822                	sd	s0,48(sp)
    80001482:	ec4e                	sd	s3,24(sp)
    80001484:	e852                	sd	s4,16(sp)
    80001486:	e456                	sd	s5,8(sp)
    80001488:	0080                	addi	s0,sp,64
    8000148a:	8aaa                	mv	s5,a0
    8000148c:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000148e:	6785                	lui	a5,0x1
    80001490:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001492:	95be                	add	a1,a1,a5
    80001494:	77fd                	lui	a5,0xfffff
    80001496:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000149a:	08c9fc63          	bgeu	s3,a2,80001532 <uvmalloc+0xba>
    8000149e:	f426                	sd	s1,40(sp)
    800014a0:	f04a                	sd	s2,32(sp)
    800014a2:	e05a                	sd	s6,0(sp)
    800014a4:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800014a6:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800014aa:	fffff097          	auipc	ra,0xfffff
    800014ae:	69c080e7          	jalr	1692(ra) # 80000b46 <kalloc>
    800014b2:	84aa                	mv	s1,a0
    if(mem == 0){
    800014b4:	c915                	beqz	a0,800014e8 <uvmalloc+0x70>
    memset(mem, 0, PGSIZE);
    800014b6:	6605                	lui	a2,0x1
    800014b8:	4581                	li	a1,0
    800014ba:	00000097          	auipc	ra,0x0
    800014be:	878080e7          	jalr	-1928(ra) # 80000d32 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800014c2:	875a                	mv	a4,s6
    800014c4:	86a6                	mv	a3,s1
    800014c6:	6605                	lui	a2,0x1
    800014c8:	85ca                	mv	a1,s2
    800014ca:	8556                	mv	a0,s5
    800014cc:	00000097          	auipc	ra,0x0
    800014d0:	c2a080e7          	jalr	-982(ra) # 800010f6 <mappages>
    800014d4:	ed05                	bnez	a0,8000150c <uvmalloc+0x94>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014d6:	6785                	lui	a5,0x1
    800014d8:	993e                	add	s2,s2,a5
    800014da:	fd4968e3          	bltu	s2,s4,800014aa <uvmalloc+0x32>
  return newsz;
    800014de:	8552                	mv	a0,s4
    800014e0:	74a2                	ld	s1,40(sp)
    800014e2:	7902                	ld	s2,32(sp)
    800014e4:	6b02                	ld	s6,0(sp)
    800014e6:	a821                	j	800014fe <uvmalloc+0x86>
      uvmdealloc(pagetable, a, oldsz);
    800014e8:	864e                	mv	a2,s3
    800014ea:	85ca                	mv	a1,s2
    800014ec:	8556                	mv	a0,s5
    800014ee:	00000097          	auipc	ra,0x0
    800014f2:	f42080e7          	jalr	-190(ra) # 80001430 <uvmdealloc>
      return 0;
    800014f6:	4501                	li	a0,0
    800014f8:	74a2                	ld	s1,40(sp)
    800014fa:	7902                	ld	s2,32(sp)
    800014fc:	6b02                	ld	s6,0(sp)
}
    800014fe:	70e2                	ld	ra,56(sp)
    80001500:	7442                	ld	s0,48(sp)
    80001502:	69e2                	ld	s3,24(sp)
    80001504:	6a42                	ld	s4,16(sp)
    80001506:	6aa2                	ld	s5,8(sp)
    80001508:	6121                	addi	sp,sp,64
    8000150a:	8082                	ret
      kfree(mem);
    8000150c:	8526                	mv	a0,s1
    8000150e:	fffff097          	auipc	ra,0xfffff
    80001512:	53a080e7          	jalr	1338(ra) # 80000a48 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001516:	864e                	mv	a2,s3
    80001518:	85ca                	mv	a1,s2
    8000151a:	8556                	mv	a0,s5
    8000151c:	00000097          	auipc	ra,0x0
    80001520:	f14080e7          	jalr	-236(ra) # 80001430 <uvmdealloc>
      return 0;
    80001524:	4501                	li	a0,0
    80001526:	74a2                	ld	s1,40(sp)
    80001528:	7902                	ld	s2,32(sp)
    8000152a:	6b02                	ld	s6,0(sp)
    8000152c:	bfc9                	j	800014fe <uvmalloc+0x86>
    return oldsz;
    8000152e:	852e                	mv	a0,a1
}
    80001530:	8082                	ret
  return newsz;
    80001532:	8532                	mv	a0,a2
    80001534:	b7e9                	j	800014fe <uvmalloc+0x86>

0000000080001536 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001536:	7179                	addi	sp,sp,-48
    80001538:	f406                	sd	ra,40(sp)
    8000153a:	f022                	sd	s0,32(sp)
    8000153c:	ec26                	sd	s1,24(sp)
    8000153e:	e84a                	sd	s2,16(sp)
    80001540:	e44e                	sd	s3,8(sp)
    80001542:	e052                	sd	s4,0(sp)
    80001544:	1800                	addi	s0,sp,48
    80001546:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001548:	84aa                	mv	s1,a0
    8000154a:	6905                	lui	s2,0x1
    8000154c:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000154e:	4985                	li	s3,1
    80001550:	a829                	j	8000156a <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001552:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001554:	00c79513          	slli	a0,a5,0xc
    80001558:	00000097          	auipc	ra,0x0
    8000155c:	fde080e7          	jalr	-34(ra) # 80001536 <freewalk>
      pagetable[i] = 0;
    80001560:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001564:	04a1                	addi	s1,s1,8
    80001566:	03248163          	beq	s1,s2,80001588 <freewalk+0x52>
    pte_t pte = pagetable[i];
    8000156a:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000156c:	00f7f713          	andi	a4,a5,15
    80001570:	ff3701e3          	beq	a4,s3,80001552 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001574:	8b85                	andi	a5,a5,1
    80001576:	d7fd                	beqz	a5,80001564 <freewalk+0x2e>
      panic("freewalk: leaf");
    80001578:	00007517          	auipc	a0,0x7
    8000157c:	be050513          	addi	a0,a0,-1056 # 80008158 <etext+0x158>
    80001580:	fffff097          	auipc	ra,0xfffff
    80001584:	fde080e7          	jalr	-34(ra) # 8000055e <panic>
    }
  }
  kfree((void*)pagetable);
    80001588:	8552                	mv	a0,s4
    8000158a:	fffff097          	auipc	ra,0xfffff
    8000158e:	4be080e7          	jalr	1214(ra) # 80000a48 <kfree>
}
    80001592:	70a2                	ld	ra,40(sp)
    80001594:	7402                	ld	s0,32(sp)
    80001596:	64e2                	ld	s1,24(sp)
    80001598:	6942                	ld	s2,16(sp)
    8000159a:	69a2                	ld	s3,8(sp)
    8000159c:	6a02                	ld	s4,0(sp)
    8000159e:	6145                	addi	sp,sp,48
    800015a0:	8082                	ret

00000000800015a2 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800015a2:	1101                	addi	sp,sp,-32
    800015a4:	ec06                	sd	ra,24(sp)
    800015a6:	e822                	sd	s0,16(sp)
    800015a8:	e426                	sd	s1,8(sp)
    800015aa:	1000                	addi	s0,sp,32
    800015ac:	84aa                	mv	s1,a0
  if(sz > 0)
    800015ae:	e999                	bnez	a1,800015c4 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800015b0:	8526                	mv	a0,s1
    800015b2:	00000097          	auipc	ra,0x0
    800015b6:	f84080e7          	jalr	-124(ra) # 80001536 <freewalk>
}
    800015ba:	60e2                	ld	ra,24(sp)
    800015bc:	6442                	ld	s0,16(sp)
    800015be:	64a2                	ld	s1,8(sp)
    800015c0:	6105                	addi	sp,sp,32
    800015c2:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800015c4:	6785                	lui	a5,0x1
    800015c6:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800015c8:	95be                	add	a1,a1,a5
    800015ca:	4685                	li	a3,1
    800015cc:	00c5d613          	srli	a2,a1,0xc
    800015d0:	4581                	li	a1,0
    800015d2:	00000097          	auipc	ra,0x0
    800015d6:	cea080e7          	jalr	-790(ra) # 800012bc <uvmunmap>
    800015da:	bfd9                	j	800015b0 <uvmfree+0xe>

00000000800015dc <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800015dc:	c679                	beqz	a2,800016aa <uvmcopy+0xce>
{
    800015de:	715d                	addi	sp,sp,-80
    800015e0:	e486                	sd	ra,72(sp)
    800015e2:	e0a2                	sd	s0,64(sp)
    800015e4:	fc26                	sd	s1,56(sp)
    800015e6:	f84a                	sd	s2,48(sp)
    800015e8:	f44e                	sd	s3,40(sp)
    800015ea:	f052                	sd	s4,32(sp)
    800015ec:	ec56                	sd	s5,24(sp)
    800015ee:	e85a                	sd	s6,16(sp)
    800015f0:	e45e                	sd	s7,8(sp)
    800015f2:	0880                	addi	s0,sp,80
    800015f4:	8b2a                	mv	s6,a0
    800015f6:	8aae                	mv	s5,a1
    800015f8:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800015fa:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800015fc:	4601                	li	a2,0
    800015fe:	85ce                	mv	a1,s3
    80001600:	855a                	mv	a0,s6
    80001602:	00000097          	auipc	ra,0x0
    80001606:	a0c080e7          	jalr	-1524(ra) # 8000100e <walk>
    8000160a:	c531                	beqz	a0,80001656 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000160c:	6118                	ld	a4,0(a0)
    8000160e:	00177793          	andi	a5,a4,1
    80001612:	cbb1                	beqz	a5,80001666 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001614:	00a75593          	srli	a1,a4,0xa
    80001618:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000161c:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001620:	fffff097          	auipc	ra,0xfffff
    80001624:	526080e7          	jalr	1318(ra) # 80000b46 <kalloc>
    80001628:	892a                	mv	s2,a0
    8000162a:	c939                	beqz	a0,80001680 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000162c:	6605                	lui	a2,0x1
    8000162e:	85de                	mv	a1,s7
    80001630:	fffff097          	auipc	ra,0xfffff
    80001634:	75e080e7          	jalr	1886(ra) # 80000d8e <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001638:	8726                	mv	a4,s1
    8000163a:	86ca                	mv	a3,s2
    8000163c:	6605                	lui	a2,0x1
    8000163e:	85ce                	mv	a1,s3
    80001640:	8556                	mv	a0,s5
    80001642:	00000097          	auipc	ra,0x0
    80001646:	ab4080e7          	jalr	-1356(ra) # 800010f6 <mappages>
    8000164a:	e515                	bnez	a0,80001676 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    8000164c:	6785                	lui	a5,0x1
    8000164e:	99be                	add	s3,s3,a5
    80001650:	fb49e6e3          	bltu	s3,s4,800015fc <uvmcopy+0x20>
    80001654:	a081                	j	80001694 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80001656:	00007517          	auipc	a0,0x7
    8000165a:	b1250513          	addi	a0,a0,-1262 # 80008168 <etext+0x168>
    8000165e:	fffff097          	auipc	ra,0xfffff
    80001662:	f00080e7          	jalr	-256(ra) # 8000055e <panic>
      panic("uvmcopy: page not present");
    80001666:	00007517          	auipc	a0,0x7
    8000166a:	b2250513          	addi	a0,a0,-1246 # 80008188 <etext+0x188>
    8000166e:	fffff097          	auipc	ra,0xfffff
    80001672:	ef0080e7          	jalr	-272(ra) # 8000055e <panic>
      kfree(mem);
    80001676:	854a                	mv	a0,s2
    80001678:	fffff097          	auipc	ra,0xfffff
    8000167c:	3d0080e7          	jalr	976(ra) # 80000a48 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001680:	4685                	li	a3,1
    80001682:	00c9d613          	srli	a2,s3,0xc
    80001686:	4581                	li	a1,0
    80001688:	8556                	mv	a0,s5
    8000168a:	00000097          	auipc	ra,0x0
    8000168e:	c32080e7          	jalr	-974(ra) # 800012bc <uvmunmap>
  return -1;
    80001692:	557d                	li	a0,-1
}
    80001694:	60a6                	ld	ra,72(sp)
    80001696:	6406                	ld	s0,64(sp)
    80001698:	74e2                	ld	s1,56(sp)
    8000169a:	7942                	ld	s2,48(sp)
    8000169c:	79a2                	ld	s3,40(sp)
    8000169e:	7a02                	ld	s4,32(sp)
    800016a0:	6ae2                	ld	s5,24(sp)
    800016a2:	6b42                	ld	s6,16(sp)
    800016a4:	6ba2                	ld	s7,8(sp)
    800016a6:	6161                	addi	sp,sp,80
    800016a8:	8082                	ret
  return 0;
    800016aa:	4501                	li	a0,0
}
    800016ac:	8082                	ret

00000000800016ae <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800016ae:	1141                	addi	sp,sp,-16
    800016b0:	e406                	sd	ra,8(sp)
    800016b2:	e022                	sd	s0,0(sp)
    800016b4:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800016b6:	4601                	li	a2,0
    800016b8:	00000097          	auipc	ra,0x0
    800016bc:	956080e7          	jalr	-1706(ra) # 8000100e <walk>
  if(pte == 0)
    800016c0:	c901                	beqz	a0,800016d0 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800016c2:	611c                	ld	a5,0(a0)
    800016c4:	9bbd                	andi	a5,a5,-17
    800016c6:	e11c                	sd	a5,0(a0)
}
    800016c8:	60a2                	ld	ra,8(sp)
    800016ca:	6402                	ld	s0,0(sp)
    800016cc:	0141                	addi	sp,sp,16
    800016ce:	8082                	ret
    panic("uvmclear");
    800016d0:	00007517          	auipc	a0,0x7
    800016d4:	ad850513          	addi	a0,a0,-1320 # 800081a8 <etext+0x1a8>
    800016d8:	fffff097          	auipc	ra,0xfffff
    800016dc:	e86080e7          	jalr	-378(ra) # 8000055e <panic>

00000000800016e0 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016e0:	c6bd                	beqz	a3,8000174e <copyout+0x6e>
{
    800016e2:	715d                	addi	sp,sp,-80
    800016e4:	e486                	sd	ra,72(sp)
    800016e6:	e0a2                	sd	s0,64(sp)
    800016e8:	fc26                	sd	s1,56(sp)
    800016ea:	f84a                	sd	s2,48(sp)
    800016ec:	f44e                	sd	s3,40(sp)
    800016ee:	f052                	sd	s4,32(sp)
    800016f0:	ec56                	sd	s5,24(sp)
    800016f2:	e85a                	sd	s6,16(sp)
    800016f4:	e45e                	sd	s7,8(sp)
    800016f6:	e062                	sd	s8,0(sp)
    800016f8:	0880                	addi	s0,sp,80
    800016fa:	8b2a                	mv	s6,a0
    800016fc:	8c2e                	mv	s8,a1
    800016fe:	8a32                	mv	s4,a2
    80001700:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001702:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001704:	6a85                	lui	s5,0x1
    80001706:	a015                	j	8000172a <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001708:	9562                	add	a0,a0,s8
    8000170a:	0004861b          	sext.w	a2,s1
    8000170e:	85d2                	mv	a1,s4
    80001710:	41250533          	sub	a0,a0,s2
    80001714:	fffff097          	auipc	ra,0xfffff
    80001718:	67a080e7          	jalr	1658(ra) # 80000d8e <memmove>

    len -= n;
    8000171c:	409989b3          	sub	s3,s3,s1
    src += n;
    80001720:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001722:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001726:	02098263          	beqz	s3,8000174a <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    8000172a:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000172e:	85ca                	mv	a1,s2
    80001730:	855a                	mv	a0,s6
    80001732:	00000097          	auipc	ra,0x0
    80001736:	982080e7          	jalr	-1662(ra) # 800010b4 <walkaddr>
    if(pa0 == 0)
    8000173a:	cd01                	beqz	a0,80001752 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    8000173c:	418904b3          	sub	s1,s2,s8
    80001740:	94d6                	add	s1,s1,s5
    if(n > len)
    80001742:	fc99f3e3          	bgeu	s3,s1,80001708 <copyout+0x28>
    80001746:	84ce                	mv	s1,s3
    80001748:	b7c1                	j	80001708 <copyout+0x28>
  }
  return 0;
    8000174a:	4501                	li	a0,0
    8000174c:	a021                	j	80001754 <copyout+0x74>
    8000174e:	4501                	li	a0,0
}
    80001750:	8082                	ret
      return -1;
    80001752:	557d                	li	a0,-1
}
    80001754:	60a6                	ld	ra,72(sp)
    80001756:	6406                	ld	s0,64(sp)
    80001758:	74e2                	ld	s1,56(sp)
    8000175a:	7942                	ld	s2,48(sp)
    8000175c:	79a2                	ld	s3,40(sp)
    8000175e:	7a02                	ld	s4,32(sp)
    80001760:	6ae2                	ld	s5,24(sp)
    80001762:	6b42                	ld	s6,16(sp)
    80001764:	6ba2                	ld	s7,8(sp)
    80001766:	6c02                	ld	s8,0(sp)
    80001768:	6161                	addi	sp,sp,80
    8000176a:	8082                	ret

000000008000176c <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000176c:	caa5                	beqz	a3,800017dc <copyin+0x70>
{
    8000176e:	715d                	addi	sp,sp,-80
    80001770:	e486                	sd	ra,72(sp)
    80001772:	e0a2                	sd	s0,64(sp)
    80001774:	fc26                	sd	s1,56(sp)
    80001776:	f84a                	sd	s2,48(sp)
    80001778:	f44e                	sd	s3,40(sp)
    8000177a:	f052                	sd	s4,32(sp)
    8000177c:	ec56                	sd	s5,24(sp)
    8000177e:	e85a                	sd	s6,16(sp)
    80001780:	e45e                	sd	s7,8(sp)
    80001782:	e062                	sd	s8,0(sp)
    80001784:	0880                	addi	s0,sp,80
    80001786:	8b2a                	mv	s6,a0
    80001788:	8a2e                	mv	s4,a1
    8000178a:	8c32                	mv	s8,a2
    8000178c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000178e:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001790:	6a85                	lui	s5,0x1
    80001792:	a01d                	j	800017b8 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001794:	018505b3          	add	a1,a0,s8
    80001798:	0004861b          	sext.w	a2,s1
    8000179c:	412585b3          	sub	a1,a1,s2
    800017a0:	8552                	mv	a0,s4
    800017a2:	fffff097          	auipc	ra,0xfffff
    800017a6:	5ec080e7          	jalr	1516(ra) # 80000d8e <memmove>

    len -= n;
    800017aa:	409989b3          	sub	s3,s3,s1
    dst += n;
    800017ae:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800017b0:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800017b4:	02098263          	beqz	s3,800017d8 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800017b8:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800017bc:	85ca                	mv	a1,s2
    800017be:	855a                	mv	a0,s6
    800017c0:	00000097          	auipc	ra,0x0
    800017c4:	8f4080e7          	jalr	-1804(ra) # 800010b4 <walkaddr>
    if(pa0 == 0)
    800017c8:	cd01                	beqz	a0,800017e0 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    800017ca:	418904b3          	sub	s1,s2,s8
    800017ce:	94d6                	add	s1,s1,s5
    if(n > len)
    800017d0:	fc99f2e3          	bgeu	s3,s1,80001794 <copyin+0x28>
    800017d4:	84ce                	mv	s1,s3
    800017d6:	bf7d                	j	80001794 <copyin+0x28>
  }
  return 0;
    800017d8:	4501                	li	a0,0
    800017da:	a021                	j	800017e2 <copyin+0x76>
    800017dc:	4501                	li	a0,0
}
    800017de:	8082                	ret
      return -1;
    800017e0:	557d                	li	a0,-1
}
    800017e2:	60a6                	ld	ra,72(sp)
    800017e4:	6406                	ld	s0,64(sp)
    800017e6:	74e2                	ld	s1,56(sp)
    800017e8:	7942                	ld	s2,48(sp)
    800017ea:	79a2                	ld	s3,40(sp)
    800017ec:	7a02                	ld	s4,32(sp)
    800017ee:	6ae2                	ld	s5,24(sp)
    800017f0:	6b42                	ld	s6,16(sp)
    800017f2:	6ba2                	ld	s7,8(sp)
    800017f4:	6c02                	ld	s8,0(sp)
    800017f6:	6161                	addi	sp,sp,80
    800017f8:	8082                	ret

00000000800017fa <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800017fa:	cacd                	beqz	a3,800018ac <copyinstr+0xb2>
{
    800017fc:	715d                	addi	sp,sp,-80
    800017fe:	e486                	sd	ra,72(sp)
    80001800:	e0a2                	sd	s0,64(sp)
    80001802:	fc26                	sd	s1,56(sp)
    80001804:	f84a                	sd	s2,48(sp)
    80001806:	f44e                	sd	s3,40(sp)
    80001808:	f052                	sd	s4,32(sp)
    8000180a:	ec56                	sd	s5,24(sp)
    8000180c:	e85a                	sd	s6,16(sp)
    8000180e:	e45e                	sd	s7,8(sp)
    80001810:	0880                	addi	s0,sp,80
    80001812:	8a2a                	mv	s4,a0
    80001814:	8b2e                	mv	s6,a1
    80001816:	8bb2                	mv	s7,a2
    80001818:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    8000181a:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000181c:	6985                	lui	s3,0x1
    8000181e:	a825                	j	80001856 <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001820:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001824:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001826:	37fd                	addiw	a5,a5,-1
    80001828:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000182c:	60a6                	ld	ra,72(sp)
    8000182e:	6406                	ld	s0,64(sp)
    80001830:	74e2                	ld	s1,56(sp)
    80001832:	7942                	ld	s2,48(sp)
    80001834:	79a2                	ld	s3,40(sp)
    80001836:	7a02                	ld	s4,32(sp)
    80001838:	6ae2                	ld	s5,24(sp)
    8000183a:	6b42                	ld	s6,16(sp)
    8000183c:	6ba2                	ld	s7,8(sp)
    8000183e:	6161                	addi	sp,sp,80
    80001840:	8082                	ret
    80001842:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    80001846:	9742                	add	a4,a4,a6
      --max;
    80001848:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    8000184c:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    80001850:	04e58663          	beq	a1,a4,8000189c <copyinstr+0xa2>
{
    80001854:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    80001856:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000185a:	85a6                	mv	a1,s1
    8000185c:	8552                	mv	a0,s4
    8000185e:	00000097          	auipc	ra,0x0
    80001862:	856080e7          	jalr	-1962(ra) # 800010b4 <walkaddr>
    if(pa0 == 0)
    80001866:	cd0d                	beqz	a0,800018a0 <copyinstr+0xa6>
    n = PGSIZE - (srcva - va0);
    80001868:	417486b3          	sub	a3,s1,s7
    8000186c:	96ce                	add	a3,a3,s3
    if(n > max)
    8000186e:	00d97363          	bgeu	s2,a3,80001874 <copyinstr+0x7a>
    80001872:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    80001874:	955e                	add	a0,a0,s7
    80001876:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80001878:	c695                	beqz	a3,800018a4 <copyinstr+0xaa>
    8000187a:	87da                	mv	a5,s6
    8000187c:	885a                	mv	a6,s6
      if(*p == '\0'){
    8000187e:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80001882:	96da                	add	a3,a3,s6
    80001884:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001886:	00f60733          	add	a4,a2,a5
    8000188a:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdd0c0>
    8000188e:	db49                	beqz	a4,80001820 <copyinstr+0x26>
        *dst = *p;
    80001890:	00e78023          	sb	a4,0(a5)
      dst++;
    80001894:	0785                	addi	a5,a5,1
    while(n > 0){
    80001896:	fed797e3          	bne	a5,a3,80001884 <copyinstr+0x8a>
    8000189a:	b765                	j	80001842 <copyinstr+0x48>
    8000189c:	4781                	li	a5,0
    8000189e:	b761                	j	80001826 <copyinstr+0x2c>
      return -1;
    800018a0:	557d                	li	a0,-1
    800018a2:	b769                	j	8000182c <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    800018a4:	6b85                	lui	s7,0x1
    800018a6:	9ba6                	add	s7,s7,s1
    800018a8:	87da                	mv	a5,s6
    800018aa:	b76d                	j	80001854 <copyinstr+0x5a>
  int got_null = 0;
    800018ac:	4781                	li	a5,0
  if(got_null){
    800018ae:	37fd                	addiw	a5,a5,-1
    800018b0:	0007851b          	sext.w	a0,a5
}
    800018b4:	8082                	ret

00000000800018b6 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800018b6:	7139                	addi	sp,sp,-64
    800018b8:	fc06                	sd	ra,56(sp)
    800018ba:	f822                	sd	s0,48(sp)
    800018bc:	f426                	sd	s1,40(sp)
    800018be:	f04a                	sd	s2,32(sp)
    800018c0:	ec4e                	sd	s3,24(sp)
    800018c2:	e852                	sd	s4,16(sp)
    800018c4:	e456                	sd	s5,8(sp)
    800018c6:	e05a                	sd	s6,0(sp)
    800018c8:	0080                	addi	s0,sp,64
    800018ca:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800018cc:	0000f497          	auipc	s1,0xf
    800018d0:	69448493          	addi	s1,s1,1684 # 80010f60 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800018d4:	8b26                	mv	s6,s1
    800018d6:	ff4df937          	lui	s2,0xff4df
    800018da:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bca7d>
    800018de:	0936                	slli	s2,s2,0xd
    800018e0:	6f590913          	addi	s2,s2,1781
    800018e4:	0936                	slli	s2,s2,0xd
    800018e6:	bd390913          	addi	s2,s2,-1069
    800018ea:	0932                	slli	s2,s2,0xc
    800018ec:	7a790913          	addi	s2,s2,1959
    800018f0:	040009b7          	lui	s3,0x4000
    800018f4:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800018f6:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800018f8:	00015a97          	auipc	s5,0x15
    800018fc:	268a8a93          	addi	s5,s5,616 # 80016b60 <tickslock>
    char *pa = kalloc();
    80001900:	fffff097          	auipc	ra,0xfffff
    80001904:	246080e7          	jalr	582(ra) # 80000b46 <kalloc>
    80001908:	862a                	mv	a2,a0
    if(pa == 0)
    8000190a:	c121                	beqz	a0,8000194a <proc_mapstacks+0x94>
    uint64 va = KSTACK((int) (p - proc));
    8000190c:	416485b3          	sub	a1,s1,s6
    80001910:	8591                	srai	a1,a1,0x4
    80001912:	032585b3          	mul	a1,a1,s2
    80001916:	2585                	addiw	a1,a1,1
    80001918:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000191c:	4719                	li	a4,6
    8000191e:	6685                	lui	a3,0x1
    80001920:	40b985b3          	sub	a1,s3,a1
    80001924:	8552                	mv	a0,s4
    80001926:	00000097          	auipc	ra,0x0
    8000192a:	870080e7          	jalr	-1936(ra) # 80001196 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000192e:	17048493          	addi	s1,s1,368
    80001932:	fd5497e3          	bne	s1,s5,80001900 <proc_mapstacks+0x4a>
  }
}
    80001936:	70e2                	ld	ra,56(sp)
    80001938:	7442                	ld	s0,48(sp)
    8000193a:	74a2                	ld	s1,40(sp)
    8000193c:	7902                	ld	s2,32(sp)
    8000193e:	69e2                	ld	s3,24(sp)
    80001940:	6a42                	ld	s4,16(sp)
    80001942:	6aa2                	ld	s5,8(sp)
    80001944:	6b02                	ld	s6,0(sp)
    80001946:	6121                	addi	sp,sp,64
    80001948:	8082                	ret
      panic("kalloc");
    8000194a:	00007517          	auipc	a0,0x7
    8000194e:	86e50513          	addi	a0,a0,-1938 # 800081b8 <etext+0x1b8>
    80001952:	fffff097          	auipc	ra,0xfffff
    80001956:	c0c080e7          	jalr	-1012(ra) # 8000055e <panic>

000000008000195a <procinit>:

// initialize the proc table.
void
procinit(void)
{
    8000195a:	7139                	addi	sp,sp,-64
    8000195c:	fc06                	sd	ra,56(sp)
    8000195e:	f822                	sd	s0,48(sp)
    80001960:	f426                	sd	s1,40(sp)
    80001962:	f04a                	sd	s2,32(sp)
    80001964:	ec4e                	sd	s3,24(sp)
    80001966:	e852                	sd	s4,16(sp)
    80001968:	e456                	sd	s5,8(sp)
    8000196a:	e05a                	sd	s6,0(sp)
    8000196c:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    8000196e:	00007597          	auipc	a1,0x7
    80001972:	85258593          	addi	a1,a1,-1966 # 800081c0 <etext+0x1c0>
    80001976:	0000f517          	auipc	a0,0xf
    8000197a:	1ba50513          	addi	a0,a0,442 # 80010b30 <pid_lock>
    8000197e:	fffff097          	auipc	ra,0xfffff
    80001982:	228080e7          	jalr	552(ra) # 80000ba6 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001986:	00007597          	auipc	a1,0x7
    8000198a:	84258593          	addi	a1,a1,-1982 # 800081c8 <etext+0x1c8>
    8000198e:	0000f517          	auipc	a0,0xf
    80001992:	1ba50513          	addi	a0,a0,442 # 80010b48 <wait_lock>
    80001996:	fffff097          	auipc	ra,0xfffff
    8000199a:	210080e7          	jalr	528(ra) # 80000ba6 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000199e:	0000f497          	auipc	s1,0xf
    800019a2:	5c248493          	addi	s1,s1,1474 # 80010f60 <proc>
      initlock(&p->lock, "proc");
    800019a6:	00007b17          	auipc	s6,0x7
    800019aa:	832b0b13          	addi	s6,s6,-1998 # 800081d8 <etext+0x1d8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    800019ae:	8aa6                	mv	s5,s1
    800019b0:	ff4df937          	lui	s2,0xff4df
    800019b4:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bca7d>
    800019b8:	0936                	slli	s2,s2,0xd
    800019ba:	6f590913          	addi	s2,s2,1781
    800019be:	0936                	slli	s2,s2,0xd
    800019c0:	bd390913          	addi	s2,s2,-1069
    800019c4:	0932                	slli	s2,s2,0xc
    800019c6:	7a790913          	addi	s2,s2,1959
    800019ca:	040009b7          	lui	s3,0x4000
    800019ce:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800019d0:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800019d2:	00015a17          	auipc	s4,0x15
    800019d6:	18ea0a13          	addi	s4,s4,398 # 80016b60 <tickslock>
      initlock(&p->lock, "proc");
    800019da:	85da                	mv	a1,s6
    800019dc:	8526                	mv	a0,s1
    800019de:	fffff097          	auipc	ra,0xfffff
    800019e2:	1c8080e7          	jalr	456(ra) # 80000ba6 <initlock>
      p->state = UNUSED;
    800019e6:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    800019ea:	415487b3          	sub	a5,s1,s5
    800019ee:	8791                	srai	a5,a5,0x4
    800019f0:	032787b3          	mul	a5,a5,s2
    800019f4:	2785                	addiw	a5,a5,1
    800019f6:	00d7979b          	slliw	a5,a5,0xd
    800019fa:	40f987b3          	sub	a5,s3,a5
    800019fe:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a00:	17048493          	addi	s1,s1,368
    80001a04:	fd449be3          	bne	s1,s4,800019da <procinit+0x80>
  }
}
    80001a08:	70e2                	ld	ra,56(sp)
    80001a0a:	7442                	ld	s0,48(sp)
    80001a0c:	74a2                	ld	s1,40(sp)
    80001a0e:	7902                	ld	s2,32(sp)
    80001a10:	69e2                	ld	s3,24(sp)
    80001a12:	6a42                	ld	s4,16(sp)
    80001a14:	6aa2                	ld	s5,8(sp)
    80001a16:	6b02                	ld	s6,0(sp)
    80001a18:	6121                	addi	sp,sp,64
    80001a1a:	8082                	ret

0000000080001a1c <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001a1c:	1141                	addi	sp,sp,-16
    80001a1e:	e422                	sd	s0,8(sp)
    80001a20:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a22:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001a24:	2501                	sext.w	a0,a0
    80001a26:	6422                	ld	s0,8(sp)
    80001a28:	0141                	addi	sp,sp,16
    80001a2a:	8082                	ret

0000000080001a2c <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001a2c:	1141                	addi	sp,sp,-16
    80001a2e:	e422                	sd	s0,8(sp)
    80001a30:	0800                	addi	s0,sp,16
    80001a32:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001a34:	2781                	sext.w	a5,a5
    80001a36:	079e                	slli	a5,a5,0x7
  return c;
}
    80001a38:	0000f517          	auipc	a0,0xf
    80001a3c:	12850513          	addi	a0,a0,296 # 80010b60 <cpus>
    80001a40:	953e                	add	a0,a0,a5
    80001a42:	6422                	ld	s0,8(sp)
    80001a44:	0141                	addi	sp,sp,16
    80001a46:	8082                	ret

0000000080001a48 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001a48:	1101                	addi	sp,sp,-32
    80001a4a:	ec06                	sd	ra,24(sp)
    80001a4c:	e822                	sd	s0,16(sp)
    80001a4e:	e426                	sd	s1,8(sp)
    80001a50:	1000                	addi	s0,sp,32
  push_off();
    80001a52:	fffff097          	auipc	ra,0xfffff
    80001a56:	198080e7          	jalr	408(ra) # 80000bea <push_off>
    80001a5a:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001a5c:	2781                	sext.w	a5,a5
    80001a5e:	079e                	slli	a5,a5,0x7
    80001a60:	0000f717          	auipc	a4,0xf
    80001a64:	0d070713          	addi	a4,a4,208 # 80010b30 <pid_lock>
    80001a68:	97ba                	add	a5,a5,a4
    80001a6a:	7b84                	ld	s1,48(a5)
  pop_off();
    80001a6c:	fffff097          	auipc	ra,0xfffff
    80001a70:	21e080e7          	jalr	542(ra) # 80000c8a <pop_off>
  return p;
}
    80001a74:	8526                	mv	a0,s1
    80001a76:	60e2                	ld	ra,24(sp)
    80001a78:	6442                	ld	s0,16(sp)
    80001a7a:	64a2                	ld	s1,8(sp)
    80001a7c:	6105                	addi	sp,sp,32
    80001a7e:	8082                	ret

0000000080001a80 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001a80:	1141                	addi	sp,sp,-16
    80001a82:	e406                	sd	ra,8(sp)
    80001a84:	e022                	sd	s0,0(sp)
    80001a86:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a88:	00000097          	auipc	ra,0x0
    80001a8c:	fc0080e7          	jalr	-64(ra) # 80001a48 <myproc>
    80001a90:	fffff097          	auipc	ra,0xfffff
    80001a94:	25a080e7          	jalr	602(ra) # 80000cea <release>

  if (first) {
    80001a98:	00007797          	auipc	a5,0x7
    80001a9c:	da87a783          	lw	a5,-600(a5) # 80008840 <first.1>
    80001aa0:	eb89                	bnez	a5,80001ab2 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001aa2:	00001097          	auipc	ra,0x1
    80001aa6:	cc4080e7          	jalr	-828(ra) # 80002766 <usertrapret>
}
    80001aaa:	60a2                	ld	ra,8(sp)
    80001aac:	6402                	ld	s0,0(sp)
    80001aae:	0141                	addi	sp,sp,16
    80001ab0:	8082                	ret
    first = 0;
    80001ab2:	00007797          	auipc	a5,0x7
    80001ab6:	d807a723          	sw	zero,-626(a5) # 80008840 <first.1>
    fsinit(ROOTDEV);
    80001aba:	4505                	li	a0,1
    80001abc:	00002097          	auipc	ra,0x2
    80001ac0:	a18080e7          	jalr	-1512(ra) # 800034d4 <fsinit>
    80001ac4:	bff9                	j	80001aa2 <forkret+0x22>

0000000080001ac6 <allocpid>:
{
    80001ac6:	1101                	addi	sp,sp,-32
    80001ac8:	ec06                	sd	ra,24(sp)
    80001aca:	e822                	sd	s0,16(sp)
    80001acc:	e426                	sd	s1,8(sp)
    80001ace:	e04a                	sd	s2,0(sp)
    80001ad0:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001ad2:	0000f917          	auipc	s2,0xf
    80001ad6:	05e90913          	addi	s2,s2,94 # 80010b30 <pid_lock>
    80001ada:	854a                	mv	a0,s2
    80001adc:	fffff097          	auipc	ra,0xfffff
    80001ae0:	15a080e7          	jalr	346(ra) # 80000c36 <acquire>
  pid = nextpid;
    80001ae4:	00007797          	auipc	a5,0x7
    80001ae8:	d6078793          	addi	a5,a5,-672 # 80008844 <nextpid>
    80001aec:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001aee:	0014871b          	addiw	a4,s1,1
    80001af2:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001af4:	854a                	mv	a0,s2
    80001af6:	fffff097          	auipc	ra,0xfffff
    80001afa:	1f4080e7          	jalr	500(ra) # 80000cea <release>
}
    80001afe:	8526                	mv	a0,s1
    80001b00:	60e2                	ld	ra,24(sp)
    80001b02:	6442                	ld	s0,16(sp)
    80001b04:	64a2                	ld	s1,8(sp)
    80001b06:	6902                	ld	s2,0(sp)
    80001b08:	6105                	addi	sp,sp,32
    80001b0a:	8082                	ret

0000000080001b0c <proc_pagetable>:
{
    80001b0c:	1101                	addi	sp,sp,-32
    80001b0e:	ec06                	sd	ra,24(sp)
    80001b10:	e822                	sd	s0,16(sp)
    80001b12:	e426                	sd	s1,8(sp)
    80001b14:	e04a                	sd	s2,0(sp)
    80001b16:	1000                	addi	s0,sp,32
    80001b18:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b1a:	00000097          	auipc	ra,0x0
    80001b1e:	876080e7          	jalr	-1930(ra) # 80001390 <uvmcreate>
    80001b22:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001b24:	c121                	beqz	a0,80001b64 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b26:	4729                	li	a4,10
    80001b28:	00005697          	auipc	a3,0x5
    80001b2c:	4d868693          	addi	a3,a3,1240 # 80007000 <_trampoline>
    80001b30:	6605                	lui	a2,0x1
    80001b32:	040005b7          	lui	a1,0x4000
    80001b36:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b38:	05b2                	slli	a1,a1,0xc
    80001b3a:	fffff097          	auipc	ra,0xfffff
    80001b3e:	5bc080e7          	jalr	1468(ra) # 800010f6 <mappages>
    80001b42:	02054863          	bltz	a0,80001b72 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b46:	4719                	li	a4,6
    80001b48:	05893683          	ld	a3,88(s2)
    80001b4c:	6605                	lui	a2,0x1
    80001b4e:	020005b7          	lui	a1,0x2000
    80001b52:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b54:	05b6                	slli	a1,a1,0xd
    80001b56:	8526                	mv	a0,s1
    80001b58:	fffff097          	auipc	ra,0xfffff
    80001b5c:	59e080e7          	jalr	1438(ra) # 800010f6 <mappages>
    80001b60:	02054163          	bltz	a0,80001b82 <proc_pagetable+0x76>
}
    80001b64:	8526                	mv	a0,s1
    80001b66:	60e2                	ld	ra,24(sp)
    80001b68:	6442                	ld	s0,16(sp)
    80001b6a:	64a2                	ld	s1,8(sp)
    80001b6c:	6902                	ld	s2,0(sp)
    80001b6e:	6105                	addi	sp,sp,32
    80001b70:	8082                	ret
    uvmfree(pagetable, 0);
    80001b72:	4581                	li	a1,0
    80001b74:	8526                	mv	a0,s1
    80001b76:	00000097          	auipc	ra,0x0
    80001b7a:	a2c080e7          	jalr	-1492(ra) # 800015a2 <uvmfree>
    return 0;
    80001b7e:	4481                	li	s1,0
    80001b80:	b7d5                	j	80001b64 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b82:	4681                	li	a3,0
    80001b84:	4605                	li	a2,1
    80001b86:	040005b7          	lui	a1,0x4000
    80001b8a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b8c:	05b2                	slli	a1,a1,0xc
    80001b8e:	8526                	mv	a0,s1
    80001b90:	fffff097          	auipc	ra,0xfffff
    80001b94:	72c080e7          	jalr	1836(ra) # 800012bc <uvmunmap>
    uvmfree(pagetable, 0);
    80001b98:	4581                	li	a1,0
    80001b9a:	8526                	mv	a0,s1
    80001b9c:	00000097          	auipc	ra,0x0
    80001ba0:	a06080e7          	jalr	-1530(ra) # 800015a2 <uvmfree>
    return 0;
    80001ba4:	4481                	li	s1,0
    80001ba6:	bf7d                	j	80001b64 <proc_pagetable+0x58>

0000000080001ba8 <proc_freepagetable>:
{
    80001ba8:	1101                	addi	sp,sp,-32
    80001baa:	ec06                	sd	ra,24(sp)
    80001bac:	e822                	sd	s0,16(sp)
    80001bae:	e426                	sd	s1,8(sp)
    80001bb0:	e04a                	sd	s2,0(sp)
    80001bb2:	1000                	addi	s0,sp,32
    80001bb4:	84aa                	mv	s1,a0
    80001bb6:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bb8:	4681                	li	a3,0
    80001bba:	4605                	li	a2,1
    80001bbc:	040005b7          	lui	a1,0x4000
    80001bc0:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001bc2:	05b2                	slli	a1,a1,0xc
    80001bc4:	fffff097          	auipc	ra,0xfffff
    80001bc8:	6f8080e7          	jalr	1784(ra) # 800012bc <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001bcc:	4681                	li	a3,0
    80001bce:	4605                	li	a2,1
    80001bd0:	020005b7          	lui	a1,0x2000
    80001bd4:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001bd6:	05b6                	slli	a1,a1,0xd
    80001bd8:	8526                	mv	a0,s1
    80001bda:	fffff097          	auipc	ra,0xfffff
    80001bde:	6e2080e7          	jalr	1762(ra) # 800012bc <uvmunmap>
  uvmfree(pagetable, sz);
    80001be2:	85ca                	mv	a1,s2
    80001be4:	8526                	mv	a0,s1
    80001be6:	00000097          	auipc	ra,0x0
    80001bea:	9bc080e7          	jalr	-1604(ra) # 800015a2 <uvmfree>
}
    80001bee:	60e2                	ld	ra,24(sp)
    80001bf0:	6442                	ld	s0,16(sp)
    80001bf2:	64a2                	ld	s1,8(sp)
    80001bf4:	6902                	ld	s2,0(sp)
    80001bf6:	6105                	addi	sp,sp,32
    80001bf8:	8082                	ret

0000000080001bfa <freeproc>:
{
    80001bfa:	1101                	addi	sp,sp,-32
    80001bfc:	ec06                	sd	ra,24(sp)
    80001bfe:	e822                	sd	s0,16(sp)
    80001c00:	e426                	sd	s1,8(sp)
    80001c02:	1000                	addi	s0,sp,32
    80001c04:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001c06:	6d28                	ld	a0,88(a0)
    80001c08:	c509                	beqz	a0,80001c12 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001c0a:	fffff097          	auipc	ra,0xfffff
    80001c0e:	e3e080e7          	jalr	-450(ra) # 80000a48 <kfree>
  p->trapframe = 0;
    80001c12:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001c16:	68a8                	ld	a0,80(s1)
    80001c18:	c511                	beqz	a0,80001c24 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001c1a:	64ac                	ld	a1,72(s1)
    80001c1c:	00000097          	auipc	ra,0x0
    80001c20:	f8c080e7          	jalr	-116(ra) # 80001ba8 <proc_freepagetable>
  p->pagetable = 0;
    80001c24:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001c28:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001c2c:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001c30:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001c34:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c38:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001c3c:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001c40:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001c44:	0004ac23          	sw	zero,24(s1)
}
    80001c48:	60e2                	ld	ra,24(sp)
    80001c4a:	6442                	ld	s0,16(sp)
    80001c4c:	64a2                	ld	s1,8(sp)
    80001c4e:	6105                	addi	sp,sp,32
    80001c50:	8082                	ret

0000000080001c52 <allocproc>:
{
    80001c52:	1101                	addi	sp,sp,-32
    80001c54:	ec06                	sd	ra,24(sp)
    80001c56:	e822                	sd	s0,16(sp)
    80001c58:	e426                	sd	s1,8(sp)
    80001c5a:	e04a                	sd	s2,0(sp)
    80001c5c:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c5e:	0000f497          	auipc	s1,0xf
    80001c62:	30248493          	addi	s1,s1,770 # 80010f60 <proc>
    80001c66:	00015917          	auipc	s2,0x15
    80001c6a:	efa90913          	addi	s2,s2,-262 # 80016b60 <tickslock>
    acquire(&p->lock);
    80001c6e:	8526                	mv	a0,s1
    80001c70:	fffff097          	auipc	ra,0xfffff
    80001c74:	fc6080e7          	jalr	-58(ra) # 80000c36 <acquire>
    if(p->state == UNUSED) {
    80001c78:	4c9c                	lw	a5,24(s1)
    80001c7a:	cf81                	beqz	a5,80001c92 <allocproc+0x40>
      release(&p->lock);
    80001c7c:	8526                	mv	a0,s1
    80001c7e:	fffff097          	auipc	ra,0xfffff
    80001c82:	06c080e7          	jalr	108(ra) # 80000cea <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c86:	17048493          	addi	s1,s1,368
    80001c8a:	ff2492e3          	bne	s1,s2,80001c6e <allocproc+0x1c>
  return 0;
    80001c8e:	4481                	li	s1,0
    80001c90:	a889                	j	80001ce2 <allocproc+0x90>
  p->pid = allocpid();
    80001c92:	00000097          	auipc	ra,0x0
    80001c96:	e34080e7          	jalr	-460(ra) # 80001ac6 <allocpid>
    80001c9a:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c9c:	4785                	li	a5,1
    80001c9e:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001ca0:	fffff097          	auipc	ra,0xfffff
    80001ca4:	ea6080e7          	jalr	-346(ra) # 80000b46 <kalloc>
    80001ca8:	892a                	mv	s2,a0
    80001caa:	eca8                	sd	a0,88(s1)
    80001cac:	c131                	beqz	a0,80001cf0 <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001cae:	8526                	mv	a0,s1
    80001cb0:	00000097          	auipc	ra,0x0
    80001cb4:	e5c080e7          	jalr	-420(ra) # 80001b0c <proc_pagetable>
    80001cb8:	892a                	mv	s2,a0
    80001cba:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001cbc:	c531                	beqz	a0,80001d08 <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001cbe:	07000613          	li	a2,112
    80001cc2:	4581                	li	a1,0
    80001cc4:	06048513          	addi	a0,s1,96
    80001cc8:	fffff097          	auipc	ra,0xfffff
    80001ccc:	06a080e7          	jalr	106(ra) # 80000d32 <memset>
  p->context.ra = (uint64)forkret;
    80001cd0:	00000797          	auipc	a5,0x0
    80001cd4:	db078793          	addi	a5,a5,-592 # 80001a80 <forkret>
    80001cd8:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001cda:	60bc                	ld	a5,64(s1)
    80001cdc:	6705                	lui	a4,0x1
    80001cde:	97ba                	add	a5,a5,a4
    80001ce0:	f4bc                	sd	a5,104(s1)
}
    80001ce2:	8526                	mv	a0,s1
    80001ce4:	60e2                	ld	ra,24(sp)
    80001ce6:	6442                	ld	s0,16(sp)
    80001ce8:	64a2                	ld	s1,8(sp)
    80001cea:	6902                	ld	s2,0(sp)
    80001cec:	6105                	addi	sp,sp,32
    80001cee:	8082                	ret
    freeproc(p);
    80001cf0:	8526                	mv	a0,s1
    80001cf2:	00000097          	auipc	ra,0x0
    80001cf6:	f08080e7          	jalr	-248(ra) # 80001bfa <freeproc>
    release(&p->lock);
    80001cfa:	8526                	mv	a0,s1
    80001cfc:	fffff097          	auipc	ra,0xfffff
    80001d00:	fee080e7          	jalr	-18(ra) # 80000cea <release>
    return 0;
    80001d04:	84ca                	mv	s1,s2
    80001d06:	bff1                	j	80001ce2 <allocproc+0x90>
    freeproc(p);
    80001d08:	8526                	mv	a0,s1
    80001d0a:	00000097          	auipc	ra,0x0
    80001d0e:	ef0080e7          	jalr	-272(ra) # 80001bfa <freeproc>
    release(&p->lock);
    80001d12:	8526                	mv	a0,s1
    80001d14:	fffff097          	auipc	ra,0xfffff
    80001d18:	fd6080e7          	jalr	-42(ra) # 80000cea <release>
    return 0;
    80001d1c:	84ca                	mv	s1,s2
    80001d1e:	b7d1                	j	80001ce2 <allocproc+0x90>

0000000080001d20 <userinit>:
{
    80001d20:	1101                	addi	sp,sp,-32
    80001d22:	ec06                	sd	ra,24(sp)
    80001d24:	e822                	sd	s0,16(sp)
    80001d26:	e426                	sd	s1,8(sp)
    80001d28:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d2a:	00000097          	auipc	ra,0x0
    80001d2e:	f28080e7          	jalr	-216(ra) # 80001c52 <allocproc>
    80001d32:	84aa                	mv	s1,a0
  initproc = p;
    80001d34:	00007797          	auipc	a5,0x7
    80001d38:	b8a7b223          	sd	a0,-1148(a5) # 800088b8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001d3c:	03400613          	li	a2,52
    80001d40:	00007597          	auipc	a1,0x7
    80001d44:	b1058593          	addi	a1,a1,-1264 # 80008850 <initcode>
    80001d48:	6928                	ld	a0,80(a0)
    80001d4a:	fffff097          	auipc	ra,0xfffff
    80001d4e:	674080e7          	jalr	1652(ra) # 800013be <uvmfirst>
  p->sz = PGSIZE;
    80001d52:	6785                	lui	a5,0x1
    80001d54:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d56:	6cb8                	ld	a4,88(s1)
    80001d58:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d5c:	6cb8                	ld	a4,88(s1)
    80001d5e:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d60:	4641                	li	a2,16
    80001d62:	00006597          	auipc	a1,0x6
    80001d66:	47e58593          	addi	a1,a1,1150 # 800081e0 <etext+0x1e0>
    80001d6a:	15848513          	addi	a0,s1,344
    80001d6e:	fffff097          	auipc	ra,0xfffff
    80001d72:	106080e7          	jalr	262(ra) # 80000e74 <safestrcpy>
  p->cwd = namei("/");
    80001d76:	00006517          	auipc	a0,0x6
    80001d7a:	47a50513          	addi	a0,a0,1146 # 800081f0 <etext+0x1f0>
    80001d7e:	00002097          	auipc	ra,0x2
    80001d82:	1a8080e7          	jalr	424(ra) # 80003f26 <namei>
    80001d86:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d8a:	478d                	li	a5,3
    80001d8c:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d8e:	8526                	mv	a0,s1
    80001d90:	fffff097          	auipc	ra,0xfffff
    80001d94:	f5a080e7          	jalr	-166(ra) # 80000cea <release>
}
    80001d98:	60e2                	ld	ra,24(sp)
    80001d9a:	6442                	ld	s0,16(sp)
    80001d9c:	64a2                	ld	s1,8(sp)
    80001d9e:	6105                	addi	sp,sp,32
    80001da0:	8082                	ret

0000000080001da2 <growproc>:
{
    80001da2:	1101                	addi	sp,sp,-32
    80001da4:	ec06                	sd	ra,24(sp)
    80001da6:	e822                	sd	s0,16(sp)
    80001da8:	e426                	sd	s1,8(sp)
    80001daa:	e04a                	sd	s2,0(sp)
    80001dac:	1000                	addi	s0,sp,32
    80001dae:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001db0:	00000097          	auipc	ra,0x0
    80001db4:	c98080e7          	jalr	-872(ra) # 80001a48 <myproc>
    80001db8:	84aa                	mv	s1,a0
  sz = p->sz;
    80001dba:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001dbc:	01204c63          	bgtz	s2,80001dd4 <growproc+0x32>
  } else if(n < 0){
    80001dc0:	02094663          	bltz	s2,80001dec <growproc+0x4a>
  p->sz = sz;
    80001dc4:	e4ac                	sd	a1,72(s1)
  return 0;
    80001dc6:	4501                	li	a0,0
}
    80001dc8:	60e2                	ld	ra,24(sp)
    80001dca:	6442                	ld	s0,16(sp)
    80001dcc:	64a2                	ld	s1,8(sp)
    80001dce:	6902                	ld	s2,0(sp)
    80001dd0:	6105                	addi	sp,sp,32
    80001dd2:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001dd4:	4691                	li	a3,4
    80001dd6:	00b90633          	add	a2,s2,a1
    80001dda:	6928                	ld	a0,80(a0)
    80001ddc:	fffff097          	auipc	ra,0xfffff
    80001de0:	69c080e7          	jalr	1692(ra) # 80001478 <uvmalloc>
    80001de4:	85aa                	mv	a1,a0
    80001de6:	fd79                	bnez	a0,80001dc4 <growproc+0x22>
      return -1;
    80001de8:	557d                	li	a0,-1
    80001dea:	bff9                	j	80001dc8 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001dec:	00b90633          	add	a2,s2,a1
    80001df0:	6928                	ld	a0,80(a0)
    80001df2:	fffff097          	auipc	ra,0xfffff
    80001df6:	63e080e7          	jalr	1598(ra) # 80001430 <uvmdealloc>
    80001dfa:	85aa                	mv	a1,a0
    80001dfc:	b7e1                	j	80001dc4 <growproc+0x22>

0000000080001dfe <fork>:
{
    80001dfe:	7139                	addi	sp,sp,-64
    80001e00:	fc06                	sd	ra,56(sp)
    80001e02:	f822                	sd	s0,48(sp)
    80001e04:	f04a                	sd	s2,32(sp)
    80001e06:	e456                	sd	s5,8(sp)
    80001e08:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e0a:	00000097          	auipc	ra,0x0
    80001e0e:	c3e080e7          	jalr	-962(ra) # 80001a48 <myproc>
    80001e12:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e14:	00000097          	auipc	ra,0x0
    80001e18:	e3e080e7          	jalr	-450(ra) # 80001c52 <allocproc>
    80001e1c:	12050063          	beqz	a0,80001f3c <fork+0x13e>
    80001e20:	e852                	sd	s4,16(sp)
    80001e22:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e24:	048ab603          	ld	a2,72(s5)
    80001e28:	692c                	ld	a1,80(a0)
    80001e2a:	050ab503          	ld	a0,80(s5)
    80001e2e:	fffff097          	auipc	ra,0xfffff
    80001e32:	7ae080e7          	jalr	1966(ra) # 800015dc <uvmcopy>
    80001e36:	04054a63          	bltz	a0,80001e8a <fork+0x8c>
    80001e3a:	f426                	sd	s1,40(sp)
    80001e3c:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001e3e:	048ab783          	ld	a5,72(s5)
    80001e42:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001e46:	058ab683          	ld	a3,88(s5)
    80001e4a:	87b6                	mv	a5,a3
    80001e4c:	058a3703          	ld	a4,88(s4)
    80001e50:	12068693          	addi	a3,a3,288
    80001e54:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e58:	6788                	ld	a0,8(a5)
    80001e5a:	6b8c                	ld	a1,16(a5)
    80001e5c:	6f90                	ld	a2,24(a5)
    80001e5e:	01073023          	sd	a6,0(a4)
    80001e62:	e708                	sd	a0,8(a4)
    80001e64:	eb0c                	sd	a1,16(a4)
    80001e66:	ef10                	sd	a2,24(a4)
    80001e68:	02078793          	addi	a5,a5,32
    80001e6c:	02070713          	addi	a4,a4,32
    80001e70:	fed792e3          	bne	a5,a3,80001e54 <fork+0x56>
  np->trapframe->a0 = 0;
    80001e74:	058a3783          	ld	a5,88(s4)
    80001e78:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e7c:	0d0a8493          	addi	s1,s5,208
    80001e80:	0d0a0913          	addi	s2,s4,208
    80001e84:	150a8993          	addi	s3,s5,336
    80001e88:	a015                	j	80001eac <fork+0xae>
    freeproc(np);
    80001e8a:	8552                	mv	a0,s4
    80001e8c:	00000097          	auipc	ra,0x0
    80001e90:	d6e080e7          	jalr	-658(ra) # 80001bfa <freeproc>
    release(&np->lock);
    80001e94:	8552                	mv	a0,s4
    80001e96:	fffff097          	auipc	ra,0xfffff
    80001e9a:	e54080e7          	jalr	-428(ra) # 80000cea <release>
    return -1;
    80001e9e:	597d                	li	s2,-1
    80001ea0:	6a42                	ld	s4,16(sp)
    80001ea2:	a071                	j	80001f2e <fork+0x130>
  for(i = 0; i < NOFILE; i++)
    80001ea4:	04a1                	addi	s1,s1,8
    80001ea6:	0921                	addi	s2,s2,8
    80001ea8:	01348b63          	beq	s1,s3,80001ebe <fork+0xc0>
    if(p->ofile[i])
    80001eac:	6088                	ld	a0,0(s1)
    80001eae:	d97d                	beqz	a0,80001ea4 <fork+0xa6>
      np->ofile[i] = filedup(p->ofile[i]);
    80001eb0:	00002097          	auipc	ra,0x2
    80001eb4:	6ee080e7          	jalr	1774(ra) # 8000459e <filedup>
    80001eb8:	00a93023          	sd	a0,0(s2)
    80001ebc:	b7e5                	j	80001ea4 <fork+0xa6>
  np->cwd = idup(p->cwd);
    80001ebe:	150ab503          	ld	a0,336(s5)
    80001ec2:	00002097          	auipc	ra,0x2
    80001ec6:	858080e7          	jalr	-1960(ra) # 8000371a <idup>
    80001eca:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ece:	4641                	li	a2,16
    80001ed0:	158a8593          	addi	a1,s5,344
    80001ed4:	158a0513          	addi	a0,s4,344
    80001ed8:	fffff097          	auipc	ra,0xfffff
    80001edc:	f9c080e7          	jalr	-100(ra) # 80000e74 <safestrcpy>
  pid = np->pid;
    80001ee0:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001ee4:	8552                	mv	a0,s4
    80001ee6:	fffff097          	auipc	ra,0xfffff
    80001eea:	e04080e7          	jalr	-508(ra) # 80000cea <release>
  acquire(&wait_lock);
    80001eee:	0000f497          	auipc	s1,0xf
    80001ef2:	c5a48493          	addi	s1,s1,-934 # 80010b48 <wait_lock>
    80001ef6:	8526                	mv	a0,s1
    80001ef8:	fffff097          	auipc	ra,0xfffff
    80001efc:	d3e080e7          	jalr	-706(ra) # 80000c36 <acquire>
  np->parent = p;
    80001f00:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001f04:	8526                	mv	a0,s1
    80001f06:	fffff097          	auipc	ra,0xfffff
    80001f0a:	de4080e7          	jalr	-540(ra) # 80000cea <release>
  acquire(&np->lock);
    80001f0e:	8552                	mv	a0,s4
    80001f10:	fffff097          	auipc	ra,0xfffff
    80001f14:	d26080e7          	jalr	-730(ra) # 80000c36 <acquire>
  np->state = RUNNABLE;
    80001f18:	478d                	li	a5,3
    80001f1a:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001f1e:	8552                	mv	a0,s4
    80001f20:	fffff097          	auipc	ra,0xfffff
    80001f24:	dca080e7          	jalr	-566(ra) # 80000cea <release>
  return pid;
    80001f28:	74a2                	ld	s1,40(sp)
    80001f2a:	69e2                	ld	s3,24(sp)
    80001f2c:	6a42                	ld	s4,16(sp)
}
    80001f2e:	854a                	mv	a0,s2
    80001f30:	70e2                	ld	ra,56(sp)
    80001f32:	7442                	ld	s0,48(sp)
    80001f34:	7902                	ld	s2,32(sp)
    80001f36:	6aa2                	ld	s5,8(sp)
    80001f38:	6121                	addi	sp,sp,64
    80001f3a:	8082                	ret
    return -1;
    80001f3c:	597d                	li	s2,-1
    80001f3e:	bfc5                	j	80001f2e <fork+0x130>

0000000080001f40 <scheduler>:
{
    80001f40:	715d                	addi	sp,sp,-80
    80001f42:	e486                	sd	ra,72(sp)
    80001f44:	e0a2                	sd	s0,64(sp)
    80001f46:	fc26                	sd	s1,56(sp)
    80001f48:	f84a                	sd	s2,48(sp)
    80001f4a:	f44e                	sd	s3,40(sp)
    80001f4c:	f052                	sd	s4,32(sp)
    80001f4e:	ec56                	sd	s5,24(sp)
    80001f50:	e85a                	sd	s6,16(sp)
    80001f52:	e45e                	sd	s7,8(sp)
    80001f54:	0880                	addi	s0,sp,80
    80001f56:	8792                	mv	a5,tp
  int id = r_tp();
    80001f58:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f5a:	00779b93          	slli	s7,a5,0x7
    80001f5e:	0000f717          	auipc	a4,0xf
    80001f62:	bd270713          	addi	a4,a4,-1070 # 80010b30 <pid_lock>
    80001f66:	975e                	add	a4,a4,s7
    80001f68:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001f6c:	0000f717          	auipc	a4,0xf
    80001f70:	bfc70713          	addi	a4,a4,-1028 # 80010b68 <cpus+0x8>
    80001f74:	9bba                	add	s7,s7,a4
    int bestpid = 0;
    80001f76:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f78:	00015917          	auipc	s2,0x15
    80001f7c:	be890913          	addi	s2,s2,-1048 # 80016b60 <tickslock>
        c->proc = p;
    80001f80:	079e                	slli	a5,a5,0x7
    80001f82:	0000fb17          	auipc	s6,0xf
    80001f86:	baeb0b13          	addi	s6,s6,-1106 # 80010b30 <pid_lock>
    80001f8a:	9b3e                	add	s6,s6,a5
    80001f8c:	a85d                	j	80002042 <scheduler+0x102>
          bestpid = p->pid;
    80001f8e:	0304aa03          	lw	s4,48(s1)
      release(&p->lock);
    80001f92:	8526                	mv	a0,s1
    80001f94:	fffff097          	auipc	ra,0xfffff
    80001f98:	d56080e7          	jalr	-682(ra) # 80000cea <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f9c:	17048493          	addi	s1,s1,368
    80001fa0:	03248d63          	beq	s1,s2,80001fda <scheduler+0x9a>
      acquire(&p->lock);
    80001fa4:	8526                	mv	a0,s1
    80001fa6:	fffff097          	auipc	ra,0xfffff
    80001faa:	c90080e7          	jalr	-880(ra) # 80000c36 <acquire>
      if(p->state == RUNNABLE) {
    80001fae:	4c9c                	lw	a5,24(s1)
    80001fb0:	ff3791e3          	bne	a5,s3,80001f92 <scheduler+0x52>
        if(bestpid == 0 || p->pid < bestpid) {
    80001fb4:	fc0a0de3          	beqz	s4,80001f8e <scheduler+0x4e>
    80001fb8:	589c                	lw	a5,48(s1)
    80001fba:	fd47cae3          	blt	a5,s4,80001f8e <scheduler+0x4e>
      release(&p->lock);
    80001fbe:	8526                	mv	a0,s1
    80001fc0:	fffff097          	auipc	ra,0xfffff
    80001fc4:	d2a080e7          	jalr	-726(ra) # 80000cea <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fc8:	17048493          	addi	s1,s1,368
    80001fcc:	fd249ce3          	bne	s1,s2,80001fa4 <scheduler+0x64>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fd0:	0000f497          	auipc	s1,0xf
    80001fd4:	f9048493          	addi	s1,s1,-112 # 80010f60 <proc>
    80001fd8:	a805                	j	80002008 <scheduler+0xc8>
    if(bestpid == 0)
    80001fda:	fe0a1be3          	bnez	s4,80001fd0 <scheduler+0x90>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fde:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001fe2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fe6:	10079073          	csrw	sstatus,a5
    int bestpid = 0;
    80001fea:	8a56                	mv	s4,s5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fec:	0000f497          	auipc	s1,0xf
    80001ff0:	f7448493          	addi	s1,s1,-140 # 80010f60 <proc>
    80001ff4:	bf45                	j	80001fa4 <scheduler+0x64>
      release(&p->lock);
    80001ff6:	8526                	mv	a0,s1
    80001ff8:	fffff097          	auipc	ra,0xfffff
    80001ffc:	cf2080e7          	jalr	-782(ra) # 80000cea <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002000:	17048493          	addi	s1,s1,368
    80002004:	fd248de3          	beq	s1,s2,80001fde <scheduler+0x9e>
      acquire(&p->lock);
    80002008:	8526                	mv	a0,s1
    8000200a:	fffff097          	auipc	ra,0xfffff
    8000200e:	c2c080e7          	jalr	-980(ra) # 80000c36 <acquire>
      if(p->pid == bestpid && p->state == RUNNABLE) {
    80002012:	589c                	lw	a5,48(s1)
    80002014:	ff4791e3          	bne	a5,s4,80001ff6 <scheduler+0xb6>
    80002018:	4c9c                	lw	a5,24(s1)
    8000201a:	fd379ee3          	bne	a5,s3,80001ff6 <scheduler+0xb6>
        p->state = RUNNING;
    8000201e:	4791                	li	a5,4
    80002020:	cc9c                	sw	a5,24(s1)
        c->proc = p;
    80002022:	029b3823          	sd	s1,48(s6)
        swtch(&c->context, &p->context);
    80002026:	06048593          	addi	a1,s1,96
    8000202a:	855e                	mv	a0,s7
    8000202c:	00000097          	auipc	ra,0x0
    80002030:	690080e7          	jalr	1680(ra) # 800026bc <swtch>
        c->proc = 0;
    80002034:	020b3823          	sd	zero,48(s6)
        release(&p->lock);
    80002038:	8526                	mv	a0,s1
    8000203a:	fffff097          	auipc	ra,0xfffff
    8000203e:	cb0080e7          	jalr	-848(ra) # 80000cea <release>
      if(p->state == RUNNABLE) {
    80002042:	498d                	li	s3,3
    80002044:	bf69                	j	80001fde <scheduler+0x9e>

0000000080002046 <sched>:
{
    80002046:	7179                	addi	sp,sp,-48
    80002048:	f406                	sd	ra,40(sp)
    8000204a:	f022                	sd	s0,32(sp)
    8000204c:	ec26                	sd	s1,24(sp)
    8000204e:	e84a                	sd	s2,16(sp)
    80002050:	e44e                	sd	s3,8(sp)
    80002052:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002054:	00000097          	auipc	ra,0x0
    80002058:	9f4080e7          	jalr	-1548(ra) # 80001a48 <myproc>
    8000205c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000205e:	fffff097          	auipc	ra,0xfffff
    80002062:	b5e080e7          	jalr	-1186(ra) # 80000bbc <holding>
    80002066:	c93d                	beqz	a0,800020dc <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002068:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000206a:	2781                	sext.w	a5,a5
    8000206c:	079e                	slli	a5,a5,0x7
    8000206e:	0000f717          	auipc	a4,0xf
    80002072:	ac270713          	addi	a4,a4,-1342 # 80010b30 <pid_lock>
    80002076:	97ba                	add	a5,a5,a4
    80002078:	0a87a703          	lw	a4,168(a5)
    8000207c:	4785                	li	a5,1
    8000207e:	06f71763          	bne	a4,a5,800020ec <sched+0xa6>
  if(p->state == RUNNING)
    80002082:	4c98                	lw	a4,24(s1)
    80002084:	4791                	li	a5,4
    80002086:	06f70b63          	beq	a4,a5,800020fc <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000208a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000208e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002090:	efb5                	bnez	a5,8000210c <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002092:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002094:	0000f917          	auipc	s2,0xf
    80002098:	a9c90913          	addi	s2,s2,-1380 # 80010b30 <pid_lock>
    8000209c:	2781                	sext.w	a5,a5
    8000209e:	079e                	slli	a5,a5,0x7
    800020a0:	97ca                	add	a5,a5,s2
    800020a2:	0ac7a983          	lw	s3,172(a5)
    800020a6:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800020a8:	2781                	sext.w	a5,a5
    800020aa:	079e                	slli	a5,a5,0x7
    800020ac:	0000f597          	auipc	a1,0xf
    800020b0:	abc58593          	addi	a1,a1,-1348 # 80010b68 <cpus+0x8>
    800020b4:	95be                	add	a1,a1,a5
    800020b6:	06048513          	addi	a0,s1,96
    800020ba:	00000097          	auipc	ra,0x0
    800020be:	602080e7          	jalr	1538(ra) # 800026bc <swtch>
    800020c2:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800020c4:	2781                	sext.w	a5,a5
    800020c6:	079e                	slli	a5,a5,0x7
    800020c8:	993e                	add	s2,s2,a5
    800020ca:	0b392623          	sw	s3,172(s2)
}
    800020ce:	70a2                	ld	ra,40(sp)
    800020d0:	7402                	ld	s0,32(sp)
    800020d2:	64e2                	ld	s1,24(sp)
    800020d4:	6942                	ld	s2,16(sp)
    800020d6:	69a2                	ld	s3,8(sp)
    800020d8:	6145                	addi	sp,sp,48
    800020da:	8082                	ret
    panic("sched p->lock");
    800020dc:	00006517          	auipc	a0,0x6
    800020e0:	11c50513          	addi	a0,a0,284 # 800081f8 <etext+0x1f8>
    800020e4:	ffffe097          	auipc	ra,0xffffe
    800020e8:	47a080e7          	jalr	1146(ra) # 8000055e <panic>
    panic("sched locks");
    800020ec:	00006517          	auipc	a0,0x6
    800020f0:	11c50513          	addi	a0,a0,284 # 80008208 <etext+0x208>
    800020f4:	ffffe097          	auipc	ra,0xffffe
    800020f8:	46a080e7          	jalr	1130(ra) # 8000055e <panic>
    panic("sched running");
    800020fc:	00006517          	auipc	a0,0x6
    80002100:	11c50513          	addi	a0,a0,284 # 80008218 <etext+0x218>
    80002104:	ffffe097          	auipc	ra,0xffffe
    80002108:	45a080e7          	jalr	1114(ra) # 8000055e <panic>
    panic("sched interruptible");
    8000210c:	00006517          	auipc	a0,0x6
    80002110:	11c50513          	addi	a0,a0,284 # 80008228 <etext+0x228>
    80002114:	ffffe097          	auipc	ra,0xffffe
    80002118:	44a080e7          	jalr	1098(ra) # 8000055e <panic>

000000008000211c <yield>:
{
    8000211c:	1101                	addi	sp,sp,-32
    8000211e:	ec06                	sd	ra,24(sp)
    80002120:	e822                	sd	s0,16(sp)
    80002122:	e426                	sd	s1,8(sp)
    80002124:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002126:	00000097          	auipc	ra,0x0
    8000212a:	922080e7          	jalr	-1758(ra) # 80001a48 <myproc>
    8000212e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002130:	fffff097          	auipc	ra,0xfffff
    80002134:	b06080e7          	jalr	-1274(ra) # 80000c36 <acquire>
  p->state = RUNNABLE;
    80002138:	478d                	li	a5,3
    8000213a:	cc9c                	sw	a5,24(s1)
  sched();
    8000213c:	00000097          	auipc	ra,0x0
    80002140:	f0a080e7          	jalr	-246(ra) # 80002046 <sched>
  release(&p->lock);
    80002144:	8526                	mv	a0,s1
    80002146:	fffff097          	auipc	ra,0xfffff
    8000214a:	ba4080e7          	jalr	-1116(ra) # 80000cea <release>
}
    8000214e:	60e2                	ld	ra,24(sp)
    80002150:	6442                	ld	s0,16(sp)
    80002152:	64a2                	ld	s1,8(sp)
    80002154:	6105                	addi	sp,sp,32
    80002156:	8082                	ret

0000000080002158 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002158:	7179                	addi	sp,sp,-48
    8000215a:	f406                	sd	ra,40(sp)
    8000215c:	f022                	sd	s0,32(sp)
    8000215e:	ec26                	sd	s1,24(sp)
    80002160:	e84a                	sd	s2,16(sp)
    80002162:	e44e                	sd	s3,8(sp)
    80002164:	1800                	addi	s0,sp,48
    80002166:	89aa                	mv	s3,a0
    80002168:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000216a:	00000097          	auipc	ra,0x0
    8000216e:	8de080e7          	jalr	-1826(ra) # 80001a48 <myproc>
    80002172:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002174:	fffff097          	auipc	ra,0xfffff
    80002178:	ac2080e7          	jalr	-1342(ra) # 80000c36 <acquire>
  release(lk);
    8000217c:	854a                	mv	a0,s2
    8000217e:	fffff097          	auipc	ra,0xfffff
    80002182:	b6c080e7          	jalr	-1172(ra) # 80000cea <release>

  // Go to sleep.
  p->chan = chan;
    80002186:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000218a:	4789                	li	a5,2
    8000218c:	cc9c                	sw	a5,24(s1)

  sched();
    8000218e:	00000097          	auipc	ra,0x0
    80002192:	eb8080e7          	jalr	-328(ra) # 80002046 <sched>

  // Tidy up.
  p->chan = 0;
    80002196:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000219a:	8526                	mv	a0,s1
    8000219c:	fffff097          	auipc	ra,0xfffff
    800021a0:	b4e080e7          	jalr	-1202(ra) # 80000cea <release>
  acquire(lk);
    800021a4:	854a                	mv	a0,s2
    800021a6:	fffff097          	auipc	ra,0xfffff
    800021aa:	a90080e7          	jalr	-1392(ra) # 80000c36 <acquire>
}
    800021ae:	70a2                	ld	ra,40(sp)
    800021b0:	7402                	ld	s0,32(sp)
    800021b2:	64e2                	ld	s1,24(sp)
    800021b4:	6942                	ld	s2,16(sp)
    800021b6:	69a2                	ld	s3,8(sp)
    800021b8:	6145                	addi	sp,sp,48
    800021ba:	8082                	ret

00000000800021bc <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800021bc:	7139                	addi	sp,sp,-64
    800021be:	fc06                	sd	ra,56(sp)
    800021c0:	f822                	sd	s0,48(sp)
    800021c2:	f426                	sd	s1,40(sp)
    800021c4:	f04a                	sd	s2,32(sp)
    800021c6:	ec4e                	sd	s3,24(sp)
    800021c8:	e852                	sd	s4,16(sp)
    800021ca:	e456                	sd	s5,8(sp)
    800021cc:	0080                	addi	s0,sp,64
    800021ce:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800021d0:	0000f497          	auipc	s1,0xf
    800021d4:	d9048493          	addi	s1,s1,-624 # 80010f60 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800021d8:	4989                	li	s3,2
        p->state = RUNNABLE;
    800021da:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800021dc:	00015917          	auipc	s2,0x15
    800021e0:	98490913          	addi	s2,s2,-1660 # 80016b60 <tickslock>
    800021e4:	a811                	j	800021f8 <wakeup+0x3c>
      }
      release(&p->lock);
    800021e6:	8526                	mv	a0,s1
    800021e8:	fffff097          	auipc	ra,0xfffff
    800021ec:	b02080e7          	jalr	-1278(ra) # 80000cea <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800021f0:	17048493          	addi	s1,s1,368
    800021f4:	03248663          	beq	s1,s2,80002220 <wakeup+0x64>
    if(p != myproc()){
    800021f8:	00000097          	auipc	ra,0x0
    800021fc:	850080e7          	jalr	-1968(ra) # 80001a48 <myproc>
    80002200:	fea488e3          	beq	s1,a0,800021f0 <wakeup+0x34>
      acquire(&p->lock);
    80002204:	8526                	mv	a0,s1
    80002206:	fffff097          	auipc	ra,0xfffff
    8000220a:	a30080e7          	jalr	-1488(ra) # 80000c36 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    8000220e:	4c9c                	lw	a5,24(s1)
    80002210:	fd379be3          	bne	a5,s3,800021e6 <wakeup+0x2a>
    80002214:	709c                	ld	a5,32(s1)
    80002216:	fd4798e3          	bne	a5,s4,800021e6 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000221a:	0154ac23          	sw	s5,24(s1)
    8000221e:	b7e1                	j	800021e6 <wakeup+0x2a>
    }
  }
}
    80002220:	70e2                	ld	ra,56(sp)
    80002222:	7442                	ld	s0,48(sp)
    80002224:	74a2                	ld	s1,40(sp)
    80002226:	7902                	ld	s2,32(sp)
    80002228:	69e2                	ld	s3,24(sp)
    8000222a:	6a42                	ld	s4,16(sp)
    8000222c:	6aa2                	ld	s5,8(sp)
    8000222e:	6121                	addi	sp,sp,64
    80002230:	8082                	ret

0000000080002232 <reparent>:
{
    80002232:	7179                	addi	sp,sp,-48
    80002234:	f406                	sd	ra,40(sp)
    80002236:	f022                	sd	s0,32(sp)
    80002238:	ec26                	sd	s1,24(sp)
    8000223a:	e84a                	sd	s2,16(sp)
    8000223c:	e44e                	sd	s3,8(sp)
    8000223e:	e052                	sd	s4,0(sp)
    80002240:	1800                	addi	s0,sp,48
    80002242:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002244:	0000f497          	auipc	s1,0xf
    80002248:	d1c48493          	addi	s1,s1,-740 # 80010f60 <proc>
      pp->parent = initproc;
    8000224c:	00006a17          	auipc	s4,0x6
    80002250:	66ca0a13          	addi	s4,s4,1644 # 800088b8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002254:	00015997          	auipc	s3,0x15
    80002258:	90c98993          	addi	s3,s3,-1780 # 80016b60 <tickslock>
    8000225c:	a029                	j	80002266 <reparent+0x34>
    8000225e:	17048493          	addi	s1,s1,368
    80002262:	01348d63          	beq	s1,s3,8000227c <reparent+0x4a>
    if(pp->parent == p){
    80002266:	7c9c                	ld	a5,56(s1)
    80002268:	ff279be3          	bne	a5,s2,8000225e <reparent+0x2c>
      pp->parent = initproc;
    8000226c:	000a3503          	ld	a0,0(s4)
    80002270:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002272:	00000097          	auipc	ra,0x0
    80002276:	f4a080e7          	jalr	-182(ra) # 800021bc <wakeup>
    8000227a:	b7d5                	j	8000225e <reparent+0x2c>
}
    8000227c:	70a2                	ld	ra,40(sp)
    8000227e:	7402                	ld	s0,32(sp)
    80002280:	64e2                	ld	s1,24(sp)
    80002282:	6942                	ld	s2,16(sp)
    80002284:	69a2                	ld	s3,8(sp)
    80002286:	6a02                	ld	s4,0(sp)
    80002288:	6145                	addi	sp,sp,48
    8000228a:	8082                	ret

000000008000228c <exit>:
{
    8000228c:	7179                	addi	sp,sp,-48
    8000228e:	f406                	sd	ra,40(sp)
    80002290:	f022                	sd	s0,32(sp)
    80002292:	ec26                	sd	s1,24(sp)
    80002294:	e84a                	sd	s2,16(sp)
    80002296:	e44e                	sd	s3,8(sp)
    80002298:	e052                	sd	s4,0(sp)
    8000229a:	1800                	addi	s0,sp,48
    8000229c:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000229e:	fffff097          	auipc	ra,0xfffff
    800022a2:	7aa080e7          	jalr	1962(ra) # 80001a48 <myproc>
    800022a6:	89aa                	mv	s3,a0
  if(p == initproc)
    800022a8:	00006797          	auipc	a5,0x6
    800022ac:	6107b783          	ld	a5,1552(a5) # 800088b8 <initproc>
    800022b0:	0d050493          	addi	s1,a0,208
    800022b4:	15050913          	addi	s2,a0,336
    800022b8:	02a79363          	bne	a5,a0,800022de <exit+0x52>
    panic("init exiting");
    800022bc:	00006517          	auipc	a0,0x6
    800022c0:	f8450513          	addi	a0,a0,-124 # 80008240 <etext+0x240>
    800022c4:	ffffe097          	auipc	ra,0xffffe
    800022c8:	29a080e7          	jalr	666(ra) # 8000055e <panic>
      fileclose(f);
    800022cc:	00002097          	auipc	ra,0x2
    800022d0:	324080e7          	jalr	804(ra) # 800045f0 <fileclose>
      p->ofile[fd] = 0;
    800022d4:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800022d8:	04a1                	addi	s1,s1,8
    800022da:	01248563          	beq	s1,s2,800022e4 <exit+0x58>
    if(p->ofile[fd]){
    800022de:	6088                	ld	a0,0(s1)
    800022e0:	f575                	bnez	a0,800022cc <exit+0x40>
    800022e2:	bfdd                	j	800022d8 <exit+0x4c>
  begin_op();
    800022e4:	00002097          	auipc	ra,0x2
    800022e8:	e42080e7          	jalr	-446(ra) # 80004126 <begin_op>
  iput(p->cwd);
    800022ec:	1509b503          	ld	a0,336(s3)
    800022f0:	00001097          	auipc	ra,0x1
    800022f4:	626080e7          	jalr	1574(ra) # 80003916 <iput>
  end_op();
    800022f8:	00002097          	auipc	ra,0x2
    800022fc:	ea8080e7          	jalr	-344(ra) # 800041a0 <end_op>
  p->cwd = 0;
    80002300:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002304:	0000f497          	auipc	s1,0xf
    80002308:	84448493          	addi	s1,s1,-1980 # 80010b48 <wait_lock>
    8000230c:	8526                	mv	a0,s1
    8000230e:	fffff097          	auipc	ra,0xfffff
    80002312:	928080e7          	jalr	-1752(ra) # 80000c36 <acquire>
  reparent(p);
    80002316:	854e                	mv	a0,s3
    80002318:	00000097          	auipc	ra,0x0
    8000231c:	f1a080e7          	jalr	-230(ra) # 80002232 <reparent>
  wakeup(p->parent);
    80002320:	0389b503          	ld	a0,56(s3)
    80002324:	00000097          	auipc	ra,0x0
    80002328:	e98080e7          	jalr	-360(ra) # 800021bc <wakeup>
  acquire(&p->lock);
    8000232c:	854e                	mv	a0,s3
    8000232e:	fffff097          	auipc	ra,0xfffff
    80002332:	908080e7          	jalr	-1784(ra) # 80000c36 <acquire>
  p->xstate = status;
    80002336:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000233a:	4795                	li	a5,5
    8000233c:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002340:	8526                	mv	a0,s1
    80002342:	fffff097          	auipc	ra,0xfffff
    80002346:	9a8080e7          	jalr	-1624(ra) # 80000cea <release>
  sched();
    8000234a:	00000097          	auipc	ra,0x0
    8000234e:	cfc080e7          	jalr	-772(ra) # 80002046 <sched>
  panic("zombie exit");
    80002352:	00006517          	auipc	a0,0x6
    80002356:	efe50513          	addi	a0,a0,-258 # 80008250 <etext+0x250>
    8000235a:	ffffe097          	auipc	ra,0xffffe
    8000235e:	204080e7          	jalr	516(ra) # 8000055e <panic>

0000000080002362 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002362:	7179                	addi	sp,sp,-48
    80002364:	f406                	sd	ra,40(sp)
    80002366:	f022                	sd	s0,32(sp)
    80002368:	ec26                	sd	s1,24(sp)
    8000236a:	e84a                	sd	s2,16(sp)
    8000236c:	e44e                	sd	s3,8(sp)
    8000236e:	1800                	addi	s0,sp,48
    80002370:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002372:	0000f497          	auipc	s1,0xf
    80002376:	bee48493          	addi	s1,s1,-1042 # 80010f60 <proc>
    8000237a:	00014997          	auipc	s3,0x14
    8000237e:	7e698993          	addi	s3,s3,2022 # 80016b60 <tickslock>
    acquire(&p->lock);
    80002382:	8526                	mv	a0,s1
    80002384:	fffff097          	auipc	ra,0xfffff
    80002388:	8b2080e7          	jalr	-1870(ra) # 80000c36 <acquire>
    if(p->pid == pid){
    8000238c:	589c                	lw	a5,48(s1)
    8000238e:	01278d63          	beq	a5,s2,800023a8 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002392:	8526                	mv	a0,s1
    80002394:	fffff097          	auipc	ra,0xfffff
    80002398:	956080e7          	jalr	-1706(ra) # 80000cea <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000239c:	17048493          	addi	s1,s1,368
    800023a0:	ff3491e3          	bne	s1,s3,80002382 <kill+0x20>
  }
  return -1;
    800023a4:	557d                	li	a0,-1
    800023a6:	a829                	j	800023c0 <kill+0x5e>
      p->killed = 1;
    800023a8:	4785                	li	a5,1
    800023aa:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800023ac:	4c98                	lw	a4,24(s1)
    800023ae:	4789                	li	a5,2
    800023b0:	00f70f63          	beq	a4,a5,800023ce <kill+0x6c>
      release(&p->lock);
    800023b4:	8526                	mv	a0,s1
    800023b6:	fffff097          	auipc	ra,0xfffff
    800023ba:	934080e7          	jalr	-1740(ra) # 80000cea <release>
      return 0;
    800023be:	4501                	li	a0,0
}
    800023c0:	70a2                	ld	ra,40(sp)
    800023c2:	7402                	ld	s0,32(sp)
    800023c4:	64e2                	ld	s1,24(sp)
    800023c6:	6942                	ld	s2,16(sp)
    800023c8:	69a2                	ld	s3,8(sp)
    800023ca:	6145                	addi	sp,sp,48
    800023cc:	8082                	ret
        p->state = RUNNABLE;
    800023ce:	478d                	li	a5,3
    800023d0:	cc9c                	sw	a5,24(s1)
    800023d2:	b7cd                	j	800023b4 <kill+0x52>

00000000800023d4 <setkilled>:

void
setkilled(struct proc *p)
{
    800023d4:	1101                	addi	sp,sp,-32
    800023d6:	ec06                	sd	ra,24(sp)
    800023d8:	e822                	sd	s0,16(sp)
    800023da:	e426                	sd	s1,8(sp)
    800023dc:	1000                	addi	s0,sp,32
    800023de:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800023e0:	fffff097          	auipc	ra,0xfffff
    800023e4:	856080e7          	jalr	-1962(ra) # 80000c36 <acquire>
  p->killed = 1;
    800023e8:	4785                	li	a5,1
    800023ea:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800023ec:	8526                	mv	a0,s1
    800023ee:	fffff097          	auipc	ra,0xfffff
    800023f2:	8fc080e7          	jalr	-1796(ra) # 80000cea <release>
}
    800023f6:	60e2                	ld	ra,24(sp)
    800023f8:	6442                	ld	s0,16(sp)
    800023fa:	64a2                	ld	s1,8(sp)
    800023fc:	6105                	addi	sp,sp,32
    800023fe:	8082                	ret

0000000080002400 <killed>:

int
killed(struct proc *p)
{
    80002400:	1101                	addi	sp,sp,-32
    80002402:	ec06                	sd	ra,24(sp)
    80002404:	e822                	sd	s0,16(sp)
    80002406:	e426                	sd	s1,8(sp)
    80002408:	e04a                	sd	s2,0(sp)
    8000240a:	1000                	addi	s0,sp,32
    8000240c:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000240e:	fffff097          	auipc	ra,0xfffff
    80002412:	828080e7          	jalr	-2008(ra) # 80000c36 <acquire>
  k = p->killed;
    80002416:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000241a:	8526                	mv	a0,s1
    8000241c:	fffff097          	auipc	ra,0xfffff
    80002420:	8ce080e7          	jalr	-1842(ra) # 80000cea <release>
  return k;
}
    80002424:	854a                	mv	a0,s2
    80002426:	60e2                	ld	ra,24(sp)
    80002428:	6442                	ld	s0,16(sp)
    8000242a:	64a2                	ld	s1,8(sp)
    8000242c:	6902                	ld	s2,0(sp)
    8000242e:	6105                	addi	sp,sp,32
    80002430:	8082                	ret

0000000080002432 <wait>:
{
    80002432:	715d                	addi	sp,sp,-80
    80002434:	e486                	sd	ra,72(sp)
    80002436:	e0a2                	sd	s0,64(sp)
    80002438:	fc26                	sd	s1,56(sp)
    8000243a:	f84a                	sd	s2,48(sp)
    8000243c:	f44e                	sd	s3,40(sp)
    8000243e:	f052                	sd	s4,32(sp)
    80002440:	ec56                	sd	s5,24(sp)
    80002442:	e85a                	sd	s6,16(sp)
    80002444:	e45e                	sd	s7,8(sp)
    80002446:	e062                	sd	s8,0(sp)
    80002448:	0880                	addi	s0,sp,80
    8000244a:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000244c:	fffff097          	auipc	ra,0xfffff
    80002450:	5fc080e7          	jalr	1532(ra) # 80001a48 <myproc>
    80002454:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002456:	0000e517          	auipc	a0,0xe
    8000245a:	6f250513          	addi	a0,a0,1778 # 80010b48 <wait_lock>
    8000245e:	ffffe097          	auipc	ra,0xffffe
    80002462:	7d8080e7          	jalr	2008(ra) # 80000c36 <acquire>
    havekids = 0;
    80002466:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002468:	4a15                	li	s4,5
        havekids = 1;
    8000246a:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000246c:	00014997          	auipc	s3,0x14
    80002470:	6f498993          	addi	s3,s3,1780 # 80016b60 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002474:	0000ec17          	auipc	s8,0xe
    80002478:	6d4c0c13          	addi	s8,s8,1748 # 80010b48 <wait_lock>
    8000247c:	a0d1                	j	80002540 <wait+0x10e>
          pid = pp->pid;
    8000247e:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002482:	000b0e63          	beqz	s6,8000249e <wait+0x6c>
    80002486:	4691                	li	a3,4
    80002488:	02c48613          	addi	a2,s1,44
    8000248c:	85da                	mv	a1,s6
    8000248e:	05093503          	ld	a0,80(s2)
    80002492:	fffff097          	auipc	ra,0xfffff
    80002496:	24e080e7          	jalr	590(ra) # 800016e0 <copyout>
    8000249a:	04054163          	bltz	a0,800024dc <wait+0xaa>
          freeproc(pp);
    8000249e:	8526                	mv	a0,s1
    800024a0:	fffff097          	auipc	ra,0xfffff
    800024a4:	75a080e7          	jalr	1882(ra) # 80001bfa <freeproc>
          release(&pp->lock);
    800024a8:	8526                	mv	a0,s1
    800024aa:	fffff097          	auipc	ra,0xfffff
    800024ae:	840080e7          	jalr	-1984(ra) # 80000cea <release>
          release(&wait_lock);
    800024b2:	0000e517          	auipc	a0,0xe
    800024b6:	69650513          	addi	a0,a0,1686 # 80010b48 <wait_lock>
    800024ba:	fffff097          	auipc	ra,0xfffff
    800024be:	830080e7          	jalr	-2000(ra) # 80000cea <release>
}
    800024c2:	854e                	mv	a0,s3
    800024c4:	60a6                	ld	ra,72(sp)
    800024c6:	6406                	ld	s0,64(sp)
    800024c8:	74e2                	ld	s1,56(sp)
    800024ca:	7942                	ld	s2,48(sp)
    800024cc:	79a2                	ld	s3,40(sp)
    800024ce:	7a02                	ld	s4,32(sp)
    800024d0:	6ae2                	ld	s5,24(sp)
    800024d2:	6b42                	ld	s6,16(sp)
    800024d4:	6ba2                	ld	s7,8(sp)
    800024d6:	6c02                	ld	s8,0(sp)
    800024d8:	6161                	addi	sp,sp,80
    800024da:	8082                	ret
            release(&pp->lock);
    800024dc:	8526                	mv	a0,s1
    800024de:	fffff097          	auipc	ra,0xfffff
    800024e2:	80c080e7          	jalr	-2036(ra) # 80000cea <release>
            release(&wait_lock);
    800024e6:	0000e517          	auipc	a0,0xe
    800024ea:	66250513          	addi	a0,a0,1634 # 80010b48 <wait_lock>
    800024ee:	ffffe097          	auipc	ra,0xffffe
    800024f2:	7fc080e7          	jalr	2044(ra) # 80000cea <release>
            return -1;
    800024f6:	59fd                	li	s3,-1
    800024f8:	b7e9                	j	800024c2 <wait+0x90>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024fa:	17048493          	addi	s1,s1,368
    800024fe:	03348463          	beq	s1,s3,80002526 <wait+0xf4>
      if(pp->parent == p){
    80002502:	7c9c                	ld	a5,56(s1)
    80002504:	ff279be3          	bne	a5,s2,800024fa <wait+0xc8>
        acquire(&pp->lock);
    80002508:	8526                	mv	a0,s1
    8000250a:	ffffe097          	auipc	ra,0xffffe
    8000250e:	72c080e7          	jalr	1836(ra) # 80000c36 <acquire>
        if(pp->state == ZOMBIE){
    80002512:	4c9c                	lw	a5,24(s1)
    80002514:	f74785e3          	beq	a5,s4,8000247e <wait+0x4c>
        release(&pp->lock);
    80002518:	8526                	mv	a0,s1
    8000251a:	ffffe097          	auipc	ra,0xffffe
    8000251e:	7d0080e7          	jalr	2000(ra) # 80000cea <release>
        havekids = 1;
    80002522:	8756                	mv	a4,s5
    80002524:	bfd9                	j	800024fa <wait+0xc8>
    if(!havekids || killed(p)){
    80002526:	c31d                	beqz	a4,8000254c <wait+0x11a>
    80002528:	854a                	mv	a0,s2
    8000252a:	00000097          	auipc	ra,0x0
    8000252e:	ed6080e7          	jalr	-298(ra) # 80002400 <killed>
    80002532:	ed09                	bnez	a0,8000254c <wait+0x11a>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002534:	85e2                	mv	a1,s8
    80002536:	854a                	mv	a0,s2
    80002538:	00000097          	auipc	ra,0x0
    8000253c:	c20080e7          	jalr	-992(ra) # 80002158 <sleep>
    havekids = 0;
    80002540:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002542:	0000f497          	auipc	s1,0xf
    80002546:	a1e48493          	addi	s1,s1,-1506 # 80010f60 <proc>
    8000254a:	bf65                	j	80002502 <wait+0xd0>
      release(&wait_lock);
    8000254c:	0000e517          	auipc	a0,0xe
    80002550:	5fc50513          	addi	a0,a0,1532 # 80010b48 <wait_lock>
    80002554:	ffffe097          	auipc	ra,0xffffe
    80002558:	796080e7          	jalr	1942(ra) # 80000cea <release>
      return -1;
    8000255c:	59fd                	li	s3,-1
    8000255e:	b795                	j	800024c2 <wait+0x90>

0000000080002560 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002560:	7179                	addi	sp,sp,-48
    80002562:	f406                	sd	ra,40(sp)
    80002564:	f022                	sd	s0,32(sp)
    80002566:	ec26                	sd	s1,24(sp)
    80002568:	e84a                	sd	s2,16(sp)
    8000256a:	e44e                	sd	s3,8(sp)
    8000256c:	e052                	sd	s4,0(sp)
    8000256e:	1800                	addi	s0,sp,48
    80002570:	84aa                	mv	s1,a0
    80002572:	892e                	mv	s2,a1
    80002574:	89b2                	mv	s3,a2
    80002576:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002578:	fffff097          	auipc	ra,0xfffff
    8000257c:	4d0080e7          	jalr	1232(ra) # 80001a48 <myproc>
  if(user_dst){
    80002580:	c08d                	beqz	s1,800025a2 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002582:	86d2                	mv	a3,s4
    80002584:	864e                	mv	a2,s3
    80002586:	85ca                	mv	a1,s2
    80002588:	6928                	ld	a0,80(a0)
    8000258a:	fffff097          	auipc	ra,0xfffff
    8000258e:	156080e7          	jalr	342(ra) # 800016e0 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002592:	70a2                	ld	ra,40(sp)
    80002594:	7402                	ld	s0,32(sp)
    80002596:	64e2                	ld	s1,24(sp)
    80002598:	6942                	ld	s2,16(sp)
    8000259a:	69a2                	ld	s3,8(sp)
    8000259c:	6a02                	ld	s4,0(sp)
    8000259e:	6145                	addi	sp,sp,48
    800025a0:	8082                	ret
    memmove((char *)dst, src, len);
    800025a2:	000a061b          	sext.w	a2,s4
    800025a6:	85ce                	mv	a1,s3
    800025a8:	854a                	mv	a0,s2
    800025aa:	ffffe097          	auipc	ra,0xffffe
    800025ae:	7e4080e7          	jalr	2020(ra) # 80000d8e <memmove>
    return 0;
    800025b2:	8526                	mv	a0,s1
    800025b4:	bff9                	j	80002592 <either_copyout+0x32>

00000000800025b6 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800025b6:	7179                	addi	sp,sp,-48
    800025b8:	f406                	sd	ra,40(sp)
    800025ba:	f022                	sd	s0,32(sp)
    800025bc:	ec26                	sd	s1,24(sp)
    800025be:	e84a                	sd	s2,16(sp)
    800025c0:	e44e                	sd	s3,8(sp)
    800025c2:	e052                	sd	s4,0(sp)
    800025c4:	1800                	addi	s0,sp,48
    800025c6:	892a                	mv	s2,a0
    800025c8:	84ae                	mv	s1,a1
    800025ca:	89b2                	mv	s3,a2
    800025cc:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025ce:	fffff097          	auipc	ra,0xfffff
    800025d2:	47a080e7          	jalr	1146(ra) # 80001a48 <myproc>
  if(user_src){
    800025d6:	c08d                	beqz	s1,800025f8 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800025d8:	86d2                	mv	a3,s4
    800025da:	864e                	mv	a2,s3
    800025dc:	85ca                	mv	a1,s2
    800025de:	6928                	ld	a0,80(a0)
    800025e0:	fffff097          	auipc	ra,0xfffff
    800025e4:	18c080e7          	jalr	396(ra) # 8000176c <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800025e8:	70a2                	ld	ra,40(sp)
    800025ea:	7402                	ld	s0,32(sp)
    800025ec:	64e2                	ld	s1,24(sp)
    800025ee:	6942                	ld	s2,16(sp)
    800025f0:	69a2                	ld	s3,8(sp)
    800025f2:	6a02                	ld	s4,0(sp)
    800025f4:	6145                	addi	sp,sp,48
    800025f6:	8082                	ret
    memmove(dst, (char*)src, len);
    800025f8:	000a061b          	sext.w	a2,s4
    800025fc:	85ce                	mv	a1,s3
    800025fe:	854a                	mv	a0,s2
    80002600:	ffffe097          	auipc	ra,0xffffe
    80002604:	78e080e7          	jalr	1934(ra) # 80000d8e <memmove>
    return 0;
    80002608:	8526                	mv	a0,s1
    8000260a:	bff9                	j	800025e8 <either_copyin+0x32>

000000008000260c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000260c:	715d                	addi	sp,sp,-80
    8000260e:	e486                	sd	ra,72(sp)
    80002610:	e0a2                	sd	s0,64(sp)
    80002612:	fc26                	sd	s1,56(sp)
    80002614:	f84a                	sd	s2,48(sp)
    80002616:	f44e                	sd	s3,40(sp)
    80002618:	f052                	sd	s4,32(sp)
    8000261a:	ec56                	sd	s5,24(sp)
    8000261c:	e85a                	sd	s6,16(sp)
    8000261e:	e45e                	sd	s7,8(sp)
    80002620:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002622:	00006517          	auipc	a0,0x6
    80002626:	9ee50513          	addi	a0,a0,-1554 # 80008010 <etext+0x10>
    8000262a:	ffffe097          	auipc	ra,0xffffe
    8000262e:	f7e080e7          	jalr	-130(ra) # 800005a8 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002632:	0000f497          	auipc	s1,0xf
    80002636:	a8648493          	addi	s1,s1,-1402 # 800110b8 <proc+0x158>
    8000263a:	00014917          	auipc	s2,0x14
    8000263e:	67e90913          	addi	s2,s2,1662 # 80016cb8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002642:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002644:	00006997          	auipc	s3,0x6
    80002648:	c1c98993          	addi	s3,s3,-996 # 80008260 <etext+0x260>
    printf("%d %s %s", p->pid, state, p->name);
    8000264c:	00006a97          	auipc	s5,0x6
    80002650:	c1ca8a93          	addi	s5,s5,-996 # 80008268 <etext+0x268>
    printf("\n");
    80002654:	00006a17          	auipc	s4,0x6
    80002658:	9bca0a13          	addi	s4,s4,-1604 # 80008010 <etext+0x10>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000265c:	00006b97          	auipc	s7,0x6
    80002660:	0e4b8b93          	addi	s7,s7,228 # 80008740 <states.0>
    80002664:	a00d                	j	80002686 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002666:	ed86a583          	lw	a1,-296(a3)
    8000266a:	8556                	mv	a0,s5
    8000266c:	ffffe097          	auipc	ra,0xffffe
    80002670:	f3c080e7          	jalr	-196(ra) # 800005a8 <printf>
    printf("\n");
    80002674:	8552                	mv	a0,s4
    80002676:	ffffe097          	auipc	ra,0xffffe
    8000267a:	f32080e7          	jalr	-206(ra) # 800005a8 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000267e:	17048493          	addi	s1,s1,368
    80002682:	03248263          	beq	s1,s2,800026a6 <procdump+0x9a>
    if(p->state == UNUSED)
    80002686:	86a6                	mv	a3,s1
    80002688:	ec04a783          	lw	a5,-320(s1)
    8000268c:	dbed                	beqz	a5,8000267e <procdump+0x72>
      state = "???";
    8000268e:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002690:	fcfb6be3          	bltu	s6,a5,80002666 <procdump+0x5a>
    80002694:	02079713          	slli	a4,a5,0x20
    80002698:	01d75793          	srli	a5,a4,0x1d
    8000269c:	97de                	add	a5,a5,s7
    8000269e:	6390                	ld	a2,0(a5)
    800026a0:	f279                	bnez	a2,80002666 <procdump+0x5a>
      state = "???";
    800026a2:	864e                	mv	a2,s3
    800026a4:	b7c9                	j	80002666 <procdump+0x5a>
  }
}
    800026a6:	60a6                	ld	ra,72(sp)
    800026a8:	6406                	ld	s0,64(sp)
    800026aa:	74e2                	ld	s1,56(sp)
    800026ac:	7942                	ld	s2,48(sp)
    800026ae:	79a2                	ld	s3,40(sp)
    800026b0:	7a02                	ld	s4,32(sp)
    800026b2:	6ae2                	ld	s5,24(sp)
    800026b4:	6b42                	ld	s6,16(sp)
    800026b6:	6ba2                	ld	s7,8(sp)
    800026b8:	6161                	addi	sp,sp,80
    800026ba:	8082                	ret

00000000800026bc <swtch>:
    800026bc:	00153023          	sd	ra,0(a0)
    800026c0:	00253423          	sd	sp,8(a0)
    800026c4:	e900                	sd	s0,16(a0)
    800026c6:	ed04                	sd	s1,24(a0)
    800026c8:	03253023          	sd	s2,32(a0)
    800026cc:	03353423          	sd	s3,40(a0)
    800026d0:	03453823          	sd	s4,48(a0)
    800026d4:	03553c23          	sd	s5,56(a0)
    800026d8:	05653023          	sd	s6,64(a0)
    800026dc:	05753423          	sd	s7,72(a0)
    800026e0:	05853823          	sd	s8,80(a0)
    800026e4:	05953c23          	sd	s9,88(a0)
    800026e8:	07a53023          	sd	s10,96(a0)
    800026ec:	07b53423          	sd	s11,104(a0)
    800026f0:	0005b083          	ld	ra,0(a1)
    800026f4:	0085b103          	ld	sp,8(a1)
    800026f8:	6980                	ld	s0,16(a1)
    800026fa:	6d84                	ld	s1,24(a1)
    800026fc:	0205b903          	ld	s2,32(a1)
    80002700:	0285b983          	ld	s3,40(a1)
    80002704:	0305ba03          	ld	s4,48(a1)
    80002708:	0385ba83          	ld	s5,56(a1)
    8000270c:	0405bb03          	ld	s6,64(a1)
    80002710:	0485bb83          	ld	s7,72(a1)
    80002714:	0505bc03          	ld	s8,80(a1)
    80002718:	0585bc83          	ld	s9,88(a1)
    8000271c:	0605bd03          	ld	s10,96(a1)
    80002720:	0685bd83          	ld	s11,104(a1)
    80002724:	8082                	ret

0000000080002726 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002726:	1141                	addi	sp,sp,-16
    80002728:	e406                	sd	ra,8(sp)
    8000272a:	e022                	sd	s0,0(sp)
    8000272c:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000272e:	00006597          	auipc	a1,0x6
    80002732:	b7a58593          	addi	a1,a1,-1158 # 800082a8 <etext+0x2a8>
    80002736:	00014517          	auipc	a0,0x14
    8000273a:	42a50513          	addi	a0,a0,1066 # 80016b60 <tickslock>
    8000273e:	ffffe097          	auipc	ra,0xffffe
    80002742:	468080e7          	jalr	1128(ra) # 80000ba6 <initlock>
}
    80002746:	60a2                	ld	ra,8(sp)
    80002748:	6402                	ld	s0,0(sp)
    8000274a:	0141                	addi	sp,sp,16
    8000274c:	8082                	ret

000000008000274e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000274e:	1141                	addi	sp,sp,-16
    80002750:	e422                	sd	s0,8(sp)
    80002752:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002754:	00003797          	auipc	a5,0x3
    80002758:	59c78793          	addi	a5,a5,1436 # 80005cf0 <kernelvec>
    8000275c:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002760:	6422                	ld	s0,8(sp)
    80002762:	0141                	addi	sp,sp,16
    80002764:	8082                	ret

0000000080002766 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002766:	1141                	addi	sp,sp,-16
    80002768:	e406                	sd	ra,8(sp)
    8000276a:	e022                	sd	s0,0(sp)
    8000276c:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000276e:	fffff097          	auipc	ra,0xfffff
    80002772:	2da080e7          	jalr	730(ra) # 80001a48 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002776:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000277a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000277c:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002780:	00005697          	auipc	a3,0x5
    80002784:	88068693          	addi	a3,a3,-1920 # 80007000 <_trampoline>
    80002788:	00005717          	auipc	a4,0x5
    8000278c:	87870713          	addi	a4,a4,-1928 # 80007000 <_trampoline>
    80002790:	8f15                	sub	a4,a4,a3
    80002792:	040007b7          	lui	a5,0x4000
    80002796:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002798:	07b2                	slli	a5,a5,0xc
    8000279a:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000279c:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800027a0:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800027a2:	18002673          	csrr	a2,satp
    800027a6:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800027a8:	6d30                	ld	a2,88(a0)
    800027aa:	6138                	ld	a4,64(a0)
    800027ac:	6585                	lui	a1,0x1
    800027ae:	972e                	add	a4,a4,a1
    800027b0:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800027b2:	6d38                	ld	a4,88(a0)
    800027b4:	00000617          	auipc	a2,0x0
    800027b8:	13860613          	addi	a2,a2,312 # 800028ec <usertrap>
    800027bc:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800027be:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800027c0:	8612                	mv	a2,tp
    800027c2:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027c4:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800027c8:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800027cc:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027d0:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800027d4:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800027d6:	6f18                	ld	a4,24(a4)
    800027d8:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800027dc:	6928                	ld	a0,80(a0)
    800027de:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800027e0:	00005717          	auipc	a4,0x5
    800027e4:	8bc70713          	addi	a4,a4,-1860 # 8000709c <userret>
    800027e8:	8f15                	sub	a4,a4,a3
    800027ea:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800027ec:	577d                	li	a4,-1
    800027ee:	177e                	slli	a4,a4,0x3f
    800027f0:	8d59                	or	a0,a0,a4
    800027f2:	9782                	jalr	a5
}
    800027f4:	60a2                	ld	ra,8(sp)
    800027f6:	6402                	ld	s0,0(sp)
    800027f8:	0141                	addi	sp,sp,16
    800027fa:	8082                	ret

00000000800027fc <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800027fc:	1101                	addi	sp,sp,-32
    800027fe:	ec06                	sd	ra,24(sp)
    80002800:	e822                	sd	s0,16(sp)
    80002802:	e426                	sd	s1,8(sp)
    80002804:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002806:	00014497          	auipc	s1,0x14
    8000280a:	35a48493          	addi	s1,s1,858 # 80016b60 <tickslock>
    8000280e:	8526                	mv	a0,s1
    80002810:	ffffe097          	auipc	ra,0xffffe
    80002814:	426080e7          	jalr	1062(ra) # 80000c36 <acquire>
  ticks++;
    80002818:	00006517          	auipc	a0,0x6
    8000281c:	0a850513          	addi	a0,a0,168 # 800088c0 <ticks>
    80002820:	411c                	lw	a5,0(a0)
    80002822:	2785                	addiw	a5,a5,1
    80002824:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002826:	00000097          	auipc	ra,0x0
    8000282a:	996080e7          	jalr	-1642(ra) # 800021bc <wakeup>
  release(&tickslock);
    8000282e:	8526                	mv	a0,s1
    80002830:	ffffe097          	auipc	ra,0xffffe
    80002834:	4ba080e7          	jalr	1210(ra) # 80000cea <release>
}
    80002838:	60e2                	ld	ra,24(sp)
    8000283a:	6442                	ld	s0,16(sp)
    8000283c:	64a2                	ld	s1,8(sp)
    8000283e:	6105                	addi	sp,sp,32
    80002840:	8082                	ret

0000000080002842 <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002842:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002846:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    80002848:	0a07d163          	bgez	a5,800028ea <devintr+0xa8>
{
    8000284c:	1101                	addi	sp,sp,-32
    8000284e:	ec06                	sd	ra,24(sp)
    80002850:	e822                	sd	s0,16(sp)
    80002852:	1000                	addi	s0,sp,32
     (scause & 0xff) == 9){
    80002854:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    80002858:	46a5                	li	a3,9
    8000285a:	00d70c63          	beq	a4,a3,80002872 <devintr+0x30>
  } else if(scause == 0x8000000000000001L){
    8000285e:	577d                	li	a4,-1
    80002860:	177e                	slli	a4,a4,0x3f
    80002862:	0705                	addi	a4,a4,1
    return 0;
    80002864:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002866:	06e78163          	beq	a5,a4,800028c8 <devintr+0x86>
  }
}
    8000286a:	60e2                	ld	ra,24(sp)
    8000286c:	6442                	ld	s0,16(sp)
    8000286e:	6105                	addi	sp,sp,32
    80002870:	8082                	ret
    80002872:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002874:	00003097          	auipc	ra,0x3
    80002878:	588080e7          	jalr	1416(ra) # 80005dfc <plic_claim>
    8000287c:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000287e:	47a9                	li	a5,10
    80002880:	00f50963          	beq	a0,a5,80002892 <devintr+0x50>
    } else if(irq == VIRTIO0_IRQ){
    80002884:	4785                	li	a5,1
    80002886:	00f50b63          	beq	a0,a5,8000289c <devintr+0x5a>
    return 1;
    8000288a:	4505                	li	a0,1
    } else if(irq){
    8000288c:	ec89                	bnez	s1,800028a6 <devintr+0x64>
    8000288e:	64a2                	ld	s1,8(sp)
    80002890:	bfe9                	j	8000286a <devintr+0x28>
      uartintr();
    80002892:	ffffe097          	auipc	ra,0xffffe
    80002896:	166080e7          	jalr	358(ra) # 800009f8 <uartintr>
    if(irq)
    8000289a:	a839                	j	800028b8 <devintr+0x76>
      virtio_disk_intr();
    8000289c:	00004097          	auipc	ra,0x4
    800028a0:	a8a080e7          	jalr	-1398(ra) # 80006326 <virtio_disk_intr>
    if(irq)
    800028a4:	a811                	j	800028b8 <devintr+0x76>
      printf("unexpected interrupt irq=%d\n", irq);
    800028a6:	85a6                	mv	a1,s1
    800028a8:	00006517          	auipc	a0,0x6
    800028ac:	a0850513          	addi	a0,a0,-1528 # 800082b0 <etext+0x2b0>
    800028b0:	ffffe097          	auipc	ra,0xffffe
    800028b4:	cf8080e7          	jalr	-776(ra) # 800005a8 <printf>
      plic_complete(irq);
    800028b8:	8526                	mv	a0,s1
    800028ba:	00003097          	auipc	ra,0x3
    800028be:	566080e7          	jalr	1382(ra) # 80005e20 <plic_complete>
    return 1;
    800028c2:	4505                	li	a0,1
    800028c4:	64a2                	ld	s1,8(sp)
    800028c6:	b755                	j	8000286a <devintr+0x28>
    if(cpuid() == 0){
    800028c8:	fffff097          	auipc	ra,0xfffff
    800028cc:	154080e7          	jalr	340(ra) # 80001a1c <cpuid>
    800028d0:	c901                	beqz	a0,800028e0 <devintr+0x9e>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800028d2:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800028d6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800028d8:	14479073          	csrw	sip,a5
    return 2;
    800028dc:	4509                	li	a0,2
    800028de:	b771                	j	8000286a <devintr+0x28>
      clockintr();
    800028e0:	00000097          	auipc	ra,0x0
    800028e4:	f1c080e7          	jalr	-228(ra) # 800027fc <clockintr>
    800028e8:	b7ed                	j	800028d2 <devintr+0x90>
}
    800028ea:	8082                	ret

00000000800028ec <usertrap>:
{
    800028ec:	1101                	addi	sp,sp,-32
    800028ee:	ec06                	sd	ra,24(sp)
    800028f0:	e822                	sd	s0,16(sp)
    800028f2:	e426                	sd	s1,8(sp)
    800028f4:	e04a                	sd	s2,0(sp)
    800028f6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028f8:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800028fc:	1007f793          	andi	a5,a5,256
    80002900:	e3b1                	bnez	a5,80002944 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002902:	00003797          	auipc	a5,0x3
    80002906:	3ee78793          	addi	a5,a5,1006 # 80005cf0 <kernelvec>
    8000290a:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000290e:	fffff097          	auipc	ra,0xfffff
    80002912:	13a080e7          	jalr	314(ra) # 80001a48 <myproc>
    80002916:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002918:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000291a:	14102773          	csrr	a4,sepc
    8000291e:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002920:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002924:	47a1                	li	a5,8
    80002926:	02f70763          	beq	a4,a5,80002954 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    8000292a:	00000097          	auipc	ra,0x0
    8000292e:	f18080e7          	jalr	-232(ra) # 80002842 <devintr>
    80002932:	892a                	mv	s2,a0
    80002934:	c151                	beqz	a0,800029b8 <usertrap+0xcc>
  if(killed(p))
    80002936:	8526                	mv	a0,s1
    80002938:	00000097          	auipc	ra,0x0
    8000293c:	ac8080e7          	jalr	-1336(ra) # 80002400 <killed>
    80002940:	c929                	beqz	a0,80002992 <usertrap+0xa6>
    80002942:	a099                	j	80002988 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002944:	00006517          	auipc	a0,0x6
    80002948:	98c50513          	addi	a0,a0,-1652 # 800082d0 <etext+0x2d0>
    8000294c:	ffffe097          	auipc	ra,0xffffe
    80002950:	c12080e7          	jalr	-1006(ra) # 8000055e <panic>
    if(killed(p))
    80002954:	00000097          	auipc	ra,0x0
    80002958:	aac080e7          	jalr	-1364(ra) # 80002400 <killed>
    8000295c:	e921                	bnez	a0,800029ac <usertrap+0xc0>
    p->trapframe->epc += 4;
    8000295e:	6cb8                	ld	a4,88(s1)
    80002960:	6f1c                	ld	a5,24(a4)
    80002962:	0791                	addi	a5,a5,4
    80002964:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002966:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000296a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000296e:	10079073          	csrw	sstatus,a5
    syscall();
    80002972:	00000097          	auipc	ra,0x0
    80002976:	2d4080e7          	jalr	724(ra) # 80002c46 <syscall>
  if(killed(p))
    8000297a:	8526                	mv	a0,s1
    8000297c:	00000097          	auipc	ra,0x0
    80002980:	a84080e7          	jalr	-1404(ra) # 80002400 <killed>
    80002984:	c911                	beqz	a0,80002998 <usertrap+0xac>
    80002986:	4901                	li	s2,0
    exit(-1);
    80002988:	557d                	li	a0,-1
    8000298a:	00000097          	auipc	ra,0x0
    8000298e:	902080e7          	jalr	-1790(ra) # 8000228c <exit>
  if(which_dev == 2)
    80002992:	4789                	li	a5,2
    80002994:	04f90f63          	beq	s2,a5,800029f2 <usertrap+0x106>
  usertrapret();
    80002998:	00000097          	auipc	ra,0x0
    8000299c:	dce080e7          	jalr	-562(ra) # 80002766 <usertrapret>
}
    800029a0:	60e2                	ld	ra,24(sp)
    800029a2:	6442                	ld	s0,16(sp)
    800029a4:	64a2                	ld	s1,8(sp)
    800029a6:	6902                	ld	s2,0(sp)
    800029a8:	6105                	addi	sp,sp,32
    800029aa:	8082                	ret
      exit(-1);
    800029ac:	557d                	li	a0,-1
    800029ae:	00000097          	auipc	ra,0x0
    800029b2:	8de080e7          	jalr	-1826(ra) # 8000228c <exit>
    800029b6:	b765                	j	8000295e <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029b8:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800029bc:	5890                	lw	a2,48(s1)
    800029be:	00006517          	auipc	a0,0x6
    800029c2:	93250513          	addi	a0,a0,-1742 # 800082f0 <etext+0x2f0>
    800029c6:	ffffe097          	auipc	ra,0xffffe
    800029ca:	be2080e7          	jalr	-1054(ra) # 800005a8 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029ce:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029d2:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800029d6:	00006517          	auipc	a0,0x6
    800029da:	94a50513          	addi	a0,a0,-1718 # 80008320 <etext+0x320>
    800029de:	ffffe097          	auipc	ra,0xffffe
    800029e2:	bca080e7          	jalr	-1078(ra) # 800005a8 <printf>
    setkilled(p);
    800029e6:	8526                	mv	a0,s1
    800029e8:	00000097          	auipc	ra,0x0
    800029ec:	9ec080e7          	jalr	-1556(ra) # 800023d4 <setkilled>
    800029f0:	b769                	j	8000297a <usertrap+0x8e>
    yield();
    800029f2:	fffff097          	auipc	ra,0xfffff
    800029f6:	72a080e7          	jalr	1834(ra) # 8000211c <yield>
    800029fa:	bf79                	j	80002998 <usertrap+0xac>

00000000800029fc <kerneltrap>:
{
    800029fc:	7179                	addi	sp,sp,-48
    800029fe:	f406                	sd	ra,40(sp)
    80002a00:	f022                	sd	s0,32(sp)
    80002a02:	ec26                	sd	s1,24(sp)
    80002a04:	e84a                	sd	s2,16(sp)
    80002a06:	e44e                	sd	s3,8(sp)
    80002a08:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a0a:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a0e:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a12:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002a16:	1004f793          	andi	a5,s1,256
    80002a1a:	cb85                	beqz	a5,80002a4a <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a1c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002a20:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002a22:	ef85                	bnez	a5,80002a5a <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002a24:	00000097          	auipc	ra,0x0
    80002a28:	e1e080e7          	jalr	-482(ra) # 80002842 <devintr>
    80002a2c:	cd1d                	beqz	a0,80002a6a <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a2e:	4789                	li	a5,2
    80002a30:	06f50a63          	beq	a0,a5,80002aa4 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a34:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a38:	10049073          	csrw	sstatus,s1
}
    80002a3c:	70a2                	ld	ra,40(sp)
    80002a3e:	7402                	ld	s0,32(sp)
    80002a40:	64e2                	ld	s1,24(sp)
    80002a42:	6942                	ld	s2,16(sp)
    80002a44:	69a2                	ld	s3,8(sp)
    80002a46:	6145                	addi	sp,sp,48
    80002a48:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002a4a:	00006517          	auipc	a0,0x6
    80002a4e:	8f650513          	addi	a0,a0,-1802 # 80008340 <etext+0x340>
    80002a52:	ffffe097          	auipc	ra,0xffffe
    80002a56:	b0c080e7          	jalr	-1268(ra) # 8000055e <panic>
    panic("kerneltrap: interrupts enabled");
    80002a5a:	00006517          	auipc	a0,0x6
    80002a5e:	90e50513          	addi	a0,a0,-1778 # 80008368 <etext+0x368>
    80002a62:	ffffe097          	auipc	ra,0xffffe
    80002a66:	afc080e7          	jalr	-1284(ra) # 8000055e <panic>
    printf("scause %p\n", scause);
    80002a6a:	85ce                	mv	a1,s3
    80002a6c:	00006517          	auipc	a0,0x6
    80002a70:	91c50513          	addi	a0,a0,-1764 # 80008388 <etext+0x388>
    80002a74:	ffffe097          	auipc	ra,0xffffe
    80002a78:	b34080e7          	jalr	-1228(ra) # 800005a8 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a7c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a80:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a84:	00006517          	auipc	a0,0x6
    80002a88:	91450513          	addi	a0,a0,-1772 # 80008398 <etext+0x398>
    80002a8c:	ffffe097          	auipc	ra,0xffffe
    80002a90:	b1c080e7          	jalr	-1252(ra) # 800005a8 <printf>
    panic("kerneltrap");
    80002a94:	00006517          	auipc	a0,0x6
    80002a98:	91c50513          	addi	a0,a0,-1764 # 800083b0 <etext+0x3b0>
    80002a9c:	ffffe097          	auipc	ra,0xffffe
    80002aa0:	ac2080e7          	jalr	-1342(ra) # 8000055e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002aa4:	fffff097          	auipc	ra,0xfffff
    80002aa8:	fa4080e7          	jalr	-92(ra) # 80001a48 <myproc>
    80002aac:	d541                	beqz	a0,80002a34 <kerneltrap+0x38>
    80002aae:	fffff097          	auipc	ra,0xfffff
    80002ab2:	f9a080e7          	jalr	-102(ra) # 80001a48 <myproc>
    80002ab6:	4d18                	lw	a4,24(a0)
    80002ab8:	4791                	li	a5,4
    80002aba:	f6f71de3          	bne	a4,a5,80002a34 <kerneltrap+0x38>
    yield();
    80002abe:	fffff097          	auipc	ra,0xfffff
    80002ac2:	65e080e7          	jalr	1630(ra) # 8000211c <yield>
    80002ac6:	b7bd                	j	80002a34 <kerneltrap+0x38>

0000000080002ac8 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002ac8:	1101                	addi	sp,sp,-32
    80002aca:	ec06                	sd	ra,24(sp)
    80002acc:	e822                	sd	s0,16(sp)
    80002ace:	e426                	sd	s1,8(sp)
    80002ad0:	1000                	addi	s0,sp,32
    80002ad2:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002ad4:	fffff097          	auipc	ra,0xfffff
    80002ad8:	f74080e7          	jalr	-140(ra) # 80001a48 <myproc>
  switch (n) {
    80002adc:	4795                	li	a5,5
    80002ade:	0497e163          	bltu	a5,s1,80002b20 <argraw+0x58>
    80002ae2:	048a                	slli	s1,s1,0x2
    80002ae4:	00006717          	auipc	a4,0x6
    80002ae8:	c8c70713          	addi	a4,a4,-884 # 80008770 <states.0+0x30>
    80002aec:	94ba                	add	s1,s1,a4
    80002aee:	409c                	lw	a5,0(s1)
    80002af0:	97ba                	add	a5,a5,a4
    80002af2:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002af4:	6d3c                	ld	a5,88(a0)
    80002af6:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002af8:	60e2                	ld	ra,24(sp)
    80002afa:	6442                	ld	s0,16(sp)
    80002afc:	64a2                	ld	s1,8(sp)
    80002afe:	6105                	addi	sp,sp,32
    80002b00:	8082                	ret
    return p->trapframe->a1;
    80002b02:	6d3c                	ld	a5,88(a0)
    80002b04:	7fa8                	ld	a0,120(a5)
    80002b06:	bfcd                	j	80002af8 <argraw+0x30>
    return p->trapframe->a2;
    80002b08:	6d3c                	ld	a5,88(a0)
    80002b0a:	63c8                	ld	a0,128(a5)
    80002b0c:	b7f5                	j	80002af8 <argraw+0x30>
    return p->trapframe->a3;
    80002b0e:	6d3c                	ld	a5,88(a0)
    80002b10:	67c8                	ld	a0,136(a5)
    80002b12:	b7dd                	j	80002af8 <argraw+0x30>
    return p->trapframe->a4;
    80002b14:	6d3c                	ld	a5,88(a0)
    80002b16:	6bc8                	ld	a0,144(a5)
    80002b18:	b7c5                	j	80002af8 <argraw+0x30>
    return p->trapframe->a5;
    80002b1a:	6d3c                	ld	a5,88(a0)
    80002b1c:	6fc8                	ld	a0,152(a5)
    80002b1e:	bfe9                	j	80002af8 <argraw+0x30>
  panic("argraw");
    80002b20:	00006517          	auipc	a0,0x6
    80002b24:	8a050513          	addi	a0,a0,-1888 # 800083c0 <etext+0x3c0>
    80002b28:	ffffe097          	auipc	ra,0xffffe
    80002b2c:	a36080e7          	jalr	-1482(ra) # 8000055e <panic>

0000000080002b30 <fetchaddr>:
{
    80002b30:	1101                	addi	sp,sp,-32
    80002b32:	ec06                	sd	ra,24(sp)
    80002b34:	e822                	sd	s0,16(sp)
    80002b36:	e426                	sd	s1,8(sp)
    80002b38:	e04a                	sd	s2,0(sp)
    80002b3a:	1000                	addi	s0,sp,32
    80002b3c:	84aa                	mv	s1,a0
    80002b3e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002b40:	fffff097          	auipc	ra,0xfffff
    80002b44:	f08080e7          	jalr	-248(ra) # 80001a48 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002b48:	653c                	ld	a5,72(a0)
    80002b4a:	02f4f863          	bgeu	s1,a5,80002b7a <fetchaddr+0x4a>
    80002b4e:	00848713          	addi	a4,s1,8
    80002b52:	02e7e663          	bltu	a5,a4,80002b7e <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002b56:	46a1                	li	a3,8
    80002b58:	8626                	mv	a2,s1
    80002b5a:	85ca                	mv	a1,s2
    80002b5c:	6928                	ld	a0,80(a0)
    80002b5e:	fffff097          	auipc	ra,0xfffff
    80002b62:	c0e080e7          	jalr	-1010(ra) # 8000176c <copyin>
    80002b66:	00a03533          	snez	a0,a0
    80002b6a:	40a00533          	neg	a0,a0
}
    80002b6e:	60e2                	ld	ra,24(sp)
    80002b70:	6442                	ld	s0,16(sp)
    80002b72:	64a2                	ld	s1,8(sp)
    80002b74:	6902                	ld	s2,0(sp)
    80002b76:	6105                	addi	sp,sp,32
    80002b78:	8082                	ret
    return -1;
    80002b7a:	557d                	li	a0,-1
    80002b7c:	bfcd                	j	80002b6e <fetchaddr+0x3e>
    80002b7e:	557d                	li	a0,-1
    80002b80:	b7fd                	j	80002b6e <fetchaddr+0x3e>

0000000080002b82 <fetchstr>:
{
    80002b82:	7179                	addi	sp,sp,-48
    80002b84:	f406                	sd	ra,40(sp)
    80002b86:	f022                	sd	s0,32(sp)
    80002b88:	ec26                	sd	s1,24(sp)
    80002b8a:	e84a                	sd	s2,16(sp)
    80002b8c:	e44e                	sd	s3,8(sp)
    80002b8e:	1800                	addi	s0,sp,48
    80002b90:	892a                	mv	s2,a0
    80002b92:	84ae                	mv	s1,a1
    80002b94:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002b96:	fffff097          	auipc	ra,0xfffff
    80002b9a:	eb2080e7          	jalr	-334(ra) # 80001a48 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002b9e:	86ce                	mv	a3,s3
    80002ba0:	864a                	mv	a2,s2
    80002ba2:	85a6                	mv	a1,s1
    80002ba4:	6928                	ld	a0,80(a0)
    80002ba6:	fffff097          	auipc	ra,0xfffff
    80002baa:	c54080e7          	jalr	-940(ra) # 800017fa <copyinstr>
    80002bae:	00054e63          	bltz	a0,80002bca <fetchstr+0x48>
  return strlen(buf);
    80002bb2:	8526                	mv	a0,s1
    80002bb4:	ffffe097          	auipc	ra,0xffffe
    80002bb8:	2f2080e7          	jalr	754(ra) # 80000ea6 <strlen>
}
    80002bbc:	70a2                	ld	ra,40(sp)
    80002bbe:	7402                	ld	s0,32(sp)
    80002bc0:	64e2                	ld	s1,24(sp)
    80002bc2:	6942                	ld	s2,16(sp)
    80002bc4:	69a2                	ld	s3,8(sp)
    80002bc6:	6145                	addi	sp,sp,48
    80002bc8:	8082                	ret
    return -1;
    80002bca:	557d                	li	a0,-1
    80002bcc:	bfc5                	j	80002bbc <fetchstr+0x3a>

0000000080002bce <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002bce:	1101                	addi	sp,sp,-32
    80002bd0:	ec06                	sd	ra,24(sp)
    80002bd2:	e822                	sd	s0,16(sp)
    80002bd4:	e426                	sd	s1,8(sp)
    80002bd6:	1000                	addi	s0,sp,32
    80002bd8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002bda:	00000097          	auipc	ra,0x0
    80002bde:	eee080e7          	jalr	-274(ra) # 80002ac8 <argraw>
    80002be2:	c088                	sw	a0,0(s1)
}
    80002be4:	60e2                	ld	ra,24(sp)
    80002be6:	6442                	ld	s0,16(sp)
    80002be8:	64a2                	ld	s1,8(sp)
    80002bea:	6105                	addi	sp,sp,32
    80002bec:	8082                	ret

0000000080002bee <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002bee:	1101                	addi	sp,sp,-32
    80002bf0:	ec06                	sd	ra,24(sp)
    80002bf2:	e822                	sd	s0,16(sp)
    80002bf4:	e426                	sd	s1,8(sp)
    80002bf6:	1000                	addi	s0,sp,32
    80002bf8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002bfa:	00000097          	auipc	ra,0x0
    80002bfe:	ece080e7          	jalr	-306(ra) # 80002ac8 <argraw>
    80002c02:	e088                	sd	a0,0(s1)
}
    80002c04:	60e2                	ld	ra,24(sp)
    80002c06:	6442                	ld	s0,16(sp)
    80002c08:	64a2                	ld	s1,8(sp)
    80002c0a:	6105                	addi	sp,sp,32
    80002c0c:	8082                	ret

0000000080002c0e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002c0e:	7179                	addi	sp,sp,-48
    80002c10:	f406                	sd	ra,40(sp)
    80002c12:	f022                	sd	s0,32(sp)
    80002c14:	ec26                	sd	s1,24(sp)
    80002c16:	e84a                	sd	s2,16(sp)
    80002c18:	1800                	addi	s0,sp,48
    80002c1a:	84ae                	mv	s1,a1
    80002c1c:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002c1e:	fd840593          	addi	a1,s0,-40
    80002c22:	00000097          	auipc	ra,0x0
    80002c26:	fcc080e7          	jalr	-52(ra) # 80002bee <argaddr>
  return fetchstr(addr, buf, max);
    80002c2a:	864a                	mv	a2,s2
    80002c2c:	85a6                	mv	a1,s1
    80002c2e:	fd843503          	ld	a0,-40(s0)
    80002c32:	00000097          	auipc	ra,0x0
    80002c36:	f50080e7          	jalr	-176(ra) # 80002b82 <fetchstr>
}
    80002c3a:	70a2                	ld	ra,40(sp)
    80002c3c:	7402                	ld	s0,32(sp)
    80002c3e:	64e2                	ld	s1,24(sp)
    80002c40:	6942                	ld	s2,16(sp)
    80002c42:	6145                	addi	sp,sp,48
    80002c44:	8082                	ret

0000000080002c46 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002c46:	1101                	addi	sp,sp,-32
    80002c48:	ec06                	sd	ra,24(sp)
    80002c4a:	e822                	sd	s0,16(sp)
    80002c4c:	e426                	sd	s1,8(sp)
    80002c4e:	e04a                	sd	s2,0(sp)
    80002c50:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002c52:	fffff097          	auipc	ra,0xfffff
    80002c56:	df6080e7          	jalr	-522(ra) # 80001a48 <myproc>
    80002c5a:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002c5c:	05853903          	ld	s2,88(a0)
    80002c60:	0a893783          	ld	a5,168(s2)
    80002c64:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002c68:	37fd                	addiw	a5,a5,-1
    80002c6a:	4751                	li	a4,20
    80002c6c:	00f76f63          	bltu	a4,a5,80002c8a <syscall+0x44>
    80002c70:	00369713          	slli	a4,a3,0x3
    80002c74:	00006797          	auipc	a5,0x6
    80002c78:	b1478793          	addi	a5,a5,-1260 # 80008788 <syscalls>
    80002c7c:	97ba                	add	a5,a5,a4
    80002c7e:	639c                	ld	a5,0(a5)
    80002c80:	c789                	beqz	a5,80002c8a <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002c82:	9782                	jalr	a5
    80002c84:	06a93823          	sd	a0,112(s2)
    80002c88:	a839                	j	80002ca6 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002c8a:	15848613          	addi	a2,s1,344
    80002c8e:	588c                	lw	a1,48(s1)
    80002c90:	00005517          	auipc	a0,0x5
    80002c94:	73850513          	addi	a0,a0,1848 # 800083c8 <etext+0x3c8>
    80002c98:	ffffe097          	auipc	ra,0xffffe
    80002c9c:	910080e7          	jalr	-1776(ra) # 800005a8 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002ca0:	6cbc                	ld	a5,88(s1)
    80002ca2:	577d                	li	a4,-1
    80002ca4:	fbb8                	sd	a4,112(a5)
  }
}
    80002ca6:	60e2                	ld	ra,24(sp)
    80002ca8:	6442                	ld	s0,16(sp)
    80002caa:	64a2                	ld	s1,8(sp)
    80002cac:	6902                	ld	s2,0(sp)
    80002cae:	6105                	addi	sp,sp,32
    80002cb0:	8082                	ret

0000000080002cb2 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002cb2:	1101                	addi	sp,sp,-32
    80002cb4:	ec06                	sd	ra,24(sp)
    80002cb6:	e822                	sd	s0,16(sp)
    80002cb8:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002cba:	fec40593          	addi	a1,s0,-20
    80002cbe:	4501                	li	a0,0
    80002cc0:	00000097          	auipc	ra,0x0
    80002cc4:	f0e080e7          	jalr	-242(ra) # 80002bce <argint>
  exit(n);
    80002cc8:	fec42503          	lw	a0,-20(s0)
    80002ccc:	fffff097          	auipc	ra,0xfffff
    80002cd0:	5c0080e7          	jalr	1472(ra) # 8000228c <exit>
  return 0;  // not reached
}
    80002cd4:	4501                	li	a0,0
    80002cd6:	60e2                	ld	ra,24(sp)
    80002cd8:	6442                	ld	s0,16(sp)
    80002cda:	6105                	addi	sp,sp,32
    80002cdc:	8082                	ret

0000000080002cde <sys_getpid>:

uint64
sys_getpid(void)
{
    80002cde:	1141                	addi	sp,sp,-16
    80002ce0:	e406                	sd	ra,8(sp)
    80002ce2:	e022                	sd	s0,0(sp)
    80002ce4:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002ce6:	fffff097          	auipc	ra,0xfffff
    80002cea:	d62080e7          	jalr	-670(ra) # 80001a48 <myproc>
}
    80002cee:	5908                	lw	a0,48(a0)
    80002cf0:	60a2                	ld	ra,8(sp)
    80002cf2:	6402                	ld	s0,0(sp)
    80002cf4:	0141                	addi	sp,sp,16
    80002cf6:	8082                	ret

0000000080002cf8 <sys_fork>:

uint64
sys_fork(void)
{
    80002cf8:	1141                	addi	sp,sp,-16
    80002cfa:	e406                	sd	ra,8(sp)
    80002cfc:	e022                	sd	s0,0(sp)
    80002cfe:	0800                	addi	s0,sp,16
  return fork();
    80002d00:	fffff097          	auipc	ra,0xfffff
    80002d04:	0fe080e7          	jalr	254(ra) # 80001dfe <fork>
}
    80002d08:	60a2                	ld	ra,8(sp)
    80002d0a:	6402                	ld	s0,0(sp)
    80002d0c:	0141                	addi	sp,sp,16
    80002d0e:	8082                	ret

0000000080002d10 <sys_wait>:

uint64
sys_wait(void)
{
    80002d10:	1101                	addi	sp,sp,-32
    80002d12:	ec06                	sd	ra,24(sp)
    80002d14:	e822                	sd	s0,16(sp)
    80002d16:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002d18:	fe840593          	addi	a1,s0,-24
    80002d1c:	4501                	li	a0,0
    80002d1e:	00000097          	auipc	ra,0x0
    80002d22:	ed0080e7          	jalr	-304(ra) # 80002bee <argaddr>
  return wait(p);
    80002d26:	fe843503          	ld	a0,-24(s0)
    80002d2a:	fffff097          	auipc	ra,0xfffff
    80002d2e:	708080e7          	jalr	1800(ra) # 80002432 <wait>
}
    80002d32:	60e2                	ld	ra,24(sp)
    80002d34:	6442                	ld	s0,16(sp)
    80002d36:	6105                	addi	sp,sp,32
    80002d38:	8082                	ret

0000000080002d3a <sys_sbrk>:
  
*/

uint64
sys_sbrk(void)
{
    80002d3a:	7179                	addi	sp,sp,-48
    80002d3c:	f406                	sd	ra,40(sp)
    80002d3e:	f022                	sd	s0,32(sp)
    80002d40:	ec26                	sd	s1,24(sp)
    80002d42:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  // Se usa un único argumento 'n' (n bytes).
  argint(0, &n);
    80002d44:	fdc40593          	addi	a1,s0,-36
    80002d48:	4501                	li	a0,0
    80002d4a:	00000097          	auipc	ra,0x0
    80002d4e:	e84080e7          	jalr	-380(ra) # 80002bce <argint>
  addr = myproc()->sz;
    80002d52:	fffff097          	auipc	ra,0xfffff
    80002d56:	cf6080e7          	jalr	-778(ra) # 80001a48 <myproc>
    80002d5a:	6524                	ld	s1,72(a0)

  // Realiza la asignación inmediata mediante growproc.
  // Razonamiento: mantener ABI simple y coincidente con wrappers de usuario.
  if(growproc(n) < 0) {
    80002d5c:	fdc42503          	lw	a0,-36(s0)
    80002d60:	fffff097          	auipc	ra,0xfffff
    80002d64:	042080e7          	jalr	66(ra) # 80001da2 <growproc>
    80002d68:	00054863          	bltz	a0,80002d78 <sys_sbrk+0x3e>
    return -1;
  }
  return addr;
}
    80002d6c:	8526                	mv	a0,s1
    80002d6e:	70a2                	ld	ra,40(sp)
    80002d70:	7402                	ld	s0,32(sp)
    80002d72:	64e2                	ld	s1,24(sp)
    80002d74:	6145                	addi	sp,sp,48
    80002d76:	8082                	ret
    return -1;
    80002d78:	54fd                	li	s1,-1
    80002d7a:	bfcd                	j	80002d6c <sys_sbrk+0x32>

0000000080002d7c <sys_sleep>:

uint64
sys_sleep(void)
{
    80002d7c:	7139                	addi	sp,sp,-64
    80002d7e:	fc06                	sd	ra,56(sp)
    80002d80:	f822                	sd	s0,48(sp)
    80002d82:	f04a                	sd	s2,32(sp)
    80002d84:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002d86:	fcc40593          	addi	a1,s0,-52
    80002d8a:	4501                	li	a0,0
    80002d8c:	00000097          	auipc	ra,0x0
    80002d90:	e42080e7          	jalr	-446(ra) # 80002bce <argint>
  acquire(&tickslock);
    80002d94:	00014517          	auipc	a0,0x14
    80002d98:	dcc50513          	addi	a0,a0,-564 # 80016b60 <tickslock>
    80002d9c:	ffffe097          	auipc	ra,0xffffe
    80002da0:	e9a080e7          	jalr	-358(ra) # 80000c36 <acquire>
  ticks0 = ticks;
    80002da4:	00006917          	auipc	s2,0x6
    80002da8:	b1c92903          	lw	s2,-1252(s2) # 800088c0 <ticks>
  while(ticks - ticks0 < n){
    80002dac:	fcc42783          	lw	a5,-52(s0)
    80002db0:	c3b9                	beqz	a5,80002df6 <sys_sleep+0x7a>
    80002db2:	f426                	sd	s1,40(sp)
    80002db4:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002db6:	00014997          	auipc	s3,0x14
    80002dba:	daa98993          	addi	s3,s3,-598 # 80016b60 <tickslock>
    80002dbe:	00006497          	auipc	s1,0x6
    80002dc2:	b0248493          	addi	s1,s1,-1278 # 800088c0 <ticks>
    if(killed(myproc())){
    80002dc6:	fffff097          	auipc	ra,0xfffff
    80002dca:	c82080e7          	jalr	-894(ra) # 80001a48 <myproc>
    80002dce:	fffff097          	auipc	ra,0xfffff
    80002dd2:	632080e7          	jalr	1586(ra) # 80002400 <killed>
    80002dd6:	ed15                	bnez	a0,80002e12 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002dd8:	85ce                	mv	a1,s3
    80002dda:	8526                	mv	a0,s1
    80002ddc:	fffff097          	auipc	ra,0xfffff
    80002de0:	37c080e7          	jalr	892(ra) # 80002158 <sleep>
  while(ticks - ticks0 < n){
    80002de4:	409c                	lw	a5,0(s1)
    80002de6:	412787bb          	subw	a5,a5,s2
    80002dea:	fcc42703          	lw	a4,-52(s0)
    80002dee:	fce7ece3          	bltu	a5,a4,80002dc6 <sys_sleep+0x4a>
    80002df2:	74a2                	ld	s1,40(sp)
    80002df4:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002df6:	00014517          	auipc	a0,0x14
    80002dfa:	d6a50513          	addi	a0,a0,-662 # 80016b60 <tickslock>
    80002dfe:	ffffe097          	auipc	ra,0xffffe
    80002e02:	eec080e7          	jalr	-276(ra) # 80000cea <release>
  return 0;
    80002e06:	4501                	li	a0,0
}
    80002e08:	70e2                	ld	ra,56(sp)
    80002e0a:	7442                	ld	s0,48(sp)
    80002e0c:	7902                	ld	s2,32(sp)
    80002e0e:	6121                	addi	sp,sp,64
    80002e10:	8082                	ret
      release(&tickslock);
    80002e12:	00014517          	auipc	a0,0x14
    80002e16:	d4e50513          	addi	a0,a0,-690 # 80016b60 <tickslock>
    80002e1a:	ffffe097          	auipc	ra,0xffffe
    80002e1e:	ed0080e7          	jalr	-304(ra) # 80000cea <release>
      return -1;
    80002e22:	557d                	li	a0,-1
    80002e24:	74a2                	ld	s1,40(sp)
    80002e26:	69e2                	ld	s3,24(sp)
    80002e28:	b7c5                	j	80002e08 <sys_sleep+0x8c>

0000000080002e2a <sys_kill>:

uint64
sys_kill(void)
{
    80002e2a:	1101                	addi	sp,sp,-32
    80002e2c:	ec06                	sd	ra,24(sp)
    80002e2e:	e822                	sd	s0,16(sp)
    80002e30:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002e32:	fec40593          	addi	a1,s0,-20
    80002e36:	4501                	li	a0,0
    80002e38:	00000097          	auipc	ra,0x0
    80002e3c:	d96080e7          	jalr	-618(ra) # 80002bce <argint>
  return kill(pid);
    80002e40:	fec42503          	lw	a0,-20(s0)
    80002e44:	fffff097          	auipc	ra,0xfffff
    80002e48:	51e080e7          	jalr	1310(ra) # 80002362 <kill>
}
    80002e4c:	60e2                	ld	ra,24(sp)
    80002e4e:	6442                	ld	s0,16(sp)
    80002e50:	6105                	addi	sp,sp,32
    80002e52:	8082                	ret

0000000080002e54 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002e54:	1101                	addi	sp,sp,-32
    80002e56:	ec06                	sd	ra,24(sp)
    80002e58:	e822                	sd	s0,16(sp)
    80002e5a:	e426                	sd	s1,8(sp)
    80002e5c:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002e5e:	00014517          	auipc	a0,0x14
    80002e62:	d0250513          	addi	a0,a0,-766 # 80016b60 <tickslock>
    80002e66:	ffffe097          	auipc	ra,0xffffe
    80002e6a:	dd0080e7          	jalr	-560(ra) # 80000c36 <acquire>
  xticks = ticks;
    80002e6e:	00006497          	auipc	s1,0x6
    80002e72:	a524a483          	lw	s1,-1454(s1) # 800088c0 <ticks>
  release(&tickslock);
    80002e76:	00014517          	auipc	a0,0x14
    80002e7a:	cea50513          	addi	a0,a0,-790 # 80016b60 <tickslock>
    80002e7e:	ffffe097          	auipc	ra,0xffffe
    80002e82:	e6c080e7          	jalr	-404(ra) # 80000cea <release>
  return xticks;
}
    80002e86:	02049513          	slli	a0,s1,0x20
    80002e8a:	9101                	srli	a0,a0,0x20
    80002e8c:	60e2                	ld	ra,24(sp)
    80002e8e:	6442                	ld	s0,16(sp)
    80002e90:	64a2                	ld	s1,8(sp)
    80002e92:	6105                	addi	sp,sp,32
    80002e94:	8082                	ret

0000000080002e96 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002e96:	7179                	addi	sp,sp,-48
    80002e98:	f406                	sd	ra,40(sp)
    80002e9a:	f022                	sd	s0,32(sp)
    80002e9c:	ec26                	sd	s1,24(sp)
    80002e9e:	e84a                	sd	s2,16(sp)
    80002ea0:	e44e                	sd	s3,8(sp)
    80002ea2:	e052                	sd	s4,0(sp)
    80002ea4:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002ea6:	00005597          	auipc	a1,0x5
    80002eaa:	54258593          	addi	a1,a1,1346 # 800083e8 <etext+0x3e8>
    80002eae:	00014517          	auipc	a0,0x14
    80002eb2:	cca50513          	addi	a0,a0,-822 # 80016b78 <bcache>
    80002eb6:	ffffe097          	auipc	ra,0xffffe
    80002eba:	cf0080e7          	jalr	-784(ra) # 80000ba6 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002ebe:	0001c797          	auipc	a5,0x1c
    80002ec2:	cba78793          	addi	a5,a5,-838 # 8001eb78 <bcache+0x8000>
    80002ec6:	0001c717          	auipc	a4,0x1c
    80002eca:	f1a70713          	addi	a4,a4,-230 # 8001ede0 <bcache+0x8268>
    80002ece:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002ed2:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002ed6:	00014497          	auipc	s1,0x14
    80002eda:	cba48493          	addi	s1,s1,-838 # 80016b90 <bcache+0x18>
    b->next = bcache.head.next;
    80002ede:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002ee0:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002ee2:	00005a17          	auipc	s4,0x5
    80002ee6:	50ea0a13          	addi	s4,s4,1294 # 800083f0 <etext+0x3f0>
    b->next = bcache.head.next;
    80002eea:	2b893783          	ld	a5,696(s2)
    80002eee:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002ef0:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002ef4:	85d2                	mv	a1,s4
    80002ef6:	01048513          	addi	a0,s1,16
    80002efa:	00001097          	auipc	ra,0x1
    80002efe:	4e8080e7          	jalr	1256(ra) # 800043e2 <initsleeplock>
    bcache.head.next->prev = b;
    80002f02:	2b893783          	ld	a5,696(s2)
    80002f06:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002f08:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f0c:	45848493          	addi	s1,s1,1112
    80002f10:	fd349de3          	bne	s1,s3,80002eea <binit+0x54>
  }
}
    80002f14:	70a2                	ld	ra,40(sp)
    80002f16:	7402                	ld	s0,32(sp)
    80002f18:	64e2                	ld	s1,24(sp)
    80002f1a:	6942                	ld	s2,16(sp)
    80002f1c:	69a2                	ld	s3,8(sp)
    80002f1e:	6a02                	ld	s4,0(sp)
    80002f20:	6145                	addi	sp,sp,48
    80002f22:	8082                	ret

0000000080002f24 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002f24:	7179                	addi	sp,sp,-48
    80002f26:	f406                	sd	ra,40(sp)
    80002f28:	f022                	sd	s0,32(sp)
    80002f2a:	ec26                	sd	s1,24(sp)
    80002f2c:	e84a                	sd	s2,16(sp)
    80002f2e:	e44e                	sd	s3,8(sp)
    80002f30:	1800                	addi	s0,sp,48
    80002f32:	892a                	mv	s2,a0
    80002f34:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002f36:	00014517          	auipc	a0,0x14
    80002f3a:	c4250513          	addi	a0,a0,-958 # 80016b78 <bcache>
    80002f3e:	ffffe097          	auipc	ra,0xffffe
    80002f42:	cf8080e7          	jalr	-776(ra) # 80000c36 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002f46:	0001c497          	auipc	s1,0x1c
    80002f4a:	eea4b483          	ld	s1,-278(s1) # 8001ee30 <bcache+0x82b8>
    80002f4e:	0001c797          	auipc	a5,0x1c
    80002f52:	e9278793          	addi	a5,a5,-366 # 8001ede0 <bcache+0x8268>
    80002f56:	02f48f63          	beq	s1,a5,80002f94 <bread+0x70>
    80002f5a:	873e                	mv	a4,a5
    80002f5c:	a021                	j	80002f64 <bread+0x40>
    80002f5e:	68a4                	ld	s1,80(s1)
    80002f60:	02e48a63          	beq	s1,a4,80002f94 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002f64:	449c                	lw	a5,8(s1)
    80002f66:	ff279ce3          	bne	a5,s2,80002f5e <bread+0x3a>
    80002f6a:	44dc                	lw	a5,12(s1)
    80002f6c:	ff3799e3          	bne	a5,s3,80002f5e <bread+0x3a>
      b->refcnt++;
    80002f70:	40bc                	lw	a5,64(s1)
    80002f72:	2785                	addiw	a5,a5,1
    80002f74:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f76:	00014517          	auipc	a0,0x14
    80002f7a:	c0250513          	addi	a0,a0,-1022 # 80016b78 <bcache>
    80002f7e:	ffffe097          	auipc	ra,0xffffe
    80002f82:	d6c080e7          	jalr	-660(ra) # 80000cea <release>
      acquiresleep(&b->lock);
    80002f86:	01048513          	addi	a0,s1,16
    80002f8a:	00001097          	auipc	ra,0x1
    80002f8e:	492080e7          	jalr	1170(ra) # 8000441c <acquiresleep>
      return b;
    80002f92:	a8b9                	j	80002ff0 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f94:	0001c497          	auipc	s1,0x1c
    80002f98:	e944b483          	ld	s1,-364(s1) # 8001ee28 <bcache+0x82b0>
    80002f9c:	0001c797          	auipc	a5,0x1c
    80002fa0:	e4478793          	addi	a5,a5,-444 # 8001ede0 <bcache+0x8268>
    80002fa4:	00f48863          	beq	s1,a5,80002fb4 <bread+0x90>
    80002fa8:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002faa:	40bc                	lw	a5,64(s1)
    80002fac:	cf81                	beqz	a5,80002fc4 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002fae:	64a4                	ld	s1,72(s1)
    80002fb0:	fee49de3          	bne	s1,a4,80002faa <bread+0x86>
  panic("bget: no buffers");
    80002fb4:	00005517          	auipc	a0,0x5
    80002fb8:	44450513          	addi	a0,a0,1092 # 800083f8 <etext+0x3f8>
    80002fbc:	ffffd097          	auipc	ra,0xffffd
    80002fc0:	5a2080e7          	jalr	1442(ra) # 8000055e <panic>
      b->dev = dev;
    80002fc4:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002fc8:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002fcc:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002fd0:	4785                	li	a5,1
    80002fd2:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002fd4:	00014517          	auipc	a0,0x14
    80002fd8:	ba450513          	addi	a0,a0,-1116 # 80016b78 <bcache>
    80002fdc:	ffffe097          	auipc	ra,0xffffe
    80002fe0:	d0e080e7          	jalr	-754(ra) # 80000cea <release>
      acquiresleep(&b->lock);
    80002fe4:	01048513          	addi	a0,s1,16
    80002fe8:	00001097          	auipc	ra,0x1
    80002fec:	434080e7          	jalr	1076(ra) # 8000441c <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002ff0:	409c                	lw	a5,0(s1)
    80002ff2:	cb89                	beqz	a5,80003004 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002ff4:	8526                	mv	a0,s1
    80002ff6:	70a2                	ld	ra,40(sp)
    80002ff8:	7402                	ld	s0,32(sp)
    80002ffa:	64e2                	ld	s1,24(sp)
    80002ffc:	6942                	ld	s2,16(sp)
    80002ffe:	69a2                	ld	s3,8(sp)
    80003000:	6145                	addi	sp,sp,48
    80003002:	8082                	ret
    virtio_disk_rw(b, 0);
    80003004:	4581                	li	a1,0
    80003006:	8526                	mv	a0,s1
    80003008:	00003097          	auipc	ra,0x3
    8000300c:	0f0080e7          	jalr	240(ra) # 800060f8 <virtio_disk_rw>
    b->valid = 1;
    80003010:	4785                	li	a5,1
    80003012:	c09c                	sw	a5,0(s1)
  return b;
    80003014:	b7c5                	j	80002ff4 <bread+0xd0>

0000000080003016 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003016:	1101                	addi	sp,sp,-32
    80003018:	ec06                	sd	ra,24(sp)
    8000301a:	e822                	sd	s0,16(sp)
    8000301c:	e426                	sd	s1,8(sp)
    8000301e:	1000                	addi	s0,sp,32
    80003020:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003022:	0541                	addi	a0,a0,16
    80003024:	00001097          	auipc	ra,0x1
    80003028:	492080e7          	jalr	1170(ra) # 800044b6 <holdingsleep>
    8000302c:	cd01                	beqz	a0,80003044 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000302e:	4585                	li	a1,1
    80003030:	8526                	mv	a0,s1
    80003032:	00003097          	auipc	ra,0x3
    80003036:	0c6080e7          	jalr	198(ra) # 800060f8 <virtio_disk_rw>
}
    8000303a:	60e2                	ld	ra,24(sp)
    8000303c:	6442                	ld	s0,16(sp)
    8000303e:	64a2                	ld	s1,8(sp)
    80003040:	6105                	addi	sp,sp,32
    80003042:	8082                	ret
    panic("bwrite");
    80003044:	00005517          	auipc	a0,0x5
    80003048:	3cc50513          	addi	a0,a0,972 # 80008410 <etext+0x410>
    8000304c:	ffffd097          	auipc	ra,0xffffd
    80003050:	512080e7          	jalr	1298(ra) # 8000055e <panic>

0000000080003054 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003054:	1101                	addi	sp,sp,-32
    80003056:	ec06                	sd	ra,24(sp)
    80003058:	e822                	sd	s0,16(sp)
    8000305a:	e426                	sd	s1,8(sp)
    8000305c:	e04a                	sd	s2,0(sp)
    8000305e:	1000                	addi	s0,sp,32
    80003060:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003062:	01050913          	addi	s2,a0,16
    80003066:	854a                	mv	a0,s2
    80003068:	00001097          	auipc	ra,0x1
    8000306c:	44e080e7          	jalr	1102(ra) # 800044b6 <holdingsleep>
    80003070:	c925                	beqz	a0,800030e0 <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    80003072:	854a                	mv	a0,s2
    80003074:	00001097          	auipc	ra,0x1
    80003078:	3fe080e7          	jalr	1022(ra) # 80004472 <releasesleep>

  acquire(&bcache.lock);
    8000307c:	00014517          	auipc	a0,0x14
    80003080:	afc50513          	addi	a0,a0,-1284 # 80016b78 <bcache>
    80003084:	ffffe097          	auipc	ra,0xffffe
    80003088:	bb2080e7          	jalr	-1102(ra) # 80000c36 <acquire>
  b->refcnt--;
    8000308c:	40bc                	lw	a5,64(s1)
    8000308e:	37fd                	addiw	a5,a5,-1
    80003090:	0007871b          	sext.w	a4,a5
    80003094:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003096:	e71d                	bnez	a4,800030c4 <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003098:	68b8                	ld	a4,80(s1)
    8000309a:	64bc                	ld	a5,72(s1)
    8000309c:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    8000309e:	68b8                	ld	a4,80(s1)
    800030a0:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800030a2:	0001c797          	auipc	a5,0x1c
    800030a6:	ad678793          	addi	a5,a5,-1322 # 8001eb78 <bcache+0x8000>
    800030aa:	2b87b703          	ld	a4,696(a5)
    800030ae:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800030b0:	0001c717          	auipc	a4,0x1c
    800030b4:	d3070713          	addi	a4,a4,-720 # 8001ede0 <bcache+0x8268>
    800030b8:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800030ba:	2b87b703          	ld	a4,696(a5)
    800030be:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800030c0:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800030c4:	00014517          	auipc	a0,0x14
    800030c8:	ab450513          	addi	a0,a0,-1356 # 80016b78 <bcache>
    800030cc:	ffffe097          	auipc	ra,0xffffe
    800030d0:	c1e080e7          	jalr	-994(ra) # 80000cea <release>
}
    800030d4:	60e2                	ld	ra,24(sp)
    800030d6:	6442                	ld	s0,16(sp)
    800030d8:	64a2                	ld	s1,8(sp)
    800030da:	6902                	ld	s2,0(sp)
    800030dc:	6105                	addi	sp,sp,32
    800030de:	8082                	ret
    panic("brelse");
    800030e0:	00005517          	auipc	a0,0x5
    800030e4:	33850513          	addi	a0,a0,824 # 80008418 <etext+0x418>
    800030e8:	ffffd097          	auipc	ra,0xffffd
    800030ec:	476080e7          	jalr	1142(ra) # 8000055e <panic>

00000000800030f0 <bpin>:

void
bpin(struct buf *b) {
    800030f0:	1101                	addi	sp,sp,-32
    800030f2:	ec06                	sd	ra,24(sp)
    800030f4:	e822                	sd	s0,16(sp)
    800030f6:	e426                	sd	s1,8(sp)
    800030f8:	1000                	addi	s0,sp,32
    800030fa:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800030fc:	00014517          	auipc	a0,0x14
    80003100:	a7c50513          	addi	a0,a0,-1412 # 80016b78 <bcache>
    80003104:	ffffe097          	auipc	ra,0xffffe
    80003108:	b32080e7          	jalr	-1230(ra) # 80000c36 <acquire>
  b->refcnt++;
    8000310c:	40bc                	lw	a5,64(s1)
    8000310e:	2785                	addiw	a5,a5,1
    80003110:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003112:	00014517          	auipc	a0,0x14
    80003116:	a6650513          	addi	a0,a0,-1434 # 80016b78 <bcache>
    8000311a:	ffffe097          	auipc	ra,0xffffe
    8000311e:	bd0080e7          	jalr	-1072(ra) # 80000cea <release>
}
    80003122:	60e2                	ld	ra,24(sp)
    80003124:	6442                	ld	s0,16(sp)
    80003126:	64a2                	ld	s1,8(sp)
    80003128:	6105                	addi	sp,sp,32
    8000312a:	8082                	ret

000000008000312c <bunpin>:

void
bunpin(struct buf *b) {
    8000312c:	1101                	addi	sp,sp,-32
    8000312e:	ec06                	sd	ra,24(sp)
    80003130:	e822                	sd	s0,16(sp)
    80003132:	e426                	sd	s1,8(sp)
    80003134:	1000                	addi	s0,sp,32
    80003136:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003138:	00014517          	auipc	a0,0x14
    8000313c:	a4050513          	addi	a0,a0,-1472 # 80016b78 <bcache>
    80003140:	ffffe097          	auipc	ra,0xffffe
    80003144:	af6080e7          	jalr	-1290(ra) # 80000c36 <acquire>
  b->refcnt--;
    80003148:	40bc                	lw	a5,64(s1)
    8000314a:	37fd                	addiw	a5,a5,-1
    8000314c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000314e:	00014517          	auipc	a0,0x14
    80003152:	a2a50513          	addi	a0,a0,-1494 # 80016b78 <bcache>
    80003156:	ffffe097          	auipc	ra,0xffffe
    8000315a:	b94080e7          	jalr	-1132(ra) # 80000cea <release>
}
    8000315e:	60e2                	ld	ra,24(sp)
    80003160:	6442                	ld	s0,16(sp)
    80003162:	64a2                	ld	s1,8(sp)
    80003164:	6105                	addi	sp,sp,32
    80003166:	8082                	ret

0000000080003168 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003168:	1101                	addi	sp,sp,-32
    8000316a:	ec06                	sd	ra,24(sp)
    8000316c:	e822                	sd	s0,16(sp)
    8000316e:	e426                	sd	s1,8(sp)
    80003170:	e04a                	sd	s2,0(sp)
    80003172:	1000                	addi	s0,sp,32
    80003174:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003176:	00d5d59b          	srliw	a1,a1,0xd
    8000317a:	0001c797          	auipc	a5,0x1c
    8000317e:	0da7a783          	lw	a5,218(a5) # 8001f254 <sb+0x1c>
    80003182:	9dbd                	addw	a1,a1,a5
    80003184:	00000097          	auipc	ra,0x0
    80003188:	da0080e7          	jalr	-608(ra) # 80002f24 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000318c:	0074f713          	andi	a4,s1,7
    80003190:	4785                	li	a5,1
    80003192:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003196:	14ce                	slli	s1,s1,0x33
    80003198:	90d9                	srli	s1,s1,0x36
    8000319a:	00950733          	add	a4,a0,s1
    8000319e:	05874703          	lbu	a4,88(a4)
    800031a2:	00e7f6b3          	and	a3,a5,a4
    800031a6:	c69d                	beqz	a3,800031d4 <bfree+0x6c>
    800031a8:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800031aa:	94aa                	add	s1,s1,a0
    800031ac:	fff7c793          	not	a5,a5
    800031b0:	8f7d                	and	a4,a4,a5
    800031b2:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800031b6:	00001097          	auipc	ra,0x1
    800031ba:	148080e7          	jalr	328(ra) # 800042fe <log_write>
  brelse(bp);
    800031be:	854a                	mv	a0,s2
    800031c0:	00000097          	auipc	ra,0x0
    800031c4:	e94080e7          	jalr	-364(ra) # 80003054 <brelse>
}
    800031c8:	60e2                	ld	ra,24(sp)
    800031ca:	6442                	ld	s0,16(sp)
    800031cc:	64a2                	ld	s1,8(sp)
    800031ce:	6902                	ld	s2,0(sp)
    800031d0:	6105                	addi	sp,sp,32
    800031d2:	8082                	ret
    panic("freeing free block");
    800031d4:	00005517          	auipc	a0,0x5
    800031d8:	24c50513          	addi	a0,a0,588 # 80008420 <etext+0x420>
    800031dc:	ffffd097          	auipc	ra,0xffffd
    800031e0:	382080e7          	jalr	898(ra) # 8000055e <panic>

00000000800031e4 <balloc>:
{
    800031e4:	711d                	addi	sp,sp,-96
    800031e6:	ec86                	sd	ra,88(sp)
    800031e8:	e8a2                	sd	s0,80(sp)
    800031ea:	e4a6                	sd	s1,72(sp)
    800031ec:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800031ee:	0001c797          	auipc	a5,0x1c
    800031f2:	04e7a783          	lw	a5,78(a5) # 8001f23c <sb+0x4>
    800031f6:	10078f63          	beqz	a5,80003314 <balloc+0x130>
    800031fa:	e0ca                	sd	s2,64(sp)
    800031fc:	fc4e                	sd	s3,56(sp)
    800031fe:	f852                	sd	s4,48(sp)
    80003200:	f456                	sd	s5,40(sp)
    80003202:	f05a                	sd	s6,32(sp)
    80003204:	ec5e                	sd	s7,24(sp)
    80003206:	e862                	sd	s8,16(sp)
    80003208:	e466                	sd	s9,8(sp)
    8000320a:	8baa                	mv	s7,a0
    8000320c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000320e:	0001cb17          	auipc	s6,0x1c
    80003212:	02ab0b13          	addi	s6,s6,42 # 8001f238 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003216:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003218:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000321a:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000321c:	6c89                	lui	s9,0x2
    8000321e:	a061                	j	800032a6 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003220:	97ca                	add	a5,a5,s2
    80003222:	8e55                	or	a2,a2,a3
    80003224:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003228:	854a                	mv	a0,s2
    8000322a:	00001097          	auipc	ra,0x1
    8000322e:	0d4080e7          	jalr	212(ra) # 800042fe <log_write>
        brelse(bp);
    80003232:	854a                	mv	a0,s2
    80003234:	00000097          	auipc	ra,0x0
    80003238:	e20080e7          	jalr	-480(ra) # 80003054 <brelse>
  bp = bread(dev, bno);
    8000323c:	85a6                	mv	a1,s1
    8000323e:	855e                	mv	a0,s7
    80003240:	00000097          	auipc	ra,0x0
    80003244:	ce4080e7          	jalr	-796(ra) # 80002f24 <bread>
    80003248:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000324a:	40000613          	li	a2,1024
    8000324e:	4581                	li	a1,0
    80003250:	05850513          	addi	a0,a0,88
    80003254:	ffffe097          	auipc	ra,0xffffe
    80003258:	ade080e7          	jalr	-1314(ra) # 80000d32 <memset>
  log_write(bp);
    8000325c:	854a                	mv	a0,s2
    8000325e:	00001097          	auipc	ra,0x1
    80003262:	0a0080e7          	jalr	160(ra) # 800042fe <log_write>
  brelse(bp);
    80003266:	854a                	mv	a0,s2
    80003268:	00000097          	auipc	ra,0x0
    8000326c:	dec080e7          	jalr	-532(ra) # 80003054 <brelse>
}
    80003270:	6906                	ld	s2,64(sp)
    80003272:	79e2                	ld	s3,56(sp)
    80003274:	7a42                	ld	s4,48(sp)
    80003276:	7aa2                	ld	s5,40(sp)
    80003278:	7b02                	ld	s6,32(sp)
    8000327a:	6be2                	ld	s7,24(sp)
    8000327c:	6c42                	ld	s8,16(sp)
    8000327e:	6ca2                	ld	s9,8(sp)
}
    80003280:	8526                	mv	a0,s1
    80003282:	60e6                	ld	ra,88(sp)
    80003284:	6446                	ld	s0,80(sp)
    80003286:	64a6                	ld	s1,72(sp)
    80003288:	6125                	addi	sp,sp,96
    8000328a:	8082                	ret
    brelse(bp);
    8000328c:	854a                	mv	a0,s2
    8000328e:	00000097          	auipc	ra,0x0
    80003292:	dc6080e7          	jalr	-570(ra) # 80003054 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003296:	015c87bb          	addw	a5,s9,s5
    8000329a:	00078a9b          	sext.w	s5,a5
    8000329e:	004b2703          	lw	a4,4(s6)
    800032a2:	06eaf163          	bgeu	s5,a4,80003304 <balloc+0x120>
    bp = bread(dev, BBLOCK(b, sb));
    800032a6:	41fad79b          	sraiw	a5,s5,0x1f
    800032aa:	0137d79b          	srliw	a5,a5,0x13
    800032ae:	015787bb          	addw	a5,a5,s5
    800032b2:	40d7d79b          	sraiw	a5,a5,0xd
    800032b6:	01cb2583          	lw	a1,28(s6)
    800032ba:	9dbd                	addw	a1,a1,a5
    800032bc:	855e                	mv	a0,s7
    800032be:	00000097          	auipc	ra,0x0
    800032c2:	c66080e7          	jalr	-922(ra) # 80002f24 <bread>
    800032c6:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032c8:	004b2503          	lw	a0,4(s6)
    800032cc:	000a849b          	sext.w	s1,s5
    800032d0:	8762                	mv	a4,s8
    800032d2:	faa4fde3          	bgeu	s1,a0,8000328c <balloc+0xa8>
      m = 1 << (bi % 8);
    800032d6:	00777693          	andi	a3,a4,7
    800032da:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800032de:	41f7579b          	sraiw	a5,a4,0x1f
    800032e2:	01d7d79b          	srliw	a5,a5,0x1d
    800032e6:	9fb9                	addw	a5,a5,a4
    800032e8:	4037d79b          	sraiw	a5,a5,0x3
    800032ec:	00f90633          	add	a2,s2,a5
    800032f0:	05864603          	lbu	a2,88(a2)
    800032f4:	00c6f5b3          	and	a1,a3,a2
    800032f8:	d585                	beqz	a1,80003220 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032fa:	2705                	addiw	a4,a4,1
    800032fc:	2485                	addiw	s1,s1,1
    800032fe:	fd471ae3          	bne	a4,s4,800032d2 <balloc+0xee>
    80003302:	b769                	j	8000328c <balloc+0xa8>
    80003304:	6906                	ld	s2,64(sp)
    80003306:	79e2                	ld	s3,56(sp)
    80003308:	7a42                	ld	s4,48(sp)
    8000330a:	7aa2                	ld	s5,40(sp)
    8000330c:	7b02                	ld	s6,32(sp)
    8000330e:	6be2                	ld	s7,24(sp)
    80003310:	6c42                	ld	s8,16(sp)
    80003312:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80003314:	00005517          	auipc	a0,0x5
    80003318:	12450513          	addi	a0,a0,292 # 80008438 <etext+0x438>
    8000331c:	ffffd097          	auipc	ra,0xffffd
    80003320:	28c080e7          	jalr	652(ra) # 800005a8 <printf>
  return 0;
    80003324:	4481                	li	s1,0
    80003326:	bfa9                	j	80003280 <balloc+0x9c>

0000000080003328 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003328:	7179                	addi	sp,sp,-48
    8000332a:	f406                	sd	ra,40(sp)
    8000332c:	f022                	sd	s0,32(sp)
    8000332e:	ec26                	sd	s1,24(sp)
    80003330:	e84a                	sd	s2,16(sp)
    80003332:	e44e                	sd	s3,8(sp)
    80003334:	1800                	addi	s0,sp,48
    80003336:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003338:	47ad                	li	a5,11
    8000333a:	02b7e863          	bltu	a5,a1,8000336a <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    8000333e:	02059793          	slli	a5,a1,0x20
    80003342:	01e7d593          	srli	a1,a5,0x1e
    80003346:	00b504b3          	add	s1,a0,a1
    8000334a:	0504a903          	lw	s2,80(s1)
    8000334e:	08091263          	bnez	s2,800033d2 <bmap+0xaa>
      addr = balloc(ip->dev);
    80003352:	4108                	lw	a0,0(a0)
    80003354:	00000097          	auipc	ra,0x0
    80003358:	e90080e7          	jalr	-368(ra) # 800031e4 <balloc>
    8000335c:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003360:	06090963          	beqz	s2,800033d2 <bmap+0xaa>
        return 0;
      ip->addrs[bn] = addr;
    80003364:	0524a823          	sw	s2,80(s1)
    80003368:	a0ad                	j	800033d2 <bmap+0xaa>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000336a:	ff45849b          	addiw	s1,a1,-12
    8000336e:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003372:	0ff00793          	li	a5,255
    80003376:	08e7e863          	bltu	a5,a4,80003406 <bmap+0xde>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000337a:	08052903          	lw	s2,128(a0)
    8000337e:	00091f63          	bnez	s2,8000339c <bmap+0x74>
      addr = balloc(ip->dev);
    80003382:	4108                	lw	a0,0(a0)
    80003384:	00000097          	auipc	ra,0x0
    80003388:	e60080e7          	jalr	-416(ra) # 800031e4 <balloc>
    8000338c:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003390:	04090163          	beqz	s2,800033d2 <bmap+0xaa>
    80003394:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003396:	0929a023          	sw	s2,128(s3)
    8000339a:	a011                	j	8000339e <bmap+0x76>
    8000339c:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    8000339e:	85ca                	mv	a1,s2
    800033a0:	0009a503          	lw	a0,0(s3)
    800033a4:	00000097          	auipc	ra,0x0
    800033a8:	b80080e7          	jalr	-1152(ra) # 80002f24 <bread>
    800033ac:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800033ae:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800033b2:	02049713          	slli	a4,s1,0x20
    800033b6:	01e75593          	srli	a1,a4,0x1e
    800033ba:	00b784b3          	add	s1,a5,a1
    800033be:	0004a903          	lw	s2,0(s1)
    800033c2:	02090063          	beqz	s2,800033e2 <bmap+0xba>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800033c6:	8552                	mv	a0,s4
    800033c8:	00000097          	auipc	ra,0x0
    800033cc:	c8c080e7          	jalr	-884(ra) # 80003054 <brelse>
    return addr;
    800033d0:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800033d2:	854a                	mv	a0,s2
    800033d4:	70a2                	ld	ra,40(sp)
    800033d6:	7402                	ld	s0,32(sp)
    800033d8:	64e2                	ld	s1,24(sp)
    800033da:	6942                	ld	s2,16(sp)
    800033dc:	69a2                	ld	s3,8(sp)
    800033de:	6145                	addi	sp,sp,48
    800033e0:	8082                	ret
      addr = balloc(ip->dev);
    800033e2:	0009a503          	lw	a0,0(s3)
    800033e6:	00000097          	auipc	ra,0x0
    800033ea:	dfe080e7          	jalr	-514(ra) # 800031e4 <balloc>
    800033ee:	0005091b          	sext.w	s2,a0
      if(addr){
    800033f2:	fc090ae3          	beqz	s2,800033c6 <bmap+0x9e>
        a[bn] = addr;
    800033f6:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800033fa:	8552                	mv	a0,s4
    800033fc:	00001097          	auipc	ra,0x1
    80003400:	f02080e7          	jalr	-254(ra) # 800042fe <log_write>
    80003404:	b7c9                	j	800033c6 <bmap+0x9e>
    80003406:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003408:	00005517          	auipc	a0,0x5
    8000340c:	04850513          	addi	a0,a0,72 # 80008450 <etext+0x450>
    80003410:	ffffd097          	auipc	ra,0xffffd
    80003414:	14e080e7          	jalr	334(ra) # 8000055e <panic>

0000000080003418 <iget>:
{
    80003418:	7179                	addi	sp,sp,-48
    8000341a:	f406                	sd	ra,40(sp)
    8000341c:	f022                	sd	s0,32(sp)
    8000341e:	ec26                	sd	s1,24(sp)
    80003420:	e84a                	sd	s2,16(sp)
    80003422:	e44e                	sd	s3,8(sp)
    80003424:	e052                	sd	s4,0(sp)
    80003426:	1800                	addi	s0,sp,48
    80003428:	89aa                	mv	s3,a0
    8000342a:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000342c:	0001c517          	auipc	a0,0x1c
    80003430:	e2c50513          	addi	a0,a0,-468 # 8001f258 <itable>
    80003434:	ffffe097          	auipc	ra,0xffffe
    80003438:	802080e7          	jalr	-2046(ra) # 80000c36 <acquire>
  empty = 0;
    8000343c:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000343e:	0001c497          	auipc	s1,0x1c
    80003442:	e3248493          	addi	s1,s1,-462 # 8001f270 <itable+0x18>
    80003446:	0001e697          	auipc	a3,0x1e
    8000344a:	8ba68693          	addi	a3,a3,-1862 # 80020d00 <log>
    8000344e:	a039                	j	8000345c <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003450:	02090b63          	beqz	s2,80003486 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003454:	08848493          	addi	s1,s1,136
    80003458:	02d48a63          	beq	s1,a3,8000348c <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000345c:	449c                	lw	a5,8(s1)
    8000345e:	fef059e3          	blez	a5,80003450 <iget+0x38>
    80003462:	4098                	lw	a4,0(s1)
    80003464:	ff3716e3          	bne	a4,s3,80003450 <iget+0x38>
    80003468:	40d8                	lw	a4,4(s1)
    8000346a:	ff4713e3          	bne	a4,s4,80003450 <iget+0x38>
      ip->ref++;
    8000346e:	2785                	addiw	a5,a5,1
    80003470:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003472:	0001c517          	auipc	a0,0x1c
    80003476:	de650513          	addi	a0,a0,-538 # 8001f258 <itable>
    8000347a:	ffffe097          	auipc	ra,0xffffe
    8000347e:	870080e7          	jalr	-1936(ra) # 80000cea <release>
      return ip;
    80003482:	8926                	mv	s2,s1
    80003484:	a03d                	j	800034b2 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003486:	f7f9                	bnez	a5,80003454 <iget+0x3c>
      empty = ip;
    80003488:	8926                	mv	s2,s1
    8000348a:	b7e9                	j	80003454 <iget+0x3c>
  if(empty == 0)
    8000348c:	02090c63          	beqz	s2,800034c4 <iget+0xac>
  ip->dev = dev;
    80003490:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003494:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003498:	4785                	li	a5,1
    8000349a:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000349e:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800034a2:	0001c517          	auipc	a0,0x1c
    800034a6:	db650513          	addi	a0,a0,-586 # 8001f258 <itable>
    800034aa:	ffffe097          	auipc	ra,0xffffe
    800034ae:	840080e7          	jalr	-1984(ra) # 80000cea <release>
}
    800034b2:	854a                	mv	a0,s2
    800034b4:	70a2                	ld	ra,40(sp)
    800034b6:	7402                	ld	s0,32(sp)
    800034b8:	64e2                	ld	s1,24(sp)
    800034ba:	6942                	ld	s2,16(sp)
    800034bc:	69a2                	ld	s3,8(sp)
    800034be:	6a02                	ld	s4,0(sp)
    800034c0:	6145                	addi	sp,sp,48
    800034c2:	8082                	ret
    panic("iget: no inodes");
    800034c4:	00005517          	auipc	a0,0x5
    800034c8:	fa450513          	addi	a0,a0,-92 # 80008468 <etext+0x468>
    800034cc:	ffffd097          	auipc	ra,0xffffd
    800034d0:	092080e7          	jalr	146(ra) # 8000055e <panic>

00000000800034d4 <fsinit>:
fsinit(int dev) {
    800034d4:	7179                	addi	sp,sp,-48
    800034d6:	f406                	sd	ra,40(sp)
    800034d8:	f022                	sd	s0,32(sp)
    800034da:	ec26                	sd	s1,24(sp)
    800034dc:	e84a                	sd	s2,16(sp)
    800034de:	e44e                	sd	s3,8(sp)
    800034e0:	1800                	addi	s0,sp,48
    800034e2:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800034e4:	4585                	li	a1,1
    800034e6:	00000097          	auipc	ra,0x0
    800034ea:	a3e080e7          	jalr	-1474(ra) # 80002f24 <bread>
    800034ee:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800034f0:	0001c997          	auipc	s3,0x1c
    800034f4:	d4898993          	addi	s3,s3,-696 # 8001f238 <sb>
    800034f8:	02000613          	li	a2,32
    800034fc:	05850593          	addi	a1,a0,88
    80003500:	854e                	mv	a0,s3
    80003502:	ffffe097          	auipc	ra,0xffffe
    80003506:	88c080e7          	jalr	-1908(ra) # 80000d8e <memmove>
  brelse(bp);
    8000350a:	8526                	mv	a0,s1
    8000350c:	00000097          	auipc	ra,0x0
    80003510:	b48080e7          	jalr	-1208(ra) # 80003054 <brelse>
  if(sb.magic != FSMAGIC)
    80003514:	0009a703          	lw	a4,0(s3)
    80003518:	102037b7          	lui	a5,0x10203
    8000351c:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003520:	02f71263          	bne	a4,a5,80003544 <fsinit+0x70>
  initlog(dev, &sb);
    80003524:	0001c597          	auipc	a1,0x1c
    80003528:	d1458593          	addi	a1,a1,-748 # 8001f238 <sb>
    8000352c:	854a                	mv	a0,s2
    8000352e:	00001097          	auipc	ra,0x1
    80003532:	b60080e7          	jalr	-1184(ra) # 8000408e <initlog>
}
    80003536:	70a2                	ld	ra,40(sp)
    80003538:	7402                	ld	s0,32(sp)
    8000353a:	64e2                	ld	s1,24(sp)
    8000353c:	6942                	ld	s2,16(sp)
    8000353e:	69a2                	ld	s3,8(sp)
    80003540:	6145                	addi	sp,sp,48
    80003542:	8082                	ret
    panic("invalid file system");
    80003544:	00005517          	auipc	a0,0x5
    80003548:	f3450513          	addi	a0,a0,-204 # 80008478 <etext+0x478>
    8000354c:	ffffd097          	auipc	ra,0xffffd
    80003550:	012080e7          	jalr	18(ra) # 8000055e <panic>

0000000080003554 <iinit>:
{
    80003554:	7179                	addi	sp,sp,-48
    80003556:	f406                	sd	ra,40(sp)
    80003558:	f022                	sd	s0,32(sp)
    8000355a:	ec26                	sd	s1,24(sp)
    8000355c:	e84a                	sd	s2,16(sp)
    8000355e:	e44e                	sd	s3,8(sp)
    80003560:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003562:	00005597          	auipc	a1,0x5
    80003566:	f2e58593          	addi	a1,a1,-210 # 80008490 <etext+0x490>
    8000356a:	0001c517          	auipc	a0,0x1c
    8000356e:	cee50513          	addi	a0,a0,-786 # 8001f258 <itable>
    80003572:	ffffd097          	auipc	ra,0xffffd
    80003576:	634080e7          	jalr	1588(ra) # 80000ba6 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000357a:	0001c497          	auipc	s1,0x1c
    8000357e:	d0648493          	addi	s1,s1,-762 # 8001f280 <itable+0x28>
    80003582:	0001d997          	auipc	s3,0x1d
    80003586:	78e98993          	addi	s3,s3,1934 # 80020d10 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000358a:	00005917          	auipc	s2,0x5
    8000358e:	f0e90913          	addi	s2,s2,-242 # 80008498 <etext+0x498>
    80003592:	85ca                	mv	a1,s2
    80003594:	8526                	mv	a0,s1
    80003596:	00001097          	auipc	ra,0x1
    8000359a:	e4c080e7          	jalr	-436(ra) # 800043e2 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000359e:	08848493          	addi	s1,s1,136
    800035a2:	ff3498e3          	bne	s1,s3,80003592 <iinit+0x3e>
}
    800035a6:	70a2                	ld	ra,40(sp)
    800035a8:	7402                	ld	s0,32(sp)
    800035aa:	64e2                	ld	s1,24(sp)
    800035ac:	6942                	ld	s2,16(sp)
    800035ae:	69a2                	ld	s3,8(sp)
    800035b0:	6145                	addi	sp,sp,48
    800035b2:	8082                	ret

00000000800035b4 <ialloc>:
{
    800035b4:	7139                	addi	sp,sp,-64
    800035b6:	fc06                	sd	ra,56(sp)
    800035b8:	f822                	sd	s0,48(sp)
    800035ba:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800035bc:	0001c717          	auipc	a4,0x1c
    800035c0:	c8872703          	lw	a4,-888(a4) # 8001f244 <sb+0xc>
    800035c4:	4785                	li	a5,1
    800035c6:	06e7f463          	bgeu	a5,a4,8000362e <ialloc+0x7a>
    800035ca:	f426                	sd	s1,40(sp)
    800035cc:	f04a                	sd	s2,32(sp)
    800035ce:	ec4e                	sd	s3,24(sp)
    800035d0:	e852                	sd	s4,16(sp)
    800035d2:	e456                	sd	s5,8(sp)
    800035d4:	e05a                	sd	s6,0(sp)
    800035d6:	8aaa                	mv	s5,a0
    800035d8:	8b2e                	mv	s6,a1
    800035da:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    800035dc:	0001ca17          	auipc	s4,0x1c
    800035e0:	c5ca0a13          	addi	s4,s4,-932 # 8001f238 <sb>
    800035e4:	00495593          	srli	a1,s2,0x4
    800035e8:	018a2783          	lw	a5,24(s4)
    800035ec:	9dbd                	addw	a1,a1,a5
    800035ee:	8556                	mv	a0,s5
    800035f0:	00000097          	auipc	ra,0x0
    800035f4:	934080e7          	jalr	-1740(ra) # 80002f24 <bread>
    800035f8:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800035fa:	05850993          	addi	s3,a0,88
    800035fe:	00f97793          	andi	a5,s2,15
    80003602:	079a                	slli	a5,a5,0x6
    80003604:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003606:	00099783          	lh	a5,0(s3)
    8000360a:	cf9d                	beqz	a5,80003648 <ialloc+0x94>
    brelse(bp);
    8000360c:	00000097          	auipc	ra,0x0
    80003610:	a48080e7          	jalr	-1464(ra) # 80003054 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003614:	0905                	addi	s2,s2,1
    80003616:	00ca2703          	lw	a4,12(s4)
    8000361a:	0009079b          	sext.w	a5,s2
    8000361e:	fce7e3e3          	bltu	a5,a4,800035e4 <ialloc+0x30>
    80003622:	74a2                	ld	s1,40(sp)
    80003624:	7902                	ld	s2,32(sp)
    80003626:	69e2                	ld	s3,24(sp)
    80003628:	6a42                	ld	s4,16(sp)
    8000362a:	6aa2                	ld	s5,8(sp)
    8000362c:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    8000362e:	00005517          	auipc	a0,0x5
    80003632:	e7250513          	addi	a0,a0,-398 # 800084a0 <etext+0x4a0>
    80003636:	ffffd097          	auipc	ra,0xffffd
    8000363a:	f72080e7          	jalr	-142(ra) # 800005a8 <printf>
  return 0;
    8000363e:	4501                	li	a0,0
}
    80003640:	70e2                	ld	ra,56(sp)
    80003642:	7442                	ld	s0,48(sp)
    80003644:	6121                	addi	sp,sp,64
    80003646:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003648:	04000613          	li	a2,64
    8000364c:	4581                	li	a1,0
    8000364e:	854e                	mv	a0,s3
    80003650:	ffffd097          	auipc	ra,0xffffd
    80003654:	6e2080e7          	jalr	1762(ra) # 80000d32 <memset>
      dip->type = type;
    80003658:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000365c:	8526                	mv	a0,s1
    8000365e:	00001097          	auipc	ra,0x1
    80003662:	ca0080e7          	jalr	-864(ra) # 800042fe <log_write>
      brelse(bp);
    80003666:	8526                	mv	a0,s1
    80003668:	00000097          	auipc	ra,0x0
    8000366c:	9ec080e7          	jalr	-1556(ra) # 80003054 <brelse>
      return iget(dev, inum);
    80003670:	0009059b          	sext.w	a1,s2
    80003674:	8556                	mv	a0,s5
    80003676:	00000097          	auipc	ra,0x0
    8000367a:	da2080e7          	jalr	-606(ra) # 80003418 <iget>
    8000367e:	74a2                	ld	s1,40(sp)
    80003680:	7902                	ld	s2,32(sp)
    80003682:	69e2                	ld	s3,24(sp)
    80003684:	6a42                	ld	s4,16(sp)
    80003686:	6aa2                	ld	s5,8(sp)
    80003688:	6b02                	ld	s6,0(sp)
    8000368a:	bf5d                	j	80003640 <ialloc+0x8c>

000000008000368c <iupdate>:
{
    8000368c:	1101                	addi	sp,sp,-32
    8000368e:	ec06                	sd	ra,24(sp)
    80003690:	e822                	sd	s0,16(sp)
    80003692:	e426                	sd	s1,8(sp)
    80003694:	e04a                	sd	s2,0(sp)
    80003696:	1000                	addi	s0,sp,32
    80003698:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000369a:	415c                	lw	a5,4(a0)
    8000369c:	0047d79b          	srliw	a5,a5,0x4
    800036a0:	0001c597          	auipc	a1,0x1c
    800036a4:	bb05a583          	lw	a1,-1104(a1) # 8001f250 <sb+0x18>
    800036a8:	9dbd                	addw	a1,a1,a5
    800036aa:	4108                	lw	a0,0(a0)
    800036ac:	00000097          	auipc	ra,0x0
    800036b0:	878080e7          	jalr	-1928(ra) # 80002f24 <bread>
    800036b4:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036b6:	05850793          	addi	a5,a0,88
    800036ba:	40d8                	lw	a4,4(s1)
    800036bc:	8b3d                	andi	a4,a4,15
    800036be:	071a                	slli	a4,a4,0x6
    800036c0:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800036c2:	04449703          	lh	a4,68(s1)
    800036c6:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800036ca:	04649703          	lh	a4,70(s1)
    800036ce:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800036d2:	04849703          	lh	a4,72(s1)
    800036d6:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800036da:	04a49703          	lh	a4,74(s1)
    800036de:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800036e2:	44f8                	lw	a4,76(s1)
    800036e4:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800036e6:	03400613          	li	a2,52
    800036ea:	05048593          	addi	a1,s1,80
    800036ee:	00c78513          	addi	a0,a5,12
    800036f2:	ffffd097          	auipc	ra,0xffffd
    800036f6:	69c080e7          	jalr	1692(ra) # 80000d8e <memmove>
  log_write(bp);
    800036fa:	854a                	mv	a0,s2
    800036fc:	00001097          	auipc	ra,0x1
    80003700:	c02080e7          	jalr	-1022(ra) # 800042fe <log_write>
  brelse(bp);
    80003704:	854a                	mv	a0,s2
    80003706:	00000097          	auipc	ra,0x0
    8000370a:	94e080e7          	jalr	-1714(ra) # 80003054 <brelse>
}
    8000370e:	60e2                	ld	ra,24(sp)
    80003710:	6442                	ld	s0,16(sp)
    80003712:	64a2                	ld	s1,8(sp)
    80003714:	6902                	ld	s2,0(sp)
    80003716:	6105                	addi	sp,sp,32
    80003718:	8082                	ret

000000008000371a <idup>:
{
    8000371a:	1101                	addi	sp,sp,-32
    8000371c:	ec06                	sd	ra,24(sp)
    8000371e:	e822                	sd	s0,16(sp)
    80003720:	e426                	sd	s1,8(sp)
    80003722:	1000                	addi	s0,sp,32
    80003724:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003726:	0001c517          	auipc	a0,0x1c
    8000372a:	b3250513          	addi	a0,a0,-1230 # 8001f258 <itable>
    8000372e:	ffffd097          	auipc	ra,0xffffd
    80003732:	508080e7          	jalr	1288(ra) # 80000c36 <acquire>
  ip->ref++;
    80003736:	449c                	lw	a5,8(s1)
    80003738:	2785                	addiw	a5,a5,1
    8000373a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000373c:	0001c517          	auipc	a0,0x1c
    80003740:	b1c50513          	addi	a0,a0,-1252 # 8001f258 <itable>
    80003744:	ffffd097          	auipc	ra,0xffffd
    80003748:	5a6080e7          	jalr	1446(ra) # 80000cea <release>
}
    8000374c:	8526                	mv	a0,s1
    8000374e:	60e2                	ld	ra,24(sp)
    80003750:	6442                	ld	s0,16(sp)
    80003752:	64a2                	ld	s1,8(sp)
    80003754:	6105                	addi	sp,sp,32
    80003756:	8082                	ret

0000000080003758 <ilock>:
{
    80003758:	1101                	addi	sp,sp,-32
    8000375a:	ec06                	sd	ra,24(sp)
    8000375c:	e822                	sd	s0,16(sp)
    8000375e:	e426                	sd	s1,8(sp)
    80003760:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003762:	c10d                	beqz	a0,80003784 <ilock+0x2c>
    80003764:	84aa                	mv	s1,a0
    80003766:	451c                	lw	a5,8(a0)
    80003768:	00f05e63          	blez	a5,80003784 <ilock+0x2c>
  acquiresleep(&ip->lock);
    8000376c:	0541                	addi	a0,a0,16
    8000376e:	00001097          	auipc	ra,0x1
    80003772:	cae080e7          	jalr	-850(ra) # 8000441c <acquiresleep>
  if(ip->valid == 0){
    80003776:	40bc                	lw	a5,64(s1)
    80003778:	cf99                	beqz	a5,80003796 <ilock+0x3e>
}
    8000377a:	60e2                	ld	ra,24(sp)
    8000377c:	6442                	ld	s0,16(sp)
    8000377e:	64a2                	ld	s1,8(sp)
    80003780:	6105                	addi	sp,sp,32
    80003782:	8082                	ret
    80003784:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003786:	00005517          	auipc	a0,0x5
    8000378a:	d3250513          	addi	a0,a0,-718 # 800084b8 <etext+0x4b8>
    8000378e:	ffffd097          	auipc	ra,0xffffd
    80003792:	dd0080e7          	jalr	-560(ra) # 8000055e <panic>
    80003796:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003798:	40dc                	lw	a5,4(s1)
    8000379a:	0047d79b          	srliw	a5,a5,0x4
    8000379e:	0001c597          	auipc	a1,0x1c
    800037a2:	ab25a583          	lw	a1,-1358(a1) # 8001f250 <sb+0x18>
    800037a6:	9dbd                	addw	a1,a1,a5
    800037a8:	4088                	lw	a0,0(s1)
    800037aa:	fffff097          	auipc	ra,0xfffff
    800037ae:	77a080e7          	jalr	1914(ra) # 80002f24 <bread>
    800037b2:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800037b4:	05850593          	addi	a1,a0,88
    800037b8:	40dc                	lw	a5,4(s1)
    800037ba:	8bbd                	andi	a5,a5,15
    800037bc:	079a                	slli	a5,a5,0x6
    800037be:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800037c0:	00059783          	lh	a5,0(a1)
    800037c4:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800037c8:	00259783          	lh	a5,2(a1)
    800037cc:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800037d0:	00459783          	lh	a5,4(a1)
    800037d4:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800037d8:	00659783          	lh	a5,6(a1)
    800037dc:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800037e0:	459c                	lw	a5,8(a1)
    800037e2:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800037e4:	03400613          	li	a2,52
    800037e8:	05b1                	addi	a1,a1,12
    800037ea:	05048513          	addi	a0,s1,80
    800037ee:	ffffd097          	auipc	ra,0xffffd
    800037f2:	5a0080e7          	jalr	1440(ra) # 80000d8e <memmove>
    brelse(bp);
    800037f6:	854a                	mv	a0,s2
    800037f8:	00000097          	auipc	ra,0x0
    800037fc:	85c080e7          	jalr	-1956(ra) # 80003054 <brelse>
    ip->valid = 1;
    80003800:	4785                	li	a5,1
    80003802:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003804:	04449783          	lh	a5,68(s1)
    80003808:	c399                	beqz	a5,8000380e <ilock+0xb6>
    8000380a:	6902                	ld	s2,0(sp)
    8000380c:	b7bd                	j	8000377a <ilock+0x22>
      panic("ilock: no type");
    8000380e:	00005517          	auipc	a0,0x5
    80003812:	cb250513          	addi	a0,a0,-846 # 800084c0 <etext+0x4c0>
    80003816:	ffffd097          	auipc	ra,0xffffd
    8000381a:	d48080e7          	jalr	-696(ra) # 8000055e <panic>

000000008000381e <iunlock>:
{
    8000381e:	1101                	addi	sp,sp,-32
    80003820:	ec06                	sd	ra,24(sp)
    80003822:	e822                	sd	s0,16(sp)
    80003824:	e426                	sd	s1,8(sp)
    80003826:	e04a                	sd	s2,0(sp)
    80003828:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000382a:	c905                	beqz	a0,8000385a <iunlock+0x3c>
    8000382c:	84aa                	mv	s1,a0
    8000382e:	01050913          	addi	s2,a0,16
    80003832:	854a                	mv	a0,s2
    80003834:	00001097          	auipc	ra,0x1
    80003838:	c82080e7          	jalr	-894(ra) # 800044b6 <holdingsleep>
    8000383c:	cd19                	beqz	a0,8000385a <iunlock+0x3c>
    8000383e:	449c                	lw	a5,8(s1)
    80003840:	00f05d63          	blez	a5,8000385a <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003844:	854a                	mv	a0,s2
    80003846:	00001097          	auipc	ra,0x1
    8000384a:	c2c080e7          	jalr	-980(ra) # 80004472 <releasesleep>
}
    8000384e:	60e2                	ld	ra,24(sp)
    80003850:	6442                	ld	s0,16(sp)
    80003852:	64a2                	ld	s1,8(sp)
    80003854:	6902                	ld	s2,0(sp)
    80003856:	6105                	addi	sp,sp,32
    80003858:	8082                	ret
    panic("iunlock");
    8000385a:	00005517          	auipc	a0,0x5
    8000385e:	c7650513          	addi	a0,a0,-906 # 800084d0 <etext+0x4d0>
    80003862:	ffffd097          	auipc	ra,0xffffd
    80003866:	cfc080e7          	jalr	-772(ra) # 8000055e <panic>

000000008000386a <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000386a:	7179                	addi	sp,sp,-48
    8000386c:	f406                	sd	ra,40(sp)
    8000386e:	f022                	sd	s0,32(sp)
    80003870:	ec26                	sd	s1,24(sp)
    80003872:	e84a                	sd	s2,16(sp)
    80003874:	e44e                	sd	s3,8(sp)
    80003876:	1800                	addi	s0,sp,48
    80003878:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000387a:	05050493          	addi	s1,a0,80
    8000387e:	08050913          	addi	s2,a0,128
    80003882:	a021                	j	8000388a <itrunc+0x20>
    80003884:	0491                	addi	s1,s1,4
    80003886:	01248d63          	beq	s1,s2,800038a0 <itrunc+0x36>
    if(ip->addrs[i]){
    8000388a:	408c                	lw	a1,0(s1)
    8000388c:	dde5                	beqz	a1,80003884 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    8000388e:	0009a503          	lw	a0,0(s3)
    80003892:	00000097          	auipc	ra,0x0
    80003896:	8d6080e7          	jalr	-1834(ra) # 80003168 <bfree>
      ip->addrs[i] = 0;
    8000389a:	0004a023          	sw	zero,0(s1)
    8000389e:	b7dd                	j	80003884 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800038a0:	0809a583          	lw	a1,128(s3)
    800038a4:	ed99                	bnez	a1,800038c2 <itrunc+0x58>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800038a6:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800038aa:	854e                	mv	a0,s3
    800038ac:	00000097          	auipc	ra,0x0
    800038b0:	de0080e7          	jalr	-544(ra) # 8000368c <iupdate>
}
    800038b4:	70a2                	ld	ra,40(sp)
    800038b6:	7402                	ld	s0,32(sp)
    800038b8:	64e2                	ld	s1,24(sp)
    800038ba:	6942                	ld	s2,16(sp)
    800038bc:	69a2                	ld	s3,8(sp)
    800038be:	6145                	addi	sp,sp,48
    800038c0:	8082                	ret
    800038c2:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800038c4:	0009a503          	lw	a0,0(s3)
    800038c8:	fffff097          	auipc	ra,0xfffff
    800038cc:	65c080e7          	jalr	1628(ra) # 80002f24 <bread>
    800038d0:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800038d2:	05850493          	addi	s1,a0,88
    800038d6:	45850913          	addi	s2,a0,1112
    800038da:	a021                	j	800038e2 <itrunc+0x78>
    800038dc:	0491                	addi	s1,s1,4
    800038de:	01248b63          	beq	s1,s2,800038f4 <itrunc+0x8a>
      if(a[j])
    800038e2:	408c                	lw	a1,0(s1)
    800038e4:	dde5                	beqz	a1,800038dc <itrunc+0x72>
        bfree(ip->dev, a[j]);
    800038e6:	0009a503          	lw	a0,0(s3)
    800038ea:	00000097          	auipc	ra,0x0
    800038ee:	87e080e7          	jalr	-1922(ra) # 80003168 <bfree>
    800038f2:	b7ed                	j	800038dc <itrunc+0x72>
    brelse(bp);
    800038f4:	8552                	mv	a0,s4
    800038f6:	fffff097          	auipc	ra,0xfffff
    800038fa:	75e080e7          	jalr	1886(ra) # 80003054 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800038fe:	0809a583          	lw	a1,128(s3)
    80003902:	0009a503          	lw	a0,0(s3)
    80003906:	00000097          	auipc	ra,0x0
    8000390a:	862080e7          	jalr	-1950(ra) # 80003168 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000390e:	0809a023          	sw	zero,128(s3)
    80003912:	6a02                	ld	s4,0(sp)
    80003914:	bf49                	j	800038a6 <itrunc+0x3c>

0000000080003916 <iput>:
{
    80003916:	1101                	addi	sp,sp,-32
    80003918:	ec06                	sd	ra,24(sp)
    8000391a:	e822                	sd	s0,16(sp)
    8000391c:	e426                	sd	s1,8(sp)
    8000391e:	1000                	addi	s0,sp,32
    80003920:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003922:	0001c517          	auipc	a0,0x1c
    80003926:	93650513          	addi	a0,a0,-1738 # 8001f258 <itable>
    8000392a:	ffffd097          	auipc	ra,0xffffd
    8000392e:	30c080e7          	jalr	780(ra) # 80000c36 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003932:	4498                	lw	a4,8(s1)
    80003934:	4785                	li	a5,1
    80003936:	02f70263          	beq	a4,a5,8000395a <iput+0x44>
  ip->ref--;
    8000393a:	449c                	lw	a5,8(s1)
    8000393c:	37fd                	addiw	a5,a5,-1
    8000393e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003940:	0001c517          	auipc	a0,0x1c
    80003944:	91850513          	addi	a0,a0,-1768 # 8001f258 <itable>
    80003948:	ffffd097          	auipc	ra,0xffffd
    8000394c:	3a2080e7          	jalr	930(ra) # 80000cea <release>
}
    80003950:	60e2                	ld	ra,24(sp)
    80003952:	6442                	ld	s0,16(sp)
    80003954:	64a2                	ld	s1,8(sp)
    80003956:	6105                	addi	sp,sp,32
    80003958:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000395a:	40bc                	lw	a5,64(s1)
    8000395c:	dff9                	beqz	a5,8000393a <iput+0x24>
    8000395e:	04a49783          	lh	a5,74(s1)
    80003962:	ffe1                	bnez	a5,8000393a <iput+0x24>
    80003964:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003966:	01048913          	addi	s2,s1,16
    8000396a:	854a                	mv	a0,s2
    8000396c:	00001097          	auipc	ra,0x1
    80003970:	ab0080e7          	jalr	-1360(ra) # 8000441c <acquiresleep>
    release(&itable.lock);
    80003974:	0001c517          	auipc	a0,0x1c
    80003978:	8e450513          	addi	a0,a0,-1820 # 8001f258 <itable>
    8000397c:	ffffd097          	auipc	ra,0xffffd
    80003980:	36e080e7          	jalr	878(ra) # 80000cea <release>
    itrunc(ip);
    80003984:	8526                	mv	a0,s1
    80003986:	00000097          	auipc	ra,0x0
    8000398a:	ee4080e7          	jalr	-284(ra) # 8000386a <itrunc>
    ip->type = 0;
    8000398e:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003992:	8526                	mv	a0,s1
    80003994:	00000097          	auipc	ra,0x0
    80003998:	cf8080e7          	jalr	-776(ra) # 8000368c <iupdate>
    ip->valid = 0;
    8000399c:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800039a0:	854a                	mv	a0,s2
    800039a2:	00001097          	auipc	ra,0x1
    800039a6:	ad0080e7          	jalr	-1328(ra) # 80004472 <releasesleep>
    acquire(&itable.lock);
    800039aa:	0001c517          	auipc	a0,0x1c
    800039ae:	8ae50513          	addi	a0,a0,-1874 # 8001f258 <itable>
    800039b2:	ffffd097          	auipc	ra,0xffffd
    800039b6:	284080e7          	jalr	644(ra) # 80000c36 <acquire>
    800039ba:	6902                	ld	s2,0(sp)
    800039bc:	bfbd                	j	8000393a <iput+0x24>

00000000800039be <iunlockput>:
{
    800039be:	1101                	addi	sp,sp,-32
    800039c0:	ec06                	sd	ra,24(sp)
    800039c2:	e822                	sd	s0,16(sp)
    800039c4:	e426                	sd	s1,8(sp)
    800039c6:	1000                	addi	s0,sp,32
    800039c8:	84aa                	mv	s1,a0
  iunlock(ip);
    800039ca:	00000097          	auipc	ra,0x0
    800039ce:	e54080e7          	jalr	-428(ra) # 8000381e <iunlock>
  iput(ip);
    800039d2:	8526                	mv	a0,s1
    800039d4:	00000097          	auipc	ra,0x0
    800039d8:	f42080e7          	jalr	-190(ra) # 80003916 <iput>
}
    800039dc:	60e2                	ld	ra,24(sp)
    800039de:	6442                	ld	s0,16(sp)
    800039e0:	64a2                	ld	s1,8(sp)
    800039e2:	6105                	addi	sp,sp,32
    800039e4:	8082                	ret

00000000800039e6 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800039e6:	1141                	addi	sp,sp,-16
    800039e8:	e422                	sd	s0,8(sp)
    800039ea:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800039ec:	411c                	lw	a5,0(a0)
    800039ee:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800039f0:	415c                	lw	a5,4(a0)
    800039f2:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800039f4:	04451783          	lh	a5,68(a0)
    800039f8:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800039fc:	04a51783          	lh	a5,74(a0)
    80003a00:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003a04:	04c56783          	lwu	a5,76(a0)
    80003a08:	e99c                	sd	a5,16(a1)
}
    80003a0a:	6422                	ld	s0,8(sp)
    80003a0c:	0141                	addi	sp,sp,16
    80003a0e:	8082                	ret

0000000080003a10 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a10:	457c                	lw	a5,76(a0)
    80003a12:	10d7e563          	bltu	a5,a3,80003b1c <readi+0x10c>
{
    80003a16:	7159                	addi	sp,sp,-112
    80003a18:	f486                	sd	ra,104(sp)
    80003a1a:	f0a2                	sd	s0,96(sp)
    80003a1c:	eca6                	sd	s1,88(sp)
    80003a1e:	e0d2                	sd	s4,64(sp)
    80003a20:	fc56                	sd	s5,56(sp)
    80003a22:	f85a                	sd	s6,48(sp)
    80003a24:	f45e                	sd	s7,40(sp)
    80003a26:	1880                	addi	s0,sp,112
    80003a28:	8b2a                	mv	s6,a0
    80003a2a:	8bae                	mv	s7,a1
    80003a2c:	8a32                	mv	s4,a2
    80003a2e:	84b6                	mv	s1,a3
    80003a30:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003a32:	9f35                	addw	a4,a4,a3
    return 0;
    80003a34:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003a36:	0cd76a63          	bltu	a4,a3,80003b0a <readi+0xfa>
    80003a3a:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003a3c:	00e7f463          	bgeu	a5,a4,80003a44 <readi+0x34>
    n = ip->size - off;
    80003a40:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a44:	0a0a8963          	beqz	s5,80003af6 <readi+0xe6>
    80003a48:	e8ca                	sd	s2,80(sp)
    80003a4a:	f062                	sd	s8,32(sp)
    80003a4c:	ec66                	sd	s9,24(sp)
    80003a4e:	e86a                	sd	s10,16(sp)
    80003a50:	e46e                	sd	s11,8(sp)
    80003a52:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a54:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003a58:	5c7d                	li	s8,-1
    80003a5a:	a82d                	j	80003a94 <readi+0x84>
    80003a5c:	020d1d93          	slli	s11,s10,0x20
    80003a60:	020ddd93          	srli	s11,s11,0x20
    80003a64:	05890613          	addi	a2,s2,88
    80003a68:	86ee                	mv	a3,s11
    80003a6a:	963a                	add	a2,a2,a4
    80003a6c:	85d2                	mv	a1,s4
    80003a6e:	855e                	mv	a0,s7
    80003a70:	fffff097          	auipc	ra,0xfffff
    80003a74:	af0080e7          	jalr	-1296(ra) # 80002560 <either_copyout>
    80003a78:	05850d63          	beq	a0,s8,80003ad2 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003a7c:	854a                	mv	a0,s2
    80003a7e:	fffff097          	auipc	ra,0xfffff
    80003a82:	5d6080e7          	jalr	1494(ra) # 80003054 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a86:	013d09bb          	addw	s3,s10,s3
    80003a8a:	009d04bb          	addw	s1,s10,s1
    80003a8e:	9a6e                	add	s4,s4,s11
    80003a90:	0559fd63          	bgeu	s3,s5,80003aea <readi+0xda>
    uint addr = bmap(ip, off/BSIZE);
    80003a94:	00a4d59b          	srliw	a1,s1,0xa
    80003a98:	855a                	mv	a0,s6
    80003a9a:	00000097          	auipc	ra,0x0
    80003a9e:	88e080e7          	jalr	-1906(ra) # 80003328 <bmap>
    80003aa2:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003aa6:	c9b1                	beqz	a1,80003afa <readi+0xea>
    bp = bread(ip->dev, addr);
    80003aa8:	000b2503          	lw	a0,0(s6)
    80003aac:	fffff097          	auipc	ra,0xfffff
    80003ab0:	478080e7          	jalr	1144(ra) # 80002f24 <bread>
    80003ab4:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ab6:	3ff4f713          	andi	a4,s1,1023
    80003aba:	40ec87bb          	subw	a5,s9,a4
    80003abe:	413a86bb          	subw	a3,s5,s3
    80003ac2:	8d3e                	mv	s10,a5
    80003ac4:	2781                	sext.w	a5,a5
    80003ac6:	0006861b          	sext.w	a2,a3
    80003aca:	f8f679e3          	bgeu	a2,a5,80003a5c <readi+0x4c>
    80003ace:	8d36                	mv	s10,a3
    80003ad0:	b771                	j	80003a5c <readi+0x4c>
      brelse(bp);
    80003ad2:	854a                	mv	a0,s2
    80003ad4:	fffff097          	auipc	ra,0xfffff
    80003ad8:	580080e7          	jalr	1408(ra) # 80003054 <brelse>
      tot = -1;
    80003adc:	59fd                	li	s3,-1
      break;
    80003ade:	6946                	ld	s2,80(sp)
    80003ae0:	7c02                	ld	s8,32(sp)
    80003ae2:	6ce2                	ld	s9,24(sp)
    80003ae4:	6d42                	ld	s10,16(sp)
    80003ae6:	6da2                	ld	s11,8(sp)
    80003ae8:	a831                	j	80003b04 <readi+0xf4>
    80003aea:	6946                	ld	s2,80(sp)
    80003aec:	7c02                	ld	s8,32(sp)
    80003aee:	6ce2                	ld	s9,24(sp)
    80003af0:	6d42                	ld	s10,16(sp)
    80003af2:	6da2                	ld	s11,8(sp)
    80003af4:	a801                	j	80003b04 <readi+0xf4>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003af6:	89d6                	mv	s3,s5
    80003af8:	a031                	j	80003b04 <readi+0xf4>
    80003afa:	6946                	ld	s2,80(sp)
    80003afc:	7c02                	ld	s8,32(sp)
    80003afe:	6ce2                	ld	s9,24(sp)
    80003b00:	6d42                	ld	s10,16(sp)
    80003b02:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003b04:	0009851b          	sext.w	a0,s3
    80003b08:	69a6                	ld	s3,72(sp)
}
    80003b0a:	70a6                	ld	ra,104(sp)
    80003b0c:	7406                	ld	s0,96(sp)
    80003b0e:	64e6                	ld	s1,88(sp)
    80003b10:	6a06                	ld	s4,64(sp)
    80003b12:	7ae2                	ld	s5,56(sp)
    80003b14:	7b42                	ld	s6,48(sp)
    80003b16:	7ba2                	ld	s7,40(sp)
    80003b18:	6165                	addi	sp,sp,112
    80003b1a:	8082                	ret
    return 0;
    80003b1c:	4501                	li	a0,0
}
    80003b1e:	8082                	ret

0000000080003b20 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b20:	457c                	lw	a5,76(a0)
    80003b22:	10d7ee63          	bltu	a5,a3,80003c3e <writei+0x11e>
{
    80003b26:	7159                	addi	sp,sp,-112
    80003b28:	f486                	sd	ra,104(sp)
    80003b2a:	f0a2                	sd	s0,96(sp)
    80003b2c:	e8ca                	sd	s2,80(sp)
    80003b2e:	e0d2                	sd	s4,64(sp)
    80003b30:	fc56                	sd	s5,56(sp)
    80003b32:	f85a                	sd	s6,48(sp)
    80003b34:	f45e                	sd	s7,40(sp)
    80003b36:	1880                	addi	s0,sp,112
    80003b38:	8aaa                	mv	s5,a0
    80003b3a:	8bae                	mv	s7,a1
    80003b3c:	8a32                	mv	s4,a2
    80003b3e:	8936                	mv	s2,a3
    80003b40:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003b42:	00e687bb          	addw	a5,a3,a4
    80003b46:	0ed7ee63          	bltu	a5,a3,80003c42 <writei+0x122>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003b4a:	00043737          	lui	a4,0x43
    80003b4e:	0ef76c63          	bltu	a4,a5,80003c46 <writei+0x126>
    80003b52:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b54:	0c0b0d63          	beqz	s6,80003c2e <writei+0x10e>
    80003b58:	eca6                	sd	s1,88(sp)
    80003b5a:	f062                	sd	s8,32(sp)
    80003b5c:	ec66                	sd	s9,24(sp)
    80003b5e:	e86a                	sd	s10,16(sp)
    80003b60:	e46e                	sd	s11,8(sp)
    80003b62:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b64:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003b68:	5c7d                	li	s8,-1
    80003b6a:	a091                	j	80003bae <writei+0x8e>
    80003b6c:	020d1d93          	slli	s11,s10,0x20
    80003b70:	020ddd93          	srli	s11,s11,0x20
    80003b74:	05848513          	addi	a0,s1,88
    80003b78:	86ee                	mv	a3,s11
    80003b7a:	8652                	mv	a2,s4
    80003b7c:	85de                	mv	a1,s7
    80003b7e:	953a                	add	a0,a0,a4
    80003b80:	fffff097          	auipc	ra,0xfffff
    80003b84:	a36080e7          	jalr	-1482(ra) # 800025b6 <either_copyin>
    80003b88:	07850263          	beq	a0,s8,80003bec <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003b8c:	8526                	mv	a0,s1
    80003b8e:	00000097          	auipc	ra,0x0
    80003b92:	770080e7          	jalr	1904(ra) # 800042fe <log_write>
    brelse(bp);
    80003b96:	8526                	mv	a0,s1
    80003b98:	fffff097          	auipc	ra,0xfffff
    80003b9c:	4bc080e7          	jalr	1212(ra) # 80003054 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ba0:	013d09bb          	addw	s3,s10,s3
    80003ba4:	012d093b          	addw	s2,s10,s2
    80003ba8:	9a6e                	add	s4,s4,s11
    80003baa:	0569f663          	bgeu	s3,s6,80003bf6 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003bae:	00a9559b          	srliw	a1,s2,0xa
    80003bb2:	8556                	mv	a0,s5
    80003bb4:	fffff097          	auipc	ra,0xfffff
    80003bb8:	774080e7          	jalr	1908(ra) # 80003328 <bmap>
    80003bbc:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003bc0:	c99d                	beqz	a1,80003bf6 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003bc2:	000aa503          	lw	a0,0(s5)
    80003bc6:	fffff097          	auipc	ra,0xfffff
    80003bca:	35e080e7          	jalr	862(ra) # 80002f24 <bread>
    80003bce:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bd0:	3ff97713          	andi	a4,s2,1023
    80003bd4:	40ec87bb          	subw	a5,s9,a4
    80003bd8:	413b06bb          	subw	a3,s6,s3
    80003bdc:	8d3e                	mv	s10,a5
    80003bde:	2781                	sext.w	a5,a5
    80003be0:	0006861b          	sext.w	a2,a3
    80003be4:	f8f674e3          	bgeu	a2,a5,80003b6c <writei+0x4c>
    80003be8:	8d36                	mv	s10,a3
    80003bea:	b749                	j	80003b6c <writei+0x4c>
      brelse(bp);
    80003bec:	8526                	mv	a0,s1
    80003bee:	fffff097          	auipc	ra,0xfffff
    80003bf2:	466080e7          	jalr	1126(ra) # 80003054 <brelse>
  }

  if(off > ip->size)
    80003bf6:	04caa783          	lw	a5,76(s5)
    80003bfa:	0327fc63          	bgeu	a5,s2,80003c32 <writei+0x112>
    ip->size = off;
    80003bfe:	052aa623          	sw	s2,76(s5)
    80003c02:	64e6                	ld	s1,88(sp)
    80003c04:	7c02                	ld	s8,32(sp)
    80003c06:	6ce2                	ld	s9,24(sp)
    80003c08:	6d42                	ld	s10,16(sp)
    80003c0a:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003c0c:	8556                	mv	a0,s5
    80003c0e:	00000097          	auipc	ra,0x0
    80003c12:	a7e080e7          	jalr	-1410(ra) # 8000368c <iupdate>

  return tot;
    80003c16:	0009851b          	sext.w	a0,s3
    80003c1a:	69a6                	ld	s3,72(sp)
}
    80003c1c:	70a6                	ld	ra,104(sp)
    80003c1e:	7406                	ld	s0,96(sp)
    80003c20:	6946                	ld	s2,80(sp)
    80003c22:	6a06                	ld	s4,64(sp)
    80003c24:	7ae2                	ld	s5,56(sp)
    80003c26:	7b42                	ld	s6,48(sp)
    80003c28:	7ba2                	ld	s7,40(sp)
    80003c2a:	6165                	addi	sp,sp,112
    80003c2c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c2e:	89da                	mv	s3,s6
    80003c30:	bff1                	j	80003c0c <writei+0xec>
    80003c32:	64e6                	ld	s1,88(sp)
    80003c34:	7c02                	ld	s8,32(sp)
    80003c36:	6ce2                	ld	s9,24(sp)
    80003c38:	6d42                	ld	s10,16(sp)
    80003c3a:	6da2                	ld	s11,8(sp)
    80003c3c:	bfc1                	j	80003c0c <writei+0xec>
    return -1;
    80003c3e:	557d                	li	a0,-1
}
    80003c40:	8082                	ret
    return -1;
    80003c42:	557d                	li	a0,-1
    80003c44:	bfe1                	j	80003c1c <writei+0xfc>
    return -1;
    80003c46:	557d                	li	a0,-1
    80003c48:	bfd1                	j	80003c1c <writei+0xfc>

0000000080003c4a <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003c4a:	1141                	addi	sp,sp,-16
    80003c4c:	e406                	sd	ra,8(sp)
    80003c4e:	e022                	sd	s0,0(sp)
    80003c50:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003c52:	4639                	li	a2,14
    80003c54:	ffffd097          	auipc	ra,0xffffd
    80003c58:	1ae080e7          	jalr	430(ra) # 80000e02 <strncmp>
}
    80003c5c:	60a2                	ld	ra,8(sp)
    80003c5e:	6402                	ld	s0,0(sp)
    80003c60:	0141                	addi	sp,sp,16
    80003c62:	8082                	ret

0000000080003c64 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003c64:	7139                	addi	sp,sp,-64
    80003c66:	fc06                	sd	ra,56(sp)
    80003c68:	f822                	sd	s0,48(sp)
    80003c6a:	f426                	sd	s1,40(sp)
    80003c6c:	f04a                	sd	s2,32(sp)
    80003c6e:	ec4e                	sd	s3,24(sp)
    80003c70:	e852                	sd	s4,16(sp)
    80003c72:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003c74:	04451703          	lh	a4,68(a0)
    80003c78:	4785                	li	a5,1
    80003c7a:	00f71a63          	bne	a4,a5,80003c8e <dirlookup+0x2a>
    80003c7e:	892a                	mv	s2,a0
    80003c80:	89ae                	mv	s3,a1
    80003c82:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c84:	457c                	lw	a5,76(a0)
    80003c86:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003c88:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c8a:	e79d                	bnez	a5,80003cb8 <dirlookup+0x54>
    80003c8c:	a8a5                	j	80003d04 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003c8e:	00005517          	auipc	a0,0x5
    80003c92:	84a50513          	addi	a0,a0,-1974 # 800084d8 <etext+0x4d8>
    80003c96:	ffffd097          	auipc	ra,0xffffd
    80003c9a:	8c8080e7          	jalr	-1848(ra) # 8000055e <panic>
      panic("dirlookup read");
    80003c9e:	00005517          	auipc	a0,0x5
    80003ca2:	85250513          	addi	a0,a0,-1966 # 800084f0 <etext+0x4f0>
    80003ca6:	ffffd097          	auipc	ra,0xffffd
    80003caa:	8b8080e7          	jalr	-1864(ra) # 8000055e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003cae:	24c1                	addiw	s1,s1,16
    80003cb0:	04c92783          	lw	a5,76(s2)
    80003cb4:	04f4f763          	bgeu	s1,a5,80003d02 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003cb8:	4741                	li	a4,16
    80003cba:	86a6                	mv	a3,s1
    80003cbc:	fc040613          	addi	a2,s0,-64
    80003cc0:	4581                	li	a1,0
    80003cc2:	854a                	mv	a0,s2
    80003cc4:	00000097          	auipc	ra,0x0
    80003cc8:	d4c080e7          	jalr	-692(ra) # 80003a10 <readi>
    80003ccc:	47c1                	li	a5,16
    80003cce:	fcf518e3          	bne	a0,a5,80003c9e <dirlookup+0x3a>
    if(de.inum == 0)
    80003cd2:	fc045783          	lhu	a5,-64(s0)
    80003cd6:	dfe1                	beqz	a5,80003cae <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003cd8:	fc240593          	addi	a1,s0,-62
    80003cdc:	854e                	mv	a0,s3
    80003cde:	00000097          	auipc	ra,0x0
    80003ce2:	f6c080e7          	jalr	-148(ra) # 80003c4a <namecmp>
    80003ce6:	f561                	bnez	a0,80003cae <dirlookup+0x4a>
      if(poff)
    80003ce8:	000a0463          	beqz	s4,80003cf0 <dirlookup+0x8c>
        *poff = off;
    80003cec:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003cf0:	fc045583          	lhu	a1,-64(s0)
    80003cf4:	00092503          	lw	a0,0(s2)
    80003cf8:	fffff097          	auipc	ra,0xfffff
    80003cfc:	720080e7          	jalr	1824(ra) # 80003418 <iget>
    80003d00:	a011                	j	80003d04 <dirlookup+0xa0>
  return 0;
    80003d02:	4501                	li	a0,0
}
    80003d04:	70e2                	ld	ra,56(sp)
    80003d06:	7442                	ld	s0,48(sp)
    80003d08:	74a2                	ld	s1,40(sp)
    80003d0a:	7902                	ld	s2,32(sp)
    80003d0c:	69e2                	ld	s3,24(sp)
    80003d0e:	6a42                	ld	s4,16(sp)
    80003d10:	6121                	addi	sp,sp,64
    80003d12:	8082                	ret

0000000080003d14 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003d14:	711d                	addi	sp,sp,-96
    80003d16:	ec86                	sd	ra,88(sp)
    80003d18:	e8a2                	sd	s0,80(sp)
    80003d1a:	e4a6                	sd	s1,72(sp)
    80003d1c:	e0ca                	sd	s2,64(sp)
    80003d1e:	fc4e                	sd	s3,56(sp)
    80003d20:	f852                	sd	s4,48(sp)
    80003d22:	f456                	sd	s5,40(sp)
    80003d24:	f05a                	sd	s6,32(sp)
    80003d26:	ec5e                	sd	s7,24(sp)
    80003d28:	e862                	sd	s8,16(sp)
    80003d2a:	e466                	sd	s9,8(sp)
    80003d2c:	1080                	addi	s0,sp,96
    80003d2e:	84aa                	mv	s1,a0
    80003d30:	8b2e                	mv	s6,a1
    80003d32:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003d34:	00054703          	lbu	a4,0(a0)
    80003d38:	02f00793          	li	a5,47
    80003d3c:	02f70263          	beq	a4,a5,80003d60 <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003d40:	ffffe097          	auipc	ra,0xffffe
    80003d44:	d08080e7          	jalr	-760(ra) # 80001a48 <myproc>
    80003d48:	15053503          	ld	a0,336(a0)
    80003d4c:	00000097          	auipc	ra,0x0
    80003d50:	9ce080e7          	jalr	-1586(ra) # 8000371a <idup>
    80003d54:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003d56:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003d5a:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003d5c:	4b85                	li	s7,1
    80003d5e:	a875                	j	80003e1a <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    80003d60:	4585                	li	a1,1
    80003d62:	4505                	li	a0,1
    80003d64:	fffff097          	auipc	ra,0xfffff
    80003d68:	6b4080e7          	jalr	1716(ra) # 80003418 <iget>
    80003d6c:	8a2a                	mv	s4,a0
    80003d6e:	b7e5                	j	80003d56 <namex+0x42>
      iunlockput(ip);
    80003d70:	8552                	mv	a0,s4
    80003d72:	00000097          	auipc	ra,0x0
    80003d76:	c4c080e7          	jalr	-948(ra) # 800039be <iunlockput>
      return 0;
    80003d7a:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003d7c:	8552                	mv	a0,s4
    80003d7e:	60e6                	ld	ra,88(sp)
    80003d80:	6446                	ld	s0,80(sp)
    80003d82:	64a6                	ld	s1,72(sp)
    80003d84:	6906                	ld	s2,64(sp)
    80003d86:	79e2                	ld	s3,56(sp)
    80003d88:	7a42                	ld	s4,48(sp)
    80003d8a:	7aa2                	ld	s5,40(sp)
    80003d8c:	7b02                	ld	s6,32(sp)
    80003d8e:	6be2                	ld	s7,24(sp)
    80003d90:	6c42                	ld	s8,16(sp)
    80003d92:	6ca2                	ld	s9,8(sp)
    80003d94:	6125                	addi	sp,sp,96
    80003d96:	8082                	ret
      iunlock(ip);
    80003d98:	8552                	mv	a0,s4
    80003d9a:	00000097          	auipc	ra,0x0
    80003d9e:	a84080e7          	jalr	-1404(ra) # 8000381e <iunlock>
      return ip;
    80003da2:	bfe9                	j	80003d7c <namex+0x68>
      iunlockput(ip);
    80003da4:	8552                	mv	a0,s4
    80003da6:	00000097          	auipc	ra,0x0
    80003daa:	c18080e7          	jalr	-1000(ra) # 800039be <iunlockput>
      return 0;
    80003dae:	8a4e                	mv	s4,s3
    80003db0:	b7f1                	j	80003d7c <namex+0x68>
  len = path - s;
    80003db2:	40998633          	sub	a2,s3,s1
    80003db6:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003dba:	099c5863          	bge	s8,s9,80003e4a <namex+0x136>
    memmove(name, s, DIRSIZ);
    80003dbe:	4639                	li	a2,14
    80003dc0:	85a6                	mv	a1,s1
    80003dc2:	8556                	mv	a0,s5
    80003dc4:	ffffd097          	auipc	ra,0xffffd
    80003dc8:	fca080e7          	jalr	-54(ra) # 80000d8e <memmove>
    80003dcc:	84ce                	mv	s1,s3
  while(*path == '/')
    80003dce:	0004c783          	lbu	a5,0(s1)
    80003dd2:	01279763          	bne	a5,s2,80003de0 <namex+0xcc>
    path++;
    80003dd6:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003dd8:	0004c783          	lbu	a5,0(s1)
    80003ddc:	ff278de3          	beq	a5,s2,80003dd6 <namex+0xc2>
    ilock(ip);
    80003de0:	8552                	mv	a0,s4
    80003de2:	00000097          	auipc	ra,0x0
    80003de6:	976080e7          	jalr	-1674(ra) # 80003758 <ilock>
    if(ip->type != T_DIR){
    80003dea:	044a1783          	lh	a5,68(s4)
    80003dee:	f97791e3          	bne	a5,s7,80003d70 <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80003df2:	000b0563          	beqz	s6,80003dfc <namex+0xe8>
    80003df6:	0004c783          	lbu	a5,0(s1)
    80003dfa:	dfd9                	beqz	a5,80003d98 <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003dfc:	4601                	li	a2,0
    80003dfe:	85d6                	mv	a1,s5
    80003e00:	8552                	mv	a0,s4
    80003e02:	00000097          	auipc	ra,0x0
    80003e06:	e62080e7          	jalr	-414(ra) # 80003c64 <dirlookup>
    80003e0a:	89aa                	mv	s3,a0
    80003e0c:	dd41                	beqz	a0,80003da4 <namex+0x90>
    iunlockput(ip);
    80003e0e:	8552                	mv	a0,s4
    80003e10:	00000097          	auipc	ra,0x0
    80003e14:	bae080e7          	jalr	-1106(ra) # 800039be <iunlockput>
    ip = next;
    80003e18:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003e1a:	0004c783          	lbu	a5,0(s1)
    80003e1e:	01279763          	bne	a5,s2,80003e2c <namex+0x118>
    path++;
    80003e22:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003e24:	0004c783          	lbu	a5,0(s1)
    80003e28:	ff278de3          	beq	a5,s2,80003e22 <namex+0x10e>
  if(*path == 0)
    80003e2c:	cb9d                	beqz	a5,80003e62 <namex+0x14e>
  while(*path != '/' && *path != 0)
    80003e2e:	0004c783          	lbu	a5,0(s1)
    80003e32:	89a6                	mv	s3,s1
  len = path - s;
    80003e34:	4c81                	li	s9,0
    80003e36:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003e38:	01278963          	beq	a5,s2,80003e4a <namex+0x136>
    80003e3c:	dbbd                	beqz	a5,80003db2 <namex+0x9e>
    path++;
    80003e3e:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003e40:	0009c783          	lbu	a5,0(s3)
    80003e44:	ff279ce3          	bne	a5,s2,80003e3c <namex+0x128>
    80003e48:	b7ad                	j	80003db2 <namex+0x9e>
    memmove(name, s, len);
    80003e4a:	2601                	sext.w	a2,a2
    80003e4c:	85a6                	mv	a1,s1
    80003e4e:	8556                	mv	a0,s5
    80003e50:	ffffd097          	auipc	ra,0xffffd
    80003e54:	f3e080e7          	jalr	-194(ra) # 80000d8e <memmove>
    name[len] = 0;
    80003e58:	9cd6                	add	s9,s9,s5
    80003e5a:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003e5e:	84ce                	mv	s1,s3
    80003e60:	b7bd                	j	80003dce <namex+0xba>
  if(nameiparent){
    80003e62:	f00b0de3          	beqz	s6,80003d7c <namex+0x68>
    iput(ip);
    80003e66:	8552                	mv	a0,s4
    80003e68:	00000097          	auipc	ra,0x0
    80003e6c:	aae080e7          	jalr	-1362(ra) # 80003916 <iput>
    return 0;
    80003e70:	4a01                	li	s4,0
    80003e72:	b729                	j	80003d7c <namex+0x68>

0000000080003e74 <dirlink>:
{
    80003e74:	7139                	addi	sp,sp,-64
    80003e76:	fc06                	sd	ra,56(sp)
    80003e78:	f822                	sd	s0,48(sp)
    80003e7a:	f04a                	sd	s2,32(sp)
    80003e7c:	ec4e                	sd	s3,24(sp)
    80003e7e:	e852                	sd	s4,16(sp)
    80003e80:	0080                	addi	s0,sp,64
    80003e82:	892a                	mv	s2,a0
    80003e84:	8a2e                	mv	s4,a1
    80003e86:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003e88:	4601                	li	a2,0
    80003e8a:	00000097          	auipc	ra,0x0
    80003e8e:	dda080e7          	jalr	-550(ra) # 80003c64 <dirlookup>
    80003e92:	ed25                	bnez	a0,80003f0a <dirlink+0x96>
    80003e94:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e96:	04c92483          	lw	s1,76(s2)
    80003e9a:	c49d                	beqz	s1,80003ec8 <dirlink+0x54>
    80003e9c:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e9e:	4741                	li	a4,16
    80003ea0:	86a6                	mv	a3,s1
    80003ea2:	fc040613          	addi	a2,s0,-64
    80003ea6:	4581                	li	a1,0
    80003ea8:	854a                	mv	a0,s2
    80003eaa:	00000097          	auipc	ra,0x0
    80003eae:	b66080e7          	jalr	-1178(ra) # 80003a10 <readi>
    80003eb2:	47c1                	li	a5,16
    80003eb4:	06f51163          	bne	a0,a5,80003f16 <dirlink+0xa2>
    if(de.inum == 0)
    80003eb8:	fc045783          	lhu	a5,-64(s0)
    80003ebc:	c791                	beqz	a5,80003ec8 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ebe:	24c1                	addiw	s1,s1,16
    80003ec0:	04c92783          	lw	a5,76(s2)
    80003ec4:	fcf4ede3          	bltu	s1,a5,80003e9e <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003ec8:	4639                	li	a2,14
    80003eca:	85d2                	mv	a1,s4
    80003ecc:	fc240513          	addi	a0,s0,-62
    80003ed0:	ffffd097          	auipc	ra,0xffffd
    80003ed4:	f68080e7          	jalr	-152(ra) # 80000e38 <strncpy>
  de.inum = inum;
    80003ed8:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003edc:	4741                	li	a4,16
    80003ede:	86a6                	mv	a3,s1
    80003ee0:	fc040613          	addi	a2,s0,-64
    80003ee4:	4581                	li	a1,0
    80003ee6:	854a                	mv	a0,s2
    80003ee8:	00000097          	auipc	ra,0x0
    80003eec:	c38080e7          	jalr	-968(ra) # 80003b20 <writei>
    80003ef0:	1541                	addi	a0,a0,-16
    80003ef2:	00a03533          	snez	a0,a0
    80003ef6:	40a00533          	neg	a0,a0
    80003efa:	74a2                	ld	s1,40(sp)
}
    80003efc:	70e2                	ld	ra,56(sp)
    80003efe:	7442                	ld	s0,48(sp)
    80003f00:	7902                	ld	s2,32(sp)
    80003f02:	69e2                	ld	s3,24(sp)
    80003f04:	6a42                	ld	s4,16(sp)
    80003f06:	6121                	addi	sp,sp,64
    80003f08:	8082                	ret
    iput(ip);
    80003f0a:	00000097          	auipc	ra,0x0
    80003f0e:	a0c080e7          	jalr	-1524(ra) # 80003916 <iput>
    return -1;
    80003f12:	557d                	li	a0,-1
    80003f14:	b7e5                	j	80003efc <dirlink+0x88>
      panic("dirlink read");
    80003f16:	00004517          	auipc	a0,0x4
    80003f1a:	5ea50513          	addi	a0,a0,1514 # 80008500 <etext+0x500>
    80003f1e:	ffffc097          	auipc	ra,0xffffc
    80003f22:	640080e7          	jalr	1600(ra) # 8000055e <panic>

0000000080003f26 <namei>:

struct inode*
namei(char *path)
{
    80003f26:	1101                	addi	sp,sp,-32
    80003f28:	ec06                	sd	ra,24(sp)
    80003f2a:	e822                	sd	s0,16(sp)
    80003f2c:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003f2e:	fe040613          	addi	a2,s0,-32
    80003f32:	4581                	li	a1,0
    80003f34:	00000097          	auipc	ra,0x0
    80003f38:	de0080e7          	jalr	-544(ra) # 80003d14 <namex>
}
    80003f3c:	60e2                	ld	ra,24(sp)
    80003f3e:	6442                	ld	s0,16(sp)
    80003f40:	6105                	addi	sp,sp,32
    80003f42:	8082                	ret

0000000080003f44 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003f44:	1141                	addi	sp,sp,-16
    80003f46:	e406                	sd	ra,8(sp)
    80003f48:	e022                	sd	s0,0(sp)
    80003f4a:	0800                	addi	s0,sp,16
    80003f4c:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003f4e:	4585                	li	a1,1
    80003f50:	00000097          	auipc	ra,0x0
    80003f54:	dc4080e7          	jalr	-572(ra) # 80003d14 <namex>
}
    80003f58:	60a2                	ld	ra,8(sp)
    80003f5a:	6402                	ld	s0,0(sp)
    80003f5c:	0141                	addi	sp,sp,16
    80003f5e:	8082                	ret

0000000080003f60 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003f60:	1101                	addi	sp,sp,-32
    80003f62:	ec06                	sd	ra,24(sp)
    80003f64:	e822                	sd	s0,16(sp)
    80003f66:	e426                	sd	s1,8(sp)
    80003f68:	e04a                	sd	s2,0(sp)
    80003f6a:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003f6c:	0001d917          	auipc	s2,0x1d
    80003f70:	d9490913          	addi	s2,s2,-620 # 80020d00 <log>
    80003f74:	01892583          	lw	a1,24(s2)
    80003f78:	02892503          	lw	a0,40(s2)
    80003f7c:	fffff097          	auipc	ra,0xfffff
    80003f80:	fa8080e7          	jalr	-88(ra) # 80002f24 <bread>
    80003f84:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003f86:	02c92603          	lw	a2,44(s2)
    80003f8a:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003f8c:	00c05f63          	blez	a2,80003faa <write_head+0x4a>
    80003f90:	0001d717          	auipc	a4,0x1d
    80003f94:	da070713          	addi	a4,a4,-608 # 80020d30 <log+0x30>
    80003f98:	87aa                	mv	a5,a0
    80003f9a:	060a                	slli	a2,a2,0x2
    80003f9c:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003f9e:	4314                	lw	a3,0(a4)
    80003fa0:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003fa2:	0711                	addi	a4,a4,4
    80003fa4:	0791                	addi	a5,a5,4
    80003fa6:	fec79ce3          	bne	a5,a2,80003f9e <write_head+0x3e>
  }
  bwrite(buf);
    80003faa:	8526                	mv	a0,s1
    80003fac:	fffff097          	auipc	ra,0xfffff
    80003fb0:	06a080e7          	jalr	106(ra) # 80003016 <bwrite>
  brelse(buf);
    80003fb4:	8526                	mv	a0,s1
    80003fb6:	fffff097          	auipc	ra,0xfffff
    80003fba:	09e080e7          	jalr	158(ra) # 80003054 <brelse>
}
    80003fbe:	60e2                	ld	ra,24(sp)
    80003fc0:	6442                	ld	s0,16(sp)
    80003fc2:	64a2                	ld	s1,8(sp)
    80003fc4:	6902                	ld	s2,0(sp)
    80003fc6:	6105                	addi	sp,sp,32
    80003fc8:	8082                	ret

0000000080003fca <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fca:	0001d797          	auipc	a5,0x1d
    80003fce:	d627a783          	lw	a5,-670(a5) # 80020d2c <log+0x2c>
    80003fd2:	0af05d63          	blez	a5,8000408c <install_trans+0xc2>
{
    80003fd6:	7139                	addi	sp,sp,-64
    80003fd8:	fc06                	sd	ra,56(sp)
    80003fda:	f822                	sd	s0,48(sp)
    80003fdc:	f426                	sd	s1,40(sp)
    80003fde:	f04a                	sd	s2,32(sp)
    80003fe0:	ec4e                	sd	s3,24(sp)
    80003fe2:	e852                	sd	s4,16(sp)
    80003fe4:	e456                	sd	s5,8(sp)
    80003fe6:	e05a                	sd	s6,0(sp)
    80003fe8:	0080                	addi	s0,sp,64
    80003fea:	8b2a                	mv	s6,a0
    80003fec:	0001da97          	auipc	s5,0x1d
    80003ff0:	d44a8a93          	addi	s5,s5,-700 # 80020d30 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ff4:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003ff6:	0001d997          	auipc	s3,0x1d
    80003ffa:	d0a98993          	addi	s3,s3,-758 # 80020d00 <log>
    80003ffe:	a00d                	j	80004020 <install_trans+0x56>
    brelse(lbuf);
    80004000:	854a                	mv	a0,s2
    80004002:	fffff097          	auipc	ra,0xfffff
    80004006:	052080e7          	jalr	82(ra) # 80003054 <brelse>
    brelse(dbuf);
    8000400a:	8526                	mv	a0,s1
    8000400c:	fffff097          	auipc	ra,0xfffff
    80004010:	048080e7          	jalr	72(ra) # 80003054 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004014:	2a05                	addiw	s4,s4,1
    80004016:	0a91                	addi	s5,s5,4
    80004018:	02c9a783          	lw	a5,44(s3)
    8000401c:	04fa5e63          	bge	s4,a5,80004078 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004020:	0189a583          	lw	a1,24(s3)
    80004024:	014585bb          	addw	a1,a1,s4
    80004028:	2585                	addiw	a1,a1,1
    8000402a:	0289a503          	lw	a0,40(s3)
    8000402e:	fffff097          	auipc	ra,0xfffff
    80004032:	ef6080e7          	jalr	-266(ra) # 80002f24 <bread>
    80004036:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004038:	000aa583          	lw	a1,0(s5)
    8000403c:	0289a503          	lw	a0,40(s3)
    80004040:	fffff097          	auipc	ra,0xfffff
    80004044:	ee4080e7          	jalr	-284(ra) # 80002f24 <bread>
    80004048:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000404a:	40000613          	li	a2,1024
    8000404e:	05890593          	addi	a1,s2,88
    80004052:	05850513          	addi	a0,a0,88
    80004056:	ffffd097          	auipc	ra,0xffffd
    8000405a:	d38080e7          	jalr	-712(ra) # 80000d8e <memmove>
    bwrite(dbuf);  // write dst to disk
    8000405e:	8526                	mv	a0,s1
    80004060:	fffff097          	auipc	ra,0xfffff
    80004064:	fb6080e7          	jalr	-74(ra) # 80003016 <bwrite>
    if(recovering == 0)
    80004068:	f80b1ce3          	bnez	s6,80004000 <install_trans+0x36>
      bunpin(dbuf);
    8000406c:	8526                	mv	a0,s1
    8000406e:	fffff097          	auipc	ra,0xfffff
    80004072:	0be080e7          	jalr	190(ra) # 8000312c <bunpin>
    80004076:	b769                	j	80004000 <install_trans+0x36>
}
    80004078:	70e2                	ld	ra,56(sp)
    8000407a:	7442                	ld	s0,48(sp)
    8000407c:	74a2                	ld	s1,40(sp)
    8000407e:	7902                	ld	s2,32(sp)
    80004080:	69e2                	ld	s3,24(sp)
    80004082:	6a42                	ld	s4,16(sp)
    80004084:	6aa2                	ld	s5,8(sp)
    80004086:	6b02                	ld	s6,0(sp)
    80004088:	6121                	addi	sp,sp,64
    8000408a:	8082                	ret
    8000408c:	8082                	ret

000000008000408e <initlog>:
{
    8000408e:	7179                	addi	sp,sp,-48
    80004090:	f406                	sd	ra,40(sp)
    80004092:	f022                	sd	s0,32(sp)
    80004094:	ec26                	sd	s1,24(sp)
    80004096:	e84a                	sd	s2,16(sp)
    80004098:	e44e                	sd	s3,8(sp)
    8000409a:	1800                	addi	s0,sp,48
    8000409c:	892a                	mv	s2,a0
    8000409e:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800040a0:	0001d497          	auipc	s1,0x1d
    800040a4:	c6048493          	addi	s1,s1,-928 # 80020d00 <log>
    800040a8:	00004597          	auipc	a1,0x4
    800040ac:	46858593          	addi	a1,a1,1128 # 80008510 <etext+0x510>
    800040b0:	8526                	mv	a0,s1
    800040b2:	ffffd097          	auipc	ra,0xffffd
    800040b6:	af4080e7          	jalr	-1292(ra) # 80000ba6 <initlock>
  log.start = sb->logstart;
    800040ba:	0149a583          	lw	a1,20(s3)
    800040be:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800040c0:	0109a783          	lw	a5,16(s3)
    800040c4:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800040c6:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800040ca:	854a                	mv	a0,s2
    800040cc:	fffff097          	auipc	ra,0xfffff
    800040d0:	e58080e7          	jalr	-424(ra) # 80002f24 <bread>
  log.lh.n = lh->n;
    800040d4:	4d30                	lw	a2,88(a0)
    800040d6:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800040d8:	00c05f63          	blez	a2,800040f6 <initlog+0x68>
    800040dc:	87aa                	mv	a5,a0
    800040de:	0001d717          	auipc	a4,0x1d
    800040e2:	c5270713          	addi	a4,a4,-942 # 80020d30 <log+0x30>
    800040e6:	060a                	slli	a2,a2,0x2
    800040e8:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    800040ea:	4ff4                	lw	a3,92(a5)
    800040ec:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800040ee:	0791                	addi	a5,a5,4
    800040f0:	0711                	addi	a4,a4,4
    800040f2:	fec79ce3          	bne	a5,a2,800040ea <initlog+0x5c>
  brelse(buf);
    800040f6:	fffff097          	auipc	ra,0xfffff
    800040fa:	f5e080e7          	jalr	-162(ra) # 80003054 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800040fe:	4505                	li	a0,1
    80004100:	00000097          	auipc	ra,0x0
    80004104:	eca080e7          	jalr	-310(ra) # 80003fca <install_trans>
  log.lh.n = 0;
    80004108:	0001d797          	auipc	a5,0x1d
    8000410c:	c207a223          	sw	zero,-988(a5) # 80020d2c <log+0x2c>
  write_head(); // clear the log
    80004110:	00000097          	auipc	ra,0x0
    80004114:	e50080e7          	jalr	-432(ra) # 80003f60 <write_head>
}
    80004118:	70a2                	ld	ra,40(sp)
    8000411a:	7402                	ld	s0,32(sp)
    8000411c:	64e2                	ld	s1,24(sp)
    8000411e:	6942                	ld	s2,16(sp)
    80004120:	69a2                	ld	s3,8(sp)
    80004122:	6145                	addi	sp,sp,48
    80004124:	8082                	ret

0000000080004126 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004126:	1101                	addi	sp,sp,-32
    80004128:	ec06                	sd	ra,24(sp)
    8000412a:	e822                	sd	s0,16(sp)
    8000412c:	e426                	sd	s1,8(sp)
    8000412e:	e04a                	sd	s2,0(sp)
    80004130:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004132:	0001d517          	auipc	a0,0x1d
    80004136:	bce50513          	addi	a0,a0,-1074 # 80020d00 <log>
    8000413a:	ffffd097          	auipc	ra,0xffffd
    8000413e:	afc080e7          	jalr	-1284(ra) # 80000c36 <acquire>
  while(1){
    if(log.committing){
    80004142:	0001d497          	auipc	s1,0x1d
    80004146:	bbe48493          	addi	s1,s1,-1090 # 80020d00 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000414a:	4979                	li	s2,30
    8000414c:	a039                	j	8000415a <begin_op+0x34>
      sleep(&log, &log.lock);
    8000414e:	85a6                	mv	a1,s1
    80004150:	8526                	mv	a0,s1
    80004152:	ffffe097          	auipc	ra,0xffffe
    80004156:	006080e7          	jalr	6(ra) # 80002158 <sleep>
    if(log.committing){
    8000415a:	50dc                	lw	a5,36(s1)
    8000415c:	fbed                	bnez	a5,8000414e <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000415e:	5098                	lw	a4,32(s1)
    80004160:	2705                	addiw	a4,a4,1
    80004162:	0027179b          	slliw	a5,a4,0x2
    80004166:	9fb9                	addw	a5,a5,a4
    80004168:	0017979b          	slliw	a5,a5,0x1
    8000416c:	54d4                	lw	a3,44(s1)
    8000416e:	9fb5                	addw	a5,a5,a3
    80004170:	00f95963          	bge	s2,a5,80004182 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004174:	85a6                	mv	a1,s1
    80004176:	8526                	mv	a0,s1
    80004178:	ffffe097          	auipc	ra,0xffffe
    8000417c:	fe0080e7          	jalr	-32(ra) # 80002158 <sleep>
    80004180:	bfe9                	j	8000415a <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004182:	0001d517          	auipc	a0,0x1d
    80004186:	b7e50513          	addi	a0,a0,-1154 # 80020d00 <log>
    8000418a:	d118                	sw	a4,32(a0)
      release(&log.lock);
    8000418c:	ffffd097          	auipc	ra,0xffffd
    80004190:	b5e080e7          	jalr	-1186(ra) # 80000cea <release>
      break;
    }
  }
}
    80004194:	60e2                	ld	ra,24(sp)
    80004196:	6442                	ld	s0,16(sp)
    80004198:	64a2                	ld	s1,8(sp)
    8000419a:	6902                	ld	s2,0(sp)
    8000419c:	6105                	addi	sp,sp,32
    8000419e:	8082                	ret

00000000800041a0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800041a0:	7139                	addi	sp,sp,-64
    800041a2:	fc06                	sd	ra,56(sp)
    800041a4:	f822                	sd	s0,48(sp)
    800041a6:	f426                	sd	s1,40(sp)
    800041a8:	f04a                	sd	s2,32(sp)
    800041aa:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800041ac:	0001d497          	auipc	s1,0x1d
    800041b0:	b5448493          	addi	s1,s1,-1196 # 80020d00 <log>
    800041b4:	8526                	mv	a0,s1
    800041b6:	ffffd097          	auipc	ra,0xffffd
    800041ba:	a80080e7          	jalr	-1408(ra) # 80000c36 <acquire>
  log.outstanding -= 1;
    800041be:	509c                	lw	a5,32(s1)
    800041c0:	37fd                	addiw	a5,a5,-1
    800041c2:	0007891b          	sext.w	s2,a5
    800041c6:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800041c8:	50dc                	lw	a5,36(s1)
    800041ca:	e7b9                	bnez	a5,80004218 <end_op+0x78>
    panic("log.committing");
  if(log.outstanding == 0){
    800041cc:	06091163          	bnez	s2,8000422e <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800041d0:	0001d497          	auipc	s1,0x1d
    800041d4:	b3048493          	addi	s1,s1,-1232 # 80020d00 <log>
    800041d8:	4785                	li	a5,1
    800041da:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800041dc:	8526                	mv	a0,s1
    800041de:	ffffd097          	auipc	ra,0xffffd
    800041e2:	b0c080e7          	jalr	-1268(ra) # 80000cea <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800041e6:	54dc                	lw	a5,44(s1)
    800041e8:	06f04763          	bgtz	a5,80004256 <end_op+0xb6>
    acquire(&log.lock);
    800041ec:	0001d497          	auipc	s1,0x1d
    800041f0:	b1448493          	addi	s1,s1,-1260 # 80020d00 <log>
    800041f4:	8526                	mv	a0,s1
    800041f6:	ffffd097          	auipc	ra,0xffffd
    800041fa:	a40080e7          	jalr	-1472(ra) # 80000c36 <acquire>
    log.committing = 0;
    800041fe:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004202:	8526                	mv	a0,s1
    80004204:	ffffe097          	auipc	ra,0xffffe
    80004208:	fb8080e7          	jalr	-72(ra) # 800021bc <wakeup>
    release(&log.lock);
    8000420c:	8526                	mv	a0,s1
    8000420e:	ffffd097          	auipc	ra,0xffffd
    80004212:	adc080e7          	jalr	-1316(ra) # 80000cea <release>
}
    80004216:	a815                	j	8000424a <end_op+0xaa>
    80004218:	ec4e                	sd	s3,24(sp)
    8000421a:	e852                	sd	s4,16(sp)
    8000421c:	e456                	sd	s5,8(sp)
    panic("log.committing");
    8000421e:	00004517          	auipc	a0,0x4
    80004222:	2fa50513          	addi	a0,a0,762 # 80008518 <etext+0x518>
    80004226:	ffffc097          	auipc	ra,0xffffc
    8000422a:	338080e7          	jalr	824(ra) # 8000055e <panic>
    wakeup(&log);
    8000422e:	0001d497          	auipc	s1,0x1d
    80004232:	ad248493          	addi	s1,s1,-1326 # 80020d00 <log>
    80004236:	8526                	mv	a0,s1
    80004238:	ffffe097          	auipc	ra,0xffffe
    8000423c:	f84080e7          	jalr	-124(ra) # 800021bc <wakeup>
  release(&log.lock);
    80004240:	8526                	mv	a0,s1
    80004242:	ffffd097          	auipc	ra,0xffffd
    80004246:	aa8080e7          	jalr	-1368(ra) # 80000cea <release>
}
    8000424a:	70e2                	ld	ra,56(sp)
    8000424c:	7442                	ld	s0,48(sp)
    8000424e:	74a2                	ld	s1,40(sp)
    80004250:	7902                	ld	s2,32(sp)
    80004252:	6121                	addi	sp,sp,64
    80004254:	8082                	ret
    80004256:	ec4e                	sd	s3,24(sp)
    80004258:	e852                	sd	s4,16(sp)
    8000425a:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    8000425c:	0001da97          	auipc	s5,0x1d
    80004260:	ad4a8a93          	addi	s5,s5,-1324 # 80020d30 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004264:	0001da17          	auipc	s4,0x1d
    80004268:	a9ca0a13          	addi	s4,s4,-1380 # 80020d00 <log>
    8000426c:	018a2583          	lw	a1,24(s4)
    80004270:	012585bb          	addw	a1,a1,s2
    80004274:	2585                	addiw	a1,a1,1
    80004276:	028a2503          	lw	a0,40(s4)
    8000427a:	fffff097          	auipc	ra,0xfffff
    8000427e:	caa080e7          	jalr	-854(ra) # 80002f24 <bread>
    80004282:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004284:	000aa583          	lw	a1,0(s5)
    80004288:	028a2503          	lw	a0,40(s4)
    8000428c:	fffff097          	auipc	ra,0xfffff
    80004290:	c98080e7          	jalr	-872(ra) # 80002f24 <bread>
    80004294:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004296:	40000613          	li	a2,1024
    8000429a:	05850593          	addi	a1,a0,88
    8000429e:	05848513          	addi	a0,s1,88
    800042a2:	ffffd097          	auipc	ra,0xffffd
    800042a6:	aec080e7          	jalr	-1300(ra) # 80000d8e <memmove>
    bwrite(to);  // write the log
    800042aa:	8526                	mv	a0,s1
    800042ac:	fffff097          	auipc	ra,0xfffff
    800042b0:	d6a080e7          	jalr	-662(ra) # 80003016 <bwrite>
    brelse(from);
    800042b4:	854e                	mv	a0,s3
    800042b6:	fffff097          	auipc	ra,0xfffff
    800042ba:	d9e080e7          	jalr	-610(ra) # 80003054 <brelse>
    brelse(to);
    800042be:	8526                	mv	a0,s1
    800042c0:	fffff097          	auipc	ra,0xfffff
    800042c4:	d94080e7          	jalr	-620(ra) # 80003054 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800042c8:	2905                	addiw	s2,s2,1
    800042ca:	0a91                	addi	s5,s5,4
    800042cc:	02ca2783          	lw	a5,44(s4)
    800042d0:	f8f94ee3          	blt	s2,a5,8000426c <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800042d4:	00000097          	auipc	ra,0x0
    800042d8:	c8c080e7          	jalr	-884(ra) # 80003f60 <write_head>
    install_trans(0); // Now install writes to home locations
    800042dc:	4501                	li	a0,0
    800042de:	00000097          	auipc	ra,0x0
    800042e2:	cec080e7          	jalr	-788(ra) # 80003fca <install_trans>
    log.lh.n = 0;
    800042e6:	0001d797          	auipc	a5,0x1d
    800042ea:	a407a323          	sw	zero,-1466(a5) # 80020d2c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800042ee:	00000097          	auipc	ra,0x0
    800042f2:	c72080e7          	jalr	-910(ra) # 80003f60 <write_head>
    800042f6:	69e2                	ld	s3,24(sp)
    800042f8:	6a42                	ld	s4,16(sp)
    800042fa:	6aa2                	ld	s5,8(sp)
    800042fc:	bdc5                	j	800041ec <end_op+0x4c>

00000000800042fe <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800042fe:	1101                	addi	sp,sp,-32
    80004300:	ec06                	sd	ra,24(sp)
    80004302:	e822                	sd	s0,16(sp)
    80004304:	e426                	sd	s1,8(sp)
    80004306:	e04a                	sd	s2,0(sp)
    80004308:	1000                	addi	s0,sp,32
    8000430a:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000430c:	0001d917          	auipc	s2,0x1d
    80004310:	9f490913          	addi	s2,s2,-1548 # 80020d00 <log>
    80004314:	854a                	mv	a0,s2
    80004316:	ffffd097          	auipc	ra,0xffffd
    8000431a:	920080e7          	jalr	-1760(ra) # 80000c36 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000431e:	02c92603          	lw	a2,44(s2)
    80004322:	47f5                	li	a5,29
    80004324:	06c7c563          	blt	a5,a2,8000438e <log_write+0x90>
    80004328:	0001d797          	auipc	a5,0x1d
    8000432c:	9f47a783          	lw	a5,-1548(a5) # 80020d1c <log+0x1c>
    80004330:	37fd                	addiw	a5,a5,-1
    80004332:	04f65e63          	bge	a2,a5,8000438e <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004336:	0001d797          	auipc	a5,0x1d
    8000433a:	9ea7a783          	lw	a5,-1558(a5) # 80020d20 <log+0x20>
    8000433e:	06f05063          	blez	a5,8000439e <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004342:	4781                	li	a5,0
    80004344:	06c05563          	blez	a2,800043ae <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004348:	44cc                	lw	a1,12(s1)
    8000434a:	0001d717          	auipc	a4,0x1d
    8000434e:	9e670713          	addi	a4,a4,-1562 # 80020d30 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004352:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004354:	4314                	lw	a3,0(a4)
    80004356:	04b68c63          	beq	a3,a1,800043ae <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    8000435a:	2785                	addiw	a5,a5,1
    8000435c:	0711                	addi	a4,a4,4
    8000435e:	fef61be3          	bne	a2,a5,80004354 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004362:	0621                	addi	a2,a2,8
    80004364:	060a                	slli	a2,a2,0x2
    80004366:	0001d797          	auipc	a5,0x1d
    8000436a:	99a78793          	addi	a5,a5,-1638 # 80020d00 <log>
    8000436e:	97b2                	add	a5,a5,a2
    80004370:	44d8                	lw	a4,12(s1)
    80004372:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004374:	8526                	mv	a0,s1
    80004376:	fffff097          	auipc	ra,0xfffff
    8000437a:	d7a080e7          	jalr	-646(ra) # 800030f0 <bpin>
    log.lh.n++;
    8000437e:	0001d717          	auipc	a4,0x1d
    80004382:	98270713          	addi	a4,a4,-1662 # 80020d00 <log>
    80004386:	575c                	lw	a5,44(a4)
    80004388:	2785                	addiw	a5,a5,1
    8000438a:	d75c                	sw	a5,44(a4)
    8000438c:	a82d                	j	800043c6 <log_write+0xc8>
    panic("too big a transaction");
    8000438e:	00004517          	auipc	a0,0x4
    80004392:	19a50513          	addi	a0,a0,410 # 80008528 <etext+0x528>
    80004396:	ffffc097          	auipc	ra,0xffffc
    8000439a:	1c8080e7          	jalr	456(ra) # 8000055e <panic>
    panic("log_write outside of trans");
    8000439e:	00004517          	auipc	a0,0x4
    800043a2:	1a250513          	addi	a0,a0,418 # 80008540 <etext+0x540>
    800043a6:	ffffc097          	auipc	ra,0xffffc
    800043aa:	1b8080e7          	jalr	440(ra) # 8000055e <panic>
  log.lh.block[i] = b->blockno;
    800043ae:	00878693          	addi	a3,a5,8
    800043b2:	068a                	slli	a3,a3,0x2
    800043b4:	0001d717          	auipc	a4,0x1d
    800043b8:	94c70713          	addi	a4,a4,-1716 # 80020d00 <log>
    800043bc:	9736                	add	a4,a4,a3
    800043be:	44d4                	lw	a3,12(s1)
    800043c0:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800043c2:	faf609e3          	beq	a2,a5,80004374 <log_write+0x76>
  }
  release(&log.lock);
    800043c6:	0001d517          	auipc	a0,0x1d
    800043ca:	93a50513          	addi	a0,a0,-1734 # 80020d00 <log>
    800043ce:	ffffd097          	auipc	ra,0xffffd
    800043d2:	91c080e7          	jalr	-1764(ra) # 80000cea <release>
}
    800043d6:	60e2                	ld	ra,24(sp)
    800043d8:	6442                	ld	s0,16(sp)
    800043da:	64a2                	ld	s1,8(sp)
    800043dc:	6902                	ld	s2,0(sp)
    800043de:	6105                	addi	sp,sp,32
    800043e0:	8082                	ret

00000000800043e2 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800043e2:	1101                	addi	sp,sp,-32
    800043e4:	ec06                	sd	ra,24(sp)
    800043e6:	e822                	sd	s0,16(sp)
    800043e8:	e426                	sd	s1,8(sp)
    800043ea:	e04a                	sd	s2,0(sp)
    800043ec:	1000                	addi	s0,sp,32
    800043ee:	84aa                	mv	s1,a0
    800043f0:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800043f2:	00004597          	auipc	a1,0x4
    800043f6:	16e58593          	addi	a1,a1,366 # 80008560 <etext+0x560>
    800043fa:	0521                	addi	a0,a0,8
    800043fc:	ffffc097          	auipc	ra,0xffffc
    80004400:	7aa080e7          	jalr	1962(ra) # 80000ba6 <initlock>
  lk->name = name;
    80004404:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004408:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000440c:	0204a423          	sw	zero,40(s1)
}
    80004410:	60e2                	ld	ra,24(sp)
    80004412:	6442                	ld	s0,16(sp)
    80004414:	64a2                	ld	s1,8(sp)
    80004416:	6902                	ld	s2,0(sp)
    80004418:	6105                	addi	sp,sp,32
    8000441a:	8082                	ret

000000008000441c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000441c:	1101                	addi	sp,sp,-32
    8000441e:	ec06                	sd	ra,24(sp)
    80004420:	e822                	sd	s0,16(sp)
    80004422:	e426                	sd	s1,8(sp)
    80004424:	e04a                	sd	s2,0(sp)
    80004426:	1000                	addi	s0,sp,32
    80004428:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000442a:	00850913          	addi	s2,a0,8
    8000442e:	854a                	mv	a0,s2
    80004430:	ffffd097          	auipc	ra,0xffffd
    80004434:	806080e7          	jalr	-2042(ra) # 80000c36 <acquire>
  while (lk->locked) {
    80004438:	409c                	lw	a5,0(s1)
    8000443a:	cb89                	beqz	a5,8000444c <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000443c:	85ca                	mv	a1,s2
    8000443e:	8526                	mv	a0,s1
    80004440:	ffffe097          	auipc	ra,0xffffe
    80004444:	d18080e7          	jalr	-744(ra) # 80002158 <sleep>
  while (lk->locked) {
    80004448:	409c                	lw	a5,0(s1)
    8000444a:	fbed                	bnez	a5,8000443c <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000444c:	4785                	li	a5,1
    8000444e:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004450:	ffffd097          	auipc	ra,0xffffd
    80004454:	5f8080e7          	jalr	1528(ra) # 80001a48 <myproc>
    80004458:	591c                	lw	a5,48(a0)
    8000445a:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000445c:	854a                	mv	a0,s2
    8000445e:	ffffd097          	auipc	ra,0xffffd
    80004462:	88c080e7          	jalr	-1908(ra) # 80000cea <release>
}
    80004466:	60e2                	ld	ra,24(sp)
    80004468:	6442                	ld	s0,16(sp)
    8000446a:	64a2                	ld	s1,8(sp)
    8000446c:	6902                	ld	s2,0(sp)
    8000446e:	6105                	addi	sp,sp,32
    80004470:	8082                	ret

0000000080004472 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004472:	1101                	addi	sp,sp,-32
    80004474:	ec06                	sd	ra,24(sp)
    80004476:	e822                	sd	s0,16(sp)
    80004478:	e426                	sd	s1,8(sp)
    8000447a:	e04a                	sd	s2,0(sp)
    8000447c:	1000                	addi	s0,sp,32
    8000447e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004480:	00850913          	addi	s2,a0,8
    80004484:	854a                	mv	a0,s2
    80004486:	ffffc097          	auipc	ra,0xffffc
    8000448a:	7b0080e7          	jalr	1968(ra) # 80000c36 <acquire>
  lk->locked = 0;
    8000448e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004492:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004496:	8526                	mv	a0,s1
    80004498:	ffffe097          	auipc	ra,0xffffe
    8000449c:	d24080e7          	jalr	-732(ra) # 800021bc <wakeup>
  release(&lk->lk);
    800044a0:	854a                	mv	a0,s2
    800044a2:	ffffd097          	auipc	ra,0xffffd
    800044a6:	848080e7          	jalr	-1976(ra) # 80000cea <release>
}
    800044aa:	60e2                	ld	ra,24(sp)
    800044ac:	6442                	ld	s0,16(sp)
    800044ae:	64a2                	ld	s1,8(sp)
    800044b0:	6902                	ld	s2,0(sp)
    800044b2:	6105                	addi	sp,sp,32
    800044b4:	8082                	ret

00000000800044b6 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800044b6:	7179                	addi	sp,sp,-48
    800044b8:	f406                	sd	ra,40(sp)
    800044ba:	f022                	sd	s0,32(sp)
    800044bc:	ec26                	sd	s1,24(sp)
    800044be:	e84a                	sd	s2,16(sp)
    800044c0:	1800                	addi	s0,sp,48
    800044c2:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800044c4:	00850913          	addi	s2,a0,8
    800044c8:	854a                	mv	a0,s2
    800044ca:	ffffc097          	auipc	ra,0xffffc
    800044ce:	76c080e7          	jalr	1900(ra) # 80000c36 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800044d2:	409c                	lw	a5,0(s1)
    800044d4:	ef91                	bnez	a5,800044f0 <holdingsleep+0x3a>
    800044d6:	4481                	li	s1,0
  release(&lk->lk);
    800044d8:	854a                	mv	a0,s2
    800044da:	ffffd097          	auipc	ra,0xffffd
    800044de:	810080e7          	jalr	-2032(ra) # 80000cea <release>
  return r;
}
    800044e2:	8526                	mv	a0,s1
    800044e4:	70a2                	ld	ra,40(sp)
    800044e6:	7402                	ld	s0,32(sp)
    800044e8:	64e2                	ld	s1,24(sp)
    800044ea:	6942                	ld	s2,16(sp)
    800044ec:	6145                	addi	sp,sp,48
    800044ee:	8082                	ret
    800044f0:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800044f2:	0284a983          	lw	s3,40(s1)
    800044f6:	ffffd097          	auipc	ra,0xffffd
    800044fa:	552080e7          	jalr	1362(ra) # 80001a48 <myproc>
    800044fe:	5904                	lw	s1,48(a0)
    80004500:	413484b3          	sub	s1,s1,s3
    80004504:	0014b493          	seqz	s1,s1
    80004508:	69a2                	ld	s3,8(sp)
    8000450a:	b7f9                	j	800044d8 <holdingsleep+0x22>

000000008000450c <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000450c:	1141                	addi	sp,sp,-16
    8000450e:	e406                	sd	ra,8(sp)
    80004510:	e022                	sd	s0,0(sp)
    80004512:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004514:	00004597          	auipc	a1,0x4
    80004518:	05c58593          	addi	a1,a1,92 # 80008570 <etext+0x570>
    8000451c:	0001d517          	auipc	a0,0x1d
    80004520:	92c50513          	addi	a0,a0,-1748 # 80020e48 <ftable>
    80004524:	ffffc097          	auipc	ra,0xffffc
    80004528:	682080e7          	jalr	1666(ra) # 80000ba6 <initlock>
}
    8000452c:	60a2                	ld	ra,8(sp)
    8000452e:	6402                	ld	s0,0(sp)
    80004530:	0141                	addi	sp,sp,16
    80004532:	8082                	ret

0000000080004534 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004534:	1101                	addi	sp,sp,-32
    80004536:	ec06                	sd	ra,24(sp)
    80004538:	e822                	sd	s0,16(sp)
    8000453a:	e426                	sd	s1,8(sp)
    8000453c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000453e:	0001d517          	auipc	a0,0x1d
    80004542:	90a50513          	addi	a0,a0,-1782 # 80020e48 <ftable>
    80004546:	ffffc097          	auipc	ra,0xffffc
    8000454a:	6f0080e7          	jalr	1776(ra) # 80000c36 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000454e:	0001d497          	auipc	s1,0x1d
    80004552:	91248493          	addi	s1,s1,-1774 # 80020e60 <ftable+0x18>
    80004556:	0001e717          	auipc	a4,0x1e
    8000455a:	8aa70713          	addi	a4,a4,-1878 # 80021e00 <disk>
    if(f->ref == 0){
    8000455e:	40dc                	lw	a5,4(s1)
    80004560:	cf99                	beqz	a5,8000457e <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004562:	02848493          	addi	s1,s1,40
    80004566:	fee49ce3          	bne	s1,a4,8000455e <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000456a:	0001d517          	auipc	a0,0x1d
    8000456e:	8de50513          	addi	a0,a0,-1826 # 80020e48 <ftable>
    80004572:	ffffc097          	auipc	ra,0xffffc
    80004576:	778080e7          	jalr	1912(ra) # 80000cea <release>
  return 0;
    8000457a:	4481                	li	s1,0
    8000457c:	a819                	j	80004592 <filealloc+0x5e>
      f->ref = 1;
    8000457e:	4785                	li	a5,1
    80004580:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004582:	0001d517          	auipc	a0,0x1d
    80004586:	8c650513          	addi	a0,a0,-1850 # 80020e48 <ftable>
    8000458a:	ffffc097          	auipc	ra,0xffffc
    8000458e:	760080e7          	jalr	1888(ra) # 80000cea <release>
}
    80004592:	8526                	mv	a0,s1
    80004594:	60e2                	ld	ra,24(sp)
    80004596:	6442                	ld	s0,16(sp)
    80004598:	64a2                	ld	s1,8(sp)
    8000459a:	6105                	addi	sp,sp,32
    8000459c:	8082                	ret

000000008000459e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000459e:	1101                	addi	sp,sp,-32
    800045a0:	ec06                	sd	ra,24(sp)
    800045a2:	e822                	sd	s0,16(sp)
    800045a4:	e426                	sd	s1,8(sp)
    800045a6:	1000                	addi	s0,sp,32
    800045a8:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800045aa:	0001d517          	auipc	a0,0x1d
    800045ae:	89e50513          	addi	a0,a0,-1890 # 80020e48 <ftable>
    800045b2:	ffffc097          	auipc	ra,0xffffc
    800045b6:	684080e7          	jalr	1668(ra) # 80000c36 <acquire>
  if(f->ref < 1)
    800045ba:	40dc                	lw	a5,4(s1)
    800045bc:	02f05263          	blez	a5,800045e0 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800045c0:	2785                	addiw	a5,a5,1
    800045c2:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800045c4:	0001d517          	auipc	a0,0x1d
    800045c8:	88450513          	addi	a0,a0,-1916 # 80020e48 <ftable>
    800045cc:	ffffc097          	auipc	ra,0xffffc
    800045d0:	71e080e7          	jalr	1822(ra) # 80000cea <release>
  return f;
}
    800045d4:	8526                	mv	a0,s1
    800045d6:	60e2                	ld	ra,24(sp)
    800045d8:	6442                	ld	s0,16(sp)
    800045da:	64a2                	ld	s1,8(sp)
    800045dc:	6105                	addi	sp,sp,32
    800045de:	8082                	ret
    panic("filedup");
    800045e0:	00004517          	auipc	a0,0x4
    800045e4:	f9850513          	addi	a0,a0,-104 # 80008578 <etext+0x578>
    800045e8:	ffffc097          	auipc	ra,0xffffc
    800045ec:	f76080e7          	jalr	-138(ra) # 8000055e <panic>

00000000800045f0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800045f0:	7139                	addi	sp,sp,-64
    800045f2:	fc06                	sd	ra,56(sp)
    800045f4:	f822                	sd	s0,48(sp)
    800045f6:	f426                	sd	s1,40(sp)
    800045f8:	0080                	addi	s0,sp,64
    800045fa:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800045fc:	0001d517          	auipc	a0,0x1d
    80004600:	84c50513          	addi	a0,a0,-1972 # 80020e48 <ftable>
    80004604:	ffffc097          	auipc	ra,0xffffc
    80004608:	632080e7          	jalr	1586(ra) # 80000c36 <acquire>
  if(f->ref < 1)
    8000460c:	40dc                	lw	a5,4(s1)
    8000460e:	04f05c63          	blez	a5,80004666 <fileclose+0x76>
    panic("fileclose");
  if(--f->ref > 0){
    80004612:	37fd                	addiw	a5,a5,-1
    80004614:	0007871b          	sext.w	a4,a5
    80004618:	c0dc                	sw	a5,4(s1)
    8000461a:	06e04263          	bgtz	a4,8000467e <fileclose+0x8e>
    8000461e:	f04a                	sd	s2,32(sp)
    80004620:	ec4e                	sd	s3,24(sp)
    80004622:	e852                	sd	s4,16(sp)
    80004624:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004626:	0004a903          	lw	s2,0(s1)
    8000462a:	0094ca83          	lbu	s5,9(s1)
    8000462e:	0104ba03          	ld	s4,16(s1)
    80004632:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004636:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000463a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000463e:	0001d517          	auipc	a0,0x1d
    80004642:	80a50513          	addi	a0,a0,-2038 # 80020e48 <ftable>
    80004646:	ffffc097          	auipc	ra,0xffffc
    8000464a:	6a4080e7          	jalr	1700(ra) # 80000cea <release>

  if(ff.type == FD_PIPE){
    8000464e:	4785                	li	a5,1
    80004650:	04f90463          	beq	s2,a5,80004698 <fileclose+0xa8>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004654:	3979                	addiw	s2,s2,-2
    80004656:	4785                	li	a5,1
    80004658:	0527fb63          	bgeu	a5,s2,800046ae <fileclose+0xbe>
    8000465c:	7902                	ld	s2,32(sp)
    8000465e:	69e2                	ld	s3,24(sp)
    80004660:	6a42                	ld	s4,16(sp)
    80004662:	6aa2                	ld	s5,8(sp)
    80004664:	a02d                	j	8000468e <fileclose+0x9e>
    80004666:	f04a                	sd	s2,32(sp)
    80004668:	ec4e                	sd	s3,24(sp)
    8000466a:	e852                	sd	s4,16(sp)
    8000466c:	e456                	sd	s5,8(sp)
    panic("fileclose");
    8000466e:	00004517          	auipc	a0,0x4
    80004672:	f1250513          	addi	a0,a0,-238 # 80008580 <etext+0x580>
    80004676:	ffffc097          	auipc	ra,0xffffc
    8000467a:	ee8080e7          	jalr	-280(ra) # 8000055e <panic>
    release(&ftable.lock);
    8000467e:	0001c517          	auipc	a0,0x1c
    80004682:	7ca50513          	addi	a0,a0,1994 # 80020e48 <ftable>
    80004686:	ffffc097          	auipc	ra,0xffffc
    8000468a:	664080e7          	jalr	1636(ra) # 80000cea <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    8000468e:	70e2                	ld	ra,56(sp)
    80004690:	7442                	ld	s0,48(sp)
    80004692:	74a2                	ld	s1,40(sp)
    80004694:	6121                	addi	sp,sp,64
    80004696:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004698:	85d6                	mv	a1,s5
    8000469a:	8552                	mv	a0,s4
    8000469c:	00000097          	auipc	ra,0x0
    800046a0:	3a2080e7          	jalr	930(ra) # 80004a3e <pipeclose>
    800046a4:	7902                	ld	s2,32(sp)
    800046a6:	69e2                	ld	s3,24(sp)
    800046a8:	6a42                	ld	s4,16(sp)
    800046aa:	6aa2                	ld	s5,8(sp)
    800046ac:	b7cd                	j	8000468e <fileclose+0x9e>
    begin_op();
    800046ae:	00000097          	auipc	ra,0x0
    800046b2:	a78080e7          	jalr	-1416(ra) # 80004126 <begin_op>
    iput(ff.ip);
    800046b6:	854e                	mv	a0,s3
    800046b8:	fffff097          	auipc	ra,0xfffff
    800046bc:	25e080e7          	jalr	606(ra) # 80003916 <iput>
    end_op();
    800046c0:	00000097          	auipc	ra,0x0
    800046c4:	ae0080e7          	jalr	-1312(ra) # 800041a0 <end_op>
    800046c8:	7902                	ld	s2,32(sp)
    800046ca:	69e2                	ld	s3,24(sp)
    800046cc:	6a42                	ld	s4,16(sp)
    800046ce:	6aa2                	ld	s5,8(sp)
    800046d0:	bf7d                	j	8000468e <fileclose+0x9e>

00000000800046d2 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800046d2:	715d                	addi	sp,sp,-80
    800046d4:	e486                	sd	ra,72(sp)
    800046d6:	e0a2                	sd	s0,64(sp)
    800046d8:	fc26                	sd	s1,56(sp)
    800046da:	f44e                	sd	s3,40(sp)
    800046dc:	0880                	addi	s0,sp,80
    800046de:	84aa                	mv	s1,a0
    800046e0:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800046e2:	ffffd097          	auipc	ra,0xffffd
    800046e6:	366080e7          	jalr	870(ra) # 80001a48 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800046ea:	409c                	lw	a5,0(s1)
    800046ec:	37f9                	addiw	a5,a5,-2
    800046ee:	4705                	li	a4,1
    800046f0:	04f76863          	bltu	a4,a5,80004740 <filestat+0x6e>
    800046f4:	f84a                	sd	s2,48(sp)
    800046f6:	892a                	mv	s2,a0
    ilock(f->ip);
    800046f8:	6c88                	ld	a0,24(s1)
    800046fa:	fffff097          	auipc	ra,0xfffff
    800046fe:	05e080e7          	jalr	94(ra) # 80003758 <ilock>
    stati(f->ip, &st);
    80004702:	fb840593          	addi	a1,s0,-72
    80004706:	6c88                	ld	a0,24(s1)
    80004708:	fffff097          	auipc	ra,0xfffff
    8000470c:	2de080e7          	jalr	734(ra) # 800039e6 <stati>
    iunlock(f->ip);
    80004710:	6c88                	ld	a0,24(s1)
    80004712:	fffff097          	auipc	ra,0xfffff
    80004716:	10c080e7          	jalr	268(ra) # 8000381e <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000471a:	46e1                	li	a3,24
    8000471c:	fb840613          	addi	a2,s0,-72
    80004720:	85ce                	mv	a1,s3
    80004722:	05093503          	ld	a0,80(s2)
    80004726:	ffffd097          	auipc	ra,0xffffd
    8000472a:	fba080e7          	jalr	-70(ra) # 800016e0 <copyout>
    8000472e:	41f5551b          	sraiw	a0,a0,0x1f
    80004732:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004734:	60a6                	ld	ra,72(sp)
    80004736:	6406                	ld	s0,64(sp)
    80004738:	74e2                	ld	s1,56(sp)
    8000473a:	79a2                	ld	s3,40(sp)
    8000473c:	6161                	addi	sp,sp,80
    8000473e:	8082                	ret
  return -1;
    80004740:	557d                	li	a0,-1
    80004742:	bfcd                	j	80004734 <filestat+0x62>

0000000080004744 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004744:	7179                	addi	sp,sp,-48
    80004746:	f406                	sd	ra,40(sp)
    80004748:	f022                	sd	s0,32(sp)
    8000474a:	e84a                	sd	s2,16(sp)
    8000474c:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000474e:	00854783          	lbu	a5,8(a0)
    80004752:	cbc5                	beqz	a5,80004802 <fileread+0xbe>
    80004754:	ec26                	sd	s1,24(sp)
    80004756:	e44e                	sd	s3,8(sp)
    80004758:	84aa                	mv	s1,a0
    8000475a:	89ae                	mv	s3,a1
    8000475c:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000475e:	411c                	lw	a5,0(a0)
    80004760:	4705                	li	a4,1
    80004762:	04e78963          	beq	a5,a4,800047b4 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004766:	470d                	li	a4,3
    80004768:	04e78f63          	beq	a5,a4,800047c6 <fileread+0x82>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000476c:	4709                	li	a4,2
    8000476e:	08e79263          	bne	a5,a4,800047f2 <fileread+0xae>
    ilock(f->ip);
    80004772:	6d08                	ld	a0,24(a0)
    80004774:	fffff097          	auipc	ra,0xfffff
    80004778:	fe4080e7          	jalr	-28(ra) # 80003758 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000477c:	874a                	mv	a4,s2
    8000477e:	5094                	lw	a3,32(s1)
    80004780:	864e                	mv	a2,s3
    80004782:	4585                	li	a1,1
    80004784:	6c88                	ld	a0,24(s1)
    80004786:	fffff097          	auipc	ra,0xfffff
    8000478a:	28a080e7          	jalr	650(ra) # 80003a10 <readi>
    8000478e:	892a                	mv	s2,a0
    80004790:	00a05563          	blez	a0,8000479a <fileread+0x56>
      f->off += r;
    80004794:	509c                	lw	a5,32(s1)
    80004796:	9fa9                	addw	a5,a5,a0
    80004798:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000479a:	6c88                	ld	a0,24(s1)
    8000479c:	fffff097          	auipc	ra,0xfffff
    800047a0:	082080e7          	jalr	130(ra) # 8000381e <iunlock>
    800047a4:	64e2                	ld	s1,24(sp)
    800047a6:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800047a8:	854a                	mv	a0,s2
    800047aa:	70a2                	ld	ra,40(sp)
    800047ac:	7402                	ld	s0,32(sp)
    800047ae:	6942                	ld	s2,16(sp)
    800047b0:	6145                	addi	sp,sp,48
    800047b2:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800047b4:	6908                	ld	a0,16(a0)
    800047b6:	00000097          	auipc	ra,0x0
    800047ba:	400080e7          	jalr	1024(ra) # 80004bb6 <piperead>
    800047be:	892a                	mv	s2,a0
    800047c0:	64e2                	ld	s1,24(sp)
    800047c2:	69a2                	ld	s3,8(sp)
    800047c4:	b7d5                	j	800047a8 <fileread+0x64>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800047c6:	02451783          	lh	a5,36(a0)
    800047ca:	03079693          	slli	a3,a5,0x30
    800047ce:	92c1                	srli	a3,a3,0x30
    800047d0:	4725                	li	a4,9
    800047d2:	02d76a63          	bltu	a4,a3,80004806 <fileread+0xc2>
    800047d6:	0792                	slli	a5,a5,0x4
    800047d8:	0001c717          	auipc	a4,0x1c
    800047dc:	5d070713          	addi	a4,a4,1488 # 80020da8 <devsw>
    800047e0:	97ba                	add	a5,a5,a4
    800047e2:	639c                	ld	a5,0(a5)
    800047e4:	c78d                	beqz	a5,8000480e <fileread+0xca>
    r = devsw[f->major].read(1, addr, n);
    800047e6:	4505                	li	a0,1
    800047e8:	9782                	jalr	a5
    800047ea:	892a                	mv	s2,a0
    800047ec:	64e2                	ld	s1,24(sp)
    800047ee:	69a2                	ld	s3,8(sp)
    800047f0:	bf65                	j	800047a8 <fileread+0x64>
    panic("fileread");
    800047f2:	00004517          	auipc	a0,0x4
    800047f6:	d9e50513          	addi	a0,a0,-610 # 80008590 <etext+0x590>
    800047fa:	ffffc097          	auipc	ra,0xffffc
    800047fe:	d64080e7          	jalr	-668(ra) # 8000055e <panic>
    return -1;
    80004802:	597d                	li	s2,-1
    80004804:	b755                	j	800047a8 <fileread+0x64>
      return -1;
    80004806:	597d                	li	s2,-1
    80004808:	64e2                	ld	s1,24(sp)
    8000480a:	69a2                	ld	s3,8(sp)
    8000480c:	bf71                	j	800047a8 <fileread+0x64>
    8000480e:	597d                	li	s2,-1
    80004810:	64e2                	ld	s1,24(sp)
    80004812:	69a2                	ld	s3,8(sp)
    80004814:	bf51                	j	800047a8 <fileread+0x64>

0000000080004816 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004816:	00954783          	lbu	a5,9(a0)
    8000481a:	12078963          	beqz	a5,8000494c <filewrite+0x136>
{
    8000481e:	715d                	addi	sp,sp,-80
    80004820:	e486                	sd	ra,72(sp)
    80004822:	e0a2                	sd	s0,64(sp)
    80004824:	f84a                	sd	s2,48(sp)
    80004826:	f052                	sd	s4,32(sp)
    80004828:	e85a                	sd	s6,16(sp)
    8000482a:	0880                	addi	s0,sp,80
    8000482c:	892a                	mv	s2,a0
    8000482e:	8b2e                	mv	s6,a1
    80004830:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004832:	411c                	lw	a5,0(a0)
    80004834:	4705                	li	a4,1
    80004836:	02e78763          	beq	a5,a4,80004864 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000483a:	470d                	li	a4,3
    8000483c:	02e78a63          	beq	a5,a4,80004870 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004840:	4709                	li	a4,2
    80004842:	0ee79863          	bne	a5,a4,80004932 <filewrite+0x11c>
    80004846:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004848:	0cc05463          	blez	a2,80004910 <filewrite+0xfa>
    8000484c:	fc26                	sd	s1,56(sp)
    8000484e:	ec56                	sd	s5,24(sp)
    80004850:	e45e                	sd	s7,8(sp)
    80004852:	e062                	sd	s8,0(sp)
    int i = 0;
    80004854:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004856:	6b85                	lui	s7,0x1
    80004858:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000485c:	6c05                	lui	s8,0x1
    8000485e:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004862:	a851                	j	800048f6 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004864:	6908                	ld	a0,16(a0)
    80004866:	00000097          	auipc	ra,0x0
    8000486a:	248080e7          	jalr	584(ra) # 80004aae <pipewrite>
    8000486e:	a85d                	j	80004924 <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004870:	02451783          	lh	a5,36(a0)
    80004874:	03079693          	slli	a3,a5,0x30
    80004878:	92c1                	srli	a3,a3,0x30
    8000487a:	4725                	li	a4,9
    8000487c:	0cd76a63          	bltu	a4,a3,80004950 <filewrite+0x13a>
    80004880:	0792                	slli	a5,a5,0x4
    80004882:	0001c717          	auipc	a4,0x1c
    80004886:	52670713          	addi	a4,a4,1318 # 80020da8 <devsw>
    8000488a:	97ba                	add	a5,a5,a4
    8000488c:	679c                	ld	a5,8(a5)
    8000488e:	c3f9                	beqz	a5,80004954 <filewrite+0x13e>
    ret = devsw[f->major].write(1, addr, n);
    80004890:	4505                	li	a0,1
    80004892:	9782                	jalr	a5
    80004894:	a841                	j	80004924 <filewrite+0x10e>
      if(n1 > max)
    80004896:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    8000489a:	00000097          	auipc	ra,0x0
    8000489e:	88c080e7          	jalr	-1908(ra) # 80004126 <begin_op>
      ilock(f->ip);
    800048a2:	01893503          	ld	a0,24(s2)
    800048a6:	fffff097          	auipc	ra,0xfffff
    800048aa:	eb2080e7          	jalr	-334(ra) # 80003758 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800048ae:	8756                	mv	a4,s5
    800048b0:	02092683          	lw	a3,32(s2)
    800048b4:	01698633          	add	a2,s3,s6
    800048b8:	4585                	li	a1,1
    800048ba:	01893503          	ld	a0,24(s2)
    800048be:	fffff097          	auipc	ra,0xfffff
    800048c2:	262080e7          	jalr	610(ra) # 80003b20 <writei>
    800048c6:	84aa                	mv	s1,a0
    800048c8:	00a05763          	blez	a0,800048d6 <filewrite+0xc0>
        f->off += r;
    800048cc:	02092783          	lw	a5,32(s2)
    800048d0:	9fa9                	addw	a5,a5,a0
    800048d2:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800048d6:	01893503          	ld	a0,24(s2)
    800048da:	fffff097          	auipc	ra,0xfffff
    800048de:	f44080e7          	jalr	-188(ra) # 8000381e <iunlock>
      end_op();
    800048e2:	00000097          	auipc	ra,0x0
    800048e6:	8be080e7          	jalr	-1858(ra) # 800041a0 <end_op>

      if(r != n1){
    800048ea:	029a9563          	bne	s5,s1,80004914 <filewrite+0xfe>
        // error from writei
        break;
      }
      i += r;
    800048ee:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800048f2:	0149da63          	bge	s3,s4,80004906 <filewrite+0xf0>
      int n1 = n - i;
    800048f6:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    800048fa:	0004879b          	sext.w	a5,s1
    800048fe:	f8fbdce3          	bge	s7,a5,80004896 <filewrite+0x80>
    80004902:	84e2                	mv	s1,s8
    80004904:	bf49                	j	80004896 <filewrite+0x80>
    80004906:	74e2                	ld	s1,56(sp)
    80004908:	6ae2                	ld	s5,24(sp)
    8000490a:	6ba2                	ld	s7,8(sp)
    8000490c:	6c02                	ld	s8,0(sp)
    8000490e:	a039                	j	8000491c <filewrite+0x106>
    int i = 0;
    80004910:	4981                	li	s3,0
    80004912:	a029                	j	8000491c <filewrite+0x106>
    80004914:	74e2                	ld	s1,56(sp)
    80004916:	6ae2                	ld	s5,24(sp)
    80004918:	6ba2                	ld	s7,8(sp)
    8000491a:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    8000491c:	033a1e63          	bne	s4,s3,80004958 <filewrite+0x142>
    80004920:	8552                	mv	a0,s4
    80004922:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004924:	60a6                	ld	ra,72(sp)
    80004926:	6406                	ld	s0,64(sp)
    80004928:	7942                	ld	s2,48(sp)
    8000492a:	7a02                	ld	s4,32(sp)
    8000492c:	6b42                	ld	s6,16(sp)
    8000492e:	6161                	addi	sp,sp,80
    80004930:	8082                	ret
    80004932:	fc26                	sd	s1,56(sp)
    80004934:	f44e                	sd	s3,40(sp)
    80004936:	ec56                	sd	s5,24(sp)
    80004938:	e45e                	sd	s7,8(sp)
    8000493a:	e062                	sd	s8,0(sp)
    panic("filewrite");
    8000493c:	00004517          	auipc	a0,0x4
    80004940:	c6450513          	addi	a0,a0,-924 # 800085a0 <etext+0x5a0>
    80004944:	ffffc097          	auipc	ra,0xffffc
    80004948:	c1a080e7          	jalr	-998(ra) # 8000055e <panic>
    return -1;
    8000494c:	557d                	li	a0,-1
}
    8000494e:	8082                	ret
      return -1;
    80004950:	557d                	li	a0,-1
    80004952:	bfc9                	j	80004924 <filewrite+0x10e>
    80004954:	557d                	li	a0,-1
    80004956:	b7f9                	j	80004924 <filewrite+0x10e>
    ret = (i == n ? n : -1);
    80004958:	557d                	li	a0,-1
    8000495a:	79a2                	ld	s3,40(sp)
    8000495c:	b7e1                	j	80004924 <filewrite+0x10e>

000000008000495e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000495e:	7179                	addi	sp,sp,-48
    80004960:	f406                	sd	ra,40(sp)
    80004962:	f022                	sd	s0,32(sp)
    80004964:	ec26                	sd	s1,24(sp)
    80004966:	e052                	sd	s4,0(sp)
    80004968:	1800                	addi	s0,sp,48
    8000496a:	84aa                	mv	s1,a0
    8000496c:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000496e:	0005b023          	sd	zero,0(a1)
    80004972:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004976:	00000097          	auipc	ra,0x0
    8000497a:	bbe080e7          	jalr	-1090(ra) # 80004534 <filealloc>
    8000497e:	e088                	sd	a0,0(s1)
    80004980:	cd49                	beqz	a0,80004a1a <pipealloc+0xbc>
    80004982:	00000097          	auipc	ra,0x0
    80004986:	bb2080e7          	jalr	-1102(ra) # 80004534 <filealloc>
    8000498a:	00aa3023          	sd	a0,0(s4)
    8000498e:	c141                	beqz	a0,80004a0e <pipealloc+0xb0>
    80004990:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004992:	ffffc097          	auipc	ra,0xffffc
    80004996:	1b4080e7          	jalr	436(ra) # 80000b46 <kalloc>
    8000499a:	892a                	mv	s2,a0
    8000499c:	c13d                	beqz	a0,80004a02 <pipealloc+0xa4>
    8000499e:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800049a0:	4985                	li	s3,1
    800049a2:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800049a6:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800049aa:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800049ae:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800049b2:	00004597          	auipc	a1,0x4
    800049b6:	bfe58593          	addi	a1,a1,-1026 # 800085b0 <etext+0x5b0>
    800049ba:	ffffc097          	auipc	ra,0xffffc
    800049be:	1ec080e7          	jalr	492(ra) # 80000ba6 <initlock>
  (*f0)->type = FD_PIPE;
    800049c2:	609c                	ld	a5,0(s1)
    800049c4:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800049c8:	609c                	ld	a5,0(s1)
    800049ca:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800049ce:	609c                	ld	a5,0(s1)
    800049d0:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800049d4:	609c                	ld	a5,0(s1)
    800049d6:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800049da:	000a3783          	ld	a5,0(s4)
    800049de:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800049e2:	000a3783          	ld	a5,0(s4)
    800049e6:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800049ea:	000a3783          	ld	a5,0(s4)
    800049ee:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800049f2:	000a3783          	ld	a5,0(s4)
    800049f6:	0127b823          	sd	s2,16(a5)
  return 0;
    800049fa:	4501                	li	a0,0
    800049fc:	6942                	ld	s2,16(sp)
    800049fe:	69a2                	ld	s3,8(sp)
    80004a00:	a03d                	j	80004a2e <pipealloc+0xd0>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004a02:	6088                	ld	a0,0(s1)
    80004a04:	c119                	beqz	a0,80004a0a <pipealloc+0xac>
    80004a06:	6942                	ld	s2,16(sp)
    80004a08:	a029                	j	80004a12 <pipealloc+0xb4>
    80004a0a:	6942                	ld	s2,16(sp)
    80004a0c:	a039                	j	80004a1a <pipealloc+0xbc>
    80004a0e:	6088                	ld	a0,0(s1)
    80004a10:	c50d                	beqz	a0,80004a3a <pipealloc+0xdc>
    fileclose(*f0);
    80004a12:	00000097          	auipc	ra,0x0
    80004a16:	bde080e7          	jalr	-1058(ra) # 800045f0 <fileclose>
  if(*f1)
    80004a1a:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004a1e:	557d                	li	a0,-1
  if(*f1)
    80004a20:	c799                	beqz	a5,80004a2e <pipealloc+0xd0>
    fileclose(*f1);
    80004a22:	853e                	mv	a0,a5
    80004a24:	00000097          	auipc	ra,0x0
    80004a28:	bcc080e7          	jalr	-1076(ra) # 800045f0 <fileclose>
  return -1;
    80004a2c:	557d                	li	a0,-1
}
    80004a2e:	70a2                	ld	ra,40(sp)
    80004a30:	7402                	ld	s0,32(sp)
    80004a32:	64e2                	ld	s1,24(sp)
    80004a34:	6a02                	ld	s4,0(sp)
    80004a36:	6145                	addi	sp,sp,48
    80004a38:	8082                	ret
  return -1;
    80004a3a:	557d                	li	a0,-1
    80004a3c:	bfcd                	j	80004a2e <pipealloc+0xd0>

0000000080004a3e <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004a3e:	1101                	addi	sp,sp,-32
    80004a40:	ec06                	sd	ra,24(sp)
    80004a42:	e822                	sd	s0,16(sp)
    80004a44:	e426                	sd	s1,8(sp)
    80004a46:	e04a                	sd	s2,0(sp)
    80004a48:	1000                	addi	s0,sp,32
    80004a4a:	84aa                	mv	s1,a0
    80004a4c:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004a4e:	ffffc097          	auipc	ra,0xffffc
    80004a52:	1e8080e7          	jalr	488(ra) # 80000c36 <acquire>
  if(writable){
    80004a56:	02090d63          	beqz	s2,80004a90 <pipeclose+0x52>
    pi->writeopen = 0;
    80004a5a:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004a5e:	21848513          	addi	a0,s1,536
    80004a62:	ffffd097          	auipc	ra,0xffffd
    80004a66:	75a080e7          	jalr	1882(ra) # 800021bc <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004a6a:	2204b783          	ld	a5,544(s1)
    80004a6e:	eb95                	bnez	a5,80004aa2 <pipeclose+0x64>
    release(&pi->lock);
    80004a70:	8526                	mv	a0,s1
    80004a72:	ffffc097          	auipc	ra,0xffffc
    80004a76:	278080e7          	jalr	632(ra) # 80000cea <release>
    kfree((char*)pi);
    80004a7a:	8526                	mv	a0,s1
    80004a7c:	ffffc097          	auipc	ra,0xffffc
    80004a80:	fcc080e7          	jalr	-52(ra) # 80000a48 <kfree>
  } else
    release(&pi->lock);
}
    80004a84:	60e2                	ld	ra,24(sp)
    80004a86:	6442                	ld	s0,16(sp)
    80004a88:	64a2                	ld	s1,8(sp)
    80004a8a:	6902                	ld	s2,0(sp)
    80004a8c:	6105                	addi	sp,sp,32
    80004a8e:	8082                	ret
    pi->readopen = 0;
    80004a90:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004a94:	21c48513          	addi	a0,s1,540
    80004a98:	ffffd097          	auipc	ra,0xffffd
    80004a9c:	724080e7          	jalr	1828(ra) # 800021bc <wakeup>
    80004aa0:	b7e9                	j	80004a6a <pipeclose+0x2c>
    release(&pi->lock);
    80004aa2:	8526                	mv	a0,s1
    80004aa4:	ffffc097          	auipc	ra,0xffffc
    80004aa8:	246080e7          	jalr	582(ra) # 80000cea <release>
}
    80004aac:	bfe1                	j	80004a84 <pipeclose+0x46>

0000000080004aae <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004aae:	711d                	addi	sp,sp,-96
    80004ab0:	ec86                	sd	ra,88(sp)
    80004ab2:	e8a2                	sd	s0,80(sp)
    80004ab4:	e4a6                	sd	s1,72(sp)
    80004ab6:	e0ca                	sd	s2,64(sp)
    80004ab8:	fc4e                	sd	s3,56(sp)
    80004aba:	f852                	sd	s4,48(sp)
    80004abc:	f456                	sd	s5,40(sp)
    80004abe:	1080                	addi	s0,sp,96
    80004ac0:	84aa                	mv	s1,a0
    80004ac2:	8aae                	mv	s5,a1
    80004ac4:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004ac6:	ffffd097          	auipc	ra,0xffffd
    80004aca:	f82080e7          	jalr	-126(ra) # 80001a48 <myproc>
    80004ace:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004ad0:	8526                	mv	a0,s1
    80004ad2:	ffffc097          	auipc	ra,0xffffc
    80004ad6:	164080e7          	jalr	356(ra) # 80000c36 <acquire>
  while(i < n){
    80004ada:	0d405863          	blez	s4,80004baa <pipewrite+0xfc>
    80004ade:	f05a                	sd	s6,32(sp)
    80004ae0:	ec5e                	sd	s7,24(sp)
    80004ae2:	e862                	sd	s8,16(sp)
  int i = 0;
    80004ae4:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ae6:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004ae8:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004aec:	21c48b93          	addi	s7,s1,540
    80004af0:	a089                	j	80004b32 <pipewrite+0x84>
      release(&pi->lock);
    80004af2:	8526                	mv	a0,s1
    80004af4:	ffffc097          	auipc	ra,0xffffc
    80004af8:	1f6080e7          	jalr	502(ra) # 80000cea <release>
      return -1;
    80004afc:	597d                	li	s2,-1
    80004afe:	7b02                	ld	s6,32(sp)
    80004b00:	6be2                	ld	s7,24(sp)
    80004b02:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004b04:	854a                	mv	a0,s2
    80004b06:	60e6                	ld	ra,88(sp)
    80004b08:	6446                	ld	s0,80(sp)
    80004b0a:	64a6                	ld	s1,72(sp)
    80004b0c:	6906                	ld	s2,64(sp)
    80004b0e:	79e2                	ld	s3,56(sp)
    80004b10:	7a42                	ld	s4,48(sp)
    80004b12:	7aa2                	ld	s5,40(sp)
    80004b14:	6125                	addi	sp,sp,96
    80004b16:	8082                	ret
      wakeup(&pi->nread);
    80004b18:	8562                	mv	a0,s8
    80004b1a:	ffffd097          	auipc	ra,0xffffd
    80004b1e:	6a2080e7          	jalr	1698(ra) # 800021bc <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004b22:	85a6                	mv	a1,s1
    80004b24:	855e                	mv	a0,s7
    80004b26:	ffffd097          	auipc	ra,0xffffd
    80004b2a:	632080e7          	jalr	1586(ra) # 80002158 <sleep>
  while(i < n){
    80004b2e:	05495f63          	bge	s2,s4,80004b8c <pipewrite+0xde>
    if(pi->readopen == 0 || killed(pr)){
    80004b32:	2204a783          	lw	a5,544(s1)
    80004b36:	dfd5                	beqz	a5,80004af2 <pipewrite+0x44>
    80004b38:	854e                	mv	a0,s3
    80004b3a:	ffffe097          	auipc	ra,0xffffe
    80004b3e:	8c6080e7          	jalr	-1850(ra) # 80002400 <killed>
    80004b42:	f945                	bnez	a0,80004af2 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004b44:	2184a783          	lw	a5,536(s1)
    80004b48:	21c4a703          	lw	a4,540(s1)
    80004b4c:	2007879b          	addiw	a5,a5,512
    80004b50:	fcf704e3          	beq	a4,a5,80004b18 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004b54:	4685                	li	a3,1
    80004b56:	01590633          	add	a2,s2,s5
    80004b5a:	faf40593          	addi	a1,s0,-81
    80004b5e:	0509b503          	ld	a0,80(s3)
    80004b62:	ffffd097          	auipc	ra,0xffffd
    80004b66:	c0a080e7          	jalr	-1014(ra) # 8000176c <copyin>
    80004b6a:	05650263          	beq	a0,s6,80004bae <pipewrite+0x100>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004b6e:	21c4a783          	lw	a5,540(s1)
    80004b72:	0017871b          	addiw	a4,a5,1
    80004b76:	20e4ae23          	sw	a4,540(s1)
    80004b7a:	1ff7f793          	andi	a5,a5,511
    80004b7e:	97a6                	add	a5,a5,s1
    80004b80:	faf44703          	lbu	a4,-81(s0)
    80004b84:	00e78c23          	sb	a4,24(a5)
      i++;
    80004b88:	2905                	addiw	s2,s2,1
    80004b8a:	b755                	j	80004b2e <pipewrite+0x80>
    80004b8c:	7b02                	ld	s6,32(sp)
    80004b8e:	6be2                	ld	s7,24(sp)
    80004b90:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004b92:	21848513          	addi	a0,s1,536
    80004b96:	ffffd097          	auipc	ra,0xffffd
    80004b9a:	626080e7          	jalr	1574(ra) # 800021bc <wakeup>
  release(&pi->lock);
    80004b9e:	8526                	mv	a0,s1
    80004ba0:	ffffc097          	auipc	ra,0xffffc
    80004ba4:	14a080e7          	jalr	330(ra) # 80000cea <release>
  return i;
    80004ba8:	bfb1                	j	80004b04 <pipewrite+0x56>
  int i = 0;
    80004baa:	4901                	li	s2,0
    80004bac:	b7dd                	j	80004b92 <pipewrite+0xe4>
    80004bae:	7b02                	ld	s6,32(sp)
    80004bb0:	6be2                	ld	s7,24(sp)
    80004bb2:	6c42                	ld	s8,16(sp)
    80004bb4:	bff9                	j	80004b92 <pipewrite+0xe4>

0000000080004bb6 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004bb6:	715d                	addi	sp,sp,-80
    80004bb8:	e486                	sd	ra,72(sp)
    80004bba:	e0a2                	sd	s0,64(sp)
    80004bbc:	fc26                	sd	s1,56(sp)
    80004bbe:	f84a                	sd	s2,48(sp)
    80004bc0:	f44e                	sd	s3,40(sp)
    80004bc2:	f052                	sd	s4,32(sp)
    80004bc4:	ec56                	sd	s5,24(sp)
    80004bc6:	0880                	addi	s0,sp,80
    80004bc8:	84aa                	mv	s1,a0
    80004bca:	892e                	mv	s2,a1
    80004bcc:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004bce:	ffffd097          	auipc	ra,0xffffd
    80004bd2:	e7a080e7          	jalr	-390(ra) # 80001a48 <myproc>
    80004bd6:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004bd8:	8526                	mv	a0,s1
    80004bda:	ffffc097          	auipc	ra,0xffffc
    80004bde:	05c080e7          	jalr	92(ra) # 80000c36 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004be2:	2184a703          	lw	a4,536(s1)
    80004be6:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004bea:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004bee:	02f71963          	bne	a4,a5,80004c20 <piperead+0x6a>
    80004bf2:	2244a783          	lw	a5,548(s1)
    80004bf6:	cf95                	beqz	a5,80004c32 <piperead+0x7c>
    if(killed(pr)){
    80004bf8:	8552                	mv	a0,s4
    80004bfa:	ffffe097          	auipc	ra,0xffffe
    80004bfe:	806080e7          	jalr	-2042(ra) # 80002400 <killed>
    80004c02:	e10d                	bnez	a0,80004c24 <piperead+0x6e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004c04:	85a6                	mv	a1,s1
    80004c06:	854e                	mv	a0,s3
    80004c08:	ffffd097          	auipc	ra,0xffffd
    80004c0c:	550080e7          	jalr	1360(ra) # 80002158 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c10:	2184a703          	lw	a4,536(s1)
    80004c14:	21c4a783          	lw	a5,540(s1)
    80004c18:	fcf70de3          	beq	a4,a5,80004bf2 <piperead+0x3c>
    80004c1c:	e85a                	sd	s6,16(sp)
    80004c1e:	a819                	j	80004c34 <piperead+0x7e>
    80004c20:	e85a                	sd	s6,16(sp)
    80004c22:	a809                	j	80004c34 <piperead+0x7e>
      release(&pi->lock);
    80004c24:	8526                	mv	a0,s1
    80004c26:	ffffc097          	auipc	ra,0xffffc
    80004c2a:	0c4080e7          	jalr	196(ra) # 80000cea <release>
      return -1;
    80004c2e:	59fd                	li	s3,-1
    80004c30:	a0a5                	j	80004c98 <piperead+0xe2>
    80004c32:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c34:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004c36:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c38:	05505463          	blez	s5,80004c80 <piperead+0xca>
    if(pi->nread == pi->nwrite)
    80004c3c:	2184a783          	lw	a5,536(s1)
    80004c40:	21c4a703          	lw	a4,540(s1)
    80004c44:	02f70e63          	beq	a4,a5,80004c80 <piperead+0xca>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004c48:	0017871b          	addiw	a4,a5,1
    80004c4c:	20e4ac23          	sw	a4,536(s1)
    80004c50:	1ff7f793          	andi	a5,a5,511
    80004c54:	97a6                	add	a5,a5,s1
    80004c56:	0187c783          	lbu	a5,24(a5)
    80004c5a:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004c5e:	4685                	li	a3,1
    80004c60:	fbf40613          	addi	a2,s0,-65
    80004c64:	85ca                	mv	a1,s2
    80004c66:	050a3503          	ld	a0,80(s4)
    80004c6a:	ffffd097          	auipc	ra,0xffffd
    80004c6e:	a76080e7          	jalr	-1418(ra) # 800016e0 <copyout>
    80004c72:	01650763          	beq	a0,s6,80004c80 <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c76:	2985                	addiw	s3,s3,1
    80004c78:	0905                	addi	s2,s2,1
    80004c7a:	fd3a91e3          	bne	s5,s3,80004c3c <piperead+0x86>
    80004c7e:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004c80:	21c48513          	addi	a0,s1,540
    80004c84:	ffffd097          	auipc	ra,0xffffd
    80004c88:	538080e7          	jalr	1336(ra) # 800021bc <wakeup>
  release(&pi->lock);
    80004c8c:	8526                	mv	a0,s1
    80004c8e:	ffffc097          	auipc	ra,0xffffc
    80004c92:	05c080e7          	jalr	92(ra) # 80000cea <release>
    80004c96:	6b42                	ld	s6,16(sp)
  return i;
}
    80004c98:	854e                	mv	a0,s3
    80004c9a:	60a6                	ld	ra,72(sp)
    80004c9c:	6406                	ld	s0,64(sp)
    80004c9e:	74e2                	ld	s1,56(sp)
    80004ca0:	7942                	ld	s2,48(sp)
    80004ca2:	79a2                	ld	s3,40(sp)
    80004ca4:	7a02                	ld	s4,32(sp)
    80004ca6:	6ae2                	ld	s5,24(sp)
    80004ca8:	6161                	addi	sp,sp,80
    80004caa:	8082                	ret

0000000080004cac <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004cac:	1141                	addi	sp,sp,-16
    80004cae:	e422                	sd	s0,8(sp)
    80004cb0:	0800                	addi	s0,sp,16
    80004cb2:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004cb4:	8905                	andi	a0,a0,1
    80004cb6:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004cb8:	8b89                	andi	a5,a5,2
    80004cba:	c399                	beqz	a5,80004cc0 <flags2perm+0x14>
      perm |= PTE_W;
    80004cbc:	00456513          	ori	a0,a0,4
    return perm;
}
    80004cc0:	6422                	ld	s0,8(sp)
    80004cc2:	0141                	addi	sp,sp,16
    80004cc4:	8082                	ret

0000000080004cc6 <exec>:

int
exec(char *path, char **argv)
{
    80004cc6:	df010113          	addi	sp,sp,-528
    80004cca:	20113423          	sd	ra,520(sp)
    80004cce:	20813023          	sd	s0,512(sp)
    80004cd2:	ffa6                	sd	s1,504(sp)
    80004cd4:	fbca                	sd	s2,496(sp)
    80004cd6:	0c00                	addi	s0,sp,528
    80004cd8:	892a                	mv	s2,a0
    80004cda:	dea43c23          	sd	a0,-520(s0)
    80004cde:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004ce2:	ffffd097          	auipc	ra,0xffffd
    80004ce6:	d66080e7          	jalr	-666(ra) # 80001a48 <myproc>
    80004cea:	84aa                	mv	s1,a0

  begin_op();
    80004cec:	fffff097          	auipc	ra,0xfffff
    80004cf0:	43a080e7          	jalr	1082(ra) # 80004126 <begin_op>

  if((ip = namei(path)) == 0){
    80004cf4:	854a                	mv	a0,s2
    80004cf6:	fffff097          	auipc	ra,0xfffff
    80004cfa:	230080e7          	jalr	560(ra) # 80003f26 <namei>
    80004cfe:	c135                	beqz	a0,80004d62 <exec+0x9c>
    80004d00:	f3d2                	sd	s4,480(sp)
    80004d02:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004d04:	fffff097          	auipc	ra,0xfffff
    80004d08:	a54080e7          	jalr	-1452(ra) # 80003758 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004d0c:	04000713          	li	a4,64
    80004d10:	4681                	li	a3,0
    80004d12:	e5040613          	addi	a2,s0,-432
    80004d16:	4581                	li	a1,0
    80004d18:	8552                	mv	a0,s4
    80004d1a:	fffff097          	auipc	ra,0xfffff
    80004d1e:	cf6080e7          	jalr	-778(ra) # 80003a10 <readi>
    80004d22:	04000793          	li	a5,64
    80004d26:	00f51a63          	bne	a0,a5,80004d3a <exec+0x74>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004d2a:	e5042703          	lw	a4,-432(s0)
    80004d2e:	464c47b7          	lui	a5,0x464c4
    80004d32:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004d36:	02f70c63          	beq	a4,a5,80004d6e <exec+0xa8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004d3a:	8552                	mv	a0,s4
    80004d3c:	fffff097          	auipc	ra,0xfffff
    80004d40:	c82080e7          	jalr	-894(ra) # 800039be <iunlockput>
    end_op();
    80004d44:	fffff097          	auipc	ra,0xfffff
    80004d48:	45c080e7          	jalr	1116(ra) # 800041a0 <end_op>
  }
  return -1;
    80004d4c:	557d                	li	a0,-1
    80004d4e:	7a1e                	ld	s4,480(sp)
}
    80004d50:	20813083          	ld	ra,520(sp)
    80004d54:	20013403          	ld	s0,512(sp)
    80004d58:	74fe                	ld	s1,504(sp)
    80004d5a:	795e                	ld	s2,496(sp)
    80004d5c:	21010113          	addi	sp,sp,528
    80004d60:	8082                	ret
    end_op();
    80004d62:	fffff097          	auipc	ra,0xfffff
    80004d66:	43e080e7          	jalr	1086(ra) # 800041a0 <end_op>
    return -1;
    80004d6a:	557d                	li	a0,-1
    80004d6c:	b7d5                	j	80004d50 <exec+0x8a>
    80004d6e:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004d70:	8526                	mv	a0,s1
    80004d72:	ffffd097          	auipc	ra,0xffffd
    80004d76:	d9a080e7          	jalr	-614(ra) # 80001b0c <proc_pagetable>
    80004d7a:	8b2a                	mv	s6,a0
    80004d7c:	30050f63          	beqz	a0,8000509a <exec+0x3d4>
    80004d80:	f7ce                	sd	s3,488(sp)
    80004d82:	efd6                	sd	s5,472(sp)
    80004d84:	e7de                	sd	s7,456(sp)
    80004d86:	e3e2                	sd	s8,448(sp)
    80004d88:	ff66                	sd	s9,440(sp)
    80004d8a:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d8c:	e7042d03          	lw	s10,-400(s0)
    80004d90:	e8845783          	lhu	a5,-376(s0)
    80004d94:	14078d63          	beqz	a5,80004eee <exec+0x228>
    80004d98:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004d9a:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d9c:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004d9e:	6c85                	lui	s9,0x1
    80004da0:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004da4:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004da8:	6a85                	lui	s5,0x1
    80004daa:	a0b5                	j	80004e16 <exec+0x150>
      panic("loadseg: address should exist");
    80004dac:	00004517          	auipc	a0,0x4
    80004db0:	80c50513          	addi	a0,a0,-2036 # 800085b8 <etext+0x5b8>
    80004db4:	ffffb097          	auipc	ra,0xffffb
    80004db8:	7aa080e7          	jalr	1962(ra) # 8000055e <panic>
    if(sz - i < PGSIZE)
    80004dbc:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004dbe:	8726                	mv	a4,s1
    80004dc0:	012c06bb          	addw	a3,s8,s2
    80004dc4:	4581                	li	a1,0
    80004dc6:	8552                	mv	a0,s4
    80004dc8:	fffff097          	auipc	ra,0xfffff
    80004dcc:	c48080e7          	jalr	-952(ra) # 80003a10 <readi>
    80004dd0:	2501                	sext.w	a0,a0
    80004dd2:	28a49863          	bne	s1,a0,80005062 <exec+0x39c>
  for(i = 0; i < sz; i += PGSIZE){
    80004dd6:	012a893b          	addw	s2,s5,s2
    80004dda:	03397563          	bgeu	s2,s3,80004e04 <exec+0x13e>
    pa = walkaddr(pagetable, va + i);
    80004dde:	02091593          	slli	a1,s2,0x20
    80004de2:	9181                	srli	a1,a1,0x20
    80004de4:	95de                	add	a1,a1,s7
    80004de6:	855a                	mv	a0,s6
    80004de8:	ffffc097          	auipc	ra,0xffffc
    80004dec:	2cc080e7          	jalr	716(ra) # 800010b4 <walkaddr>
    80004df0:	862a                	mv	a2,a0
    if(pa == 0)
    80004df2:	dd4d                	beqz	a0,80004dac <exec+0xe6>
    if(sz - i < PGSIZE)
    80004df4:	412984bb          	subw	s1,s3,s2
    80004df8:	0004879b          	sext.w	a5,s1
    80004dfc:	fcfcf0e3          	bgeu	s9,a5,80004dbc <exec+0xf6>
    80004e00:	84d6                	mv	s1,s5
    80004e02:	bf6d                	j	80004dbc <exec+0xf6>
    sz = sz1;
    80004e04:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e08:	2d85                	addiw	s11,s11,1
    80004e0a:	038d0d1b          	addiw	s10,s10,56
    80004e0e:	e8845783          	lhu	a5,-376(s0)
    80004e12:	08fdd663          	bge	s11,a5,80004e9e <exec+0x1d8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004e16:	2d01                	sext.w	s10,s10
    80004e18:	03800713          	li	a4,56
    80004e1c:	86ea                	mv	a3,s10
    80004e1e:	e1840613          	addi	a2,s0,-488
    80004e22:	4581                	li	a1,0
    80004e24:	8552                	mv	a0,s4
    80004e26:	fffff097          	auipc	ra,0xfffff
    80004e2a:	bea080e7          	jalr	-1046(ra) # 80003a10 <readi>
    80004e2e:	03800793          	li	a5,56
    80004e32:	20f51063          	bne	a0,a5,80005032 <exec+0x36c>
    if(ph.type != ELF_PROG_LOAD)
    80004e36:	e1842783          	lw	a5,-488(s0)
    80004e3a:	4705                	li	a4,1
    80004e3c:	fce796e3          	bne	a5,a4,80004e08 <exec+0x142>
    if(ph.memsz < ph.filesz)
    80004e40:	e4043483          	ld	s1,-448(s0)
    80004e44:	e3843783          	ld	a5,-456(s0)
    80004e48:	1ef4e963          	bltu	s1,a5,8000503a <exec+0x374>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004e4c:	e2843783          	ld	a5,-472(s0)
    80004e50:	94be                	add	s1,s1,a5
    80004e52:	1ef4e863          	bltu	s1,a5,80005042 <exec+0x37c>
    if(ph.vaddr % PGSIZE != 0)
    80004e56:	df043703          	ld	a4,-528(s0)
    80004e5a:	8ff9                	and	a5,a5,a4
    80004e5c:	1e079763          	bnez	a5,8000504a <exec+0x384>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004e60:	e1c42503          	lw	a0,-484(s0)
    80004e64:	00000097          	auipc	ra,0x0
    80004e68:	e48080e7          	jalr	-440(ra) # 80004cac <flags2perm>
    80004e6c:	86aa                	mv	a3,a0
    80004e6e:	8626                	mv	a2,s1
    80004e70:	85ca                	mv	a1,s2
    80004e72:	855a                	mv	a0,s6
    80004e74:	ffffc097          	auipc	ra,0xffffc
    80004e78:	604080e7          	jalr	1540(ra) # 80001478 <uvmalloc>
    80004e7c:	e0a43423          	sd	a0,-504(s0)
    80004e80:	1c050963          	beqz	a0,80005052 <exec+0x38c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004e84:	e2843b83          	ld	s7,-472(s0)
    80004e88:	e2042c03          	lw	s8,-480(s0)
    80004e8c:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004e90:	00098463          	beqz	s3,80004e98 <exec+0x1d2>
    80004e94:	4901                	li	s2,0
    80004e96:	b7a1                	j	80004dde <exec+0x118>
    sz = sz1;
    80004e98:	e0843903          	ld	s2,-504(s0)
    80004e9c:	b7b5                	j	80004e08 <exec+0x142>
    80004e9e:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80004ea0:	8552                	mv	a0,s4
    80004ea2:	fffff097          	auipc	ra,0xfffff
    80004ea6:	b1c080e7          	jalr	-1252(ra) # 800039be <iunlockput>
  end_op();
    80004eaa:	fffff097          	auipc	ra,0xfffff
    80004eae:	2f6080e7          	jalr	758(ra) # 800041a0 <end_op>
  p = myproc();
    80004eb2:	ffffd097          	auipc	ra,0xffffd
    80004eb6:	b96080e7          	jalr	-1130(ra) # 80001a48 <myproc>
    80004eba:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004ebc:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004ec0:	6985                	lui	s3,0x1
    80004ec2:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004ec4:	99ca                	add	s3,s3,s2
    80004ec6:	77fd                	lui	a5,0xfffff
    80004ec8:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004ecc:	4691                	li	a3,4
    80004ece:	6609                	lui	a2,0x2
    80004ed0:	964e                	add	a2,a2,s3
    80004ed2:	85ce                	mv	a1,s3
    80004ed4:	855a                	mv	a0,s6
    80004ed6:	ffffc097          	auipc	ra,0xffffc
    80004eda:	5a2080e7          	jalr	1442(ra) # 80001478 <uvmalloc>
    80004ede:	892a                	mv	s2,a0
    80004ee0:	e0a43423          	sd	a0,-504(s0)
    80004ee4:	e519                	bnez	a0,80004ef2 <exec+0x22c>
  if(pagetable)
    80004ee6:	e1343423          	sd	s3,-504(s0)
    80004eea:	4a01                	li	s4,0
    80004eec:	aaa5                	j	80005064 <exec+0x39e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004eee:	4901                	li	s2,0
    80004ef0:	bf45                	j	80004ea0 <exec+0x1da>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004ef2:	75f9                	lui	a1,0xffffe
    80004ef4:	95aa                	add	a1,a1,a0
    80004ef6:	855a                	mv	a0,s6
    80004ef8:	ffffc097          	auipc	ra,0xffffc
    80004efc:	7b6080e7          	jalr	1974(ra) # 800016ae <uvmclear>
  stackbase = sp - PGSIZE;
    80004f00:	7bfd                	lui	s7,0xfffff
    80004f02:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004f04:	e0043783          	ld	a5,-512(s0)
    80004f08:	6388                	ld	a0,0(a5)
    80004f0a:	c52d                	beqz	a0,80004f74 <exec+0x2ae>
    80004f0c:	e9040993          	addi	s3,s0,-368
    80004f10:	f9040c13          	addi	s8,s0,-112
    80004f14:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004f16:	ffffc097          	auipc	ra,0xffffc
    80004f1a:	f90080e7          	jalr	-112(ra) # 80000ea6 <strlen>
    80004f1e:	0015079b          	addiw	a5,a0,1
    80004f22:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004f26:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004f2a:	13796863          	bltu	s2,s7,8000505a <exec+0x394>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004f2e:	e0043d03          	ld	s10,-512(s0)
    80004f32:	000d3a03          	ld	s4,0(s10)
    80004f36:	8552                	mv	a0,s4
    80004f38:	ffffc097          	auipc	ra,0xffffc
    80004f3c:	f6e080e7          	jalr	-146(ra) # 80000ea6 <strlen>
    80004f40:	0015069b          	addiw	a3,a0,1
    80004f44:	8652                	mv	a2,s4
    80004f46:	85ca                	mv	a1,s2
    80004f48:	855a                	mv	a0,s6
    80004f4a:	ffffc097          	auipc	ra,0xffffc
    80004f4e:	796080e7          	jalr	1942(ra) # 800016e0 <copyout>
    80004f52:	10054663          	bltz	a0,8000505e <exec+0x398>
    ustack[argc] = sp;
    80004f56:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004f5a:	0485                	addi	s1,s1,1
    80004f5c:	008d0793          	addi	a5,s10,8
    80004f60:	e0f43023          	sd	a5,-512(s0)
    80004f64:	008d3503          	ld	a0,8(s10)
    80004f68:	c909                	beqz	a0,80004f7a <exec+0x2b4>
    if(argc >= MAXARG)
    80004f6a:	09a1                	addi	s3,s3,8
    80004f6c:	fb8995e3          	bne	s3,s8,80004f16 <exec+0x250>
  ip = 0;
    80004f70:	4a01                	li	s4,0
    80004f72:	a8cd                	j	80005064 <exec+0x39e>
  sp = sz;
    80004f74:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004f78:	4481                	li	s1,0
  ustack[argc] = 0;
    80004f7a:	00349793          	slli	a5,s1,0x3
    80004f7e:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdd050>
    80004f82:	97a2                	add	a5,a5,s0
    80004f84:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004f88:	00148693          	addi	a3,s1,1
    80004f8c:	068e                	slli	a3,a3,0x3
    80004f8e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004f92:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004f96:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004f9a:	f57966e3          	bltu	s2,s7,80004ee6 <exec+0x220>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004f9e:	e9040613          	addi	a2,s0,-368
    80004fa2:	85ca                	mv	a1,s2
    80004fa4:	855a                	mv	a0,s6
    80004fa6:	ffffc097          	auipc	ra,0xffffc
    80004faa:	73a080e7          	jalr	1850(ra) # 800016e0 <copyout>
    80004fae:	0e054863          	bltz	a0,8000509e <exec+0x3d8>
  p->trapframe->a1 = sp;
    80004fb2:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004fb6:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004fba:	df843783          	ld	a5,-520(s0)
    80004fbe:	0007c703          	lbu	a4,0(a5)
    80004fc2:	cf11                	beqz	a4,80004fde <exec+0x318>
    80004fc4:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004fc6:	02f00693          	li	a3,47
    80004fca:	a039                	j	80004fd8 <exec+0x312>
      last = s+1;
    80004fcc:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004fd0:	0785                	addi	a5,a5,1
    80004fd2:	fff7c703          	lbu	a4,-1(a5)
    80004fd6:	c701                	beqz	a4,80004fde <exec+0x318>
    if(*s == '/')
    80004fd8:	fed71ce3          	bne	a4,a3,80004fd0 <exec+0x30a>
    80004fdc:	bfc5                	j	80004fcc <exec+0x306>
  safestrcpy(p->name, last, sizeof(p->name));
    80004fde:	4641                	li	a2,16
    80004fe0:	df843583          	ld	a1,-520(s0)
    80004fe4:	158a8513          	addi	a0,s5,344
    80004fe8:	ffffc097          	auipc	ra,0xffffc
    80004fec:	e8c080e7          	jalr	-372(ra) # 80000e74 <safestrcpy>
  oldpagetable = p->pagetable;
    80004ff0:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004ff4:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004ff8:	e0843783          	ld	a5,-504(s0)
    80004ffc:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005000:	058ab783          	ld	a5,88(s5)
    80005004:	e6843703          	ld	a4,-408(s0)
    80005008:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000500a:	058ab783          	ld	a5,88(s5)
    8000500e:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005012:	85e6                	mv	a1,s9
    80005014:	ffffd097          	auipc	ra,0xffffd
    80005018:	b94080e7          	jalr	-1132(ra) # 80001ba8 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000501c:	0004851b          	sext.w	a0,s1
    80005020:	79be                	ld	s3,488(sp)
    80005022:	7a1e                	ld	s4,480(sp)
    80005024:	6afe                	ld	s5,472(sp)
    80005026:	6b5e                	ld	s6,464(sp)
    80005028:	6bbe                	ld	s7,456(sp)
    8000502a:	6c1e                	ld	s8,448(sp)
    8000502c:	7cfa                	ld	s9,440(sp)
    8000502e:	7d5a                	ld	s10,432(sp)
    80005030:	b305                	j	80004d50 <exec+0x8a>
    80005032:	e1243423          	sd	s2,-504(s0)
    80005036:	7dba                	ld	s11,424(sp)
    80005038:	a035                	j	80005064 <exec+0x39e>
    8000503a:	e1243423          	sd	s2,-504(s0)
    8000503e:	7dba                	ld	s11,424(sp)
    80005040:	a015                	j	80005064 <exec+0x39e>
    80005042:	e1243423          	sd	s2,-504(s0)
    80005046:	7dba                	ld	s11,424(sp)
    80005048:	a831                	j	80005064 <exec+0x39e>
    8000504a:	e1243423          	sd	s2,-504(s0)
    8000504e:	7dba                	ld	s11,424(sp)
    80005050:	a811                	j	80005064 <exec+0x39e>
    80005052:	e1243423          	sd	s2,-504(s0)
    80005056:	7dba                	ld	s11,424(sp)
    80005058:	a031                	j	80005064 <exec+0x39e>
  ip = 0;
    8000505a:	4a01                	li	s4,0
    8000505c:	a021                	j	80005064 <exec+0x39e>
    8000505e:	4a01                	li	s4,0
  if(pagetable)
    80005060:	a011                	j	80005064 <exec+0x39e>
    80005062:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80005064:	e0843583          	ld	a1,-504(s0)
    80005068:	855a                	mv	a0,s6
    8000506a:	ffffd097          	auipc	ra,0xffffd
    8000506e:	b3e080e7          	jalr	-1218(ra) # 80001ba8 <proc_freepagetable>
  return -1;
    80005072:	557d                	li	a0,-1
  if(ip){
    80005074:	000a1b63          	bnez	s4,8000508a <exec+0x3c4>
    80005078:	79be                	ld	s3,488(sp)
    8000507a:	7a1e                	ld	s4,480(sp)
    8000507c:	6afe                	ld	s5,472(sp)
    8000507e:	6b5e                	ld	s6,464(sp)
    80005080:	6bbe                	ld	s7,456(sp)
    80005082:	6c1e                	ld	s8,448(sp)
    80005084:	7cfa                	ld	s9,440(sp)
    80005086:	7d5a                	ld	s10,432(sp)
    80005088:	b1e1                	j	80004d50 <exec+0x8a>
    8000508a:	79be                	ld	s3,488(sp)
    8000508c:	6afe                	ld	s5,472(sp)
    8000508e:	6b5e                	ld	s6,464(sp)
    80005090:	6bbe                	ld	s7,456(sp)
    80005092:	6c1e                	ld	s8,448(sp)
    80005094:	7cfa                	ld	s9,440(sp)
    80005096:	7d5a                	ld	s10,432(sp)
    80005098:	b14d                	j	80004d3a <exec+0x74>
    8000509a:	6b5e                	ld	s6,464(sp)
    8000509c:	b979                	j	80004d3a <exec+0x74>
  sz = sz1;
    8000509e:	e0843983          	ld	s3,-504(s0)
    800050a2:	b591                	j	80004ee6 <exec+0x220>

00000000800050a4 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800050a4:	7179                	addi	sp,sp,-48
    800050a6:	f406                	sd	ra,40(sp)
    800050a8:	f022                	sd	s0,32(sp)
    800050aa:	ec26                	sd	s1,24(sp)
    800050ac:	e84a                	sd	s2,16(sp)
    800050ae:	1800                	addi	s0,sp,48
    800050b0:	892e                	mv	s2,a1
    800050b2:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800050b4:	fdc40593          	addi	a1,s0,-36
    800050b8:	ffffe097          	auipc	ra,0xffffe
    800050bc:	b16080e7          	jalr	-1258(ra) # 80002bce <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800050c0:	fdc42703          	lw	a4,-36(s0)
    800050c4:	47bd                	li	a5,15
    800050c6:	02e7eb63          	bltu	a5,a4,800050fc <argfd+0x58>
    800050ca:	ffffd097          	auipc	ra,0xffffd
    800050ce:	97e080e7          	jalr	-1666(ra) # 80001a48 <myproc>
    800050d2:	fdc42703          	lw	a4,-36(s0)
    800050d6:	01a70793          	addi	a5,a4,26
    800050da:	078e                	slli	a5,a5,0x3
    800050dc:	953e                	add	a0,a0,a5
    800050de:	611c                	ld	a5,0(a0)
    800050e0:	c385                	beqz	a5,80005100 <argfd+0x5c>
    return -1;
  if(pfd)
    800050e2:	00090463          	beqz	s2,800050ea <argfd+0x46>
    *pfd = fd;
    800050e6:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800050ea:	4501                	li	a0,0
  if(pf)
    800050ec:	c091                	beqz	s1,800050f0 <argfd+0x4c>
    *pf = f;
    800050ee:	e09c                	sd	a5,0(s1)
}
    800050f0:	70a2                	ld	ra,40(sp)
    800050f2:	7402                	ld	s0,32(sp)
    800050f4:	64e2                	ld	s1,24(sp)
    800050f6:	6942                	ld	s2,16(sp)
    800050f8:	6145                	addi	sp,sp,48
    800050fa:	8082                	ret
    return -1;
    800050fc:	557d                	li	a0,-1
    800050fe:	bfcd                	j	800050f0 <argfd+0x4c>
    80005100:	557d                	li	a0,-1
    80005102:	b7fd                	j	800050f0 <argfd+0x4c>

0000000080005104 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005104:	1101                	addi	sp,sp,-32
    80005106:	ec06                	sd	ra,24(sp)
    80005108:	e822                	sd	s0,16(sp)
    8000510a:	e426                	sd	s1,8(sp)
    8000510c:	1000                	addi	s0,sp,32
    8000510e:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005110:	ffffd097          	auipc	ra,0xffffd
    80005114:	938080e7          	jalr	-1736(ra) # 80001a48 <myproc>
    80005118:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000511a:	0d050793          	addi	a5,a0,208
    8000511e:	4501                	li	a0,0
    80005120:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005122:	6398                	ld	a4,0(a5)
    80005124:	cb19                	beqz	a4,8000513a <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005126:	2505                	addiw	a0,a0,1
    80005128:	07a1                	addi	a5,a5,8
    8000512a:	fed51ce3          	bne	a0,a3,80005122 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000512e:	557d                	li	a0,-1
}
    80005130:	60e2                	ld	ra,24(sp)
    80005132:	6442                	ld	s0,16(sp)
    80005134:	64a2                	ld	s1,8(sp)
    80005136:	6105                	addi	sp,sp,32
    80005138:	8082                	ret
      p->ofile[fd] = f;
    8000513a:	01a50793          	addi	a5,a0,26
    8000513e:	078e                	slli	a5,a5,0x3
    80005140:	963e                	add	a2,a2,a5
    80005142:	e204                	sd	s1,0(a2)
      return fd;
    80005144:	b7f5                	j	80005130 <fdalloc+0x2c>

0000000080005146 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005146:	715d                	addi	sp,sp,-80
    80005148:	e486                	sd	ra,72(sp)
    8000514a:	e0a2                	sd	s0,64(sp)
    8000514c:	fc26                	sd	s1,56(sp)
    8000514e:	f84a                	sd	s2,48(sp)
    80005150:	f44e                	sd	s3,40(sp)
    80005152:	ec56                	sd	s5,24(sp)
    80005154:	e85a                	sd	s6,16(sp)
    80005156:	0880                	addi	s0,sp,80
    80005158:	8b2e                	mv	s6,a1
    8000515a:	89b2                	mv	s3,a2
    8000515c:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000515e:	fb040593          	addi	a1,s0,-80
    80005162:	fffff097          	auipc	ra,0xfffff
    80005166:	de2080e7          	jalr	-542(ra) # 80003f44 <nameiparent>
    8000516a:	84aa                	mv	s1,a0
    8000516c:	14050e63          	beqz	a0,800052c8 <create+0x182>
    return 0;

  ilock(dp);
    80005170:	ffffe097          	auipc	ra,0xffffe
    80005174:	5e8080e7          	jalr	1512(ra) # 80003758 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005178:	4601                	li	a2,0
    8000517a:	fb040593          	addi	a1,s0,-80
    8000517e:	8526                	mv	a0,s1
    80005180:	fffff097          	auipc	ra,0xfffff
    80005184:	ae4080e7          	jalr	-1308(ra) # 80003c64 <dirlookup>
    80005188:	8aaa                	mv	s5,a0
    8000518a:	c539                	beqz	a0,800051d8 <create+0x92>
    iunlockput(dp);
    8000518c:	8526                	mv	a0,s1
    8000518e:	fffff097          	auipc	ra,0xfffff
    80005192:	830080e7          	jalr	-2000(ra) # 800039be <iunlockput>
    ilock(ip);
    80005196:	8556                	mv	a0,s5
    80005198:	ffffe097          	auipc	ra,0xffffe
    8000519c:	5c0080e7          	jalr	1472(ra) # 80003758 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800051a0:	4789                	li	a5,2
    800051a2:	02fb1463          	bne	s6,a5,800051ca <create+0x84>
    800051a6:	044ad783          	lhu	a5,68(s5)
    800051aa:	37f9                	addiw	a5,a5,-2
    800051ac:	17c2                	slli	a5,a5,0x30
    800051ae:	93c1                	srli	a5,a5,0x30
    800051b0:	4705                	li	a4,1
    800051b2:	00f76c63          	bltu	a4,a5,800051ca <create+0x84>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800051b6:	8556                	mv	a0,s5
    800051b8:	60a6                	ld	ra,72(sp)
    800051ba:	6406                	ld	s0,64(sp)
    800051bc:	74e2                	ld	s1,56(sp)
    800051be:	7942                	ld	s2,48(sp)
    800051c0:	79a2                	ld	s3,40(sp)
    800051c2:	6ae2                	ld	s5,24(sp)
    800051c4:	6b42                	ld	s6,16(sp)
    800051c6:	6161                	addi	sp,sp,80
    800051c8:	8082                	ret
    iunlockput(ip);
    800051ca:	8556                	mv	a0,s5
    800051cc:	ffffe097          	auipc	ra,0xffffe
    800051d0:	7f2080e7          	jalr	2034(ra) # 800039be <iunlockput>
    return 0;
    800051d4:	4a81                	li	s5,0
    800051d6:	b7c5                	j	800051b6 <create+0x70>
    800051d8:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    800051da:	85da                	mv	a1,s6
    800051dc:	4088                	lw	a0,0(s1)
    800051de:	ffffe097          	auipc	ra,0xffffe
    800051e2:	3d6080e7          	jalr	982(ra) # 800035b4 <ialloc>
    800051e6:	8a2a                	mv	s4,a0
    800051e8:	c531                	beqz	a0,80005234 <create+0xee>
  ilock(ip);
    800051ea:	ffffe097          	auipc	ra,0xffffe
    800051ee:	56e080e7          	jalr	1390(ra) # 80003758 <ilock>
  ip->major = major;
    800051f2:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800051f6:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800051fa:	4905                	li	s2,1
    800051fc:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005200:	8552                	mv	a0,s4
    80005202:	ffffe097          	auipc	ra,0xffffe
    80005206:	48a080e7          	jalr	1162(ra) # 8000368c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000520a:	032b0d63          	beq	s6,s2,80005244 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    8000520e:	004a2603          	lw	a2,4(s4)
    80005212:	fb040593          	addi	a1,s0,-80
    80005216:	8526                	mv	a0,s1
    80005218:	fffff097          	auipc	ra,0xfffff
    8000521c:	c5c080e7          	jalr	-932(ra) # 80003e74 <dirlink>
    80005220:	08054163          	bltz	a0,800052a2 <create+0x15c>
  iunlockput(dp);
    80005224:	8526                	mv	a0,s1
    80005226:	ffffe097          	auipc	ra,0xffffe
    8000522a:	798080e7          	jalr	1944(ra) # 800039be <iunlockput>
  return ip;
    8000522e:	8ad2                	mv	s5,s4
    80005230:	7a02                	ld	s4,32(sp)
    80005232:	b751                	j	800051b6 <create+0x70>
    iunlockput(dp);
    80005234:	8526                	mv	a0,s1
    80005236:	ffffe097          	auipc	ra,0xffffe
    8000523a:	788080e7          	jalr	1928(ra) # 800039be <iunlockput>
    return 0;
    8000523e:	8ad2                	mv	s5,s4
    80005240:	7a02                	ld	s4,32(sp)
    80005242:	bf95                	j	800051b6 <create+0x70>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005244:	004a2603          	lw	a2,4(s4)
    80005248:	00003597          	auipc	a1,0x3
    8000524c:	39058593          	addi	a1,a1,912 # 800085d8 <etext+0x5d8>
    80005250:	8552                	mv	a0,s4
    80005252:	fffff097          	auipc	ra,0xfffff
    80005256:	c22080e7          	jalr	-990(ra) # 80003e74 <dirlink>
    8000525a:	04054463          	bltz	a0,800052a2 <create+0x15c>
    8000525e:	40d0                	lw	a2,4(s1)
    80005260:	00003597          	auipc	a1,0x3
    80005264:	38058593          	addi	a1,a1,896 # 800085e0 <etext+0x5e0>
    80005268:	8552                	mv	a0,s4
    8000526a:	fffff097          	auipc	ra,0xfffff
    8000526e:	c0a080e7          	jalr	-1014(ra) # 80003e74 <dirlink>
    80005272:	02054863          	bltz	a0,800052a2 <create+0x15c>
  if(dirlink(dp, name, ip->inum) < 0)
    80005276:	004a2603          	lw	a2,4(s4)
    8000527a:	fb040593          	addi	a1,s0,-80
    8000527e:	8526                	mv	a0,s1
    80005280:	fffff097          	auipc	ra,0xfffff
    80005284:	bf4080e7          	jalr	-1036(ra) # 80003e74 <dirlink>
    80005288:	00054d63          	bltz	a0,800052a2 <create+0x15c>
    dp->nlink++;  // for ".."
    8000528c:	04a4d783          	lhu	a5,74(s1)
    80005290:	2785                	addiw	a5,a5,1
    80005292:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005296:	8526                	mv	a0,s1
    80005298:	ffffe097          	auipc	ra,0xffffe
    8000529c:	3f4080e7          	jalr	1012(ra) # 8000368c <iupdate>
    800052a0:	b751                	j	80005224 <create+0xde>
  ip->nlink = 0;
    800052a2:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800052a6:	8552                	mv	a0,s4
    800052a8:	ffffe097          	auipc	ra,0xffffe
    800052ac:	3e4080e7          	jalr	996(ra) # 8000368c <iupdate>
  iunlockput(ip);
    800052b0:	8552                	mv	a0,s4
    800052b2:	ffffe097          	auipc	ra,0xffffe
    800052b6:	70c080e7          	jalr	1804(ra) # 800039be <iunlockput>
  iunlockput(dp);
    800052ba:	8526                	mv	a0,s1
    800052bc:	ffffe097          	auipc	ra,0xffffe
    800052c0:	702080e7          	jalr	1794(ra) # 800039be <iunlockput>
  return 0;
    800052c4:	7a02                	ld	s4,32(sp)
    800052c6:	bdc5                	j	800051b6 <create+0x70>
    return 0;
    800052c8:	8aaa                	mv	s5,a0
    800052ca:	b5f5                	j	800051b6 <create+0x70>

00000000800052cc <sys_dup>:
{
    800052cc:	7179                	addi	sp,sp,-48
    800052ce:	f406                	sd	ra,40(sp)
    800052d0:	f022                	sd	s0,32(sp)
    800052d2:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800052d4:	fd840613          	addi	a2,s0,-40
    800052d8:	4581                	li	a1,0
    800052da:	4501                	li	a0,0
    800052dc:	00000097          	auipc	ra,0x0
    800052e0:	dc8080e7          	jalr	-568(ra) # 800050a4 <argfd>
    return -1;
    800052e4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800052e6:	02054763          	bltz	a0,80005314 <sys_dup+0x48>
    800052ea:	ec26                	sd	s1,24(sp)
    800052ec:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    800052ee:	fd843903          	ld	s2,-40(s0)
    800052f2:	854a                	mv	a0,s2
    800052f4:	00000097          	auipc	ra,0x0
    800052f8:	e10080e7          	jalr	-496(ra) # 80005104 <fdalloc>
    800052fc:	84aa                	mv	s1,a0
    return -1;
    800052fe:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005300:	00054f63          	bltz	a0,8000531e <sys_dup+0x52>
  filedup(f);
    80005304:	854a                	mv	a0,s2
    80005306:	fffff097          	auipc	ra,0xfffff
    8000530a:	298080e7          	jalr	664(ra) # 8000459e <filedup>
  return fd;
    8000530e:	87a6                	mv	a5,s1
    80005310:	64e2                	ld	s1,24(sp)
    80005312:	6942                	ld	s2,16(sp)
}
    80005314:	853e                	mv	a0,a5
    80005316:	70a2                	ld	ra,40(sp)
    80005318:	7402                	ld	s0,32(sp)
    8000531a:	6145                	addi	sp,sp,48
    8000531c:	8082                	ret
    8000531e:	64e2                	ld	s1,24(sp)
    80005320:	6942                	ld	s2,16(sp)
    80005322:	bfcd                	j	80005314 <sys_dup+0x48>

0000000080005324 <sys_read>:
{
    80005324:	7179                	addi	sp,sp,-48
    80005326:	f406                	sd	ra,40(sp)
    80005328:	f022                	sd	s0,32(sp)
    8000532a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000532c:	fd840593          	addi	a1,s0,-40
    80005330:	4505                	li	a0,1
    80005332:	ffffe097          	auipc	ra,0xffffe
    80005336:	8bc080e7          	jalr	-1860(ra) # 80002bee <argaddr>
  argint(2, &n);
    8000533a:	fe440593          	addi	a1,s0,-28
    8000533e:	4509                	li	a0,2
    80005340:	ffffe097          	auipc	ra,0xffffe
    80005344:	88e080e7          	jalr	-1906(ra) # 80002bce <argint>
  if(argfd(0, 0, &f) < 0)
    80005348:	fe840613          	addi	a2,s0,-24
    8000534c:	4581                	li	a1,0
    8000534e:	4501                	li	a0,0
    80005350:	00000097          	auipc	ra,0x0
    80005354:	d54080e7          	jalr	-684(ra) # 800050a4 <argfd>
    80005358:	87aa                	mv	a5,a0
    return -1;
    8000535a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000535c:	0007cc63          	bltz	a5,80005374 <sys_read+0x50>
  return fileread(f, p, n);
    80005360:	fe442603          	lw	a2,-28(s0)
    80005364:	fd843583          	ld	a1,-40(s0)
    80005368:	fe843503          	ld	a0,-24(s0)
    8000536c:	fffff097          	auipc	ra,0xfffff
    80005370:	3d8080e7          	jalr	984(ra) # 80004744 <fileread>
}
    80005374:	70a2                	ld	ra,40(sp)
    80005376:	7402                	ld	s0,32(sp)
    80005378:	6145                	addi	sp,sp,48
    8000537a:	8082                	ret

000000008000537c <sys_write>:
{
    8000537c:	7179                	addi	sp,sp,-48
    8000537e:	f406                	sd	ra,40(sp)
    80005380:	f022                	sd	s0,32(sp)
    80005382:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005384:	fd840593          	addi	a1,s0,-40
    80005388:	4505                	li	a0,1
    8000538a:	ffffe097          	auipc	ra,0xffffe
    8000538e:	864080e7          	jalr	-1948(ra) # 80002bee <argaddr>
  argint(2, &n);
    80005392:	fe440593          	addi	a1,s0,-28
    80005396:	4509                	li	a0,2
    80005398:	ffffe097          	auipc	ra,0xffffe
    8000539c:	836080e7          	jalr	-1994(ra) # 80002bce <argint>
  if(argfd(0, 0, &f) < 0)
    800053a0:	fe840613          	addi	a2,s0,-24
    800053a4:	4581                	li	a1,0
    800053a6:	4501                	li	a0,0
    800053a8:	00000097          	auipc	ra,0x0
    800053ac:	cfc080e7          	jalr	-772(ra) # 800050a4 <argfd>
    800053b0:	87aa                	mv	a5,a0
    return -1;
    800053b2:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800053b4:	0007cc63          	bltz	a5,800053cc <sys_write+0x50>
  return filewrite(f, p, n);
    800053b8:	fe442603          	lw	a2,-28(s0)
    800053bc:	fd843583          	ld	a1,-40(s0)
    800053c0:	fe843503          	ld	a0,-24(s0)
    800053c4:	fffff097          	auipc	ra,0xfffff
    800053c8:	452080e7          	jalr	1106(ra) # 80004816 <filewrite>
}
    800053cc:	70a2                	ld	ra,40(sp)
    800053ce:	7402                	ld	s0,32(sp)
    800053d0:	6145                	addi	sp,sp,48
    800053d2:	8082                	ret

00000000800053d4 <sys_close>:
{
    800053d4:	1101                	addi	sp,sp,-32
    800053d6:	ec06                	sd	ra,24(sp)
    800053d8:	e822                	sd	s0,16(sp)
    800053da:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800053dc:	fe040613          	addi	a2,s0,-32
    800053e0:	fec40593          	addi	a1,s0,-20
    800053e4:	4501                	li	a0,0
    800053e6:	00000097          	auipc	ra,0x0
    800053ea:	cbe080e7          	jalr	-834(ra) # 800050a4 <argfd>
    return -1;
    800053ee:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800053f0:	02054463          	bltz	a0,80005418 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800053f4:	ffffc097          	auipc	ra,0xffffc
    800053f8:	654080e7          	jalr	1620(ra) # 80001a48 <myproc>
    800053fc:	fec42783          	lw	a5,-20(s0)
    80005400:	07e9                	addi	a5,a5,26
    80005402:	078e                	slli	a5,a5,0x3
    80005404:	953e                	add	a0,a0,a5
    80005406:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000540a:	fe043503          	ld	a0,-32(s0)
    8000540e:	fffff097          	auipc	ra,0xfffff
    80005412:	1e2080e7          	jalr	482(ra) # 800045f0 <fileclose>
  return 0;
    80005416:	4781                	li	a5,0
}
    80005418:	853e                	mv	a0,a5
    8000541a:	60e2                	ld	ra,24(sp)
    8000541c:	6442                	ld	s0,16(sp)
    8000541e:	6105                	addi	sp,sp,32
    80005420:	8082                	ret

0000000080005422 <sys_fstat>:
{
    80005422:	1101                	addi	sp,sp,-32
    80005424:	ec06                	sd	ra,24(sp)
    80005426:	e822                	sd	s0,16(sp)
    80005428:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000542a:	fe040593          	addi	a1,s0,-32
    8000542e:	4505                	li	a0,1
    80005430:	ffffd097          	auipc	ra,0xffffd
    80005434:	7be080e7          	jalr	1982(ra) # 80002bee <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005438:	fe840613          	addi	a2,s0,-24
    8000543c:	4581                	li	a1,0
    8000543e:	4501                	li	a0,0
    80005440:	00000097          	auipc	ra,0x0
    80005444:	c64080e7          	jalr	-924(ra) # 800050a4 <argfd>
    80005448:	87aa                	mv	a5,a0
    return -1;
    8000544a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000544c:	0007ca63          	bltz	a5,80005460 <sys_fstat+0x3e>
  return filestat(f, st);
    80005450:	fe043583          	ld	a1,-32(s0)
    80005454:	fe843503          	ld	a0,-24(s0)
    80005458:	fffff097          	auipc	ra,0xfffff
    8000545c:	27a080e7          	jalr	634(ra) # 800046d2 <filestat>
}
    80005460:	60e2                	ld	ra,24(sp)
    80005462:	6442                	ld	s0,16(sp)
    80005464:	6105                	addi	sp,sp,32
    80005466:	8082                	ret

0000000080005468 <sys_link>:
{
    80005468:	7169                	addi	sp,sp,-304
    8000546a:	f606                	sd	ra,296(sp)
    8000546c:	f222                	sd	s0,288(sp)
    8000546e:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005470:	08000613          	li	a2,128
    80005474:	ed040593          	addi	a1,s0,-304
    80005478:	4501                	li	a0,0
    8000547a:	ffffd097          	auipc	ra,0xffffd
    8000547e:	794080e7          	jalr	1940(ra) # 80002c0e <argstr>
    return -1;
    80005482:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005484:	12054663          	bltz	a0,800055b0 <sys_link+0x148>
    80005488:	08000613          	li	a2,128
    8000548c:	f5040593          	addi	a1,s0,-176
    80005490:	4505                	li	a0,1
    80005492:	ffffd097          	auipc	ra,0xffffd
    80005496:	77c080e7          	jalr	1916(ra) # 80002c0e <argstr>
    return -1;
    8000549a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000549c:	10054a63          	bltz	a0,800055b0 <sys_link+0x148>
    800054a0:	ee26                	sd	s1,280(sp)
  begin_op();
    800054a2:	fffff097          	auipc	ra,0xfffff
    800054a6:	c84080e7          	jalr	-892(ra) # 80004126 <begin_op>
  if((ip = namei(old)) == 0){
    800054aa:	ed040513          	addi	a0,s0,-304
    800054ae:	fffff097          	auipc	ra,0xfffff
    800054b2:	a78080e7          	jalr	-1416(ra) # 80003f26 <namei>
    800054b6:	84aa                	mv	s1,a0
    800054b8:	c949                	beqz	a0,8000554a <sys_link+0xe2>
  ilock(ip);
    800054ba:	ffffe097          	auipc	ra,0xffffe
    800054be:	29e080e7          	jalr	670(ra) # 80003758 <ilock>
  if(ip->type == T_DIR){
    800054c2:	04449703          	lh	a4,68(s1)
    800054c6:	4785                	li	a5,1
    800054c8:	08f70863          	beq	a4,a5,80005558 <sys_link+0xf0>
    800054cc:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    800054ce:	04a4d783          	lhu	a5,74(s1)
    800054d2:	2785                	addiw	a5,a5,1
    800054d4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800054d8:	8526                	mv	a0,s1
    800054da:	ffffe097          	auipc	ra,0xffffe
    800054de:	1b2080e7          	jalr	434(ra) # 8000368c <iupdate>
  iunlock(ip);
    800054e2:	8526                	mv	a0,s1
    800054e4:	ffffe097          	auipc	ra,0xffffe
    800054e8:	33a080e7          	jalr	826(ra) # 8000381e <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800054ec:	fd040593          	addi	a1,s0,-48
    800054f0:	f5040513          	addi	a0,s0,-176
    800054f4:	fffff097          	auipc	ra,0xfffff
    800054f8:	a50080e7          	jalr	-1456(ra) # 80003f44 <nameiparent>
    800054fc:	892a                	mv	s2,a0
    800054fe:	cd35                	beqz	a0,8000557a <sys_link+0x112>
  ilock(dp);
    80005500:	ffffe097          	auipc	ra,0xffffe
    80005504:	258080e7          	jalr	600(ra) # 80003758 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005508:	00092703          	lw	a4,0(s2)
    8000550c:	409c                	lw	a5,0(s1)
    8000550e:	06f71163          	bne	a4,a5,80005570 <sys_link+0x108>
    80005512:	40d0                	lw	a2,4(s1)
    80005514:	fd040593          	addi	a1,s0,-48
    80005518:	854a                	mv	a0,s2
    8000551a:	fffff097          	auipc	ra,0xfffff
    8000551e:	95a080e7          	jalr	-1702(ra) # 80003e74 <dirlink>
    80005522:	04054763          	bltz	a0,80005570 <sys_link+0x108>
  iunlockput(dp);
    80005526:	854a                	mv	a0,s2
    80005528:	ffffe097          	auipc	ra,0xffffe
    8000552c:	496080e7          	jalr	1174(ra) # 800039be <iunlockput>
  iput(ip);
    80005530:	8526                	mv	a0,s1
    80005532:	ffffe097          	auipc	ra,0xffffe
    80005536:	3e4080e7          	jalr	996(ra) # 80003916 <iput>
  end_op();
    8000553a:	fffff097          	auipc	ra,0xfffff
    8000553e:	c66080e7          	jalr	-922(ra) # 800041a0 <end_op>
  return 0;
    80005542:	4781                	li	a5,0
    80005544:	64f2                	ld	s1,280(sp)
    80005546:	6952                	ld	s2,272(sp)
    80005548:	a0a5                	j	800055b0 <sys_link+0x148>
    end_op();
    8000554a:	fffff097          	auipc	ra,0xfffff
    8000554e:	c56080e7          	jalr	-938(ra) # 800041a0 <end_op>
    return -1;
    80005552:	57fd                	li	a5,-1
    80005554:	64f2                	ld	s1,280(sp)
    80005556:	a8a9                	j	800055b0 <sys_link+0x148>
    iunlockput(ip);
    80005558:	8526                	mv	a0,s1
    8000555a:	ffffe097          	auipc	ra,0xffffe
    8000555e:	464080e7          	jalr	1124(ra) # 800039be <iunlockput>
    end_op();
    80005562:	fffff097          	auipc	ra,0xfffff
    80005566:	c3e080e7          	jalr	-962(ra) # 800041a0 <end_op>
    return -1;
    8000556a:	57fd                	li	a5,-1
    8000556c:	64f2                	ld	s1,280(sp)
    8000556e:	a089                	j	800055b0 <sys_link+0x148>
    iunlockput(dp);
    80005570:	854a                	mv	a0,s2
    80005572:	ffffe097          	auipc	ra,0xffffe
    80005576:	44c080e7          	jalr	1100(ra) # 800039be <iunlockput>
  ilock(ip);
    8000557a:	8526                	mv	a0,s1
    8000557c:	ffffe097          	auipc	ra,0xffffe
    80005580:	1dc080e7          	jalr	476(ra) # 80003758 <ilock>
  ip->nlink--;
    80005584:	04a4d783          	lhu	a5,74(s1)
    80005588:	37fd                	addiw	a5,a5,-1
    8000558a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000558e:	8526                	mv	a0,s1
    80005590:	ffffe097          	auipc	ra,0xffffe
    80005594:	0fc080e7          	jalr	252(ra) # 8000368c <iupdate>
  iunlockput(ip);
    80005598:	8526                	mv	a0,s1
    8000559a:	ffffe097          	auipc	ra,0xffffe
    8000559e:	424080e7          	jalr	1060(ra) # 800039be <iunlockput>
  end_op();
    800055a2:	fffff097          	auipc	ra,0xfffff
    800055a6:	bfe080e7          	jalr	-1026(ra) # 800041a0 <end_op>
  return -1;
    800055aa:	57fd                	li	a5,-1
    800055ac:	64f2                	ld	s1,280(sp)
    800055ae:	6952                	ld	s2,272(sp)
}
    800055b0:	853e                	mv	a0,a5
    800055b2:	70b2                	ld	ra,296(sp)
    800055b4:	7412                	ld	s0,288(sp)
    800055b6:	6155                	addi	sp,sp,304
    800055b8:	8082                	ret

00000000800055ba <sys_unlink>:
{
    800055ba:	7151                	addi	sp,sp,-240
    800055bc:	f586                	sd	ra,232(sp)
    800055be:	f1a2                	sd	s0,224(sp)
    800055c0:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800055c2:	08000613          	li	a2,128
    800055c6:	f3040593          	addi	a1,s0,-208
    800055ca:	4501                	li	a0,0
    800055cc:	ffffd097          	auipc	ra,0xffffd
    800055d0:	642080e7          	jalr	1602(ra) # 80002c0e <argstr>
    800055d4:	1a054a63          	bltz	a0,80005788 <sys_unlink+0x1ce>
    800055d8:	eda6                	sd	s1,216(sp)
  begin_op();
    800055da:	fffff097          	auipc	ra,0xfffff
    800055de:	b4c080e7          	jalr	-1204(ra) # 80004126 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800055e2:	fb040593          	addi	a1,s0,-80
    800055e6:	f3040513          	addi	a0,s0,-208
    800055ea:	fffff097          	auipc	ra,0xfffff
    800055ee:	95a080e7          	jalr	-1702(ra) # 80003f44 <nameiparent>
    800055f2:	84aa                	mv	s1,a0
    800055f4:	cd71                	beqz	a0,800056d0 <sys_unlink+0x116>
  ilock(dp);
    800055f6:	ffffe097          	auipc	ra,0xffffe
    800055fa:	162080e7          	jalr	354(ra) # 80003758 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800055fe:	00003597          	auipc	a1,0x3
    80005602:	fda58593          	addi	a1,a1,-38 # 800085d8 <etext+0x5d8>
    80005606:	fb040513          	addi	a0,s0,-80
    8000560a:	ffffe097          	auipc	ra,0xffffe
    8000560e:	640080e7          	jalr	1600(ra) # 80003c4a <namecmp>
    80005612:	14050c63          	beqz	a0,8000576a <sys_unlink+0x1b0>
    80005616:	00003597          	auipc	a1,0x3
    8000561a:	fca58593          	addi	a1,a1,-54 # 800085e0 <etext+0x5e0>
    8000561e:	fb040513          	addi	a0,s0,-80
    80005622:	ffffe097          	auipc	ra,0xffffe
    80005626:	628080e7          	jalr	1576(ra) # 80003c4a <namecmp>
    8000562a:	14050063          	beqz	a0,8000576a <sys_unlink+0x1b0>
    8000562e:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005630:	f2c40613          	addi	a2,s0,-212
    80005634:	fb040593          	addi	a1,s0,-80
    80005638:	8526                	mv	a0,s1
    8000563a:	ffffe097          	auipc	ra,0xffffe
    8000563e:	62a080e7          	jalr	1578(ra) # 80003c64 <dirlookup>
    80005642:	892a                	mv	s2,a0
    80005644:	12050263          	beqz	a0,80005768 <sys_unlink+0x1ae>
  ilock(ip);
    80005648:	ffffe097          	auipc	ra,0xffffe
    8000564c:	110080e7          	jalr	272(ra) # 80003758 <ilock>
  if(ip->nlink < 1)
    80005650:	04a91783          	lh	a5,74(s2)
    80005654:	08f05563          	blez	a5,800056de <sys_unlink+0x124>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005658:	04491703          	lh	a4,68(s2)
    8000565c:	4785                	li	a5,1
    8000565e:	08f70963          	beq	a4,a5,800056f0 <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    80005662:	4641                	li	a2,16
    80005664:	4581                	li	a1,0
    80005666:	fc040513          	addi	a0,s0,-64
    8000566a:	ffffb097          	auipc	ra,0xffffb
    8000566e:	6c8080e7          	jalr	1736(ra) # 80000d32 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005672:	4741                	li	a4,16
    80005674:	f2c42683          	lw	a3,-212(s0)
    80005678:	fc040613          	addi	a2,s0,-64
    8000567c:	4581                	li	a1,0
    8000567e:	8526                	mv	a0,s1
    80005680:	ffffe097          	auipc	ra,0xffffe
    80005684:	4a0080e7          	jalr	1184(ra) # 80003b20 <writei>
    80005688:	47c1                	li	a5,16
    8000568a:	0af51b63          	bne	a0,a5,80005740 <sys_unlink+0x186>
  if(ip->type == T_DIR){
    8000568e:	04491703          	lh	a4,68(s2)
    80005692:	4785                	li	a5,1
    80005694:	0af70f63          	beq	a4,a5,80005752 <sys_unlink+0x198>
  iunlockput(dp);
    80005698:	8526                	mv	a0,s1
    8000569a:	ffffe097          	auipc	ra,0xffffe
    8000569e:	324080e7          	jalr	804(ra) # 800039be <iunlockput>
  ip->nlink--;
    800056a2:	04a95783          	lhu	a5,74(s2)
    800056a6:	37fd                	addiw	a5,a5,-1
    800056a8:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800056ac:	854a                	mv	a0,s2
    800056ae:	ffffe097          	auipc	ra,0xffffe
    800056b2:	fde080e7          	jalr	-34(ra) # 8000368c <iupdate>
  iunlockput(ip);
    800056b6:	854a                	mv	a0,s2
    800056b8:	ffffe097          	auipc	ra,0xffffe
    800056bc:	306080e7          	jalr	774(ra) # 800039be <iunlockput>
  end_op();
    800056c0:	fffff097          	auipc	ra,0xfffff
    800056c4:	ae0080e7          	jalr	-1312(ra) # 800041a0 <end_op>
  return 0;
    800056c8:	4501                	li	a0,0
    800056ca:	64ee                	ld	s1,216(sp)
    800056cc:	694e                	ld	s2,208(sp)
    800056ce:	a84d                	j	80005780 <sys_unlink+0x1c6>
    end_op();
    800056d0:	fffff097          	auipc	ra,0xfffff
    800056d4:	ad0080e7          	jalr	-1328(ra) # 800041a0 <end_op>
    return -1;
    800056d8:	557d                	li	a0,-1
    800056da:	64ee                	ld	s1,216(sp)
    800056dc:	a055                	j	80005780 <sys_unlink+0x1c6>
    800056de:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    800056e0:	00003517          	auipc	a0,0x3
    800056e4:	f0850513          	addi	a0,a0,-248 # 800085e8 <etext+0x5e8>
    800056e8:	ffffb097          	auipc	ra,0xffffb
    800056ec:	e76080e7          	jalr	-394(ra) # 8000055e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800056f0:	04c92703          	lw	a4,76(s2)
    800056f4:	02000793          	li	a5,32
    800056f8:	f6e7f5e3          	bgeu	a5,a4,80005662 <sys_unlink+0xa8>
    800056fc:	e5ce                	sd	s3,200(sp)
    800056fe:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005702:	4741                	li	a4,16
    80005704:	86ce                	mv	a3,s3
    80005706:	f1840613          	addi	a2,s0,-232
    8000570a:	4581                	li	a1,0
    8000570c:	854a                	mv	a0,s2
    8000570e:	ffffe097          	auipc	ra,0xffffe
    80005712:	302080e7          	jalr	770(ra) # 80003a10 <readi>
    80005716:	47c1                	li	a5,16
    80005718:	00f51c63          	bne	a0,a5,80005730 <sys_unlink+0x176>
    if(de.inum != 0)
    8000571c:	f1845783          	lhu	a5,-232(s0)
    80005720:	e7b5                	bnez	a5,8000578c <sys_unlink+0x1d2>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005722:	29c1                	addiw	s3,s3,16
    80005724:	04c92783          	lw	a5,76(s2)
    80005728:	fcf9ede3          	bltu	s3,a5,80005702 <sys_unlink+0x148>
    8000572c:	69ae                	ld	s3,200(sp)
    8000572e:	bf15                	j	80005662 <sys_unlink+0xa8>
      panic("isdirempty: readi");
    80005730:	00003517          	auipc	a0,0x3
    80005734:	ed050513          	addi	a0,a0,-304 # 80008600 <etext+0x600>
    80005738:	ffffb097          	auipc	ra,0xffffb
    8000573c:	e26080e7          	jalr	-474(ra) # 8000055e <panic>
    80005740:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80005742:	00003517          	auipc	a0,0x3
    80005746:	ed650513          	addi	a0,a0,-298 # 80008618 <etext+0x618>
    8000574a:	ffffb097          	auipc	ra,0xffffb
    8000574e:	e14080e7          	jalr	-492(ra) # 8000055e <panic>
    dp->nlink--;
    80005752:	04a4d783          	lhu	a5,74(s1)
    80005756:	37fd                	addiw	a5,a5,-1
    80005758:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000575c:	8526                	mv	a0,s1
    8000575e:	ffffe097          	auipc	ra,0xffffe
    80005762:	f2e080e7          	jalr	-210(ra) # 8000368c <iupdate>
    80005766:	bf0d                	j	80005698 <sys_unlink+0xde>
    80005768:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    8000576a:	8526                	mv	a0,s1
    8000576c:	ffffe097          	auipc	ra,0xffffe
    80005770:	252080e7          	jalr	594(ra) # 800039be <iunlockput>
  end_op();
    80005774:	fffff097          	auipc	ra,0xfffff
    80005778:	a2c080e7          	jalr	-1492(ra) # 800041a0 <end_op>
  return -1;
    8000577c:	557d                	li	a0,-1
    8000577e:	64ee                	ld	s1,216(sp)
}
    80005780:	70ae                	ld	ra,232(sp)
    80005782:	740e                	ld	s0,224(sp)
    80005784:	616d                	addi	sp,sp,240
    80005786:	8082                	ret
    return -1;
    80005788:	557d                	li	a0,-1
    8000578a:	bfdd                	j	80005780 <sys_unlink+0x1c6>
    iunlockput(ip);
    8000578c:	854a                	mv	a0,s2
    8000578e:	ffffe097          	auipc	ra,0xffffe
    80005792:	230080e7          	jalr	560(ra) # 800039be <iunlockput>
    goto bad;
    80005796:	694e                	ld	s2,208(sp)
    80005798:	69ae                	ld	s3,200(sp)
    8000579a:	bfc1                	j	8000576a <sys_unlink+0x1b0>

000000008000579c <sys_open>:

uint64
sys_open(void)
{
    8000579c:	7131                	addi	sp,sp,-192
    8000579e:	fd06                	sd	ra,184(sp)
    800057a0:	f922                	sd	s0,176(sp)
    800057a2:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800057a4:	f4c40593          	addi	a1,s0,-180
    800057a8:	4505                	li	a0,1
    800057aa:	ffffd097          	auipc	ra,0xffffd
    800057ae:	424080e7          	jalr	1060(ra) # 80002bce <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800057b2:	08000613          	li	a2,128
    800057b6:	f5040593          	addi	a1,s0,-176
    800057ba:	4501                	li	a0,0
    800057bc:	ffffd097          	auipc	ra,0xffffd
    800057c0:	452080e7          	jalr	1106(ra) # 80002c0e <argstr>
    800057c4:	87aa                	mv	a5,a0
    return -1;
    800057c6:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800057c8:	0a07ce63          	bltz	a5,80005884 <sys_open+0xe8>
    800057cc:	f526                	sd	s1,168(sp)

  begin_op();
    800057ce:	fffff097          	auipc	ra,0xfffff
    800057d2:	958080e7          	jalr	-1704(ra) # 80004126 <begin_op>

  if(omode & O_CREATE){
    800057d6:	f4c42783          	lw	a5,-180(s0)
    800057da:	2007f793          	andi	a5,a5,512
    800057de:	cfd5                	beqz	a5,8000589a <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800057e0:	4681                	li	a3,0
    800057e2:	4601                	li	a2,0
    800057e4:	4589                	li	a1,2
    800057e6:	f5040513          	addi	a0,s0,-176
    800057ea:	00000097          	auipc	ra,0x0
    800057ee:	95c080e7          	jalr	-1700(ra) # 80005146 <create>
    800057f2:	84aa                	mv	s1,a0
    if(ip == 0){
    800057f4:	cd41                	beqz	a0,8000588c <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800057f6:	04449703          	lh	a4,68(s1)
    800057fa:	478d                	li	a5,3
    800057fc:	00f71763          	bne	a4,a5,8000580a <sys_open+0x6e>
    80005800:	0464d703          	lhu	a4,70(s1)
    80005804:	47a5                	li	a5,9
    80005806:	0ee7e163          	bltu	a5,a4,800058e8 <sys_open+0x14c>
    8000580a:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000580c:	fffff097          	auipc	ra,0xfffff
    80005810:	d28080e7          	jalr	-728(ra) # 80004534 <filealloc>
    80005814:	892a                	mv	s2,a0
    80005816:	c97d                	beqz	a0,8000590c <sys_open+0x170>
    80005818:	ed4e                	sd	s3,152(sp)
    8000581a:	00000097          	auipc	ra,0x0
    8000581e:	8ea080e7          	jalr	-1814(ra) # 80005104 <fdalloc>
    80005822:	89aa                	mv	s3,a0
    80005824:	0c054e63          	bltz	a0,80005900 <sys_open+0x164>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005828:	04449703          	lh	a4,68(s1)
    8000582c:	478d                	li	a5,3
    8000582e:	0ef70c63          	beq	a4,a5,80005926 <sys_open+0x18a>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005832:	4789                	li	a5,2
    80005834:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005838:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    8000583c:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005840:	f4c42783          	lw	a5,-180(s0)
    80005844:	0017c713          	xori	a4,a5,1
    80005848:	8b05                	andi	a4,a4,1
    8000584a:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000584e:	0037f713          	andi	a4,a5,3
    80005852:	00e03733          	snez	a4,a4
    80005856:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000585a:	4007f793          	andi	a5,a5,1024
    8000585e:	c791                	beqz	a5,8000586a <sys_open+0xce>
    80005860:	04449703          	lh	a4,68(s1)
    80005864:	4789                	li	a5,2
    80005866:	0cf70763          	beq	a4,a5,80005934 <sys_open+0x198>
    itrunc(ip);
  }

  iunlock(ip);
    8000586a:	8526                	mv	a0,s1
    8000586c:	ffffe097          	auipc	ra,0xffffe
    80005870:	fb2080e7          	jalr	-78(ra) # 8000381e <iunlock>
  end_op();
    80005874:	fffff097          	auipc	ra,0xfffff
    80005878:	92c080e7          	jalr	-1748(ra) # 800041a0 <end_op>

  return fd;
    8000587c:	854e                	mv	a0,s3
    8000587e:	74aa                	ld	s1,168(sp)
    80005880:	790a                	ld	s2,160(sp)
    80005882:	69ea                	ld	s3,152(sp)
}
    80005884:	70ea                	ld	ra,184(sp)
    80005886:	744a                	ld	s0,176(sp)
    80005888:	6129                	addi	sp,sp,192
    8000588a:	8082                	ret
      end_op();
    8000588c:	fffff097          	auipc	ra,0xfffff
    80005890:	914080e7          	jalr	-1772(ra) # 800041a0 <end_op>
      return -1;
    80005894:	557d                	li	a0,-1
    80005896:	74aa                	ld	s1,168(sp)
    80005898:	b7f5                	j	80005884 <sys_open+0xe8>
    if((ip = namei(path)) == 0){
    8000589a:	f5040513          	addi	a0,s0,-176
    8000589e:	ffffe097          	auipc	ra,0xffffe
    800058a2:	688080e7          	jalr	1672(ra) # 80003f26 <namei>
    800058a6:	84aa                	mv	s1,a0
    800058a8:	c90d                	beqz	a0,800058da <sys_open+0x13e>
    ilock(ip);
    800058aa:	ffffe097          	auipc	ra,0xffffe
    800058ae:	eae080e7          	jalr	-338(ra) # 80003758 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800058b2:	04449703          	lh	a4,68(s1)
    800058b6:	4785                	li	a5,1
    800058b8:	f2f71fe3          	bne	a4,a5,800057f6 <sys_open+0x5a>
    800058bc:	f4c42783          	lw	a5,-180(s0)
    800058c0:	d7a9                	beqz	a5,8000580a <sys_open+0x6e>
      iunlockput(ip);
    800058c2:	8526                	mv	a0,s1
    800058c4:	ffffe097          	auipc	ra,0xffffe
    800058c8:	0fa080e7          	jalr	250(ra) # 800039be <iunlockput>
      end_op();
    800058cc:	fffff097          	auipc	ra,0xfffff
    800058d0:	8d4080e7          	jalr	-1836(ra) # 800041a0 <end_op>
      return -1;
    800058d4:	557d                	li	a0,-1
    800058d6:	74aa                	ld	s1,168(sp)
    800058d8:	b775                	j	80005884 <sys_open+0xe8>
      end_op();
    800058da:	fffff097          	auipc	ra,0xfffff
    800058de:	8c6080e7          	jalr	-1850(ra) # 800041a0 <end_op>
      return -1;
    800058e2:	557d                	li	a0,-1
    800058e4:	74aa                	ld	s1,168(sp)
    800058e6:	bf79                	j	80005884 <sys_open+0xe8>
    iunlockput(ip);
    800058e8:	8526                	mv	a0,s1
    800058ea:	ffffe097          	auipc	ra,0xffffe
    800058ee:	0d4080e7          	jalr	212(ra) # 800039be <iunlockput>
    end_op();
    800058f2:	fffff097          	auipc	ra,0xfffff
    800058f6:	8ae080e7          	jalr	-1874(ra) # 800041a0 <end_op>
    return -1;
    800058fa:	557d                	li	a0,-1
    800058fc:	74aa                	ld	s1,168(sp)
    800058fe:	b759                	j	80005884 <sys_open+0xe8>
      fileclose(f);
    80005900:	854a                	mv	a0,s2
    80005902:	fffff097          	auipc	ra,0xfffff
    80005906:	cee080e7          	jalr	-786(ra) # 800045f0 <fileclose>
    8000590a:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    8000590c:	8526                	mv	a0,s1
    8000590e:	ffffe097          	auipc	ra,0xffffe
    80005912:	0b0080e7          	jalr	176(ra) # 800039be <iunlockput>
    end_op();
    80005916:	fffff097          	auipc	ra,0xfffff
    8000591a:	88a080e7          	jalr	-1910(ra) # 800041a0 <end_op>
    return -1;
    8000591e:	557d                	li	a0,-1
    80005920:	74aa                	ld	s1,168(sp)
    80005922:	790a                	ld	s2,160(sp)
    80005924:	b785                	j	80005884 <sys_open+0xe8>
    f->type = FD_DEVICE;
    80005926:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    8000592a:	04649783          	lh	a5,70(s1)
    8000592e:	02f91223          	sh	a5,36(s2)
    80005932:	b729                	j	8000583c <sys_open+0xa0>
    itrunc(ip);
    80005934:	8526                	mv	a0,s1
    80005936:	ffffe097          	auipc	ra,0xffffe
    8000593a:	f34080e7          	jalr	-204(ra) # 8000386a <itrunc>
    8000593e:	b735                	j	8000586a <sys_open+0xce>

0000000080005940 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005940:	7175                	addi	sp,sp,-144
    80005942:	e506                	sd	ra,136(sp)
    80005944:	e122                	sd	s0,128(sp)
    80005946:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005948:	ffffe097          	auipc	ra,0xffffe
    8000594c:	7de080e7          	jalr	2014(ra) # 80004126 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005950:	08000613          	li	a2,128
    80005954:	f7040593          	addi	a1,s0,-144
    80005958:	4501                	li	a0,0
    8000595a:	ffffd097          	auipc	ra,0xffffd
    8000595e:	2b4080e7          	jalr	692(ra) # 80002c0e <argstr>
    80005962:	02054963          	bltz	a0,80005994 <sys_mkdir+0x54>
    80005966:	4681                	li	a3,0
    80005968:	4601                	li	a2,0
    8000596a:	4585                	li	a1,1
    8000596c:	f7040513          	addi	a0,s0,-144
    80005970:	fffff097          	auipc	ra,0xfffff
    80005974:	7d6080e7          	jalr	2006(ra) # 80005146 <create>
    80005978:	cd11                	beqz	a0,80005994 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000597a:	ffffe097          	auipc	ra,0xffffe
    8000597e:	044080e7          	jalr	68(ra) # 800039be <iunlockput>
  end_op();
    80005982:	fffff097          	auipc	ra,0xfffff
    80005986:	81e080e7          	jalr	-2018(ra) # 800041a0 <end_op>
  return 0;
    8000598a:	4501                	li	a0,0
}
    8000598c:	60aa                	ld	ra,136(sp)
    8000598e:	640a                	ld	s0,128(sp)
    80005990:	6149                	addi	sp,sp,144
    80005992:	8082                	ret
    end_op();
    80005994:	fffff097          	auipc	ra,0xfffff
    80005998:	80c080e7          	jalr	-2036(ra) # 800041a0 <end_op>
    return -1;
    8000599c:	557d                	li	a0,-1
    8000599e:	b7fd                	j	8000598c <sys_mkdir+0x4c>

00000000800059a0 <sys_mknod>:

uint64
sys_mknod(void)
{
    800059a0:	7135                	addi	sp,sp,-160
    800059a2:	ed06                	sd	ra,152(sp)
    800059a4:	e922                	sd	s0,144(sp)
    800059a6:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800059a8:	ffffe097          	auipc	ra,0xffffe
    800059ac:	77e080e7          	jalr	1918(ra) # 80004126 <begin_op>
  argint(1, &major);
    800059b0:	f6c40593          	addi	a1,s0,-148
    800059b4:	4505                	li	a0,1
    800059b6:	ffffd097          	auipc	ra,0xffffd
    800059ba:	218080e7          	jalr	536(ra) # 80002bce <argint>
  argint(2, &minor);
    800059be:	f6840593          	addi	a1,s0,-152
    800059c2:	4509                	li	a0,2
    800059c4:	ffffd097          	auipc	ra,0xffffd
    800059c8:	20a080e7          	jalr	522(ra) # 80002bce <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800059cc:	08000613          	li	a2,128
    800059d0:	f7040593          	addi	a1,s0,-144
    800059d4:	4501                	li	a0,0
    800059d6:	ffffd097          	auipc	ra,0xffffd
    800059da:	238080e7          	jalr	568(ra) # 80002c0e <argstr>
    800059de:	02054b63          	bltz	a0,80005a14 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800059e2:	f6841683          	lh	a3,-152(s0)
    800059e6:	f6c41603          	lh	a2,-148(s0)
    800059ea:	458d                	li	a1,3
    800059ec:	f7040513          	addi	a0,s0,-144
    800059f0:	fffff097          	auipc	ra,0xfffff
    800059f4:	756080e7          	jalr	1878(ra) # 80005146 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800059f8:	cd11                	beqz	a0,80005a14 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800059fa:	ffffe097          	auipc	ra,0xffffe
    800059fe:	fc4080e7          	jalr	-60(ra) # 800039be <iunlockput>
  end_op();
    80005a02:	ffffe097          	auipc	ra,0xffffe
    80005a06:	79e080e7          	jalr	1950(ra) # 800041a0 <end_op>
  return 0;
    80005a0a:	4501                	li	a0,0
}
    80005a0c:	60ea                	ld	ra,152(sp)
    80005a0e:	644a                	ld	s0,144(sp)
    80005a10:	610d                	addi	sp,sp,160
    80005a12:	8082                	ret
    end_op();
    80005a14:	ffffe097          	auipc	ra,0xffffe
    80005a18:	78c080e7          	jalr	1932(ra) # 800041a0 <end_op>
    return -1;
    80005a1c:	557d                	li	a0,-1
    80005a1e:	b7fd                	j	80005a0c <sys_mknod+0x6c>

0000000080005a20 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005a20:	7135                	addi	sp,sp,-160
    80005a22:	ed06                	sd	ra,152(sp)
    80005a24:	e922                	sd	s0,144(sp)
    80005a26:	e14a                	sd	s2,128(sp)
    80005a28:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005a2a:	ffffc097          	auipc	ra,0xffffc
    80005a2e:	01e080e7          	jalr	30(ra) # 80001a48 <myproc>
    80005a32:	892a                	mv	s2,a0
  
  begin_op();
    80005a34:	ffffe097          	auipc	ra,0xffffe
    80005a38:	6f2080e7          	jalr	1778(ra) # 80004126 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005a3c:	08000613          	li	a2,128
    80005a40:	f6040593          	addi	a1,s0,-160
    80005a44:	4501                	li	a0,0
    80005a46:	ffffd097          	auipc	ra,0xffffd
    80005a4a:	1c8080e7          	jalr	456(ra) # 80002c0e <argstr>
    80005a4e:	04054d63          	bltz	a0,80005aa8 <sys_chdir+0x88>
    80005a52:	e526                	sd	s1,136(sp)
    80005a54:	f6040513          	addi	a0,s0,-160
    80005a58:	ffffe097          	auipc	ra,0xffffe
    80005a5c:	4ce080e7          	jalr	1230(ra) # 80003f26 <namei>
    80005a60:	84aa                	mv	s1,a0
    80005a62:	c131                	beqz	a0,80005aa6 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005a64:	ffffe097          	auipc	ra,0xffffe
    80005a68:	cf4080e7          	jalr	-780(ra) # 80003758 <ilock>
  if(ip->type != T_DIR){
    80005a6c:	04449703          	lh	a4,68(s1)
    80005a70:	4785                	li	a5,1
    80005a72:	04f71163          	bne	a4,a5,80005ab4 <sys_chdir+0x94>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005a76:	8526                	mv	a0,s1
    80005a78:	ffffe097          	auipc	ra,0xffffe
    80005a7c:	da6080e7          	jalr	-602(ra) # 8000381e <iunlock>
  iput(p->cwd);
    80005a80:	15093503          	ld	a0,336(s2)
    80005a84:	ffffe097          	auipc	ra,0xffffe
    80005a88:	e92080e7          	jalr	-366(ra) # 80003916 <iput>
  end_op();
    80005a8c:	ffffe097          	auipc	ra,0xffffe
    80005a90:	714080e7          	jalr	1812(ra) # 800041a0 <end_op>
  p->cwd = ip;
    80005a94:	14993823          	sd	s1,336(s2)
  return 0;
    80005a98:	4501                	li	a0,0
    80005a9a:	64aa                	ld	s1,136(sp)
}
    80005a9c:	60ea                	ld	ra,152(sp)
    80005a9e:	644a                	ld	s0,144(sp)
    80005aa0:	690a                	ld	s2,128(sp)
    80005aa2:	610d                	addi	sp,sp,160
    80005aa4:	8082                	ret
    80005aa6:	64aa                	ld	s1,136(sp)
    end_op();
    80005aa8:	ffffe097          	auipc	ra,0xffffe
    80005aac:	6f8080e7          	jalr	1784(ra) # 800041a0 <end_op>
    return -1;
    80005ab0:	557d                	li	a0,-1
    80005ab2:	b7ed                	j	80005a9c <sys_chdir+0x7c>
    iunlockput(ip);
    80005ab4:	8526                	mv	a0,s1
    80005ab6:	ffffe097          	auipc	ra,0xffffe
    80005aba:	f08080e7          	jalr	-248(ra) # 800039be <iunlockput>
    end_op();
    80005abe:	ffffe097          	auipc	ra,0xffffe
    80005ac2:	6e2080e7          	jalr	1762(ra) # 800041a0 <end_op>
    return -1;
    80005ac6:	557d                	li	a0,-1
    80005ac8:	64aa                	ld	s1,136(sp)
    80005aca:	bfc9                	j	80005a9c <sys_chdir+0x7c>

0000000080005acc <sys_exec>:

uint64
sys_exec(void)
{
    80005acc:	7121                	addi	sp,sp,-448
    80005ace:	ff06                	sd	ra,440(sp)
    80005ad0:	fb22                	sd	s0,432(sp)
    80005ad2:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005ad4:	e4840593          	addi	a1,s0,-440
    80005ad8:	4505                	li	a0,1
    80005ada:	ffffd097          	auipc	ra,0xffffd
    80005ade:	114080e7          	jalr	276(ra) # 80002bee <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005ae2:	08000613          	li	a2,128
    80005ae6:	f5040593          	addi	a1,s0,-176
    80005aea:	4501                	li	a0,0
    80005aec:	ffffd097          	auipc	ra,0xffffd
    80005af0:	122080e7          	jalr	290(ra) # 80002c0e <argstr>
    80005af4:	87aa                	mv	a5,a0
    return -1;
    80005af6:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005af8:	0e07c263          	bltz	a5,80005bdc <sys_exec+0x110>
    80005afc:	f726                	sd	s1,424(sp)
    80005afe:	f34a                	sd	s2,416(sp)
    80005b00:	ef4e                	sd	s3,408(sp)
    80005b02:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005b04:	10000613          	li	a2,256
    80005b08:	4581                	li	a1,0
    80005b0a:	e5040513          	addi	a0,s0,-432
    80005b0e:	ffffb097          	auipc	ra,0xffffb
    80005b12:	224080e7          	jalr	548(ra) # 80000d32 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005b16:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005b1a:	89a6                	mv	s3,s1
    80005b1c:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005b1e:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005b22:	00391513          	slli	a0,s2,0x3
    80005b26:	e4040593          	addi	a1,s0,-448
    80005b2a:	e4843783          	ld	a5,-440(s0)
    80005b2e:	953e                	add	a0,a0,a5
    80005b30:	ffffd097          	auipc	ra,0xffffd
    80005b34:	000080e7          	jalr	ra # 80002b30 <fetchaddr>
    80005b38:	02054a63          	bltz	a0,80005b6c <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    80005b3c:	e4043783          	ld	a5,-448(s0)
    80005b40:	c7b9                	beqz	a5,80005b8e <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005b42:	ffffb097          	auipc	ra,0xffffb
    80005b46:	004080e7          	jalr	4(ra) # 80000b46 <kalloc>
    80005b4a:	85aa                	mv	a1,a0
    80005b4c:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005b50:	cd11                	beqz	a0,80005b6c <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005b52:	6605                	lui	a2,0x1
    80005b54:	e4043503          	ld	a0,-448(s0)
    80005b58:	ffffd097          	auipc	ra,0xffffd
    80005b5c:	02a080e7          	jalr	42(ra) # 80002b82 <fetchstr>
    80005b60:	00054663          	bltz	a0,80005b6c <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    80005b64:	0905                	addi	s2,s2,1
    80005b66:	09a1                	addi	s3,s3,8
    80005b68:	fb491de3          	bne	s2,s4,80005b22 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b6c:	f5040913          	addi	s2,s0,-176
    80005b70:	6088                	ld	a0,0(s1)
    80005b72:	c125                	beqz	a0,80005bd2 <sys_exec+0x106>
    kfree(argv[i]);
    80005b74:	ffffb097          	auipc	ra,0xffffb
    80005b78:	ed4080e7          	jalr	-300(ra) # 80000a48 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b7c:	04a1                	addi	s1,s1,8
    80005b7e:	ff2499e3          	bne	s1,s2,80005b70 <sys_exec+0xa4>
  return -1;
    80005b82:	557d                	li	a0,-1
    80005b84:	74ba                	ld	s1,424(sp)
    80005b86:	791a                	ld	s2,416(sp)
    80005b88:	69fa                	ld	s3,408(sp)
    80005b8a:	6a5a                	ld	s4,400(sp)
    80005b8c:	a881                	j	80005bdc <sys_exec+0x110>
      argv[i] = 0;
    80005b8e:	0009079b          	sext.w	a5,s2
    80005b92:	078e                	slli	a5,a5,0x3
    80005b94:	fd078793          	addi	a5,a5,-48
    80005b98:	97a2                	add	a5,a5,s0
    80005b9a:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005b9e:	e5040593          	addi	a1,s0,-432
    80005ba2:	f5040513          	addi	a0,s0,-176
    80005ba6:	fffff097          	auipc	ra,0xfffff
    80005baa:	120080e7          	jalr	288(ra) # 80004cc6 <exec>
    80005bae:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005bb0:	f5040993          	addi	s3,s0,-176
    80005bb4:	6088                	ld	a0,0(s1)
    80005bb6:	c901                	beqz	a0,80005bc6 <sys_exec+0xfa>
    kfree(argv[i]);
    80005bb8:	ffffb097          	auipc	ra,0xffffb
    80005bbc:	e90080e7          	jalr	-368(ra) # 80000a48 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005bc0:	04a1                	addi	s1,s1,8
    80005bc2:	ff3499e3          	bne	s1,s3,80005bb4 <sys_exec+0xe8>
  return ret;
    80005bc6:	854a                	mv	a0,s2
    80005bc8:	74ba                	ld	s1,424(sp)
    80005bca:	791a                	ld	s2,416(sp)
    80005bcc:	69fa                	ld	s3,408(sp)
    80005bce:	6a5a                	ld	s4,400(sp)
    80005bd0:	a031                	j	80005bdc <sys_exec+0x110>
  return -1;
    80005bd2:	557d                	li	a0,-1
    80005bd4:	74ba                	ld	s1,424(sp)
    80005bd6:	791a                	ld	s2,416(sp)
    80005bd8:	69fa                	ld	s3,408(sp)
    80005bda:	6a5a                	ld	s4,400(sp)
}
    80005bdc:	70fa                	ld	ra,440(sp)
    80005bde:	745a                	ld	s0,432(sp)
    80005be0:	6139                	addi	sp,sp,448
    80005be2:	8082                	ret

0000000080005be4 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005be4:	7139                	addi	sp,sp,-64
    80005be6:	fc06                	sd	ra,56(sp)
    80005be8:	f822                	sd	s0,48(sp)
    80005bea:	f426                	sd	s1,40(sp)
    80005bec:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005bee:	ffffc097          	auipc	ra,0xffffc
    80005bf2:	e5a080e7          	jalr	-422(ra) # 80001a48 <myproc>
    80005bf6:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005bf8:	fd840593          	addi	a1,s0,-40
    80005bfc:	4501                	li	a0,0
    80005bfe:	ffffd097          	auipc	ra,0xffffd
    80005c02:	ff0080e7          	jalr	-16(ra) # 80002bee <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005c06:	fc840593          	addi	a1,s0,-56
    80005c0a:	fd040513          	addi	a0,s0,-48
    80005c0e:	fffff097          	auipc	ra,0xfffff
    80005c12:	d50080e7          	jalr	-688(ra) # 8000495e <pipealloc>
    return -1;
    80005c16:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005c18:	0c054463          	bltz	a0,80005ce0 <sys_pipe+0xfc>
  fd0 = -1;
    80005c1c:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005c20:	fd043503          	ld	a0,-48(s0)
    80005c24:	fffff097          	auipc	ra,0xfffff
    80005c28:	4e0080e7          	jalr	1248(ra) # 80005104 <fdalloc>
    80005c2c:	fca42223          	sw	a0,-60(s0)
    80005c30:	08054b63          	bltz	a0,80005cc6 <sys_pipe+0xe2>
    80005c34:	fc843503          	ld	a0,-56(s0)
    80005c38:	fffff097          	auipc	ra,0xfffff
    80005c3c:	4cc080e7          	jalr	1228(ra) # 80005104 <fdalloc>
    80005c40:	fca42023          	sw	a0,-64(s0)
    80005c44:	06054863          	bltz	a0,80005cb4 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005c48:	4691                	li	a3,4
    80005c4a:	fc440613          	addi	a2,s0,-60
    80005c4e:	fd843583          	ld	a1,-40(s0)
    80005c52:	68a8                	ld	a0,80(s1)
    80005c54:	ffffc097          	auipc	ra,0xffffc
    80005c58:	a8c080e7          	jalr	-1396(ra) # 800016e0 <copyout>
    80005c5c:	02054063          	bltz	a0,80005c7c <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005c60:	4691                	li	a3,4
    80005c62:	fc040613          	addi	a2,s0,-64
    80005c66:	fd843583          	ld	a1,-40(s0)
    80005c6a:	0591                	addi	a1,a1,4
    80005c6c:	68a8                	ld	a0,80(s1)
    80005c6e:	ffffc097          	auipc	ra,0xffffc
    80005c72:	a72080e7          	jalr	-1422(ra) # 800016e0 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005c76:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005c78:	06055463          	bgez	a0,80005ce0 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005c7c:	fc442783          	lw	a5,-60(s0)
    80005c80:	07e9                	addi	a5,a5,26
    80005c82:	078e                	slli	a5,a5,0x3
    80005c84:	97a6                	add	a5,a5,s1
    80005c86:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005c8a:	fc042783          	lw	a5,-64(s0)
    80005c8e:	07e9                	addi	a5,a5,26
    80005c90:	078e                	slli	a5,a5,0x3
    80005c92:	94be                	add	s1,s1,a5
    80005c94:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005c98:	fd043503          	ld	a0,-48(s0)
    80005c9c:	fffff097          	auipc	ra,0xfffff
    80005ca0:	954080e7          	jalr	-1708(ra) # 800045f0 <fileclose>
    fileclose(wf);
    80005ca4:	fc843503          	ld	a0,-56(s0)
    80005ca8:	fffff097          	auipc	ra,0xfffff
    80005cac:	948080e7          	jalr	-1720(ra) # 800045f0 <fileclose>
    return -1;
    80005cb0:	57fd                	li	a5,-1
    80005cb2:	a03d                	j	80005ce0 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005cb4:	fc442783          	lw	a5,-60(s0)
    80005cb8:	0007c763          	bltz	a5,80005cc6 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005cbc:	07e9                	addi	a5,a5,26
    80005cbe:	078e                	slli	a5,a5,0x3
    80005cc0:	97a6                	add	a5,a5,s1
    80005cc2:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005cc6:	fd043503          	ld	a0,-48(s0)
    80005cca:	fffff097          	auipc	ra,0xfffff
    80005cce:	926080e7          	jalr	-1754(ra) # 800045f0 <fileclose>
    fileclose(wf);
    80005cd2:	fc843503          	ld	a0,-56(s0)
    80005cd6:	fffff097          	auipc	ra,0xfffff
    80005cda:	91a080e7          	jalr	-1766(ra) # 800045f0 <fileclose>
    return -1;
    80005cde:	57fd                	li	a5,-1
}
    80005ce0:	853e                	mv	a0,a5
    80005ce2:	70e2                	ld	ra,56(sp)
    80005ce4:	7442                	ld	s0,48(sp)
    80005ce6:	74a2                	ld	s1,40(sp)
    80005ce8:	6121                	addi	sp,sp,64
    80005cea:	8082                	ret
    80005cec:	0000                	unimp
	...

0000000080005cf0 <kernelvec>:
    80005cf0:	7111                	addi	sp,sp,-256
    80005cf2:	e006                	sd	ra,0(sp)
    80005cf4:	e40a                	sd	sp,8(sp)
    80005cf6:	e80e                	sd	gp,16(sp)
    80005cf8:	ec12                	sd	tp,24(sp)
    80005cfa:	f016                	sd	t0,32(sp)
    80005cfc:	f41a                	sd	t1,40(sp)
    80005cfe:	f81e                	sd	t2,48(sp)
    80005d00:	fc22                	sd	s0,56(sp)
    80005d02:	e0a6                	sd	s1,64(sp)
    80005d04:	e4aa                	sd	a0,72(sp)
    80005d06:	e8ae                	sd	a1,80(sp)
    80005d08:	ecb2                	sd	a2,88(sp)
    80005d0a:	f0b6                	sd	a3,96(sp)
    80005d0c:	f4ba                	sd	a4,104(sp)
    80005d0e:	f8be                	sd	a5,112(sp)
    80005d10:	fcc2                	sd	a6,120(sp)
    80005d12:	e146                	sd	a7,128(sp)
    80005d14:	e54a                	sd	s2,136(sp)
    80005d16:	e94e                	sd	s3,144(sp)
    80005d18:	ed52                	sd	s4,152(sp)
    80005d1a:	f156                	sd	s5,160(sp)
    80005d1c:	f55a                	sd	s6,168(sp)
    80005d1e:	f95e                	sd	s7,176(sp)
    80005d20:	fd62                	sd	s8,184(sp)
    80005d22:	e1e6                	sd	s9,192(sp)
    80005d24:	e5ea                	sd	s10,200(sp)
    80005d26:	e9ee                	sd	s11,208(sp)
    80005d28:	edf2                	sd	t3,216(sp)
    80005d2a:	f1f6                	sd	t4,224(sp)
    80005d2c:	f5fa                	sd	t5,232(sp)
    80005d2e:	f9fe                	sd	t6,240(sp)
    80005d30:	ccdfc0ef          	jal	800029fc <kerneltrap>
    80005d34:	6082                	ld	ra,0(sp)
    80005d36:	6122                	ld	sp,8(sp)
    80005d38:	61c2                	ld	gp,16(sp)
    80005d3a:	7282                	ld	t0,32(sp)
    80005d3c:	7322                	ld	t1,40(sp)
    80005d3e:	73c2                	ld	t2,48(sp)
    80005d40:	7462                	ld	s0,56(sp)
    80005d42:	6486                	ld	s1,64(sp)
    80005d44:	6526                	ld	a0,72(sp)
    80005d46:	65c6                	ld	a1,80(sp)
    80005d48:	6666                	ld	a2,88(sp)
    80005d4a:	7686                	ld	a3,96(sp)
    80005d4c:	7726                	ld	a4,104(sp)
    80005d4e:	77c6                	ld	a5,112(sp)
    80005d50:	7866                	ld	a6,120(sp)
    80005d52:	688a                	ld	a7,128(sp)
    80005d54:	692a                	ld	s2,136(sp)
    80005d56:	69ca                	ld	s3,144(sp)
    80005d58:	6a6a                	ld	s4,152(sp)
    80005d5a:	7a8a                	ld	s5,160(sp)
    80005d5c:	7b2a                	ld	s6,168(sp)
    80005d5e:	7bca                	ld	s7,176(sp)
    80005d60:	7c6a                	ld	s8,184(sp)
    80005d62:	6c8e                	ld	s9,192(sp)
    80005d64:	6d2e                	ld	s10,200(sp)
    80005d66:	6dce                	ld	s11,208(sp)
    80005d68:	6e6e                	ld	t3,216(sp)
    80005d6a:	7e8e                	ld	t4,224(sp)
    80005d6c:	7f2e                	ld	t5,232(sp)
    80005d6e:	7fce                	ld	t6,240(sp)
    80005d70:	6111                	addi	sp,sp,256
    80005d72:	10200073          	sret
    80005d76:	00000013          	nop
    80005d7a:	00000013          	nop
    80005d7e:	0001                	nop

0000000080005d80 <timervec>:
    80005d80:	34051573          	csrrw	a0,mscratch,a0
    80005d84:	e10c                	sd	a1,0(a0)
    80005d86:	e510                	sd	a2,8(a0)
    80005d88:	e914                	sd	a3,16(a0)
    80005d8a:	6d0c                	ld	a1,24(a0)
    80005d8c:	7110                	ld	a2,32(a0)
    80005d8e:	6194                	ld	a3,0(a1)
    80005d90:	96b2                	add	a3,a3,a2
    80005d92:	e194                	sd	a3,0(a1)
    80005d94:	4589                	li	a1,2
    80005d96:	14459073          	csrw	sip,a1
    80005d9a:	6914                	ld	a3,16(a0)
    80005d9c:	6510                	ld	a2,8(a0)
    80005d9e:	610c                	ld	a1,0(a0)
    80005da0:	34051573          	csrrw	a0,mscratch,a0
    80005da4:	30200073          	mret
	...

0000000080005daa <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005daa:	1141                	addi	sp,sp,-16
    80005dac:	e422                	sd	s0,8(sp)
    80005dae:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005db0:	0c0007b7          	lui	a5,0xc000
    80005db4:	4705                	li	a4,1
    80005db6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005db8:	0c0007b7          	lui	a5,0xc000
    80005dbc:	c3d8                	sw	a4,4(a5)
}
    80005dbe:	6422                	ld	s0,8(sp)
    80005dc0:	0141                	addi	sp,sp,16
    80005dc2:	8082                	ret

0000000080005dc4 <plicinithart>:

void
plicinithart(void)
{
    80005dc4:	1141                	addi	sp,sp,-16
    80005dc6:	e406                	sd	ra,8(sp)
    80005dc8:	e022                	sd	s0,0(sp)
    80005dca:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005dcc:	ffffc097          	auipc	ra,0xffffc
    80005dd0:	c50080e7          	jalr	-944(ra) # 80001a1c <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005dd4:	0085171b          	slliw	a4,a0,0x8
    80005dd8:	0c0027b7          	lui	a5,0xc002
    80005ddc:	97ba                	add	a5,a5,a4
    80005dde:	40200713          	li	a4,1026
    80005de2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005de6:	00d5151b          	slliw	a0,a0,0xd
    80005dea:	0c2017b7          	lui	a5,0xc201
    80005dee:	97aa                	add	a5,a5,a0
    80005df0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005df4:	60a2                	ld	ra,8(sp)
    80005df6:	6402                	ld	s0,0(sp)
    80005df8:	0141                	addi	sp,sp,16
    80005dfa:	8082                	ret

0000000080005dfc <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005dfc:	1141                	addi	sp,sp,-16
    80005dfe:	e406                	sd	ra,8(sp)
    80005e00:	e022                	sd	s0,0(sp)
    80005e02:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005e04:	ffffc097          	auipc	ra,0xffffc
    80005e08:	c18080e7          	jalr	-1000(ra) # 80001a1c <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005e0c:	00d5151b          	slliw	a0,a0,0xd
    80005e10:	0c2017b7          	lui	a5,0xc201
    80005e14:	97aa                	add	a5,a5,a0
  return irq;
}
    80005e16:	43c8                	lw	a0,4(a5)
    80005e18:	60a2                	ld	ra,8(sp)
    80005e1a:	6402                	ld	s0,0(sp)
    80005e1c:	0141                	addi	sp,sp,16
    80005e1e:	8082                	ret

0000000080005e20 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005e20:	1101                	addi	sp,sp,-32
    80005e22:	ec06                	sd	ra,24(sp)
    80005e24:	e822                	sd	s0,16(sp)
    80005e26:	e426                	sd	s1,8(sp)
    80005e28:	1000                	addi	s0,sp,32
    80005e2a:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005e2c:	ffffc097          	auipc	ra,0xffffc
    80005e30:	bf0080e7          	jalr	-1040(ra) # 80001a1c <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005e34:	00d5151b          	slliw	a0,a0,0xd
    80005e38:	0c2017b7          	lui	a5,0xc201
    80005e3c:	97aa                	add	a5,a5,a0
    80005e3e:	c3c4                	sw	s1,4(a5)
}
    80005e40:	60e2                	ld	ra,24(sp)
    80005e42:	6442                	ld	s0,16(sp)
    80005e44:	64a2                	ld	s1,8(sp)
    80005e46:	6105                	addi	sp,sp,32
    80005e48:	8082                	ret

0000000080005e4a <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005e4a:	1141                	addi	sp,sp,-16
    80005e4c:	e406                	sd	ra,8(sp)
    80005e4e:	e022                	sd	s0,0(sp)
    80005e50:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005e52:	479d                	li	a5,7
    80005e54:	04a7cc63          	blt	a5,a0,80005eac <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005e58:	0001c797          	auipc	a5,0x1c
    80005e5c:	fa878793          	addi	a5,a5,-88 # 80021e00 <disk>
    80005e60:	97aa                	add	a5,a5,a0
    80005e62:	0187c783          	lbu	a5,24(a5)
    80005e66:	ebb9                	bnez	a5,80005ebc <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005e68:	00451693          	slli	a3,a0,0x4
    80005e6c:	0001c797          	auipc	a5,0x1c
    80005e70:	f9478793          	addi	a5,a5,-108 # 80021e00 <disk>
    80005e74:	6398                	ld	a4,0(a5)
    80005e76:	9736                	add	a4,a4,a3
    80005e78:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005e7c:	6398                	ld	a4,0(a5)
    80005e7e:	9736                	add	a4,a4,a3
    80005e80:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005e84:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005e88:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005e8c:	97aa                	add	a5,a5,a0
    80005e8e:	4705                	li	a4,1
    80005e90:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005e94:	0001c517          	auipc	a0,0x1c
    80005e98:	f8450513          	addi	a0,a0,-124 # 80021e18 <disk+0x18>
    80005e9c:	ffffc097          	auipc	ra,0xffffc
    80005ea0:	320080e7          	jalr	800(ra) # 800021bc <wakeup>
}
    80005ea4:	60a2                	ld	ra,8(sp)
    80005ea6:	6402                	ld	s0,0(sp)
    80005ea8:	0141                	addi	sp,sp,16
    80005eaa:	8082                	ret
    panic("free_desc 1");
    80005eac:	00002517          	auipc	a0,0x2
    80005eb0:	77c50513          	addi	a0,a0,1916 # 80008628 <etext+0x628>
    80005eb4:	ffffa097          	auipc	ra,0xffffa
    80005eb8:	6aa080e7          	jalr	1706(ra) # 8000055e <panic>
    panic("free_desc 2");
    80005ebc:	00002517          	auipc	a0,0x2
    80005ec0:	77c50513          	addi	a0,a0,1916 # 80008638 <etext+0x638>
    80005ec4:	ffffa097          	auipc	ra,0xffffa
    80005ec8:	69a080e7          	jalr	1690(ra) # 8000055e <panic>

0000000080005ecc <virtio_disk_init>:
{
    80005ecc:	1101                	addi	sp,sp,-32
    80005ece:	ec06                	sd	ra,24(sp)
    80005ed0:	e822                	sd	s0,16(sp)
    80005ed2:	e426                	sd	s1,8(sp)
    80005ed4:	e04a                	sd	s2,0(sp)
    80005ed6:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005ed8:	00002597          	auipc	a1,0x2
    80005edc:	77058593          	addi	a1,a1,1904 # 80008648 <etext+0x648>
    80005ee0:	0001c517          	auipc	a0,0x1c
    80005ee4:	04850513          	addi	a0,a0,72 # 80021f28 <disk+0x128>
    80005ee8:	ffffb097          	auipc	ra,0xffffb
    80005eec:	cbe080e7          	jalr	-834(ra) # 80000ba6 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005ef0:	100017b7          	lui	a5,0x10001
    80005ef4:	4398                	lw	a4,0(a5)
    80005ef6:	2701                	sext.w	a4,a4
    80005ef8:	747277b7          	lui	a5,0x74727
    80005efc:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005f00:	18f71c63          	bne	a4,a5,80006098 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005f04:	100017b7          	lui	a5,0x10001
    80005f08:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005f0a:	439c                	lw	a5,0(a5)
    80005f0c:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005f0e:	4709                	li	a4,2
    80005f10:	18e79463          	bne	a5,a4,80006098 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005f14:	100017b7          	lui	a5,0x10001
    80005f18:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005f1a:	439c                	lw	a5,0(a5)
    80005f1c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005f1e:	16e79d63          	bne	a5,a4,80006098 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005f22:	100017b7          	lui	a5,0x10001
    80005f26:	47d8                	lw	a4,12(a5)
    80005f28:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005f2a:	554d47b7          	lui	a5,0x554d4
    80005f2e:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005f32:	16f71363          	bne	a4,a5,80006098 <virtio_disk_init+0x1cc>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f36:	100017b7          	lui	a5,0x10001
    80005f3a:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f3e:	4705                	li	a4,1
    80005f40:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f42:	470d                	li	a4,3
    80005f44:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005f46:	10001737          	lui	a4,0x10001
    80005f4a:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005f4c:	c7ffe737          	lui	a4,0xc7ffe
    80005f50:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc81f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005f54:	8ef9                	and	a3,a3,a4
    80005f56:	10001737          	lui	a4,0x10001
    80005f5a:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f5c:	472d                	li	a4,11
    80005f5e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f60:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005f64:	439c                	lw	a5,0(a5)
    80005f66:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005f6a:	8ba1                	andi	a5,a5,8
    80005f6c:	12078e63          	beqz	a5,800060a8 <virtio_disk_init+0x1dc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005f70:	100017b7          	lui	a5,0x10001
    80005f74:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005f78:	100017b7          	lui	a5,0x10001
    80005f7c:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80005f80:	439c                	lw	a5,0(a5)
    80005f82:	2781                	sext.w	a5,a5
    80005f84:	12079a63          	bnez	a5,800060b8 <virtio_disk_init+0x1ec>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005f88:	100017b7          	lui	a5,0x10001
    80005f8c:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80005f90:	439c                	lw	a5,0(a5)
    80005f92:	2781                	sext.w	a5,a5
  if(max == 0)
    80005f94:	12078a63          	beqz	a5,800060c8 <virtio_disk_init+0x1fc>
  if(max < NUM)
    80005f98:	471d                	li	a4,7
    80005f9a:	12f77f63          	bgeu	a4,a5,800060d8 <virtio_disk_init+0x20c>
  disk.desc = kalloc();
    80005f9e:	ffffb097          	auipc	ra,0xffffb
    80005fa2:	ba8080e7          	jalr	-1112(ra) # 80000b46 <kalloc>
    80005fa6:	0001c497          	auipc	s1,0x1c
    80005faa:	e5a48493          	addi	s1,s1,-422 # 80021e00 <disk>
    80005fae:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005fb0:	ffffb097          	auipc	ra,0xffffb
    80005fb4:	b96080e7          	jalr	-1130(ra) # 80000b46 <kalloc>
    80005fb8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005fba:	ffffb097          	auipc	ra,0xffffb
    80005fbe:	b8c080e7          	jalr	-1140(ra) # 80000b46 <kalloc>
    80005fc2:	87aa                	mv	a5,a0
    80005fc4:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005fc6:	6088                	ld	a0,0(s1)
    80005fc8:	12050063          	beqz	a0,800060e8 <virtio_disk_init+0x21c>
    80005fcc:	0001c717          	auipc	a4,0x1c
    80005fd0:	e3c73703          	ld	a4,-452(a4) # 80021e08 <disk+0x8>
    80005fd4:	10070a63          	beqz	a4,800060e8 <virtio_disk_init+0x21c>
    80005fd8:	10078863          	beqz	a5,800060e8 <virtio_disk_init+0x21c>
  memset(disk.desc, 0, PGSIZE);
    80005fdc:	6605                	lui	a2,0x1
    80005fde:	4581                	li	a1,0
    80005fe0:	ffffb097          	auipc	ra,0xffffb
    80005fe4:	d52080e7          	jalr	-686(ra) # 80000d32 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005fe8:	0001c497          	auipc	s1,0x1c
    80005fec:	e1848493          	addi	s1,s1,-488 # 80021e00 <disk>
    80005ff0:	6605                	lui	a2,0x1
    80005ff2:	4581                	li	a1,0
    80005ff4:	6488                	ld	a0,8(s1)
    80005ff6:	ffffb097          	auipc	ra,0xffffb
    80005ffa:	d3c080e7          	jalr	-708(ra) # 80000d32 <memset>
  memset(disk.used, 0, PGSIZE);
    80005ffe:	6605                	lui	a2,0x1
    80006000:	4581                	li	a1,0
    80006002:	6888                	ld	a0,16(s1)
    80006004:	ffffb097          	auipc	ra,0xffffb
    80006008:	d2e080e7          	jalr	-722(ra) # 80000d32 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000600c:	100017b7          	lui	a5,0x10001
    80006010:	4721                	li	a4,8
    80006012:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006014:	4098                	lw	a4,0(s1)
    80006016:	100017b7          	lui	a5,0x10001
    8000601a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000601e:	40d8                	lw	a4,4(s1)
    80006020:	100017b7          	lui	a5,0x10001
    80006024:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80006028:	649c                	ld	a5,8(s1)
    8000602a:	0007869b          	sext.w	a3,a5
    8000602e:	10001737          	lui	a4,0x10001
    80006032:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006036:	9781                	srai	a5,a5,0x20
    80006038:	10001737          	lui	a4,0x10001
    8000603c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80006040:	689c                	ld	a5,16(s1)
    80006042:	0007869b          	sext.w	a3,a5
    80006046:	10001737          	lui	a4,0x10001
    8000604a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000604e:	9781                	srai	a5,a5,0x20
    80006050:	10001737          	lui	a4,0x10001
    80006054:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80006058:	10001737          	lui	a4,0x10001
    8000605c:	4785                	li	a5,1
    8000605e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80006060:	00f48c23          	sb	a5,24(s1)
    80006064:	00f48ca3          	sb	a5,25(s1)
    80006068:	00f48d23          	sb	a5,26(s1)
    8000606c:	00f48da3          	sb	a5,27(s1)
    80006070:	00f48e23          	sb	a5,28(s1)
    80006074:	00f48ea3          	sb	a5,29(s1)
    80006078:	00f48f23          	sb	a5,30(s1)
    8000607c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006080:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006084:	100017b7          	lui	a5,0x10001
    80006088:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000608c:	60e2                	ld	ra,24(sp)
    8000608e:	6442                	ld	s0,16(sp)
    80006090:	64a2                	ld	s1,8(sp)
    80006092:	6902                	ld	s2,0(sp)
    80006094:	6105                	addi	sp,sp,32
    80006096:	8082                	ret
    panic("could not find virtio disk");
    80006098:	00002517          	auipc	a0,0x2
    8000609c:	5c050513          	addi	a0,a0,1472 # 80008658 <etext+0x658>
    800060a0:	ffffa097          	auipc	ra,0xffffa
    800060a4:	4be080e7          	jalr	1214(ra) # 8000055e <panic>
    panic("virtio disk FEATURES_OK unset");
    800060a8:	00002517          	auipc	a0,0x2
    800060ac:	5d050513          	addi	a0,a0,1488 # 80008678 <etext+0x678>
    800060b0:	ffffa097          	auipc	ra,0xffffa
    800060b4:	4ae080e7          	jalr	1198(ra) # 8000055e <panic>
    panic("virtio disk should not be ready");
    800060b8:	00002517          	auipc	a0,0x2
    800060bc:	5e050513          	addi	a0,a0,1504 # 80008698 <etext+0x698>
    800060c0:	ffffa097          	auipc	ra,0xffffa
    800060c4:	49e080e7          	jalr	1182(ra) # 8000055e <panic>
    panic("virtio disk has no queue 0");
    800060c8:	00002517          	auipc	a0,0x2
    800060cc:	5f050513          	addi	a0,a0,1520 # 800086b8 <etext+0x6b8>
    800060d0:	ffffa097          	auipc	ra,0xffffa
    800060d4:	48e080e7          	jalr	1166(ra) # 8000055e <panic>
    panic("virtio disk max queue too short");
    800060d8:	00002517          	auipc	a0,0x2
    800060dc:	60050513          	addi	a0,a0,1536 # 800086d8 <etext+0x6d8>
    800060e0:	ffffa097          	auipc	ra,0xffffa
    800060e4:	47e080e7          	jalr	1150(ra) # 8000055e <panic>
    panic("virtio disk kalloc");
    800060e8:	00002517          	auipc	a0,0x2
    800060ec:	61050513          	addi	a0,a0,1552 # 800086f8 <etext+0x6f8>
    800060f0:	ffffa097          	auipc	ra,0xffffa
    800060f4:	46e080e7          	jalr	1134(ra) # 8000055e <panic>

00000000800060f8 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800060f8:	7159                	addi	sp,sp,-112
    800060fa:	f486                	sd	ra,104(sp)
    800060fc:	f0a2                	sd	s0,96(sp)
    800060fe:	eca6                	sd	s1,88(sp)
    80006100:	e8ca                	sd	s2,80(sp)
    80006102:	e4ce                	sd	s3,72(sp)
    80006104:	e0d2                	sd	s4,64(sp)
    80006106:	fc56                	sd	s5,56(sp)
    80006108:	f85a                	sd	s6,48(sp)
    8000610a:	f45e                	sd	s7,40(sp)
    8000610c:	f062                	sd	s8,32(sp)
    8000610e:	ec66                	sd	s9,24(sp)
    80006110:	1880                	addi	s0,sp,112
    80006112:	8a2a                	mv	s4,a0
    80006114:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006116:	00c52c83          	lw	s9,12(a0)
    8000611a:	001c9c9b          	slliw	s9,s9,0x1
    8000611e:	1c82                	slli	s9,s9,0x20
    80006120:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006124:	0001c517          	auipc	a0,0x1c
    80006128:	e0450513          	addi	a0,a0,-508 # 80021f28 <disk+0x128>
    8000612c:	ffffb097          	auipc	ra,0xffffb
    80006130:	b0a080e7          	jalr	-1270(ra) # 80000c36 <acquire>
  for(int i = 0; i < 3; i++){
    80006134:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006136:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006138:	0001cb17          	auipc	s6,0x1c
    8000613c:	cc8b0b13          	addi	s6,s6,-824 # 80021e00 <disk>
  for(int i = 0; i < 3; i++){
    80006140:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006142:	0001cc17          	auipc	s8,0x1c
    80006146:	de6c0c13          	addi	s8,s8,-538 # 80021f28 <disk+0x128>
    8000614a:	a0ad                	j	800061b4 <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    8000614c:	00fb0733          	add	a4,s6,a5
    80006150:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80006154:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006156:	0207c563          	bltz	a5,80006180 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    8000615a:	2905                	addiw	s2,s2,1
    8000615c:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    8000615e:	05590f63          	beq	s2,s5,800061bc <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    80006162:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006164:	0001c717          	auipc	a4,0x1c
    80006168:	c9c70713          	addi	a4,a4,-868 # 80021e00 <disk>
    8000616c:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000616e:	01874683          	lbu	a3,24(a4)
    80006172:	fee9                	bnez	a3,8000614c <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80006174:	2785                	addiw	a5,a5,1
    80006176:	0705                	addi	a4,a4,1
    80006178:	fe979be3          	bne	a5,s1,8000616e <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000617c:	57fd                	li	a5,-1
    8000617e:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006180:	03205163          	blez	s2,800061a2 <virtio_disk_rw+0xaa>
        free_desc(idx[j]);
    80006184:	f9042503          	lw	a0,-112(s0)
    80006188:	00000097          	auipc	ra,0x0
    8000618c:	cc2080e7          	jalr	-830(ra) # 80005e4a <free_desc>
      for(int j = 0; j < i; j++)
    80006190:	4785                	li	a5,1
    80006192:	0127d863          	bge	a5,s2,800061a2 <virtio_disk_rw+0xaa>
        free_desc(idx[j]);
    80006196:	f9442503          	lw	a0,-108(s0)
    8000619a:	00000097          	auipc	ra,0x0
    8000619e:	cb0080e7          	jalr	-848(ra) # 80005e4a <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800061a2:	85e2                	mv	a1,s8
    800061a4:	0001c517          	auipc	a0,0x1c
    800061a8:	c7450513          	addi	a0,a0,-908 # 80021e18 <disk+0x18>
    800061ac:	ffffc097          	auipc	ra,0xffffc
    800061b0:	fac080e7          	jalr	-84(ra) # 80002158 <sleep>
  for(int i = 0; i < 3; i++){
    800061b4:	f9040613          	addi	a2,s0,-112
    800061b8:	894e                	mv	s2,s3
    800061ba:	b765                	j	80006162 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800061bc:	f9042503          	lw	a0,-112(s0)
    800061c0:	00451693          	slli	a3,a0,0x4

  if(write)
    800061c4:	0001c797          	auipc	a5,0x1c
    800061c8:	c3c78793          	addi	a5,a5,-964 # 80021e00 <disk>
    800061cc:	00a50713          	addi	a4,a0,10
    800061d0:	0712                	slli	a4,a4,0x4
    800061d2:	973e                	add	a4,a4,a5
    800061d4:	01703633          	snez	a2,s7
    800061d8:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800061da:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800061de:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800061e2:	6398                	ld	a4,0(a5)
    800061e4:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800061e6:	0a868613          	addi	a2,a3,168
    800061ea:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800061ec:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800061ee:	6390                	ld	a2,0(a5)
    800061f0:	00d605b3          	add	a1,a2,a3
    800061f4:	4741                	li	a4,16
    800061f6:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800061f8:	4805                	li	a6,1
    800061fa:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    800061fe:	f9442703          	lw	a4,-108(s0)
    80006202:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006206:	0712                	slli	a4,a4,0x4
    80006208:	963a                	add	a2,a2,a4
    8000620a:	058a0593          	addi	a1,s4,88
    8000620e:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006210:	0007b883          	ld	a7,0(a5)
    80006214:	9746                	add	a4,a4,a7
    80006216:	40000613          	li	a2,1024
    8000621a:	c710                	sw	a2,8(a4)
  if(write)
    8000621c:	001bb613          	seqz	a2,s7
    80006220:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006224:	00166613          	ori	a2,a2,1
    80006228:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    8000622c:	f9842583          	lw	a1,-104(s0)
    80006230:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006234:	00250613          	addi	a2,a0,2
    80006238:	0612                	slli	a2,a2,0x4
    8000623a:	963e                	add	a2,a2,a5
    8000623c:	577d                	li	a4,-1
    8000623e:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006242:	0592                	slli	a1,a1,0x4
    80006244:	98ae                	add	a7,a7,a1
    80006246:	03068713          	addi	a4,a3,48
    8000624a:	973e                	add	a4,a4,a5
    8000624c:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80006250:	6398                	ld	a4,0(a5)
    80006252:	972e                	add	a4,a4,a1
    80006254:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006258:	4689                	li	a3,2
    8000625a:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    8000625e:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006262:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80006266:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000626a:	6794                	ld	a3,8(a5)
    8000626c:	0026d703          	lhu	a4,2(a3)
    80006270:	8b1d                	andi	a4,a4,7
    80006272:	0706                	slli	a4,a4,0x1
    80006274:	96ba                	add	a3,a3,a4
    80006276:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    8000627a:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000627e:	6798                	ld	a4,8(a5)
    80006280:	00275783          	lhu	a5,2(a4)
    80006284:	2785                	addiw	a5,a5,1
    80006286:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000628a:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000628e:	100017b7          	lui	a5,0x10001
    80006292:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006296:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    8000629a:	0001c917          	auipc	s2,0x1c
    8000629e:	c8e90913          	addi	s2,s2,-882 # 80021f28 <disk+0x128>
  while(b->disk == 1) {
    800062a2:	4485                	li	s1,1
    800062a4:	01079c63          	bne	a5,a6,800062bc <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    800062a8:	85ca                	mv	a1,s2
    800062aa:	8552                	mv	a0,s4
    800062ac:	ffffc097          	auipc	ra,0xffffc
    800062b0:	eac080e7          	jalr	-340(ra) # 80002158 <sleep>
  while(b->disk == 1) {
    800062b4:	004a2783          	lw	a5,4(s4)
    800062b8:	fe9788e3          	beq	a5,s1,800062a8 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    800062bc:	f9042903          	lw	s2,-112(s0)
    800062c0:	00290713          	addi	a4,s2,2
    800062c4:	0712                	slli	a4,a4,0x4
    800062c6:	0001c797          	auipc	a5,0x1c
    800062ca:	b3a78793          	addi	a5,a5,-1222 # 80021e00 <disk>
    800062ce:	97ba                	add	a5,a5,a4
    800062d0:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800062d4:	0001c997          	auipc	s3,0x1c
    800062d8:	b2c98993          	addi	s3,s3,-1236 # 80021e00 <disk>
    800062dc:	00491713          	slli	a4,s2,0x4
    800062e0:	0009b783          	ld	a5,0(s3)
    800062e4:	97ba                	add	a5,a5,a4
    800062e6:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800062ea:	854a                	mv	a0,s2
    800062ec:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800062f0:	00000097          	auipc	ra,0x0
    800062f4:	b5a080e7          	jalr	-1190(ra) # 80005e4a <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800062f8:	8885                	andi	s1,s1,1
    800062fa:	f0ed                	bnez	s1,800062dc <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800062fc:	0001c517          	auipc	a0,0x1c
    80006300:	c2c50513          	addi	a0,a0,-980 # 80021f28 <disk+0x128>
    80006304:	ffffb097          	auipc	ra,0xffffb
    80006308:	9e6080e7          	jalr	-1562(ra) # 80000cea <release>
}
    8000630c:	70a6                	ld	ra,104(sp)
    8000630e:	7406                	ld	s0,96(sp)
    80006310:	64e6                	ld	s1,88(sp)
    80006312:	6946                	ld	s2,80(sp)
    80006314:	69a6                	ld	s3,72(sp)
    80006316:	6a06                	ld	s4,64(sp)
    80006318:	7ae2                	ld	s5,56(sp)
    8000631a:	7b42                	ld	s6,48(sp)
    8000631c:	7ba2                	ld	s7,40(sp)
    8000631e:	7c02                	ld	s8,32(sp)
    80006320:	6ce2                	ld	s9,24(sp)
    80006322:	6165                	addi	sp,sp,112
    80006324:	8082                	ret

0000000080006326 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006326:	1101                	addi	sp,sp,-32
    80006328:	ec06                	sd	ra,24(sp)
    8000632a:	e822                	sd	s0,16(sp)
    8000632c:	e426                	sd	s1,8(sp)
    8000632e:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006330:	0001c497          	auipc	s1,0x1c
    80006334:	ad048493          	addi	s1,s1,-1328 # 80021e00 <disk>
    80006338:	0001c517          	auipc	a0,0x1c
    8000633c:	bf050513          	addi	a0,a0,-1040 # 80021f28 <disk+0x128>
    80006340:	ffffb097          	auipc	ra,0xffffb
    80006344:	8f6080e7          	jalr	-1802(ra) # 80000c36 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006348:	100017b7          	lui	a5,0x10001
    8000634c:	53b8                	lw	a4,96(a5)
    8000634e:	8b0d                	andi	a4,a4,3
    80006350:	100017b7          	lui	a5,0x10001
    80006354:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80006356:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    8000635a:	689c                	ld	a5,16(s1)
    8000635c:	0204d703          	lhu	a4,32(s1)
    80006360:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80006364:	04f70863          	beq	a4,a5,800063b4 <virtio_disk_intr+0x8e>
    __sync_synchronize();
    80006368:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000636c:	6898                	ld	a4,16(s1)
    8000636e:	0204d783          	lhu	a5,32(s1)
    80006372:	8b9d                	andi	a5,a5,7
    80006374:	078e                	slli	a5,a5,0x3
    80006376:	97ba                	add	a5,a5,a4
    80006378:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    8000637a:	00278713          	addi	a4,a5,2
    8000637e:	0712                	slli	a4,a4,0x4
    80006380:	9726                	add	a4,a4,s1
    80006382:	01074703          	lbu	a4,16(a4)
    80006386:	e721                	bnez	a4,800063ce <virtio_disk_intr+0xa8>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006388:	0789                	addi	a5,a5,2
    8000638a:	0792                	slli	a5,a5,0x4
    8000638c:	97a6                	add	a5,a5,s1
    8000638e:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006390:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006394:	ffffc097          	auipc	ra,0xffffc
    80006398:	e28080e7          	jalr	-472(ra) # 800021bc <wakeup>

    disk.used_idx += 1;
    8000639c:	0204d783          	lhu	a5,32(s1)
    800063a0:	2785                	addiw	a5,a5,1
    800063a2:	17c2                	slli	a5,a5,0x30
    800063a4:	93c1                	srli	a5,a5,0x30
    800063a6:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800063aa:	6898                	ld	a4,16(s1)
    800063ac:	00275703          	lhu	a4,2(a4)
    800063b0:	faf71ce3          	bne	a4,a5,80006368 <virtio_disk_intr+0x42>
  }

  release(&disk.vdisk_lock);
    800063b4:	0001c517          	auipc	a0,0x1c
    800063b8:	b7450513          	addi	a0,a0,-1164 # 80021f28 <disk+0x128>
    800063bc:	ffffb097          	auipc	ra,0xffffb
    800063c0:	92e080e7          	jalr	-1746(ra) # 80000cea <release>
}
    800063c4:	60e2                	ld	ra,24(sp)
    800063c6:	6442                	ld	s0,16(sp)
    800063c8:	64a2                	ld	s1,8(sp)
    800063ca:	6105                	addi	sp,sp,32
    800063cc:	8082                	ret
      panic("virtio_disk_intr status");
    800063ce:	00002517          	auipc	a0,0x2
    800063d2:	34250513          	addi	a0,a0,834 # 80008710 <etext+0x710>
    800063d6:	ffffa097          	auipc	ra,0xffffa
    800063da:	188080e7          	jalr	392(ra) # 8000055e <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
