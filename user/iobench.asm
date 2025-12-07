
user/_iobench:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <io_ops>:
static char data[IO_OPSIZE];


int
io_ops()
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	0080                	addi	s0,sp,64
    int rfd, wfd;

    int pid = getpid();
   e:	00000097          	auipc	ra,0x0
  12:	4cc080e7          	jalr	1228(ra) # 4da <getpid>

    // Crear un path unico de archivo
    char path[] = "12iops";
  16:	6f6937b7          	lui	a5,0x6f693
  1a:	23178793          	addi	a5,a5,561 # 6f693231 <base+0x6f6921e1>
  1e:	fcf42423          	sw	a5,-56(s0)
  22:	679d                	lui	a5,0x7
  24:	37078793          	addi	a5,a5,880 # 7370 <base+0x6320>
  28:	fcf41623          	sh	a5,-52(s0)
  2c:	fc040723          	sb	zero,-50(s0)
    path[0] = '0' + (pid / 10);
  30:	4729                	li	a4,10
  32:	02e547bb          	divw	a5,a0,a4
  36:	0307879b          	addiw	a5,a5,48
  3a:	fcf40423          	sb	a5,-56(s0)
    path[1] = '0' + (pid % 10);
  3e:	02e567bb          	remw	a5,a0,a4
  42:	0307879b          	addiw	a5,a5,48
  46:	fcf404a3          	sb	a5,-55(s0)

    wfd = open(path, O_CREATE | O_WRONLY);
  4a:	20100593          	li	a1,513
  4e:	fc840513          	addi	a0,s0,-56
  52:	00000097          	auipc	ra,0x0
  56:	448080e7          	jalr	1096(ra) # 49a <open>
  5a:	892a                	mv	s2,a0
  5c:	20000493          	li	s1,512

    for(int i = 0; i < IO_EXPERIMENT_LEN; ++i){
      write(wfd, data, IO_OPSIZE);
  60:	00001997          	auipc	s3,0x1
  64:	fb098993          	addi	s3,s3,-80 # 1010 <data>
  68:	04000613          	li	a2,64
  6c:	85ce                	mv	a1,s3
  6e:	854a                	mv	a0,s2
  70:	00000097          	auipc	ra,0x0
  74:	40a080e7          	jalr	1034(ra) # 47a <write>
    for(int i = 0; i < IO_EXPERIMENT_LEN; ++i){
  78:	34fd                	addiw	s1,s1,-1
  7a:	f4fd                	bnez	s1,68 <io_ops+0x68>
    }

    close(wfd);
  7c:	854a                	mv	a0,s2
  7e:	00000097          	auipc	ra,0x0
  82:	404080e7          	jalr	1028(ra) # 482 <close>

    rfd = open(path, O_RDONLY);
  86:	4581                	li	a1,0
  88:	fc840513          	addi	a0,s0,-56
  8c:	00000097          	auipc	ra,0x0
  90:	40e080e7          	jalr	1038(ra) # 49a <open>
  94:	892a                	mv	s2,a0
  96:	20000493          	li	s1,512

    for(int i = 0; i < IO_EXPERIMENT_LEN; ++i){
      read(rfd, data, IO_OPSIZE);
  9a:	00001997          	auipc	s3,0x1
  9e:	f7698993          	addi	s3,s3,-138 # 1010 <data>
  a2:	04000613          	li	a2,64
  a6:	85ce                	mv	a1,s3
  a8:	854a                	mv	a0,s2
  aa:	00000097          	auipc	ra,0x0
  ae:	3c8080e7          	jalr	968(ra) # 472 <read>
    for(int i = 0; i < IO_EXPERIMENT_LEN; ++i){
  b2:	34fd                	addiw	s1,s1,-1
  b4:	f4fd                	bnez	s1,a2 <io_ops+0xa2>
    }

    close(rfd);
  b6:	854a                	mv	a0,s2
  b8:	00000097          	auipc	ra,0x0
  bc:	3ca080e7          	jalr	970(ra) # 482 <close>
    return 2 * IO_EXPERIMENT_LEN;
}
  c0:	40000513          	li	a0,1024
  c4:	70e2                	ld	ra,56(sp)
  c6:	7442                	ld	s0,48(sp)
  c8:	74a2                	ld	s1,40(sp)
  ca:	7902                	ld	s2,32(sp)
  cc:	69e2                	ld	s3,24(sp)
  ce:	6121                	addi	sp,sp,64
  d0:	8082                	ret

00000000000000d2 <iobench>:

void
iobench(int N, int pid)
{
  d2:	715d                	addi	sp,sp,-80
  d4:	e486                	sd	ra,72(sp)
  d6:	e0a2                	sd	s0,64(sp)
  d8:	fc26                	sd	s1,56(sp)
  da:	f84a                	sd	s2,48(sp)
  dc:	ec56                	sd	s5,24(sp)
  de:	0880                	addi	s0,sp,80
  e0:	84aa                	mv	s1,a0
  e2:	8aae                	mv	s5,a1
  memset(data, 'a', sizeof(data));
  e4:	04000613          	li	a2,64
  e8:	06100593          	li	a1,97
  ec:	00001517          	auipc	a0,0x1
  f0:	f2450513          	addi	a0,a0,-220 # 1010 <data>
  f4:	00000097          	auipc	ra,0x0
  f8:	16c080e7          	jalr	364(ra) # 260 <memset>
  uint64 start_tick, end_tick, elapsed_ticks, metric;
  int total_iops;

  int *measurements = malloc(sizeof(int) * N);
  fc:	0024951b          	slliw	a0,s1,0x2
 100:	00000097          	auipc	ra,0x0
 104:	77a080e7          	jalr	1914(ra) # 87a <malloc>

  for (int i = 0; i < N; i++){
 108:	06905463          	blez	s1,170 <iobench+0x9e>
 10c:	f44e                	sd	s3,40(sp)
 10e:	f052                	sd	s4,32(sp)
 110:	e85a                	sd	s6,16(sp)
 112:	e45e                	sd	s7,8(sp)
 114:	89aa                	mv	s3,a0
 116:	048a                	slli	s1,s1,0x2
 118:	00950a33          	add	s4,a0,s1
    // Realizar escrituras y lecturas de archivos
    total_iops = io_ops();

    end_tick = uptime();
    elapsed_ticks = end_tick - start_tick;
    metric = (total_iops*1000)/elapsed_ticks;  // Cambiar esto por la métrica adecuada
 11c:	3e800b93          	li	s7,1000
    measurements[i] = metric;
    printf("%d\t[iobench]\tPerfomance\t%d\t%d\t%d\n",
 120:	00001b17          	auipc	s6,0x1
 124:	860b0b13          	addi	s6,s6,-1952 # 980 <malloc+0x106>
    start_tick = uptime();
 128:	00000097          	auipc	ra,0x0
 12c:	3ca080e7          	jalr	970(ra) # 4f2 <uptime>
 130:	892a                	mv	s2,a0
    total_iops = io_ops();
 132:	00000097          	auipc	ra,0x0
 136:	ece080e7          	jalr	-306(ra) # 0 <io_ops>
 13a:	84aa                	mv	s1,a0
    end_tick = uptime();
 13c:	00000097          	auipc	ra,0x0
 140:	3b6080e7          	jalr	950(ra) # 4f2 <uptime>
    elapsed_ticks = end_tick - start_tick;
 144:	41250733          	sub	a4,a0,s2
    metric = (total_iops*1000)/elapsed_ticks;  // Cambiar esto por la métrica adecuada
 148:	029b863b          	mulw	a2,s7,s1
 14c:	02e65633          	divu	a2,a2,a4
    measurements[i] = metric;
 150:	00c9a023          	sw	a2,0(s3)
    printf("%d\t[iobench]\tPerfomance\t%d\t%d\t%d\n",
 154:	86ca                	mv	a3,s2
 156:	85d6                	mv	a1,s5
 158:	855a                	mv	a0,s6
 15a:	00000097          	auipc	ra,0x0
 15e:	668080e7          	jalr	1640(ra) # 7c2 <printf>
  for (int i = 0; i < N; i++){
 162:	0991                	addi	s3,s3,4
 164:	fd4992e3          	bne	s3,s4,128 <iobench+0x56>
 168:	79a2                	ld	s3,40(sp)
 16a:	7a02                	ld	s4,32(sp)
 16c:	6b42                	ld	s6,16(sp)
 16e:	6ba2                	ld	s7,8(sp)
           pid, metric, start_tick, elapsed_ticks);
  }
}
 170:	60a6                	ld	ra,72(sp)
 172:	6406                	ld	s0,64(sp)
 174:	74e2                	ld	s1,56(sp)
 176:	7942                	ld	s2,48(sp)
 178:	6ae2                	ld	s5,24(sp)
 17a:	6161                	addi	sp,sp,80
 17c:	8082                	ret

000000000000017e <main>:

int
main(int argc, char *argv[])
{
 17e:	1101                	addi	sp,sp,-32
 180:	ec06                	sd	ra,24(sp)
 182:	e822                	sd	s0,16(sp)
 184:	1000                	addi	s0,sp,32
  int N, pid;
  if (argc != 2) {
 186:	4789                	li	a5,2
 188:	02f50063          	beq	a0,a5,1a8 <main+0x2a>
 18c:	e426                	sd	s1,8(sp)
    printf("Uso: benchmark N\n");
 18e:	00001517          	auipc	a0,0x1
 192:	81a50513          	addi	a0,a0,-2022 # 9a8 <malloc+0x12e>
 196:	00000097          	auipc	ra,0x0
 19a:	62c080e7          	jalr	1580(ra) # 7c2 <printf>
    exit(1);
 19e:	4505                	li	a0,1
 1a0:	00000097          	auipc	ra,0x0
 1a4:	2ba080e7          	jalr	698(ra) # 45a <exit>
 1a8:	e426                	sd	s1,8(sp)
  }

  N = atoi(argv[1]);  // Número de repeticiones para los benchmarks
 1aa:	6588                	ld	a0,8(a1)
 1ac:	00000097          	auipc	ra,0x0
 1b0:	1b4080e7          	jalr	436(ra) # 360 <atoi>
 1b4:	84aa                	mv	s1,a0
  pid = getpid();
 1b6:	00000097          	auipc	ra,0x0
 1ba:	324080e7          	jalr	804(ra) # 4da <getpid>
 1be:	85aa                	mv	a1,a0
  iobench(N, pid);
 1c0:	8526                	mv	a0,s1
 1c2:	00000097          	auipc	ra,0x0
 1c6:	f10080e7          	jalr	-240(ra) # d2 <iobench>

  exit(0);
 1ca:	4501                	li	a0,0
 1cc:	00000097          	auipc	ra,0x0
 1d0:	28e080e7          	jalr	654(ra) # 45a <exit>

00000000000001d4 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 1d4:	1141                	addi	sp,sp,-16
 1d6:	e406                	sd	ra,8(sp)
 1d8:	e022                	sd	s0,0(sp)
 1da:	0800                	addi	s0,sp,16
  extern int main();
  main();
 1dc:	00000097          	auipc	ra,0x0
 1e0:	fa2080e7          	jalr	-94(ra) # 17e <main>
  exit(0);
 1e4:	4501                	li	a0,0
 1e6:	00000097          	auipc	ra,0x0
 1ea:	274080e7          	jalr	628(ra) # 45a <exit>

00000000000001ee <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1ee:	1141                	addi	sp,sp,-16
 1f0:	e422                	sd	s0,8(sp)
 1f2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1f4:	87aa                	mv	a5,a0
 1f6:	0585                	addi	a1,a1,1
 1f8:	0785                	addi	a5,a5,1
 1fa:	fff5c703          	lbu	a4,-1(a1)
 1fe:	fee78fa3          	sb	a4,-1(a5)
 202:	fb75                	bnez	a4,1f6 <strcpy+0x8>
    ;
  return os;
}
 204:	6422                	ld	s0,8(sp)
 206:	0141                	addi	sp,sp,16
 208:	8082                	ret

000000000000020a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 20a:	1141                	addi	sp,sp,-16
 20c:	e422                	sd	s0,8(sp)
 20e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 210:	00054783          	lbu	a5,0(a0)
 214:	cb91                	beqz	a5,228 <strcmp+0x1e>
 216:	0005c703          	lbu	a4,0(a1)
 21a:	00f71763          	bne	a4,a5,228 <strcmp+0x1e>
    p++, q++;
 21e:	0505                	addi	a0,a0,1
 220:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 222:	00054783          	lbu	a5,0(a0)
 226:	fbe5                	bnez	a5,216 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 228:	0005c503          	lbu	a0,0(a1)
}
 22c:	40a7853b          	subw	a0,a5,a0
 230:	6422                	ld	s0,8(sp)
 232:	0141                	addi	sp,sp,16
 234:	8082                	ret

0000000000000236 <strlen>:

uint
strlen(const char *s)
{
 236:	1141                	addi	sp,sp,-16
 238:	e422                	sd	s0,8(sp)
 23a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 23c:	00054783          	lbu	a5,0(a0)
 240:	cf91                	beqz	a5,25c <strlen+0x26>
 242:	0505                	addi	a0,a0,1
 244:	87aa                	mv	a5,a0
 246:	86be                	mv	a3,a5
 248:	0785                	addi	a5,a5,1
 24a:	fff7c703          	lbu	a4,-1(a5)
 24e:	ff65                	bnez	a4,246 <strlen+0x10>
 250:	40a6853b          	subw	a0,a3,a0
 254:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 256:	6422                	ld	s0,8(sp)
 258:	0141                	addi	sp,sp,16
 25a:	8082                	ret
  for(n = 0; s[n]; n++)
 25c:	4501                	li	a0,0
 25e:	bfe5                	j	256 <strlen+0x20>

0000000000000260 <memset>:

void*
memset(void *dst, int c, uint n)
{
 260:	1141                	addi	sp,sp,-16
 262:	e422                	sd	s0,8(sp)
 264:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 266:	ca19                	beqz	a2,27c <memset+0x1c>
 268:	87aa                	mv	a5,a0
 26a:	1602                	slli	a2,a2,0x20
 26c:	9201                	srli	a2,a2,0x20
 26e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 272:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 276:	0785                	addi	a5,a5,1
 278:	fee79de3          	bne	a5,a4,272 <memset+0x12>
  }
  return dst;
}
 27c:	6422                	ld	s0,8(sp)
 27e:	0141                	addi	sp,sp,16
 280:	8082                	ret

0000000000000282 <strchr>:

char*
strchr(const char *s, char c)
{
 282:	1141                	addi	sp,sp,-16
 284:	e422                	sd	s0,8(sp)
 286:	0800                	addi	s0,sp,16
  for(; *s; s++)
 288:	00054783          	lbu	a5,0(a0)
 28c:	cb99                	beqz	a5,2a2 <strchr+0x20>
    if(*s == c)
 28e:	00f58763          	beq	a1,a5,29c <strchr+0x1a>
  for(; *s; s++)
 292:	0505                	addi	a0,a0,1
 294:	00054783          	lbu	a5,0(a0)
 298:	fbfd                	bnez	a5,28e <strchr+0xc>
      return (char*)s;
  return 0;
 29a:	4501                	li	a0,0
}
 29c:	6422                	ld	s0,8(sp)
 29e:	0141                	addi	sp,sp,16
 2a0:	8082                	ret
  return 0;
 2a2:	4501                	li	a0,0
 2a4:	bfe5                	j	29c <strchr+0x1a>

00000000000002a6 <gets>:

char*
gets(char *buf, int max)
{
 2a6:	711d                	addi	sp,sp,-96
 2a8:	ec86                	sd	ra,88(sp)
 2aa:	e8a2                	sd	s0,80(sp)
 2ac:	e4a6                	sd	s1,72(sp)
 2ae:	e0ca                	sd	s2,64(sp)
 2b0:	fc4e                	sd	s3,56(sp)
 2b2:	f852                	sd	s4,48(sp)
 2b4:	f456                	sd	s5,40(sp)
 2b6:	f05a                	sd	s6,32(sp)
 2b8:	ec5e                	sd	s7,24(sp)
 2ba:	1080                	addi	s0,sp,96
 2bc:	8baa                	mv	s7,a0
 2be:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2c0:	892a                	mv	s2,a0
 2c2:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2c4:	4aa9                	li	s5,10
 2c6:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2c8:	89a6                	mv	s3,s1
 2ca:	2485                	addiw	s1,s1,1
 2cc:	0344d863          	bge	s1,s4,2fc <gets+0x56>
    cc = read(0, &c, 1);
 2d0:	4605                	li	a2,1
 2d2:	faf40593          	addi	a1,s0,-81
 2d6:	4501                	li	a0,0
 2d8:	00000097          	auipc	ra,0x0
 2dc:	19a080e7          	jalr	410(ra) # 472 <read>
    if(cc < 1)
 2e0:	00a05e63          	blez	a0,2fc <gets+0x56>
    buf[i++] = c;
 2e4:	faf44783          	lbu	a5,-81(s0)
 2e8:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2ec:	01578763          	beq	a5,s5,2fa <gets+0x54>
 2f0:	0905                	addi	s2,s2,1
 2f2:	fd679be3          	bne	a5,s6,2c8 <gets+0x22>
    buf[i++] = c;
 2f6:	89a6                	mv	s3,s1
 2f8:	a011                	j	2fc <gets+0x56>
 2fa:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2fc:	99de                	add	s3,s3,s7
 2fe:	00098023          	sb	zero,0(s3)
  return buf;
}
 302:	855e                	mv	a0,s7
 304:	60e6                	ld	ra,88(sp)
 306:	6446                	ld	s0,80(sp)
 308:	64a6                	ld	s1,72(sp)
 30a:	6906                	ld	s2,64(sp)
 30c:	79e2                	ld	s3,56(sp)
 30e:	7a42                	ld	s4,48(sp)
 310:	7aa2                	ld	s5,40(sp)
 312:	7b02                	ld	s6,32(sp)
 314:	6be2                	ld	s7,24(sp)
 316:	6125                	addi	sp,sp,96
 318:	8082                	ret

000000000000031a <stat>:

int
stat(const char *n, struct stat *st)
{
 31a:	1101                	addi	sp,sp,-32
 31c:	ec06                	sd	ra,24(sp)
 31e:	e822                	sd	s0,16(sp)
 320:	e04a                	sd	s2,0(sp)
 322:	1000                	addi	s0,sp,32
 324:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 326:	4581                	li	a1,0
 328:	00000097          	auipc	ra,0x0
 32c:	172080e7          	jalr	370(ra) # 49a <open>
  if(fd < 0)
 330:	02054663          	bltz	a0,35c <stat+0x42>
 334:	e426                	sd	s1,8(sp)
 336:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 338:	85ca                	mv	a1,s2
 33a:	00000097          	auipc	ra,0x0
 33e:	178080e7          	jalr	376(ra) # 4b2 <fstat>
 342:	892a                	mv	s2,a0
  close(fd);
 344:	8526                	mv	a0,s1
 346:	00000097          	auipc	ra,0x0
 34a:	13c080e7          	jalr	316(ra) # 482 <close>
  return r;
 34e:	64a2                	ld	s1,8(sp)
}
 350:	854a                	mv	a0,s2
 352:	60e2                	ld	ra,24(sp)
 354:	6442                	ld	s0,16(sp)
 356:	6902                	ld	s2,0(sp)
 358:	6105                	addi	sp,sp,32
 35a:	8082                	ret
    return -1;
 35c:	597d                	li	s2,-1
 35e:	bfcd                	j	350 <stat+0x36>

0000000000000360 <atoi>:

int
atoi(const char *s)
{
 360:	1141                	addi	sp,sp,-16
 362:	e422                	sd	s0,8(sp)
 364:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 366:	00054683          	lbu	a3,0(a0)
 36a:	fd06879b          	addiw	a5,a3,-48
 36e:	0ff7f793          	zext.b	a5,a5
 372:	4625                	li	a2,9
 374:	02f66863          	bltu	a2,a5,3a4 <atoi+0x44>
 378:	872a                	mv	a4,a0
  n = 0;
 37a:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 37c:	0705                	addi	a4,a4,1
 37e:	0025179b          	slliw	a5,a0,0x2
 382:	9fa9                	addw	a5,a5,a0
 384:	0017979b          	slliw	a5,a5,0x1
 388:	9fb5                	addw	a5,a5,a3
 38a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 38e:	00074683          	lbu	a3,0(a4)
 392:	fd06879b          	addiw	a5,a3,-48
 396:	0ff7f793          	zext.b	a5,a5
 39a:	fef671e3          	bgeu	a2,a5,37c <atoi+0x1c>
  return n;
}
 39e:	6422                	ld	s0,8(sp)
 3a0:	0141                	addi	sp,sp,16
 3a2:	8082                	ret
  n = 0;
 3a4:	4501                	li	a0,0
 3a6:	bfe5                	j	39e <atoi+0x3e>

00000000000003a8 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3a8:	1141                	addi	sp,sp,-16
 3aa:	e422                	sd	s0,8(sp)
 3ac:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3ae:	02b57463          	bgeu	a0,a1,3d6 <memmove+0x2e>
    while(n-- > 0)
 3b2:	00c05f63          	blez	a2,3d0 <memmove+0x28>
 3b6:	1602                	slli	a2,a2,0x20
 3b8:	9201                	srli	a2,a2,0x20
 3ba:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3be:	872a                	mv	a4,a0
      *dst++ = *src++;
 3c0:	0585                	addi	a1,a1,1
 3c2:	0705                	addi	a4,a4,1
 3c4:	fff5c683          	lbu	a3,-1(a1)
 3c8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3cc:	fef71ae3          	bne	a4,a5,3c0 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3d0:	6422                	ld	s0,8(sp)
 3d2:	0141                	addi	sp,sp,16
 3d4:	8082                	ret
    dst += n;
 3d6:	00c50733          	add	a4,a0,a2
    src += n;
 3da:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3dc:	fec05ae3          	blez	a2,3d0 <memmove+0x28>
 3e0:	fff6079b          	addiw	a5,a2,-1
 3e4:	1782                	slli	a5,a5,0x20
 3e6:	9381                	srli	a5,a5,0x20
 3e8:	fff7c793          	not	a5,a5
 3ec:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3ee:	15fd                	addi	a1,a1,-1
 3f0:	177d                	addi	a4,a4,-1
 3f2:	0005c683          	lbu	a3,0(a1)
 3f6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3fa:	fee79ae3          	bne	a5,a4,3ee <memmove+0x46>
 3fe:	bfc9                	j	3d0 <memmove+0x28>

0000000000000400 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 400:	1141                	addi	sp,sp,-16
 402:	e422                	sd	s0,8(sp)
 404:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 406:	ca05                	beqz	a2,436 <memcmp+0x36>
 408:	fff6069b          	addiw	a3,a2,-1
 40c:	1682                	slli	a3,a3,0x20
 40e:	9281                	srli	a3,a3,0x20
 410:	0685                	addi	a3,a3,1
 412:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 414:	00054783          	lbu	a5,0(a0)
 418:	0005c703          	lbu	a4,0(a1)
 41c:	00e79863          	bne	a5,a4,42c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 420:	0505                	addi	a0,a0,1
    p2++;
 422:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 424:	fed518e3          	bne	a0,a3,414 <memcmp+0x14>
  }
  return 0;
 428:	4501                	li	a0,0
 42a:	a019                	j	430 <memcmp+0x30>
      return *p1 - *p2;
 42c:	40e7853b          	subw	a0,a5,a4
}
 430:	6422                	ld	s0,8(sp)
 432:	0141                	addi	sp,sp,16
 434:	8082                	ret
  return 0;
 436:	4501                	li	a0,0
 438:	bfe5                	j	430 <memcmp+0x30>

000000000000043a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 43a:	1141                	addi	sp,sp,-16
 43c:	e406                	sd	ra,8(sp)
 43e:	e022                	sd	s0,0(sp)
 440:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 442:	00000097          	auipc	ra,0x0
 446:	f66080e7          	jalr	-154(ra) # 3a8 <memmove>
}
 44a:	60a2                	ld	ra,8(sp)
 44c:	6402                	ld	s0,0(sp)
 44e:	0141                	addi	sp,sp,16
 450:	8082                	ret

0000000000000452 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 452:	4885                	li	a7,1
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <exit>:
.global exit
exit:
 li a7, SYS_exit
 45a:	4889                	li	a7,2
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <wait>:
.global wait
wait:
 li a7, SYS_wait
 462:	488d                	li	a7,3
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 46a:	4891                	li	a7,4
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <read>:
.global read
read:
 li a7, SYS_read
 472:	4895                	li	a7,5
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <write>:
.global write
write:
 li a7, SYS_write
 47a:	48c1                	li	a7,16
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <close>:
.global close
close:
 li a7, SYS_close
 482:	48d5                	li	a7,21
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <kill>:
.global kill
kill:
 li a7, SYS_kill
 48a:	4899                	li	a7,6
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <exec>:
.global exec
exec:
 li a7, SYS_exec
 492:	489d                	li	a7,7
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <open>:
.global open
open:
 li a7, SYS_open
 49a:	48bd                	li	a7,15
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4a2:	48c5                	li	a7,17
 ecall
 4a4:	00000073          	ecall
 ret
 4a8:	8082                	ret

00000000000004aa <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4aa:	48c9                	li	a7,18
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4b2:	48a1                	li	a7,8
 ecall
 4b4:	00000073          	ecall
 ret
 4b8:	8082                	ret

00000000000004ba <link>:
.global link
link:
 li a7, SYS_link
 4ba:	48cd                	li	a7,19
 ecall
 4bc:	00000073          	ecall
 ret
 4c0:	8082                	ret

00000000000004c2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4c2:	48d1                	li	a7,20
 ecall
 4c4:	00000073          	ecall
 ret
 4c8:	8082                	ret

00000000000004ca <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4ca:	48a5                	li	a7,9
 ecall
 4cc:	00000073          	ecall
 ret
 4d0:	8082                	ret

00000000000004d2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4d2:	48a9                	li	a7,10
 ecall
 4d4:	00000073          	ecall
 ret
 4d8:	8082                	ret

00000000000004da <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4da:	48ad                	li	a7,11
 ecall
 4dc:	00000073          	ecall
 ret
 4e0:	8082                	ret

00000000000004e2 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4e2:	48b1                	li	a7,12
 ecall
 4e4:	00000073          	ecall
 ret
 4e8:	8082                	ret

00000000000004ea <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4ea:	48b5                	li	a7,13
 ecall
 4ec:	00000073          	ecall
 ret
 4f0:	8082                	ret

00000000000004f2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4f2:	48b9                	li	a7,14
 ecall
 4f4:	00000073          	ecall
 ret
 4f8:	8082                	ret

00000000000004fa <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4fa:	1101                	addi	sp,sp,-32
 4fc:	ec06                	sd	ra,24(sp)
 4fe:	e822                	sd	s0,16(sp)
 500:	1000                	addi	s0,sp,32
 502:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 506:	4605                	li	a2,1
 508:	fef40593          	addi	a1,s0,-17
 50c:	00000097          	auipc	ra,0x0
 510:	f6e080e7          	jalr	-146(ra) # 47a <write>
}
 514:	60e2                	ld	ra,24(sp)
 516:	6442                	ld	s0,16(sp)
 518:	6105                	addi	sp,sp,32
 51a:	8082                	ret

000000000000051c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 51c:	7139                	addi	sp,sp,-64
 51e:	fc06                	sd	ra,56(sp)
 520:	f822                	sd	s0,48(sp)
 522:	f426                	sd	s1,40(sp)
 524:	0080                	addi	s0,sp,64
 526:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 528:	c299                	beqz	a3,52e <printint+0x12>
 52a:	0805cb63          	bltz	a1,5c0 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 52e:	2581                	sext.w	a1,a1
  neg = 0;
 530:	4881                	li	a7,0
 532:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 536:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 538:	2601                	sext.w	a2,a2
 53a:	00000517          	auipc	a0,0x0
 53e:	4e650513          	addi	a0,a0,1254 # a20 <digits>
 542:	883a                	mv	a6,a4
 544:	2705                	addiw	a4,a4,1
 546:	02c5f7bb          	remuw	a5,a1,a2
 54a:	1782                	slli	a5,a5,0x20
 54c:	9381                	srli	a5,a5,0x20
 54e:	97aa                	add	a5,a5,a0
 550:	0007c783          	lbu	a5,0(a5)
 554:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 558:	0005879b          	sext.w	a5,a1
 55c:	02c5d5bb          	divuw	a1,a1,a2
 560:	0685                	addi	a3,a3,1
 562:	fec7f0e3          	bgeu	a5,a2,542 <printint+0x26>
  if(neg)
 566:	00088c63          	beqz	a7,57e <printint+0x62>
    buf[i++] = '-';
 56a:	fd070793          	addi	a5,a4,-48
 56e:	00878733          	add	a4,a5,s0
 572:	02d00793          	li	a5,45
 576:	fef70823          	sb	a5,-16(a4)
 57a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 57e:	02e05c63          	blez	a4,5b6 <printint+0x9a>
 582:	f04a                	sd	s2,32(sp)
 584:	ec4e                	sd	s3,24(sp)
 586:	fc040793          	addi	a5,s0,-64
 58a:	00e78933          	add	s2,a5,a4
 58e:	fff78993          	addi	s3,a5,-1
 592:	99ba                	add	s3,s3,a4
 594:	377d                	addiw	a4,a4,-1
 596:	1702                	slli	a4,a4,0x20
 598:	9301                	srli	a4,a4,0x20
 59a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 59e:	fff94583          	lbu	a1,-1(s2)
 5a2:	8526                	mv	a0,s1
 5a4:	00000097          	auipc	ra,0x0
 5a8:	f56080e7          	jalr	-170(ra) # 4fa <putc>
  while(--i >= 0)
 5ac:	197d                	addi	s2,s2,-1
 5ae:	ff3918e3          	bne	s2,s3,59e <printint+0x82>
 5b2:	7902                	ld	s2,32(sp)
 5b4:	69e2                	ld	s3,24(sp)
}
 5b6:	70e2                	ld	ra,56(sp)
 5b8:	7442                	ld	s0,48(sp)
 5ba:	74a2                	ld	s1,40(sp)
 5bc:	6121                	addi	sp,sp,64
 5be:	8082                	ret
    x = -xx;
 5c0:	40b005bb          	negw	a1,a1
    neg = 1;
 5c4:	4885                	li	a7,1
    x = -xx;
 5c6:	b7b5                	j	532 <printint+0x16>

00000000000005c8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5c8:	715d                	addi	sp,sp,-80
 5ca:	e486                	sd	ra,72(sp)
 5cc:	e0a2                	sd	s0,64(sp)
 5ce:	f84a                	sd	s2,48(sp)
 5d0:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5d2:	0005c903          	lbu	s2,0(a1)
 5d6:	1a090a63          	beqz	s2,78a <vprintf+0x1c2>
 5da:	fc26                	sd	s1,56(sp)
 5dc:	f44e                	sd	s3,40(sp)
 5de:	f052                	sd	s4,32(sp)
 5e0:	ec56                	sd	s5,24(sp)
 5e2:	e85a                	sd	s6,16(sp)
 5e4:	e45e                	sd	s7,8(sp)
 5e6:	8aaa                	mv	s5,a0
 5e8:	8bb2                	mv	s7,a2
 5ea:	00158493          	addi	s1,a1,1
  state = 0;
 5ee:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5f0:	02500a13          	li	s4,37
 5f4:	4b55                	li	s6,21
 5f6:	a839                	j	614 <vprintf+0x4c>
        putc(fd, c);
 5f8:	85ca                	mv	a1,s2
 5fa:	8556                	mv	a0,s5
 5fc:	00000097          	auipc	ra,0x0
 600:	efe080e7          	jalr	-258(ra) # 4fa <putc>
 604:	a019                	j	60a <vprintf+0x42>
    } else if(state == '%'){
 606:	01498d63          	beq	s3,s4,620 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 60a:	0485                	addi	s1,s1,1
 60c:	fff4c903          	lbu	s2,-1(s1)
 610:	16090763          	beqz	s2,77e <vprintf+0x1b6>
    if(state == 0){
 614:	fe0999e3          	bnez	s3,606 <vprintf+0x3e>
      if(c == '%'){
 618:	ff4910e3          	bne	s2,s4,5f8 <vprintf+0x30>
        state = '%';
 61c:	89d2                	mv	s3,s4
 61e:	b7f5                	j	60a <vprintf+0x42>
      if(c == 'd'){
 620:	13490463          	beq	s2,s4,748 <vprintf+0x180>
 624:	f9d9079b          	addiw	a5,s2,-99
 628:	0ff7f793          	zext.b	a5,a5
 62c:	12fb6763          	bltu	s6,a5,75a <vprintf+0x192>
 630:	f9d9079b          	addiw	a5,s2,-99
 634:	0ff7f713          	zext.b	a4,a5
 638:	12eb6163          	bltu	s6,a4,75a <vprintf+0x192>
 63c:	00271793          	slli	a5,a4,0x2
 640:	00000717          	auipc	a4,0x0
 644:	38870713          	addi	a4,a4,904 # 9c8 <malloc+0x14e>
 648:	97ba                	add	a5,a5,a4
 64a:	439c                	lw	a5,0(a5)
 64c:	97ba                	add	a5,a5,a4
 64e:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 650:	008b8913          	addi	s2,s7,8
 654:	4685                	li	a3,1
 656:	4629                	li	a2,10
 658:	000ba583          	lw	a1,0(s7)
 65c:	8556                	mv	a0,s5
 65e:	00000097          	auipc	ra,0x0
 662:	ebe080e7          	jalr	-322(ra) # 51c <printint>
 666:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 668:	4981                	li	s3,0
 66a:	b745                	j	60a <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 66c:	008b8913          	addi	s2,s7,8
 670:	4681                	li	a3,0
 672:	4629                	li	a2,10
 674:	000ba583          	lw	a1,0(s7)
 678:	8556                	mv	a0,s5
 67a:	00000097          	auipc	ra,0x0
 67e:	ea2080e7          	jalr	-350(ra) # 51c <printint>
 682:	8bca                	mv	s7,s2
      state = 0;
 684:	4981                	li	s3,0
 686:	b751                	j	60a <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 688:	008b8913          	addi	s2,s7,8
 68c:	4681                	li	a3,0
 68e:	4641                	li	a2,16
 690:	000ba583          	lw	a1,0(s7)
 694:	8556                	mv	a0,s5
 696:	00000097          	auipc	ra,0x0
 69a:	e86080e7          	jalr	-378(ra) # 51c <printint>
 69e:	8bca                	mv	s7,s2
      state = 0;
 6a0:	4981                	li	s3,0
 6a2:	b7a5                	j	60a <vprintf+0x42>
 6a4:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 6a6:	008b8c13          	addi	s8,s7,8
 6aa:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6ae:	03000593          	li	a1,48
 6b2:	8556                	mv	a0,s5
 6b4:	00000097          	auipc	ra,0x0
 6b8:	e46080e7          	jalr	-442(ra) # 4fa <putc>
  putc(fd, 'x');
 6bc:	07800593          	li	a1,120
 6c0:	8556                	mv	a0,s5
 6c2:	00000097          	auipc	ra,0x0
 6c6:	e38080e7          	jalr	-456(ra) # 4fa <putc>
 6ca:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6cc:	00000b97          	auipc	s7,0x0
 6d0:	354b8b93          	addi	s7,s7,852 # a20 <digits>
 6d4:	03c9d793          	srli	a5,s3,0x3c
 6d8:	97de                	add	a5,a5,s7
 6da:	0007c583          	lbu	a1,0(a5)
 6de:	8556                	mv	a0,s5
 6e0:	00000097          	auipc	ra,0x0
 6e4:	e1a080e7          	jalr	-486(ra) # 4fa <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6e8:	0992                	slli	s3,s3,0x4
 6ea:	397d                	addiw	s2,s2,-1
 6ec:	fe0914e3          	bnez	s2,6d4 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 6f0:	8be2                	mv	s7,s8
      state = 0;
 6f2:	4981                	li	s3,0
 6f4:	6c02                	ld	s8,0(sp)
 6f6:	bf11                	j	60a <vprintf+0x42>
        s = va_arg(ap, char*);
 6f8:	008b8993          	addi	s3,s7,8
 6fc:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 700:	02090163          	beqz	s2,722 <vprintf+0x15a>
        while(*s != 0){
 704:	00094583          	lbu	a1,0(s2)
 708:	c9a5                	beqz	a1,778 <vprintf+0x1b0>
          putc(fd, *s);
 70a:	8556                	mv	a0,s5
 70c:	00000097          	auipc	ra,0x0
 710:	dee080e7          	jalr	-530(ra) # 4fa <putc>
          s++;
 714:	0905                	addi	s2,s2,1
        while(*s != 0){
 716:	00094583          	lbu	a1,0(s2)
 71a:	f9e5                	bnez	a1,70a <vprintf+0x142>
        s = va_arg(ap, char*);
 71c:	8bce                	mv	s7,s3
      state = 0;
 71e:	4981                	li	s3,0
 720:	b5ed                	j	60a <vprintf+0x42>
          s = "(null)";
 722:	00000917          	auipc	s2,0x0
 726:	29e90913          	addi	s2,s2,670 # 9c0 <malloc+0x146>
        while(*s != 0){
 72a:	02800593          	li	a1,40
 72e:	bff1                	j	70a <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 730:	008b8913          	addi	s2,s7,8
 734:	000bc583          	lbu	a1,0(s7)
 738:	8556                	mv	a0,s5
 73a:	00000097          	auipc	ra,0x0
 73e:	dc0080e7          	jalr	-576(ra) # 4fa <putc>
 742:	8bca                	mv	s7,s2
      state = 0;
 744:	4981                	li	s3,0
 746:	b5d1                	j	60a <vprintf+0x42>
        putc(fd, c);
 748:	02500593          	li	a1,37
 74c:	8556                	mv	a0,s5
 74e:	00000097          	auipc	ra,0x0
 752:	dac080e7          	jalr	-596(ra) # 4fa <putc>
      state = 0;
 756:	4981                	li	s3,0
 758:	bd4d                	j	60a <vprintf+0x42>
        putc(fd, '%');
 75a:	02500593          	li	a1,37
 75e:	8556                	mv	a0,s5
 760:	00000097          	auipc	ra,0x0
 764:	d9a080e7          	jalr	-614(ra) # 4fa <putc>
        putc(fd, c);
 768:	85ca                	mv	a1,s2
 76a:	8556                	mv	a0,s5
 76c:	00000097          	auipc	ra,0x0
 770:	d8e080e7          	jalr	-626(ra) # 4fa <putc>
      state = 0;
 774:	4981                	li	s3,0
 776:	bd51                	j	60a <vprintf+0x42>
        s = va_arg(ap, char*);
 778:	8bce                	mv	s7,s3
      state = 0;
 77a:	4981                	li	s3,0
 77c:	b579                	j	60a <vprintf+0x42>
 77e:	74e2                	ld	s1,56(sp)
 780:	79a2                	ld	s3,40(sp)
 782:	7a02                	ld	s4,32(sp)
 784:	6ae2                	ld	s5,24(sp)
 786:	6b42                	ld	s6,16(sp)
 788:	6ba2                	ld	s7,8(sp)
    }
  }
}
 78a:	60a6                	ld	ra,72(sp)
 78c:	6406                	ld	s0,64(sp)
 78e:	7942                	ld	s2,48(sp)
 790:	6161                	addi	sp,sp,80
 792:	8082                	ret

0000000000000794 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 794:	715d                	addi	sp,sp,-80
 796:	ec06                	sd	ra,24(sp)
 798:	e822                	sd	s0,16(sp)
 79a:	1000                	addi	s0,sp,32
 79c:	e010                	sd	a2,0(s0)
 79e:	e414                	sd	a3,8(s0)
 7a0:	e818                	sd	a4,16(s0)
 7a2:	ec1c                	sd	a5,24(s0)
 7a4:	03043023          	sd	a6,32(s0)
 7a8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7ac:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7b0:	8622                	mv	a2,s0
 7b2:	00000097          	auipc	ra,0x0
 7b6:	e16080e7          	jalr	-490(ra) # 5c8 <vprintf>
}
 7ba:	60e2                	ld	ra,24(sp)
 7bc:	6442                	ld	s0,16(sp)
 7be:	6161                	addi	sp,sp,80
 7c0:	8082                	ret

00000000000007c2 <printf>:

void
printf(const char *fmt, ...)
{
 7c2:	711d                	addi	sp,sp,-96
 7c4:	ec06                	sd	ra,24(sp)
 7c6:	e822                	sd	s0,16(sp)
 7c8:	1000                	addi	s0,sp,32
 7ca:	e40c                	sd	a1,8(s0)
 7cc:	e810                	sd	a2,16(s0)
 7ce:	ec14                	sd	a3,24(s0)
 7d0:	f018                	sd	a4,32(s0)
 7d2:	f41c                	sd	a5,40(s0)
 7d4:	03043823          	sd	a6,48(s0)
 7d8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7dc:	00840613          	addi	a2,s0,8
 7e0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7e4:	85aa                	mv	a1,a0
 7e6:	4505                	li	a0,1
 7e8:	00000097          	auipc	ra,0x0
 7ec:	de0080e7          	jalr	-544(ra) # 5c8 <vprintf>
}
 7f0:	60e2                	ld	ra,24(sp)
 7f2:	6442                	ld	s0,16(sp)
 7f4:	6125                	addi	sp,sp,96
 7f6:	8082                	ret

00000000000007f8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7f8:	1141                	addi	sp,sp,-16
 7fa:	e422                	sd	s0,8(sp)
 7fc:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7fe:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 802:	00000797          	auipc	a5,0x0
 806:	7fe7b783          	ld	a5,2046(a5) # 1000 <freep>
 80a:	a02d                	j	834 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 80c:	4618                	lw	a4,8(a2)
 80e:	9f2d                	addw	a4,a4,a1
 810:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 814:	6398                	ld	a4,0(a5)
 816:	6310                	ld	a2,0(a4)
 818:	a83d                	j	856 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 81a:	ff852703          	lw	a4,-8(a0)
 81e:	9f31                	addw	a4,a4,a2
 820:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 822:	ff053683          	ld	a3,-16(a0)
 826:	a091                	j	86a <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 828:	6398                	ld	a4,0(a5)
 82a:	00e7e463          	bltu	a5,a4,832 <free+0x3a>
 82e:	00e6ea63          	bltu	a3,a4,842 <free+0x4a>
{
 832:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 834:	fed7fae3          	bgeu	a5,a3,828 <free+0x30>
 838:	6398                	ld	a4,0(a5)
 83a:	00e6e463          	bltu	a3,a4,842 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 83e:	fee7eae3          	bltu	a5,a4,832 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 842:	ff852583          	lw	a1,-8(a0)
 846:	6390                	ld	a2,0(a5)
 848:	02059813          	slli	a6,a1,0x20
 84c:	01c85713          	srli	a4,a6,0x1c
 850:	9736                	add	a4,a4,a3
 852:	fae60de3          	beq	a2,a4,80c <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 856:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 85a:	4790                	lw	a2,8(a5)
 85c:	02061593          	slli	a1,a2,0x20
 860:	01c5d713          	srli	a4,a1,0x1c
 864:	973e                	add	a4,a4,a5
 866:	fae68ae3          	beq	a3,a4,81a <free+0x22>
    p->s.ptr = bp->s.ptr;
 86a:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 86c:	00000717          	auipc	a4,0x0
 870:	78f73a23          	sd	a5,1940(a4) # 1000 <freep>
}
 874:	6422                	ld	s0,8(sp)
 876:	0141                	addi	sp,sp,16
 878:	8082                	ret

000000000000087a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 87a:	7139                	addi	sp,sp,-64
 87c:	fc06                	sd	ra,56(sp)
 87e:	f822                	sd	s0,48(sp)
 880:	f426                	sd	s1,40(sp)
 882:	ec4e                	sd	s3,24(sp)
 884:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 886:	02051493          	slli	s1,a0,0x20
 88a:	9081                	srli	s1,s1,0x20
 88c:	04bd                	addi	s1,s1,15
 88e:	8091                	srli	s1,s1,0x4
 890:	0014899b          	addiw	s3,s1,1
 894:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 896:	00000517          	auipc	a0,0x0
 89a:	76a53503          	ld	a0,1898(a0) # 1000 <freep>
 89e:	c915                	beqz	a0,8d2 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8a0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8a2:	4798                	lw	a4,8(a5)
 8a4:	08977e63          	bgeu	a4,s1,940 <malloc+0xc6>
 8a8:	f04a                	sd	s2,32(sp)
 8aa:	e852                	sd	s4,16(sp)
 8ac:	e456                	sd	s5,8(sp)
 8ae:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8b0:	8a4e                	mv	s4,s3
 8b2:	0009871b          	sext.w	a4,s3
 8b6:	6685                	lui	a3,0x1
 8b8:	00d77363          	bgeu	a4,a3,8be <malloc+0x44>
 8bc:	6a05                	lui	s4,0x1
 8be:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8c2:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8c6:	00000917          	auipc	s2,0x0
 8ca:	73a90913          	addi	s2,s2,1850 # 1000 <freep>
  if(p == (char*)-1)
 8ce:	5afd                	li	s5,-1
 8d0:	a091                	j	914 <malloc+0x9a>
 8d2:	f04a                	sd	s2,32(sp)
 8d4:	e852                	sd	s4,16(sp)
 8d6:	e456                	sd	s5,8(sp)
 8d8:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8da:	00000797          	auipc	a5,0x0
 8de:	77678793          	addi	a5,a5,1910 # 1050 <base>
 8e2:	00000717          	auipc	a4,0x0
 8e6:	70f73f23          	sd	a5,1822(a4) # 1000 <freep>
 8ea:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8ec:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8f0:	b7c1                	j	8b0 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 8f2:	6398                	ld	a4,0(a5)
 8f4:	e118                	sd	a4,0(a0)
 8f6:	a08d                	j	958 <malloc+0xde>
  hp->s.size = nu;
 8f8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8fc:	0541                	addi	a0,a0,16
 8fe:	00000097          	auipc	ra,0x0
 902:	efa080e7          	jalr	-262(ra) # 7f8 <free>
  return freep;
 906:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 90a:	c13d                	beqz	a0,970 <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 90c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 90e:	4798                	lw	a4,8(a5)
 910:	02977463          	bgeu	a4,s1,938 <malloc+0xbe>
    if(p == freep)
 914:	00093703          	ld	a4,0(s2)
 918:	853e                	mv	a0,a5
 91a:	fef719e3          	bne	a4,a5,90c <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 91e:	8552                	mv	a0,s4
 920:	00000097          	auipc	ra,0x0
 924:	bc2080e7          	jalr	-1086(ra) # 4e2 <sbrk>
  if(p == (char*)-1)
 928:	fd5518e3          	bne	a0,s5,8f8 <malloc+0x7e>
        return 0;
 92c:	4501                	li	a0,0
 92e:	7902                	ld	s2,32(sp)
 930:	6a42                	ld	s4,16(sp)
 932:	6aa2                	ld	s5,8(sp)
 934:	6b02                	ld	s6,0(sp)
 936:	a03d                	j	964 <malloc+0xea>
 938:	7902                	ld	s2,32(sp)
 93a:	6a42                	ld	s4,16(sp)
 93c:	6aa2                	ld	s5,8(sp)
 93e:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 940:	fae489e3          	beq	s1,a4,8f2 <malloc+0x78>
        p->s.size -= nunits;
 944:	4137073b          	subw	a4,a4,s3
 948:	c798                	sw	a4,8(a5)
        p += p->s.size;
 94a:	02071693          	slli	a3,a4,0x20
 94e:	01c6d713          	srli	a4,a3,0x1c
 952:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 954:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 958:	00000717          	auipc	a4,0x0
 95c:	6aa73423          	sd	a0,1704(a4) # 1000 <freep>
      return (void*)(p + 1);
 960:	01078513          	addi	a0,a5,16
  }
}
 964:	70e2                	ld	ra,56(sp)
 966:	7442                	ld	s0,48(sp)
 968:	74a2                	ld	s1,40(sp)
 96a:	69e2                	ld	s3,24(sp)
 96c:	6121                	addi	sp,sp,64
 96e:	8082                	ret
 970:	7902                	ld	s2,32(sp)
 972:	6a42                	ld	s4,16(sp)
 974:	6aa2                	ld	s5,8(sp)
 976:	6b02                	ld	s6,0(sp)
 978:	b7f5                	j	964 <malloc+0xea>
