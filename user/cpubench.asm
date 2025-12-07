
user/_cpubench:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <cpu_ops_cycle>:
#define MEASURE_PERIOD 1000


// Multiplica dos matrices de tamaño CPU_MATRIX_SIZE x CPU_MATRIX_SIZE
// y devuelve la cantidad de operaciones realizadas / 1000
int cpu_ops_cycle() {
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
   6:	08000793          	li	a5,128
   a:	08000693          	li	a3,128
   e:	8736                	mv	a4,a3
  float B[CPU_MATRIX_SIZE][CPU_MATRIX_SIZE];
  float C[CPU_MATRIX_SIZE][CPU_MATRIX_SIZE];

  // Inicializar matrices con valores arbitrarios
  for (int i = 0; i < CPU_MATRIX_SIZE; i++) {
    for (int j = 0; j < CPU_MATRIX_SIZE; j++) {
  10:	377d                	addiw	a4,a4,-1
  12:	ff7d                	bnez	a4,10 <cpu_ops_cycle+0x10>
  for (int i = 0; i < CPU_MATRIX_SIZE; i++) {
  14:	37fd                	addiw	a5,a5,-1
  16:	ffe5                	bnez	a5,e <cpu_ops_cycle+0xe>
  18:	10000613          	li	a2,256
int cpu_ops_cycle() {
  1c:	08000693          	li	a3,128
  20:	85b6                	mv	a1,a3
  22:	8736                	mv	a4,a3
  24:	87b6                	mv	a5,a3
  // Multiplicar matrices N veces
  for (int n = 0; n < CPU_EXPERIMENT_LEN; n++) {
    for (int i = 0; i < CPU_MATRIX_SIZE; i++) {
      for (int j = 0; j < CPU_MATRIX_SIZE; j++) {
        C[i][j] = 0.0f;
        for (int k = 0; k < CPU_MATRIX_SIZE; k++) {
  26:	37fd                	addiw	a5,a5,-1
  28:	fffd                	bnez	a5,26 <cpu_ops_cycle+0x26>
      for (int j = 0; j < CPU_MATRIX_SIZE; j++) {
  2a:	377d                	addiw	a4,a4,-1
  2c:	ff65                	bnez	a4,24 <cpu_ops_cycle+0x24>
    for (int i = 0; i < CPU_MATRIX_SIZE; i++) {
  2e:	35fd                	addiw	a1,a1,-1
  30:	f9ed                	bnez	a1,22 <cpu_ops_cycle+0x22>
  for (int n = 0; n < CPU_EXPERIMENT_LEN; n++) {
  32:	367d                	addiw	a2,a2,-1
  34:	f675                	bnez	a2,20 <cpu_ops_cycle+0x20>
      }
    }
  }

  return (kops_matmul * CPU_EXPERIMENT_LEN);
}
  36:	00083537          	lui	a0,0x83
  3a:	10050513          	addi	a0,a0,256 # 83100 <base+0x820f0>
  3e:	6422                	ld	s0,8(sp)
  40:	0141                	addi	sp,sp,16
  42:	8082                	ret

0000000000000044 <cpubench>:

void cpubench(int N, int pid) {
  44:	715d                	addi	sp,sp,-80
  46:	e486                	sd	ra,72(sp)
  48:	e0a2                	sd	s0,64(sp)
  4a:	fc26                	sd	s1,56(sp)
  4c:	f84a                	sd	s2,48(sp)
  4e:	ec56                	sd	s5,24(sp)
  50:	0880                	addi	s0,sp,80
  52:	84aa                	mv	s1,a0
  54:	8aae                	mv	s5,a1
  uint64 start_tick, end_tick, elapsed_ticks, total_cpu_kops, metric;
  int *measurements = malloc(sizeof(int) * N);
  56:	0025151b          	slliw	a0,a0,0x2
  5a:	00000097          	auipc	ra,0x0
  5e:	77a080e7          	jalr	1914(ra) # 7d4 <malloc>

  // Realizar N ciclos de medicion
  for(int i = 0; i < N; ++i) {
  62:	06905463          	blez	s1,ca <cpubench+0x86>
  66:	f44e                	sd	s3,40(sp)
  68:	f052                	sd	s4,32(sp)
  6a:	e85a                	sd	s6,16(sp)
  6c:	e45e                	sd	s7,8(sp)
  6e:	89aa                	mv	s3,a0
  70:	048a                	slli	s1,s1,0x2
  72:	00950a33          	add	s4,a0,s1

    end_tick = uptime();
    elapsed_ticks = end_tick - start_tick;

    // TODO: Cambiar esto por la métrica adecuada
    metric = total_cpu_kops*1000/elapsed_ticks;
  76:	3e800b93          	li	s7,1000
    measurements[i] = metric;
    printf("%d\t[cpubench]\tPerfomance\t%d\t%d\t%d\n",
  7a:	00001b17          	auipc	s6,0x1
  7e:	866b0b13          	addi	s6,s6,-1946 # 8e0 <malloc+0x10c>
    start_tick = uptime();
  82:	00000097          	auipc	ra,0x0
  86:	3ca080e7          	jalr	970(ra) # 44c <uptime>
  8a:	892a                	mv	s2,a0
    total_cpu_kops = cpu_ops_cycle();
  8c:	00000097          	auipc	ra,0x0
  90:	f74080e7          	jalr	-140(ra) # 0 <cpu_ops_cycle>
  94:	84aa                	mv	s1,a0
    end_tick = uptime();
  96:	00000097          	auipc	ra,0x0
  9a:	3b6080e7          	jalr	950(ra) # 44c <uptime>
    elapsed_ticks = end_tick - start_tick;
  9e:	41250733          	sub	a4,a0,s2
    metric = total_cpu_kops*1000/elapsed_ticks;
  a2:	03748633          	mul	a2,s1,s7
  a6:	02e65633          	divu	a2,a2,a4
    measurements[i] = metric;
  aa:	00c9a023          	sw	a2,0(s3)
    printf("%d\t[cpubench]\tPerfomance\t%d\t%d\t%d\n",
  ae:	86ca                	mv	a3,s2
  b0:	85d6                	mv	a1,s5
  b2:	855a                	mv	a0,s6
  b4:	00000097          	auipc	ra,0x0
  b8:	668080e7          	jalr	1640(ra) # 71c <printf>
  for(int i = 0; i < N; ++i) {
  bc:	0991                	addi	s3,s3,4
  be:	fd4992e3          	bne	s3,s4,82 <cpubench+0x3e>
  c2:	79a2                	ld	s3,40(sp)
  c4:	7a02                	ld	s4,32(sp)
  c6:	6b42                	ld	s6,16(sp)
  c8:	6ba2                	ld	s7,8(sp)
           pid, metric, start_tick, elapsed_ticks);
  }
}
  ca:	60a6                	ld	ra,72(sp)
  cc:	6406                	ld	s0,64(sp)
  ce:	74e2                	ld	s1,56(sp)
  d0:	7942                	ld	s2,48(sp)
  d2:	6ae2                	ld	s5,24(sp)
  d4:	6161                	addi	sp,sp,80
  d6:	8082                	ret

00000000000000d8 <main>:

int
main(int argc, char *argv[])
{
  d8:	1101                	addi	sp,sp,-32
  da:	ec06                	sd	ra,24(sp)
  dc:	e822                	sd	s0,16(sp)
  de:	1000                	addi	s0,sp,32
  int N, pid;
  if (argc != 2) {
  e0:	4789                	li	a5,2
  e2:	02f50063          	beq	a0,a5,102 <main+0x2a>
  e6:	e426                	sd	s1,8(sp)
    printf("Uso: benchmark N\n");
  e8:	00001517          	auipc	a0,0x1
  ec:	82050513          	addi	a0,a0,-2016 # 908 <malloc+0x134>
  f0:	00000097          	auipc	ra,0x0
  f4:	62c080e7          	jalr	1580(ra) # 71c <printf>
    exit(1);
  f8:	4505                	li	a0,1
  fa:	00000097          	auipc	ra,0x0
  fe:	2ba080e7          	jalr	698(ra) # 3b4 <exit>
 102:	e426                	sd	s1,8(sp)
  }

  N = atoi(argv[1]);  // Número de repeticiones para los benchmarks
 104:	6588                	ld	a0,8(a1)
 106:	00000097          	auipc	ra,0x0
 10a:	1b4080e7          	jalr	436(ra) # 2ba <atoi>
 10e:	84aa                	mv	s1,a0
  pid = getpid();
 110:	00000097          	auipc	ra,0x0
 114:	324080e7          	jalr	804(ra) # 434 <getpid>
 118:	85aa                	mv	a1,a0
  cpubench(N, pid);
 11a:	8526                	mv	a0,s1
 11c:	00000097          	auipc	ra,0x0
 120:	f28080e7          	jalr	-216(ra) # 44 <cpubench>

  exit(0);
 124:	4501                	li	a0,0
 126:	00000097          	auipc	ra,0x0
 12a:	28e080e7          	jalr	654(ra) # 3b4 <exit>

000000000000012e <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 12e:	1141                	addi	sp,sp,-16
 130:	e406                	sd	ra,8(sp)
 132:	e022                	sd	s0,0(sp)
 134:	0800                	addi	s0,sp,16
  extern int main();
  main();
 136:	00000097          	auipc	ra,0x0
 13a:	fa2080e7          	jalr	-94(ra) # d8 <main>
  exit(0);
 13e:	4501                	li	a0,0
 140:	00000097          	auipc	ra,0x0
 144:	274080e7          	jalr	628(ra) # 3b4 <exit>

0000000000000148 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 148:	1141                	addi	sp,sp,-16
 14a:	e422                	sd	s0,8(sp)
 14c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 14e:	87aa                	mv	a5,a0
 150:	0585                	addi	a1,a1,1
 152:	0785                	addi	a5,a5,1
 154:	fff5c703          	lbu	a4,-1(a1)
 158:	fee78fa3          	sb	a4,-1(a5)
 15c:	fb75                	bnez	a4,150 <strcpy+0x8>
    ;
  return os;
}
 15e:	6422                	ld	s0,8(sp)
 160:	0141                	addi	sp,sp,16
 162:	8082                	ret

0000000000000164 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 164:	1141                	addi	sp,sp,-16
 166:	e422                	sd	s0,8(sp)
 168:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 16a:	00054783          	lbu	a5,0(a0)
 16e:	cb91                	beqz	a5,182 <strcmp+0x1e>
 170:	0005c703          	lbu	a4,0(a1)
 174:	00f71763          	bne	a4,a5,182 <strcmp+0x1e>
    p++, q++;
 178:	0505                	addi	a0,a0,1
 17a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 17c:	00054783          	lbu	a5,0(a0)
 180:	fbe5                	bnez	a5,170 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 182:	0005c503          	lbu	a0,0(a1)
}
 186:	40a7853b          	subw	a0,a5,a0
 18a:	6422                	ld	s0,8(sp)
 18c:	0141                	addi	sp,sp,16
 18e:	8082                	ret

0000000000000190 <strlen>:

uint
strlen(const char *s)
{
 190:	1141                	addi	sp,sp,-16
 192:	e422                	sd	s0,8(sp)
 194:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 196:	00054783          	lbu	a5,0(a0)
 19a:	cf91                	beqz	a5,1b6 <strlen+0x26>
 19c:	0505                	addi	a0,a0,1
 19e:	87aa                	mv	a5,a0
 1a0:	86be                	mv	a3,a5
 1a2:	0785                	addi	a5,a5,1
 1a4:	fff7c703          	lbu	a4,-1(a5)
 1a8:	ff65                	bnez	a4,1a0 <strlen+0x10>
 1aa:	40a6853b          	subw	a0,a3,a0
 1ae:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 1b0:	6422                	ld	s0,8(sp)
 1b2:	0141                	addi	sp,sp,16
 1b4:	8082                	ret
  for(n = 0; s[n]; n++)
 1b6:	4501                	li	a0,0
 1b8:	bfe5                	j	1b0 <strlen+0x20>

00000000000001ba <memset>:

void*
memset(void *dst, int c, uint n)
{
 1ba:	1141                	addi	sp,sp,-16
 1bc:	e422                	sd	s0,8(sp)
 1be:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1c0:	ca19                	beqz	a2,1d6 <memset+0x1c>
 1c2:	87aa                	mv	a5,a0
 1c4:	1602                	slli	a2,a2,0x20
 1c6:	9201                	srli	a2,a2,0x20
 1c8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1cc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1d0:	0785                	addi	a5,a5,1
 1d2:	fee79de3          	bne	a5,a4,1cc <memset+0x12>
  }
  return dst;
}
 1d6:	6422                	ld	s0,8(sp)
 1d8:	0141                	addi	sp,sp,16
 1da:	8082                	ret

00000000000001dc <strchr>:

char*
strchr(const char *s, char c)
{
 1dc:	1141                	addi	sp,sp,-16
 1de:	e422                	sd	s0,8(sp)
 1e0:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1e2:	00054783          	lbu	a5,0(a0)
 1e6:	cb99                	beqz	a5,1fc <strchr+0x20>
    if(*s == c)
 1e8:	00f58763          	beq	a1,a5,1f6 <strchr+0x1a>
  for(; *s; s++)
 1ec:	0505                	addi	a0,a0,1
 1ee:	00054783          	lbu	a5,0(a0)
 1f2:	fbfd                	bnez	a5,1e8 <strchr+0xc>
      return (char*)s;
  return 0;
 1f4:	4501                	li	a0,0
}
 1f6:	6422                	ld	s0,8(sp)
 1f8:	0141                	addi	sp,sp,16
 1fa:	8082                	ret
  return 0;
 1fc:	4501                	li	a0,0
 1fe:	bfe5                	j	1f6 <strchr+0x1a>

0000000000000200 <gets>:

char*
gets(char *buf, int max)
{
 200:	711d                	addi	sp,sp,-96
 202:	ec86                	sd	ra,88(sp)
 204:	e8a2                	sd	s0,80(sp)
 206:	e4a6                	sd	s1,72(sp)
 208:	e0ca                	sd	s2,64(sp)
 20a:	fc4e                	sd	s3,56(sp)
 20c:	f852                	sd	s4,48(sp)
 20e:	f456                	sd	s5,40(sp)
 210:	f05a                	sd	s6,32(sp)
 212:	ec5e                	sd	s7,24(sp)
 214:	1080                	addi	s0,sp,96
 216:	8baa                	mv	s7,a0
 218:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 21a:	892a                	mv	s2,a0
 21c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 21e:	4aa9                	li	s5,10
 220:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 222:	89a6                	mv	s3,s1
 224:	2485                	addiw	s1,s1,1
 226:	0344d863          	bge	s1,s4,256 <gets+0x56>
    cc = read(0, &c, 1);
 22a:	4605                	li	a2,1
 22c:	faf40593          	addi	a1,s0,-81
 230:	4501                	li	a0,0
 232:	00000097          	auipc	ra,0x0
 236:	19a080e7          	jalr	410(ra) # 3cc <read>
    if(cc < 1)
 23a:	00a05e63          	blez	a0,256 <gets+0x56>
    buf[i++] = c;
 23e:	faf44783          	lbu	a5,-81(s0)
 242:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 246:	01578763          	beq	a5,s5,254 <gets+0x54>
 24a:	0905                	addi	s2,s2,1
 24c:	fd679be3          	bne	a5,s6,222 <gets+0x22>
    buf[i++] = c;
 250:	89a6                	mv	s3,s1
 252:	a011                	j	256 <gets+0x56>
 254:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 256:	99de                	add	s3,s3,s7
 258:	00098023          	sb	zero,0(s3)
  return buf;
}
 25c:	855e                	mv	a0,s7
 25e:	60e6                	ld	ra,88(sp)
 260:	6446                	ld	s0,80(sp)
 262:	64a6                	ld	s1,72(sp)
 264:	6906                	ld	s2,64(sp)
 266:	79e2                	ld	s3,56(sp)
 268:	7a42                	ld	s4,48(sp)
 26a:	7aa2                	ld	s5,40(sp)
 26c:	7b02                	ld	s6,32(sp)
 26e:	6be2                	ld	s7,24(sp)
 270:	6125                	addi	sp,sp,96
 272:	8082                	ret

0000000000000274 <stat>:

int
stat(const char *n, struct stat *st)
{
 274:	1101                	addi	sp,sp,-32
 276:	ec06                	sd	ra,24(sp)
 278:	e822                	sd	s0,16(sp)
 27a:	e04a                	sd	s2,0(sp)
 27c:	1000                	addi	s0,sp,32
 27e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 280:	4581                	li	a1,0
 282:	00000097          	auipc	ra,0x0
 286:	172080e7          	jalr	370(ra) # 3f4 <open>
  if(fd < 0)
 28a:	02054663          	bltz	a0,2b6 <stat+0x42>
 28e:	e426                	sd	s1,8(sp)
 290:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 292:	85ca                	mv	a1,s2
 294:	00000097          	auipc	ra,0x0
 298:	178080e7          	jalr	376(ra) # 40c <fstat>
 29c:	892a                	mv	s2,a0
  close(fd);
 29e:	8526                	mv	a0,s1
 2a0:	00000097          	auipc	ra,0x0
 2a4:	13c080e7          	jalr	316(ra) # 3dc <close>
  return r;
 2a8:	64a2                	ld	s1,8(sp)
}
 2aa:	854a                	mv	a0,s2
 2ac:	60e2                	ld	ra,24(sp)
 2ae:	6442                	ld	s0,16(sp)
 2b0:	6902                	ld	s2,0(sp)
 2b2:	6105                	addi	sp,sp,32
 2b4:	8082                	ret
    return -1;
 2b6:	597d                	li	s2,-1
 2b8:	bfcd                	j	2aa <stat+0x36>

00000000000002ba <atoi>:

int
atoi(const char *s)
{
 2ba:	1141                	addi	sp,sp,-16
 2bc:	e422                	sd	s0,8(sp)
 2be:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2c0:	00054683          	lbu	a3,0(a0)
 2c4:	fd06879b          	addiw	a5,a3,-48
 2c8:	0ff7f793          	zext.b	a5,a5
 2cc:	4625                	li	a2,9
 2ce:	02f66863          	bltu	a2,a5,2fe <atoi+0x44>
 2d2:	872a                	mv	a4,a0
  n = 0;
 2d4:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2d6:	0705                	addi	a4,a4,1
 2d8:	0025179b          	slliw	a5,a0,0x2
 2dc:	9fa9                	addw	a5,a5,a0
 2de:	0017979b          	slliw	a5,a5,0x1
 2e2:	9fb5                	addw	a5,a5,a3
 2e4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2e8:	00074683          	lbu	a3,0(a4)
 2ec:	fd06879b          	addiw	a5,a3,-48
 2f0:	0ff7f793          	zext.b	a5,a5
 2f4:	fef671e3          	bgeu	a2,a5,2d6 <atoi+0x1c>
  return n;
}
 2f8:	6422                	ld	s0,8(sp)
 2fa:	0141                	addi	sp,sp,16
 2fc:	8082                	ret
  n = 0;
 2fe:	4501                	li	a0,0
 300:	bfe5                	j	2f8 <atoi+0x3e>

0000000000000302 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 302:	1141                	addi	sp,sp,-16
 304:	e422                	sd	s0,8(sp)
 306:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 308:	02b57463          	bgeu	a0,a1,330 <memmove+0x2e>
    while(n-- > 0)
 30c:	00c05f63          	blez	a2,32a <memmove+0x28>
 310:	1602                	slli	a2,a2,0x20
 312:	9201                	srli	a2,a2,0x20
 314:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 318:	872a                	mv	a4,a0
      *dst++ = *src++;
 31a:	0585                	addi	a1,a1,1
 31c:	0705                	addi	a4,a4,1
 31e:	fff5c683          	lbu	a3,-1(a1)
 322:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 326:	fef71ae3          	bne	a4,a5,31a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 32a:	6422                	ld	s0,8(sp)
 32c:	0141                	addi	sp,sp,16
 32e:	8082                	ret
    dst += n;
 330:	00c50733          	add	a4,a0,a2
    src += n;
 334:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 336:	fec05ae3          	blez	a2,32a <memmove+0x28>
 33a:	fff6079b          	addiw	a5,a2,-1
 33e:	1782                	slli	a5,a5,0x20
 340:	9381                	srli	a5,a5,0x20
 342:	fff7c793          	not	a5,a5
 346:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 348:	15fd                	addi	a1,a1,-1
 34a:	177d                	addi	a4,a4,-1
 34c:	0005c683          	lbu	a3,0(a1)
 350:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 354:	fee79ae3          	bne	a5,a4,348 <memmove+0x46>
 358:	bfc9                	j	32a <memmove+0x28>

000000000000035a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 35a:	1141                	addi	sp,sp,-16
 35c:	e422                	sd	s0,8(sp)
 35e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 360:	ca05                	beqz	a2,390 <memcmp+0x36>
 362:	fff6069b          	addiw	a3,a2,-1
 366:	1682                	slli	a3,a3,0x20
 368:	9281                	srli	a3,a3,0x20
 36a:	0685                	addi	a3,a3,1
 36c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 36e:	00054783          	lbu	a5,0(a0)
 372:	0005c703          	lbu	a4,0(a1)
 376:	00e79863          	bne	a5,a4,386 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 37a:	0505                	addi	a0,a0,1
    p2++;
 37c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 37e:	fed518e3          	bne	a0,a3,36e <memcmp+0x14>
  }
  return 0;
 382:	4501                	li	a0,0
 384:	a019                	j	38a <memcmp+0x30>
      return *p1 - *p2;
 386:	40e7853b          	subw	a0,a5,a4
}
 38a:	6422                	ld	s0,8(sp)
 38c:	0141                	addi	sp,sp,16
 38e:	8082                	ret
  return 0;
 390:	4501                	li	a0,0
 392:	bfe5                	j	38a <memcmp+0x30>

0000000000000394 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 394:	1141                	addi	sp,sp,-16
 396:	e406                	sd	ra,8(sp)
 398:	e022                	sd	s0,0(sp)
 39a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 39c:	00000097          	auipc	ra,0x0
 3a0:	f66080e7          	jalr	-154(ra) # 302 <memmove>
}
 3a4:	60a2                	ld	ra,8(sp)
 3a6:	6402                	ld	s0,0(sp)
 3a8:	0141                	addi	sp,sp,16
 3aa:	8082                	ret

00000000000003ac <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3ac:	4885                	li	a7,1
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3b4:	4889                	li	a7,2
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <wait>:
.global wait
wait:
 li a7, SYS_wait
 3bc:	488d                	li	a7,3
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3c4:	4891                	li	a7,4
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <read>:
.global read
read:
 li a7, SYS_read
 3cc:	4895                	li	a7,5
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <write>:
.global write
write:
 li a7, SYS_write
 3d4:	48c1                	li	a7,16
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <close>:
.global close
close:
 li a7, SYS_close
 3dc:	48d5                	li	a7,21
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3e4:	4899                	li	a7,6
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <exec>:
.global exec
exec:
 li a7, SYS_exec
 3ec:	489d                	li	a7,7
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <open>:
.global open
open:
 li a7, SYS_open
 3f4:	48bd                	li	a7,15
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3fc:	48c5                	li	a7,17
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 404:	48c9                	li	a7,18
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 40c:	48a1                	li	a7,8
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <link>:
.global link
link:
 li a7, SYS_link
 414:	48cd                	li	a7,19
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 41c:	48d1                	li	a7,20
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 424:	48a5                	li	a7,9
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <dup>:
.global dup
dup:
 li a7, SYS_dup
 42c:	48a9                	li	a7,10
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 434:	48ad                	li	a7,11
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 43c:	48b1                	li	a7,12
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 444:	48b5                	li	a7,13
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 44c:	48b9                	li	a7,14
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 454:	1101                	addi	sp,sp,-32
 456:	ec06                	sd	ra,24(sp)
 458:	e822                	sd	s0,16(sp)
 45a:	1000                	addi	s0,sp,32
 45c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 460:	4605                	li	a2,1
 462:	fef40593          	addi	a1,s0,-17
 466:	00000097          	auipc	ra,0x0
 46a:	f6e080e7          	jalr	-146(ra) # 3d4 <write>
}
 46e:	60e2                	ld	ra,24(sp)
 470:	6442                	ld	s0,16(sp)
 472:	6105                	addi	sp,sp,32
 474:	8082                	ret

0000000000000476 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 476:	7139                	addi	sp,sp,-64
 478:	fc06                	sd	ra,56(sp)
 47a:	f822                	sd	s0,48(sp)
 47c:	f426                	sd	s1,40(sp)
 47e:	0080                	addi	s0,sp,64
 480:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 482:	c299                	beqz	a3,488 <printint+0x12>
 484:	0805cb63          	bltz	a1,51a <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 488:	2581                	sext.w	a1,a1
  neg = 0;
 48a:	4881                	li	a7,0
 48c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 490:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 492:	2601                	sext.w	a2,a2
 494:	00000517          	auipc	a0,0x0
 498:	4ec50513          	addi	a0,a0,1260 # 980 <digits>
 49c:	883a                	mv	a6,a4
 49e:	2705                	addiw	a4,a4,1
 4a0:	02c5f7bb          	remuw	a5,a1,a2
 4a4:	1782                	slli	a5,a5,0x20
 4a6:	9381                	srli	a5,a5,0x20
 4a8:	97aa                	add	a5,a5,a0
 4aa:	0007c783          	lbu	a5,0(a5)
 4ae:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4b2:	0005879b          	sext.w	a5,a1
 4b6:	02c5d5bb          	divuw	a1,a1,a2
 4ba:	0685                	addi	a3,a3,1
 4bc:	fec7f0e3          	bgeu	a5,a2,49c <printint+0x26>
  if(neg)
 4c0:	00088c63          	beqz	a7,4d8 <printint+0x62>
    buf[i++] = '-';
 4c4:	fd070793          	addi	a5,a4,-48
 4c8:	00878733          	add	a4,a5,s0
 4cc:	02d00793          	li	a5,45
 4d0:	fef70823          	sb	a5,-16(a4)
 4d4:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4d8:	02e05c63          	blez	a4,510 <printint+0x9a>
 4dc:	f04a                	sd	s2,32(sp)
 4de:	ec4e                	sd	s3,24(sp)
 4e0:	fc040793          	addi	a5,s0,-64
 4e4:	00e78933          	add	s2,a5,a4
 4e8:	fff78993          	addi	s3,a5,-1
 4ec:	99ba                	add	s3,s3,a4
 4ee:	377d                	addiw	a4,a4,-1
 4f0:	1702                	slli	a4,a4,0x20
 4f2:	9301                	srli	a4,a4,0x20
 4f4:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4f8:	fff94583          	lbu	a1,-1(s2)
 4fc:	8526                	mv	a0,s1
 4fe:	00000097          	auipc	ra,0x0
 502:	f56080e7          	jalr	-170(ra) # 454 <putc>
  while(--i >= 0)
 506:	197d                	addi	s2,s2,-1
 508:	ff3918e3          	bne	s2,s3,4f8 <printint+0x82>
 50c:	7902                	ld	s2,32(sp)
 50e:	69e2                	ld	s3,24(sp)
}
 510:	70e2                	ld	ra,56(sp)
 512:	7442                	ld	s0,48(sp)
 514:	74a2                	ld	s1,40(sp)
 516:	6121                	addi	sp,sp,64
 518:	8082                	ret
    x = -xx;
 51a:	40b005bb          	negw	a1,a1
    neg = 1;
 51e:	4885                	li	a7,1
    x = -xx;
 520:	b7b5                	j	48c <printint+0x16>

0000000000000522 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 522:	715d                	addi	sp,sp,-80
 524:	e486                	sd	ra,72(sp)
 526:	e0a2                	sd	s0,64(sp)
 528:	f84a                	sd	s2,48(sp)
 52a:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 52c:	0005c903          	lbu	s2,0(a1)
 530:	1a090a63          	beqz	s2,6e4 <vprintf+0x1c2>
 534:	fc26                	sd	s1,56(sp)
 536:	f44e                	sd	s3,40(sp)
 538:	f052                	sd	s4,32(sp)
 53a:	ec56                	sd	s5,24(sp)
 53c:	e85a                	sd	s6,16(sp)
 53e:	e45e                	sd	s7,8(sp)
 540:	8aaa                	mv	s5,a0
 542:	8bb2                	mv	s7,a2
 544:	00158493          	addi	s1,a1,1
  state = 0;
 548:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 54a:	02500a13          	li	s4,37
 54e:	4b55                	li	s6,21
 550:	a839                	j	56e <vprintf+0x4c>
        putc(fd, c);
 552:	85ca                	mv	a1,s2
 554:	8556                	mv	a0,s5
 556:	00000097          	auipc	ra,0x0
 55a:	efe080e7          	jalr	-258(ra) # 454 <putc>
 55e:	a019                	j	564 <vprintf+0x42>
    } else if(state == '%'){
 560:	01498d63          	beq	s3,s4,57a <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 564:	0485                	addi	s1,s1,1
 566:	fff4c903          	lbu	s2,-1(s1)
 56a:	16090763          	beqz	s2,6d8 <vprintf+0x1b6>
    if(state == 0){
 56e:	fe0999e3          	bnez	s3,560 <vprintf+0x3e>
      if(c == '%'){
 572:	ff4910e3          	bne	s2,s4,552 <vprintf+0x30>
        state = '%';
 576:	89d2                	mv	s3,s4
 578:	b7f5                	j	564 <vprintf+0x42>
      if(c == 'd'){
 57a:	13490463          	beq	s2,s4,6a2 <vprintf+0x180>
 57e:	f9d9079b          	addiw	a5,s2,-99
 582:	0ff7f793          	zext.b	a5,a5
 586:	12fb6763          	bltu	s6,a5,6b4 <vprintf+0x192>
 58a:	f9d9079b          	addiw	a5,s2,-99
 58e:	0ff7f713          	zext.b	a4,a5
 592:	12eb6163          	bltu	s6,a4,6b4 <vprintf+0x192>
 596:	00271793          	slli	a5,a4,0x2
 59a:	00000717          	auipc	a4,0x0
 59e:	38e70713          	addi	a4,a4,910 # 928 <malloc+0x154>
 5a2:	97ba                	add	a5,a5,a4
 5a4:	439c                	lw	a5,0(a5)
 5a6:	97ba                	add	a5,a5,a4
 5a8:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 5aa:	008b8913          	addi	s2,s7,8
 5ae:	4685                	li	a3,1
 5b0:	4629                	li	a2,10
 5b2:	000ba583          	lw	a1,0(s7)
 5b6:	8556                	mv	a0,s5
 5b8:	00000097          	auipc	ra,0x0
 5bc:	ebe080e7          	jalr	-322(ra) # 476 <printint>
 5c0:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5c2:	4981                	li	s3,0
 5c4:	b745                	j	564 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5c6:	008b8913          	addi	s2,s7,8
 5ca:	4681                	li	a3,0
 5cc:	4629                	li	a2,10
 5ce:	000ba583          	lw	a1,0(s7)
 5d2:	8556                	mv	a0,s5
 5d4:	00000097          	auipc	ra,0x0
 5d8:	ea2080e7          	jalr	-350(ra) # 476 <printint>
 5dc:	8bca                	mv	s7,s2
      state = 0;
 5de:	4981                	li	s3,0
 5e0:	b751                	j	564 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 5e2:	008b8913          	addi	s2,s7,8
 5e6:	4681                	li	a3,0
 5e8:	4641                	li	a2,16
 5ea:	000ba583          	lw	a1,0(s7)
 5ee:	8556                	mv	a0,s5
 5f0:	00000097          	auipc	ra,0x0
 5f4:	e86080e7          	jalr	-378(ra) # 476 <printint>
 5f8:	8bca                	mv	s7,s2
      state = 0;
 5fa:	4981                	li	s3,0
 5fc:	b7a5                	j	564 <vprintf+0x42>
 5fe:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 600:	008b8c13          	addi	s8,s7,8
 604:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 608:	03000593          	li	a1,48
 60c:	8556                	mv	a0,s5
 60e:	00000097          	auipc	ra,0x0
 612:	e46080e7          	jalr	-442(ra) # 454 <putc>
  putc(fd, 'x');
 616:	07800593          	li	a1,120
 61a:	8556                	mv	a0,s5
 61c:	00000097          	auipc	ra,0x0
 620:	e38080e7          	jalr	-456(ra) # 454 <putc>
 624:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 626:	00000b97          	auipc	s7,0x0
 62a:	35ab8b93          	addi	s7,s7,858 # 980 <digits>
 62e:	03c9d793          	srli	a5,s3,0x3c
 632:	97de                	add	a5,a5,s7
 634:	0007c583          	lbu	a1,0(a5)
 638:	8556                	mv	a0,s5
 63a:	00000097          	auipc	ra,0x0
 63e:	e1a080e7          	jalr	-486(ra) # 454 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 642:	0992                	slli	s3,s3,0x4
 644:	397d                	addiw	s2,s2,-1
 646:	fe0914e3          	bnez	s2,62e <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 64a:	8be2                	mv	s7,s8
      state = 0;
 64c:	4981                	li	s3,0
 64e:	6c02                	ld	s8,0(sp)
 650:	bf11                	j	564 <vprintf+0x42>
        s = va_arg(ap, char*);
 652:	008b8993          	addi	s3,s7,8
 656:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 65a:	02090163          	beqz	s2,67c <vprintf+0x15a>
        while(*s != 0){
 65e:	00094583          	lbu	a1,0(s2)
 662:	c9a5                	beqz	a1,6d2 <vprintf+0x1b0>
          putc(fd, *s);
 664:	8556                	mv	a0,s5
 666:	00000097          	auipc	ra,0x0
 66a:	dee080e7          	jalr	-530(ra) # 454 <putc>
          s++;
 66e:	0905                	addi	s2,s2,1
        while(*s != 0){
 670:	00094583          	lbu	a1,0(s2)
 674:	f9e5                	bnez	a1,664 <vprintf+0x142>
        s = va_arg(ap, char*);
 676:	8bce                	mv	s7,s3
      state = 0;
 678:	4981                	li	s3,0
 67a:	b5ed                	j	564 <vprintf+0x42>
          s = "(null)";
 67c:	00000917          	auipc	s2,0x0
 680:	2a490913          	addi	s2,s2,676 # 920 <malloc+0x14c>
        while(*s != 0){
 684:	02800593          	li	a1,40
 688:	bff1                	j	664 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 68a:	008b8913          	addi	s2,s7,8
 68e:	000bc583          	lbu	a1,0(s7)
 692:	8556                	mv	a0,s5
 694:	00000097          	auipc	ra,0x0
 698:	dc0080e7          	jalr	-576(ra) # 454 <putc>
 69c:	8bca                	mv	s7,s2
      state = 0;
 69e:	4981                	li	s3,0
 6a0:	b5d1                	j	564 <vprintf+0x42>
        putc(fd, c);
 6a2:	02500593          	li	a1,37
 6a6:	8556                	mv	a0,s5
 6a8:	00000097          	auipc	ra,0x0
 6ac:	dac080e7          	jalr	-596(ra) # 454 <putc>
      state = 0;
 6b0:	4981                	li	s3,0
 6b2:	bd4d                	j	564 <vprintf+0x42>
        putc(fd, '%');
 6b4:	02500593          	li	a1,37
 6b8:	8556                	mv	a0,s5
 6ba:	00000097          	auipc	ra,0x0
 6be:	d9a080e7          	jalr	-614(ra) # 454 <putc>
        putc(fd, c);
 6c2:	85ca                	mv	a1,s2
 6c4:	8556                	mv	a0,s5
 6c6:	00000097          	auipc	ra,0x0
 6ca:	d8e080e7          	jalr	-626(ra) # 454 <putc>
      state = 0;
 6ce:	4981                	li	s3,0
 6d0:	bd51                	j	564 <vprintf+0x42>
        s = va_arg(ap, char*);
 6d2:	8bce                	mv	s7,s3
      state = 0;
 6d4:	4981                	li	s3,0
 6d6:	b579                	j	564 <vprintf+0x42>
 6d8:	74e2                	ld	s1,56(sp)
 6da:	79a2                	ld	s3,40(sp)
 6dc:	7a02                	ld	s4,32(sp)
 6de:	6ae2                	ld	s5,24(sp)
 6e0:	6b42                	ld	s6,16(sp)
 6e2:	6ba2                	ld	s7,8(sp)
    }
  }
}
 6e4:	60a6                	ld	ra,72(sp)
 6e6:	6406                	ld	s0,64(sp)
 6e8:	7942                	ld	s2,48(sp)
 6ea:	6161                	addi	sp,sp,80
 6ec:	8082                	ret

00000000000006ee <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6ee:	715d                	addi	sp,sp,-80
 6f0:	ec06                	sd	ra,24(sp)
 6f2:	e822                	sd	s0,16(sp)
 6f4:	1000                	addi	s0,sp,32
 6f6:	e010                	sd	a2,0(s0)
 6f8:	e414                	sd	a3,8(s0)
 6fa:	e818                	sd	a4,16(s0)
 6fc:	ec1c                	sd	a5,24(s0)
 6fe:	03043023          	sd	a6,32(s0)
 702:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 706:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 70a:	8622                	mv	a2,s0
 70c:	00000097          	auipc	ra,0x0
 710:	e16080e7          	jalr	-490(ra) # 522 <vprintf>
}
 714:	60e2                	ld	ra,24(sp)
 716:	6442                	ld	s0,16(sp)
 718:	6161                	addi	sp,sp,80
 71a:	8082                	ret

000000000000071c <printf>:

void
printf(const char *fmt, ...)
{
 71c:	711d                	addi	sp,sp,-96
 71e:	ec06                	sd	ra,24(sp)
 720:	e822                	sd	s0,16(sp)
 722:	1000                	addi	s0,sp,32
 724:	e40c                	sd	a1,8(s0)
 726:	e810                	sd	a2,16(s0)
 728:	ec14                	sd	a3,24(s0)
 72a:	f018                	sd	a4,32(s0)
 72c:	f41c                	sd	a5,40(s0)
 72e:	03043823          	sd	a6,48(s0)
 732:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 736:	00840613          	addi	a2,s0,8
 73a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 73e:	85aa                	mv	a1,a0
 740:	4505                	li	a0,1
 742:	00000097          	auipc	ra,0x0
 746:	de0080e7          	jalr	-544(ra) # 522 <vprintf>
}
 74a:	60e2                	ld	ra,24(sp)
 74c:	6442                	ld	s0,16(sp)
 74e:	6125                	addi	sp,sp,96
 750:	8082                	ret

0000000000000752 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 752:	1141                	addi	sp,sp,-16
 754:	e422                	sd	s0,8(sp)
 756:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 758:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 75c:	00001797          	auipc	a5,0x1
 760:	8a47b783          	ld	a5,-1884(a5) # 1000 <freep>
 764:	a02d                	j	78e <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 766:	4618                	lw	a4,8(a2)
 768:	9f2d                	addw	a4,a4,a1
 76a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 76e:	6398                	ld	a4,0(a5)
 770:	6310                	ld	a2,0(a4)
 772:	a83d                	j	7b0 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 774:	ff852703          	lw	a4,-8(a0)
 778:	9f31                	addw	a4,a4,a2
 77a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 77c:	ff053683          	ld	a3,-16(a0)
 780:	a091                	j	7c4 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 782:	6398                	ld	a4,0(a5)
 784:	00e7e463          	bltu	a5,a4,78c <free+0x3a>
 788:	00e6ea63          	bltu	a3,a4,79c <free+0x4a>
{
 78c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 78e:	fed7fae3          	bgeu	a5,a3,782 <free+0x30>
 792:	6398                	ld	a4,0(a5)
 794:	00e6e463          	bltu	a3,a4,79c <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 798:	fee7eae3          	bltu	a5,a4,78c <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 79c:	ff852583          	lw	a1,-8(a0)
 7a0:	6390                	ld	a2,0(a5)
 7a2:	02059813          	slli	a6,a1,0x20
 7a6:	01c85713          	srli	a4,a6,0x1c
 7aa:	9736                	add	a4,a4,a3
 7ac:	fae60de3          	beq	a2,a4,766 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7b0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7b4:	4790                	lw	a2,8(a5)
 7b6:	02061593          	slli	a1,a2,0x20
 7ba:	01c5d713          	srli	a4,a1,0x1c
 7be:	973e                	add	a4,a4,a5
 7c0:	fae68ae3          	beq	a3,a4,774 <free+0x22>
    p->s.ptr = bp->s.ptr;
 7c4:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7c6:	00001717          	auipc	a4,0x1
 7ca:	82f73d23          	sd	a5,-1990(a4) # 1000 <freep>
}
 7ce:	6422                	ld	s0,8(sp)
 7d0:	0141                	addi	sp,sp,16
 7d2:	8082                	ret

00000000000007d4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7d4:	7139                	addi	sp,sp,-64
 7d6:	fc06                	sd	ra,56(sp)
 7d8:	f822                	sd	s0,48(sp)
 7da:	f426                	sd	s1,40(sp)
 7dc:	ec4e                	sd	s3,24(sp)
 7de:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7e0:	02051493          	slli	s1,a0,0x20
 7e4:	9081                	srli	s1,s1,0x20
 7e6:	04bd                	addi	s1,s1,15
 7e8:	8091                	srli	s1,s1,0x4
 7ea:	0014899b          	addiw	s3,s1,1
 7ee:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7f0:	00001517          	auipc	a0,0x1
 7f4:	81053503          	ld	a0,-2032(a0) # 1000 <freep>
 7f8:	c915                	beqz	a0,82c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7fa:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7fc:	4798                	lw	a4,8(a5)
 7fe:	08977e63          	bgeu	a4,s1,89a <malloc+0xc6>
 802:	f04a                	sd	s2,32(sp)
 804:	e852                	sd	s4,16(sp)
 806:	e456                	sd	s5,8(sp)
 808:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 80a:	8a4e                	mv	s4,s3
 80c:	0009871b          	sext.w	a4,s3
 810:	6685                	lui	a3,0x1
 812:	00d77363          	bgeu	a4,a3,818 <malloc+0x44>
 816:	6a05                	lui	s4,0x1
 818:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 81c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 820:	00000917          	auipc	s2,0x0
 824:	7e090913          	addi	s2,s2,2016 # 1000 <freep>
  if(p == (char*)-1)
 828:	5afd                	li	s5,-1
 82a:	a091                	j	86e <malloc+0x9a>
 82c:	f04a                	sd	s2,32(sp)
 82e:	e852                	sd	s4,16(sp)
 830:	e456                	sd	s5,8(sp)
 832:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 834:	00000797          	auipc	a5,0x0
 838:	7dc78793          	addi	a5,a5,2012 # 1010 <base>
 83c:	00000717          	auipc	a4,0x0
 840:	7cf73223          	sd	a5,1988(a4) # 1000 <freep>
 844:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 846:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 84a:	b7c1                	j	80a <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 84c:	6398                	ld	a4,0(a5)
 84e:	e118                	sd	a4,0(a0)
 850:	a08d                	j	8b2 <malloc+0xde>
  hp->s.size = nu;
 852:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 856:	0541                	addi	a0,a0,16
 858:	00000097          	auipc	ra,0x0
 85c:	efa080e7          	jalr	-262(ra) # 752 <free>
  return freep;
 860:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 864:	c13d                	beqz	a0,8ca <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 866:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 868:	4798                	lw	a4,8(a5)
 86a:	02977463          	bgeu	a4,s1,892 <malloc+0xbe>
    if(p == freep)
 86e:	00093703          	ld	a4,0(s2)
 872:	853e                	mv	a0,a5
 874:	fef719e3          	bne	a4,a5,866 <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 878:	8552                	mv	a0,s4
 87a:	00000097          	auipc	ra,0x0
 87e:	bc2080e7          	jalr	-1086(ra) # 43c <sbrk>
  if(p == (char*)-1)
 882:	fd5518e3          	bne	a0,s5,852 <malloc+0x7e>
        return 0;
 886:	4501                	li	a0,0
 888:	7902                	ld	s2,32(sp)
 88a:	6a42                	ld	s4,16(sp)
 88c:	6aa2                	ld	s5,8(sp)
 88e:	6b02                	ld	s6,0(sp)
 890:	a03d                	j	8be <malloc+0xea>
 892:	7902                	ld	s2,32(sp)
 894:	6a42                	ld	s4,16(sp)
 896:	6aa2                	ld	s5,8(sp)
 898:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 89a:	fae489e3          	beq	s1,a4,84c <malloc+0x78>
        p->s.size -= nunits;
 89e:	4137073b          	subw	a4,a4,s3
 8a2:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8a4:	02071693          	slli	a3,a4,0x20
 8a8:	01c6d713          	srli	a4,a3,0x1c
 8ac:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8ae:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8b2:	00000717          	auipc	a4,0x0
 8b6:	74a73723          	sd	a0,1870(a4) # 1000 <freep>
      return (void*)(p + 1);
 8ba:	01078513          	addi	a0,a5,16
  }
}
 8be:	70e2                	ld	ra,56(sp)
 8c0:	7442                	ld	s0,48(sp)
 8c2:	74a2                	ld	s1,40(sp)
 8c4:	69e2                	ld	s3,24(sp)
 8c6:	6121                	addi	sp,sp,64
 8c8:	8082                	ret
 8ca:	7902                	ld	s2,32(sp)
 8cc:	6a42                	ld	s4,16(sp)
 8ce:	6aa2                	ld	s5,8(sp)
 8d0:	6b02                	ld	s6,0(sp)
 8d2:	b7f5                	j	8be <malloc+0xea>
