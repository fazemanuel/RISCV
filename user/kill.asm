
user/_kill:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char **argv)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32
  int i;

  if(argc < 2){
   8:	4785                	li	a5,1
   a:	02a7df63          	bge	a5,a0,48 <main+0x48>
   e:	e426                	sd	s1,8(sp)
  10:	e04a                	sd	s2,0(sp)
  12:	00858493          	addi	s1,a1,8
  16:	ffe5091b          	addiw	s2,a0,-2
  1a:	02091793          	slli	a5,s2,0x20
  1e:	01d7d913          	srli	s2,a5,0x1d
  22:	05c1                	addi	a1,a1,16
  24:	992e                	add	s2,s2,a1
    fprintf(2, "usage: kill pid...\n");
    exit(1);
  }
  for(i=1; i<argc; i++)
    kill(atoi(argv[i]));
  26:	6088                	ld	a0,0(s1)
  28:	00000097          	auipc	ra,0x0
  2c:	1cc080e7          	jalr	460(ra) # 1f4 <atoi>
  30:	00000097          	auipc	ra,0x0
  34:	2ee080e7          	jalr	750(ra) # 31e <kill>
  for(i=1; i<argc; i++)
  38:	04a1                	addi	s1,s1,8
  3a:	ff2496e3          	bne	s1,s2,26 <main+0x26>
  exit(0);
  3e:	4501                	li	a0,0
  40:	00000097          	auipc	ra,0x0
  44:	2ae080e7          	jalr	686(ra) # 2ee <exit>
  48:	e426                	sd	s1,8(sp)
  4a:	e04a                	sd	s2,0(sp)
    fprintf(2, "usage: kill pid...\n");
  4c:	00000597          	auipc	a1,0x0
  50:	7c458593          	addi	a1,a1,1988 # 810 <malloc+0x102>
  54:	4509                	li	a0,2
  56:	00000097          	auipc	ra,0x0
  5a:	5d2080e7          	jalr	1490(ra) # 628 <fprintf>
    exit(1);
  5e:	4505                	li	a0,1
  60:	00000097          	auipc	ra,0x0
  64:	28e080e7          	jalr	654(ra) # 2ee <exit>

0000000000000068 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  68:	1141                	addi	sp,sp,-16
  6a:	e406                	sd	ra,8(sp)
  6c:	e022                	sd	s0,0(sp)
  6e:	0800                	addi	s0,sp,16
  extern int main();
  main();
  70:	00000097          	auipc	ra,0x0
  74:	f90080e7          	jalr	-112(ra) # 0 <main>
  exit(0);
  78:	4501                	li	a0,0
  7a:	00000097          	auipc	ra,0x0
  7e:	274080e7          	jalr	628(ra) # 2ee <exit>

0000000000000082 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  82:	1141                	addi	sp,sp,-16
  84:	e422                	sd	s0,8(sp)
  86:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  88:	87aa                	mv	a5,a0
  8a:	0585                	addi	a1,a1,1
  8c:	0785                	addi	a5,a5,1
  8e:	fff5c703          	lbu	a4,-1(a1)
  92:	fee78fa3          	sb	a4,-1(a5)
  96:	fb75                	bnez	a4,8a <strcpy+0x8>
    ;
  return os;
}
  98:	6422                	ld	s0,8(sp)
  9a:	0141                	addi	sp,sp,16
  9c:	8082                	ret

000000000000009e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  9e:	1141                	addi	sp,sp,-16
  a0:	e422                	sd	s0,8(sp)
  a2:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  a4:	00054783          	lbu	a5,0(a0)
  a8:	cb91                	beqz	a5,bc <strcmp+0x1e>
  aa:	0005c703          	lbu	a4,0(a1)
  ae:	00f71763          	bne	a4,a5,bc <strcmp+0x1e>
    p++, q++;
  b2:	0505                	addi	a0,a0,1
  b4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  b6:	00054783          	lbu	a5,0(a0)
  ba:	fbe5                	bnez	a5,aa <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  bc:	0005c503          	lbu	a0,0(a1)
}
  c0:	40a7853b          	subw	a0,a5,a0
  c4:	6422                	ld	s0,8(sp)
  c6:	0141                	addi	sp,sp,16
  c8:	8082                	ret

00000000000000ca <strlen>:

uint
strlen(const char *s)
{
  ca:	1141                	addi	sp,sp,-16
  cc:	e422                	sd	s0,8(sp)
  ce:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  d0:	00054783          	lbu	a5,0(a0)
  d4:	cf91                	beqz	a5,f0 <strlen+0x26>
  d6:	0505                	addi	a0,a0,1
  d8:	87aa                	mv	a5,a0
  da:	86be                	mv	a3,a5
  dc:	0785                	addi	a5,a5,1
  de:	fff7c703          	lbu	a4,-1(a5)
  e2:	ff65                	bnez	a4,da <strlen+0x10>
  e4:	40a6853b          	subw	a0,a3,a0
  e8:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  ea:	6422                	ld	s0,8(sp)
  ec:	0141                	addi	sp,sp,16
  ee:	8082                	ret
  for(n = 0; s[n]; n++)
  f0:	4501                	li	a0,0
  f2:	bfe5                	j	ea <strlen+0x20>

00000000000000f4 <memset>:

void*
memset(void *dst, int c, uint n)
{
  f4:	1141                	addi	sp,sp,-16
  f6:	e422                	sd	s0,8(sp)
  f8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  fa:	ca19                	beqz	a2,110 <memset+0x1c>
  fc:	87aa                	mv	a5,a0
  fe:	1602                	slli	a2,a2,0x20
 100:	9201                	srli	a2,a2,0x20
 102:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 106:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 10a:	0785                	addi	a5,a5,1
 10c:	fee79de3          	bne	a5,a4,106 <memset+0x12>
  }
  return dst;
}
 110:	6422                	ld	s0,8(sp)
 112:	0141                	addi	sp,sp,16
 114:	8082                	ret

0000000000000116 <strchr>:

char*
strchr(const char *s, char c)
{
 116:	1141                	addi	sp,sp,-16
 118:	e422                	sd	s0,8(sp)
 11a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 11c:	00054783          	lbu	a5,0(a0)
 120:	cb99                	beqz	a5,136 <strchr+0x20>
    if(*s == c)
 122:	00f58763          	beq	a1,a5,130 <strchr+0x1a>
  for(; *s; s++)
 126:	0505                	addi	a0,a0,1
 128:	00054783          	lbu	a5,0(a0)
 12c:	fbfd                	bnez	a5,122 <strchr+0xc>
      return (char*)s;
  return 0;
 12e:	4501                	li	a0,0
}
 130:	6422                	ld	s0,8(sp)
 132:	0141                	addi	sp,sp,16
 134:	8082                	ret
  return 0;
 136:	4501                	li	a0,0
 138:	bfe5                	j	130 <strchr+0x1a>

000000000000013a <gets>:

char*
gets(char *buf, int max)
{
 13a:	711d                	addi	sp,sp,-96
 13c:	ec86                	sd	ra,88(sp)
 13e:	e8a2                	sd	s0,80(sp)
 140:	e4a6                	sd	s1,72(sp)
 142:	e0ca                	sd	s2,64(sp)
 144:	fc4e                	sd	s3,56(sp)
 146:	f852                	sd	s4,48(sp)
 148:	f456                	sd	s5,40(sp)
 14a:	f05a                	sd	s6,32(sp)
 14c:	ec5e                	sd	s7,24(sp)
 14e:	1080                	addi	s0,sp,96
 150:	8baa                	mv	s7,a0
 152:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 154:	892a                	mv	s2,a0
 156:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 158:	4aa9                	li	s5,10
 15a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 15c:	89a6                	mv	s3,s1
 15e:	2485                	addiw	s1,s1,1
 160:	0344d863          	bge	s1,s4,190 <gets+0x56>
    cc = read(0, &c, 1);
 164:	4605                	li	a2,1
 166:	faf40593          	addi	a1,s0,-81
 16a:	4501                	li	a0,0
 16c:	00000097          	auipc	ra,0x0
 170:	19a080e7          	jalr	410(ra) # 306 <read>
    if(cc < 1)
 174:	00a05e63          	blez	a0,190 <gets+0x56>
    buf[i++] = c;
 178:	faf44783          	lbu	a5,-81(s0)
 17c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 180:	01578763          	beq	a5,s5,18e <gets+0x54>
 184:	0905                	addi	s2,s2,1
 186:	fd679be3          	bne	a5,s6,15c <gets+0x22>
    buf[i++] = c;
 18a:	89a6                	mv	s3,s1
 18c:	a011                	j	190 <gets+0x56>
 18e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 190:	99de                	add	s3,s3,s7
 192:	00098023          	sb	zero,0(s3)
  return buf;
}
 196:	855e                	mv	a0,s7
 198:	60e6                	ld	ra,88(sp)
 19a:	6446                	ld	s0,80(sp)
 19c:	64a6                	ld	s1,72(sp)
 19e:	6906                	ld	s2,64(sp)
 1a0:	79e2                	ld	s3,56(sp)
 1a2:	7a42                	ld	s4,48(sp)
 1a4:	7aa2                	ld	s5,40(sp)
 1a6:	7b02                	ld	s6,32(sp)
 1a8:	6be2                	ld	s7,24(sp)
 1aa:	6125                	addi	sp,sp,96
 1ac:	8082                	ret

00000000000001ae <stat>:

int
stat(const char *n, struct stat *st)
{
 1ae:	1101                	addi	sp,sp,-32
 1b0:	ec06                	sd	ra,24(sp)
 1b2:	e822                	sd	s0,16(sp)
 1b4:	e04a                	sd	s2,0(sp)
 1b6:	1000                	addi	s0,sp,32
 1b8:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1ba:	4581                	li	a1,0
 1bc:	00000097          	auipc	ra,0x0
 1c0:	172080e7          	jalr	370(ra) # 32e <open>
  if(fd < 0)
 1c4:	02054663          	bltz	a0,1f0 <stat+0x42>
 1c8:	e426                	sd	s1,8(sp)
 1ca:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1cc:	85ca                	mv	a1,s2
 1ce:	00000097          	auipc	ra,0x0
 1d2:	178080e7          	jalr	376(ra) # 346 <fstat>
 1d6:	892a                	mv	s2,a0
  close(fd);
 1d8:	8526                	mv	a0,s1
 1da:	00000097          	auipc	ra,0x0
 1de:	13c080e7          	jalr	316(ra) # 316 <close>
  return r;
 1e2:	64a2                	ld	s1,8(sp)
}
 1e4:	854a                	mv	a0,s2
 1e6:	60e2                	ld	ra,24(sp)
 1e8:	6442                	ld	s0,16(sp)
 1ea:	6902                	ld	s2,0(sp)
 1ec:	6105                	addi	sp,sp,32
 1ee:	8082                	ret
    return -1;
 1f0:	597d                	li	s2,-1
 1f2:	bfcd                	j	1e4 <stat+0x36>

00000000000001f4 <atoi>:

int
atoi(const char *s)
{
 1f4:	1141                	addi	sp,sp,-16
 1f6:	e422                	sd	s0,8(sp)
 1f8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1fa:	00054683          	lbu	a3,0(a0)
 1fe:	fd06879b          	addiw	a5,a3,-48
 202:	0ff7f793          	zext.b	a5,a5
 206:	4625                	li	a2,9
 208:	02f66863          	bltu	a2,a5,238 <atoi+0x44>
 20c:	872a                	mv	a4,a0
  n = 0;
 20e:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 210:	0705                	addi	a4,a4,1
 212:	0025179b          	slliw	a5,a0,0x2
 216:	9fa9                	addw	a5,a5,a0
 218:	0017979b          	slliw	a5,a5,0x1
 21c:	9fb5                	addw	a5,a5,a3
 21e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 222:	00074683          	lbu	a3,0(a4)
 226:	fd06879b          	addiw	a5,a3,-48
 22a:	0ff7f793          	zext.b	a5,a5
 22e:	fef671e3          	bgeu	a2,a5,210 <atoi+0x1c>
  return n;
}
 232:	6422                	ld	s0,8(sp)
 234:	0141                	addi	sp,sp,16
 236:	8082                	ret
  n = 0;
 238:	4501                	li	a0,0
 23a:	bfe5                	j	232 <atoi+0x3e>

000000000000023c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 23c:	1141                	addi	sp,sp,-16
 23e:	e422                	sd	s0,8(sp)
 240:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 242:	02b57463          	bgeu	a0,a1,26a <memmove+0x2e>
    while(n-- > 0)
 246:	00c05f63          	blez	a2,264 <memmove+0x28>
 24a:	1602                	slli	a2,a2,0x20
 24c:	9201                	srli	a2,a2,0x20
 24e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 252:	872a                	mv	a4,a0
      *dst++ = *src++;
 254:	0585                	addi	a1,a1,1
 256:	0705                	addi	a4,a4,1
 258:	fff5c683          	lbu	a3,-1(a1)
 25c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 260:	fef71ae3          	bne	a4,a5,254 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 264:	6422                	ld	s0,8(sp)
 266:	0141                	addi	sp,sp,16
 268:	8082                	ret
    dst += n;
 26a:	00c50733          	add	a4,a0,a2
    src += n;
 26e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 270:	fec05ae3          	blez	a2,264 <memmove+0x28>
 274:	fff6079b          	addiw	a5,a2,-1
 278:	1782                	slli	a5,a5,0x20
 27a:	9381                	srli	a5,a5,0x20
 27c:	fff7c793          	not	a5,a5
 280:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 282:	15fd                	addi	a1,a1,-1
 284:	177d                	addi	a4,a4,-1
 286:	0005c683          	lbu	a3,0(a1)
 28a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 28e:	fee79ae3          	bne	a5,a4,282 <memmove+0x46>
 292:	bfc9                	j	264 <memmove+0x28>

0000000000000294 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 294:	1141                	addi	sp,sp,-16
 296:	e422                	sd	s0,8(sp)
 298:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 29a:	ca05                	beqz	a2,2ca <memcmp+0x36>
 29c:	fff6069b          	addiw	a3,a2,-1
 2a0:	1682                	slli	a3,a3,0x20
 2a2:	9281                	srli	a3,a3,0x20
 2a4:	0685                	addi	a3,a3,1
 2a6:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2a8:	00054783          	lbu	a5,0(a0)
 2ac:	0005c703          	lbu	a4,0(a1)
 2b0:	00e79863          	bne	a5,a4,2c0 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2b4:	0505                	addi	a0,a0,1
    p2++;
 2b6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2b8:	fed518e3          	bne	a0,a3,2a8 <memcmp+0x14>
  }
  return 0;
 2bc:	4501                	li	a0,0
 2be:	a019                	j	2c4 <memcmp+0x30>
      return *p1 - *p2;
 2c0:	40e7853b          	subw	a0,a5,a4
}
 2c4:	6422                	ld	s0,8(sp)
 2c6:	0141                	addi	sp,sp,16
 2c8:	8082                	ret
  return 0;
 2ca:	4501                	li	a0,0
 2cc:	bfe5                	j	2c4 <memcmp+0x30>

00000000000002ce <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2ce:	1141                	addi	sp,sp,-16
 2d0:	e406                	sd	ra,8(sp)
 2d2:	e022                	sd	s0,0(sp)
 2d4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2d6:	00000097          	auipc	ra,0x0
 2da:	f66080e7          	jalr	-154(ra) # 23c <memmove>
}
 2de:	60a2                	ld	ra,8(sp)
 2e0:	6402                	ld	s0,0(sp)
 2e2:	0141                	addi	sp,sp,16
 2e4:	8082                	ret

00000000000002e6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2e6:	4885                	li	a7,1
 ecall
 2e8:	00000073          	ecall
 ret
 2ec:	8082                	ret

00000000000002ee <exit>:
.global exit
exit:
 li a7, SYS_exit
 2ee:	4889                	li	a7,2
 ecall
 2f0:	00000073          	ecall
 ret
 2f4:	8082                	ret

00000000000002f6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2f6:	488d                	li	a7,3
 ecall
 2f8:	00000073          	ecall
 ret
 2fc:	8082                	ret

00000000000002fe <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2fe:	4891                	li	a7,4
 ecall
 300:	00000073          	ecall
 ret
 304:	8082                	ret

0000000000000306 <read>:
.global read
read:
 li a7, SYS_read
 306:	4895                	li	a7,5
 ecall
 308:	00000073          	ecall
 ret
 30c:	8082                	ret

000000000000030e <write>:
.global write
write:
 li a7, SYS_write
 30e:	48c1                	li	a7,16
 ecall
 310:	00000073          	ecall
 ret
 314:	8082                	ret

0000000000000316 <close>:
.global close
close:
 li a7, SYS_close
 316:	48d5                	li	a7,21
 ecall
 318:	00000073          	ecall
 ret
 31c:	8082                	ret

000000000000031e <kill>:
.global kill
kill:
 li a7, SYS_kill
 31e:	4899                	li	a7,6
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <exec>:
.global exec
exec:
 li a7, SYS_exec
 326:	489d                	li	a7,7
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <open>:
.global open
open:
 li a7, SYS_open
 32e:	48bd                	li	a7,15
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 336:	48c5                	li	a7,17
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 33e:	48c9                	li	a7,18
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 346:	48a1                	li	a7,8
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <link>:
.global link
link:
 li a7, SYS_link
 34e:	48cd                	li	a7,19
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 356:	48d1                	li	a7,20
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 35e:	48a5                	li	a7,9
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <dup>:
.global dup
dup:
 li a7, SYS_dup
 366:	48a9                	li	a7,10
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 36e:	48ad                	li	a7,11
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 376:	48b1                	li	a7,12
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 37e:	48b5                	li	a7,13
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 386:	48b9                	li	a7,14
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 38e:	1101                	addi	sp,sp,-32
 390:	ec06                	sd	ra,24(sp)
 392:	e822                	sd	s0,16(sp)
 394:	1000                	addi	s0,sp,32
 396:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 39a:	4605                	li	a2,1
 39c:	fef40593          	addi	a1,s0,-17
 3a0:	00000097          	auipc	ra,0x0
 3a4:	f6e080e7          	jalr	-146(ra) # 30e <write>
}
 3a8:	60e2                	ld	ra,24(sp)
 3aa:	6442                	ld	s0,16(sp)
 3ac:	6105                	addi	sp,sp,32
 3ae:	8082                	ret

00000000000003b0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3b0:	7139                	addi	sp,sp,-64
 3b2:	fc06                	sd	ra,56(sp)
 3b4:	f822                	sd	s0,48(sp)
 3b6:	f426                	sd	s1,40(sp)
 3b8:	0080                	addi	s0,sp,64
 3ba:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3bc:	c299                	beqz	a3,3c2 <printint+0x12>
 3be:	0805cb63          	bltz	a1,454 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3c2:	2581                	sext.w	a1,a1
  neg = 0;
 3c4:	4881                	li	a7,0
 3c6:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3ca:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3cc:	2601                	sext.w	a2,a2
 3ce:	00000517          	auipc	a0,0x0
 3d2:	4ba50513          	addi	a0,a0,1210 # 888 <digits>
 3d6:	883a                	mv	a6,a4
 3d8:	2705                	addiw	a4,a4,1
 3da:	02c5f7bb          	remuw	a5,a1,a2
 3de:	1782                	slli	a5,a5,0x20
 3e0:	9381                	srli	a5,a5,0x20
 3e2:	97aa                	add	a5,a5,a0
 3e4:	0007c783          	lbu	a5,0(a5)
 3e8:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3ec:	0005879b          	sext.w	a5,a1
 3f0:	02c5d5bb          	divuw	a1,a1,a2
 3f4:	0685                	addi	a3,a3,1
 3f6:	fec7f0e3          	bgeu	a5,a2,3d6 <printint+0x26>
  if(neg)
 3fa:	00088c63          	beqz	a7,412 <printint+0x62>
    buf[i++] = '-';
 3fe:	fd070793          	addi	a5,a4,-48
 402:	00878733          	add	a4,a5,s0
 406:	02d00793          	li	a5,45
 40a:	fef70823          	sb	a5,-16(a4)
 40e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 412:	02e05c63          	blez	a4,44a <printint+0x9a>
 416:	f04a                	sd	s2,32(sp)
 418:	ec4e                	sd	s3,24(sp)
 41a:	fc040793          	addi	a5,s0,-64
 41e:	00e78933          	add	s2,a5,a4
 422:	fff78993          	addi	s3,a5,-1
 426:	99ba                	add	s3,s3,a4
 428:	377d                	addiw	a4,a4,-1
 42a:	1702                	slli	a4,a4,0x20
 42c:	9301                	srli	a4,a4,0x20
 42e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 432:	fff94583          	lbu	a1,-1(s2)
 436:	8526                	mv	a0,s1
 438:	00000097          	auipc	ra,0x0
 43c:	f56080e7          	jalr	-170(ra) # 38e <putc>
  while(--i >= 0)
 440:	197d                	addi	s2,s2,-1
 442:	ff3918e3          	bne	s2,s3,432 <printint+0x82>
 446:	7902                	ld	s2,32(sp)
 448:	69e2                	ld	s3,24(sp)
}
 44a:	70e2                	ld	ra,56(sp)
 44c:	7442                	ld	s0,48(sp)
 44e:	74a2                	ld	s1,40(sp)
 450:	6121                	addi	sp,sp,64
 452:	8082                	ret
    x = -xx;
 454:	40b005bb          	negw	a1,a1
    neg = 1;
 458:	4885                	li	a7,1
    x = -xx;
 45a:	b7b5                	j	3c6 <printint+0x16>

000000000000045c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 45c:	715d                	addi	sp,sp,-80
 45e:	e486                	sd	ra,72(sp)
 460:	e0a2                	sd	s0,64(sp)
 462:	f84a                	sd	s2,48(sp)
 464:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 466:	0005c903          	lbu	s2,0(a1)
 46a:	1a090a63          	beqz	s2,61e <vprintf+0x1c2>
 46e:	fc26                	sd	s1,56(sp)
 470:	f44e                	sd	s3,40(sp)
 472:	f052                	sd	s4,32(sp)
 474:	ec56                	sd	s5,24(sp)
 476:	e85a                	sd	s6,16(sp)
 478:	e45e                	sd	s7,8(sp)
 47a:	8aaa                	mv	s5,a0
 47c:	8bb2                	mv	s7,a2
 47e:	00158493          	addi	s1,a1,1
  state = 0;
 482:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 484:	02500a13          	li	s4,37
 488:	4b55                	li	s6,21
 48a:	a839                	j	4a8 <vprintf+0x4c>
        putc(fd, c);
 48c:	85ca                	mv	a1,s2
 48e:	8556                	mv	a0,s5
 490:	00000097          	auipc	ra,0x0
 494:	efe080e7          	jalr	-258(ra) # 38e <putc>
 498:	a019                	j	49e <vprintf+0x42>
    } else if(state == '%'){
 49a:	01498d63          	beq	s3,s4,4b4 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 49e:	0485                	addi	s1,s1,1
 4a0:	fff4c903          	lbu	s2,-1(s1)
 4a4:	16090763          	beqz	s2,612 <vprintf+0x1b6>
    if(state == 0){
 4a8:	fe0999e3          	bnez	s3,49a <vprintf+0x3e>
      if(c == '%'){
 4ac:	ff4910e3          	bne	s2,s4,48c <vprintf+0x30>
        state = '%';
 4b0:	89d2                	mv	s3,s4
 4b2:	b7f5                	j	49e <vprintf+0x42>
      if(c == 'd'){
 4b4:	13490463          	beq	s2,s4,5dc <vprintf+0x180>
 4b8:	f9d9079b          	addiw	a5,s2,-99
 4bc:	0ff7f793          	zext.b	a5,a5
 4c0:	12fb6763          	bltu	s6,a5,5ee <vprintf+0x192>
 4c4:	f9d9079b          	addiw	a5,s2,-99
 4c8:	0ff7f713          	zext.b	a4,a5
 4cc:	12eb6163          	bltu	s6,a4,5ee <vprintf+0x192>
 4d0:	00271793          	slli	a5,a4,0x2
 4d4:	00000717          	auipc	a4,0x0
 4d8:	35c70713          	addi	a4,a4,860 # 830 <malloc+0x122>
 4dc:	97ba                	add	a5,a5,a4
 4de:	439c                	lw	a5,0(a5)
 4e0:	97ba                	add	a5,a5,a4
 4e2:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 4e4:	008b8913          	addi	s2,s7,8
 4e8:	4685                	li	a3,1
 4ea:	4629                	li	a2,10
 4ec:	000ba583          	lw	a1,0(s7)
 4f0:	8556                	mv	a0,s5
 4f2:	00000097          	auipc	ra,0x0
 4f6:	ebe080e7          	jalr	-322(ra) # 3b0 <printint>
 4fa:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 4fc:	4981                	li	s3,0
 4fe:	b745                	j	49e <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 500:	008b8913          	addi	s2,s7,8
 504:	4681                	li	a3,0
 506:	4629                	li	a2,10
 508:	000ba583          	lw	a1,0(s7)
 50c:	8556                	mv	a0,s5
 50e:	00000097          	auipc	ra,0x0
 512:	ea2080e7          	jalr	-350(ra) # 3b0 <printint>
 516:	8bca                	mv	s7,s2
      state = 0;
 518:	4981                	li	s3,0
 51a:	b751                	j	49e <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 51c:	008b8913          	addi	s2,s7,8
 520:	4681                	li	a3,0
 522:	4641                	li	a2,16
 524:	000ba583          	lw	a1,0(s7)
 528:	8556                	mv	a0,s5
 52a:	00000097          	auipc	ra,0x0
 52e:	e86080e7          	jalr	-378(ra) # 3b0 <printint>
 532:	8bca                	mv	s7,s2
      state = 0;
 534:	4981                	li	s3,0
 536:	b7a5                	j	49e <vprintf+0x42>
 538:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 53a:	008b8c13          	addi	s8,s7,8
 53e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 542:	03000593          	li	a1,48
 546:	8556                	mv	a0,s5
 548:	00000097          	auipc	ra,0x0
 54c:	e46080e7          	jalr	-442(ra) # 38e <putc>
  putc(fd, 'x');
 550:	07800593          	li	a1,120
 554:	8556                	mv	a0,s5
 556:	00000097          	auipc	ra,0x0
 55a:	e38080e7          	jalr	-456(ra) # 38e <putc>
 55e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 560:	00000b97          	auipc	s7,0x0
 564:	328b8b93          	addi	s7,s7,808 # 888 <digits>
 568:	03c9d793          	srli	a5,s3,0x3c
 56c:	97de                	add	a5,a5,s7
 56e:	0007c583          	lbu	a1,0(a5)
 572:	8556                	mv	a0,s5
 574:	00000097          	auipc	ra,0x0
 578:	e1a080e7          	jalr	-486(ra) # 38e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 57c:	0992                	slli	s3,s3,0x4
 57e:	397d                	addiw	s2,s2,-1
 580:	fe0914e3          	bnez	s2,568 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 584:	8be2                	mv	s7,s8
      state = 0;
 586:	4981                	li	s3,0
 588:	6c02                	ld	s8,0(sp)
 58a:	bf11                	j	49e <vprintf+0x42>
        s = va_arg(ap, char*);
 58c:	008b8993          	addi	s3,s7,8
 590:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 594:	02090163          	beqz	s2,5b6 <vprintf+0x15a>
        while(*s != 0){
 598:	00094583          	lbu	a1,0(s2)
 59c:	c9a5                	beqz	a1,60c <vprintf+0x1b0>
          putc(fd, *s);
 59e:	8556                	mv	a0,s5
 5a0:	00000097          	auipc	ra,0x0
 5a4:	dee080e7          	jalr	-530(ra) # 38e <putc>
          s++;
 5a8:	0905                	addi	s2,s2,1
        while(*s != 0){
 5aa:	00094583          	lbu	a1,0(s2)
 5ae:	f9e5                	bnez	a1,59e <vprintf+0x142>
        s = va_arg(ap, char*);
 5b0:	8bce                	mv	s7,s3
      state = 0;
 5b2:	4981                	li	s3,0
 5b4:	b5ed                	j	49e <vprintf+0x42>
          s = "(null)";
 5b6:	00000917          	auipc	s2,0x0
 5ba:	27290913          	addi	s2,s2,626 # 828 <malloc+0x11a>
        while(*s != 0){
 5be:	02800593          	li	a1,40
 5c2:	bff1                	j	59e <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 5c4:	008b8913          	addi	s2,s7,8
 5c8:	000bc583          	lbu	a1,0(s7)
 5cc:	8556                	mv	a0,s5
 5ce:	00000097          	auipc	ra,0x0
 5d2:	dc0080e7          	jalr	-576(ra) # 38e <putc>
 5d6:	8bca                	mv	s7,s2
      state = 0;
 5d8:	4981                	li	s3,0
 5da:	b5d1                	j	49e <vprintf+0x42>
        putc(fd, c);
 5dc:	02500593          	li	a1,37
 5e0:	8556                	mv	a0,s5
 5e2:	00000097          	auipc	ra,0x0
 5e6:	dac080e7          	jalr	-596(ra) # 38e <putc>
      state = 0;
 5ea:	4981                	li	s3,0
 5ec:	bd4d                	j	49e <vprintf+0x42>
        putc(fd, '%');
 5ee:	02500593          	li	a1,37
 5f2:	8556                	mv	a0,s5
 5f4:	00000097          	auipc	ra,0x0
 5f8:	d9a080e7          	jalr	-614(ra) # 38e <putc>
        putc(fd, c);
 5fc:	85ca                	mv	a1,s2
 5fe:	8556                	mv	a0,s5
 600:	00000097          	auipc	ra,0x0
 604:	d8e080e7          	jalr	-626(ra) # 38e <putc>
      state = 0;
 608:	4981                	li	s3,0
 60a:	bd51                	j	49e <vprintf+0x42>
        s = va_arg(ap, char*);
 60c:	8bce                	mv	s7,s3
      state = 0;
 60e:	4981                	li	s3,0
 610:	b579                	j	49e <vprintf+0x42>
 612:	74e2                	ld	s1,56(sp)
 614:	79a2                	ld	s3,40(sp)
 616:	7a02                	ld	s4,32(sp)
 618:	6ae2                	ld	s5,24(sp)
 61a:	6b42                	ld	s6,16(sp)
 61c:	6ba2                	ld	s7,8(sp)
    }
  }
}
 61e:	60a6                	ld	ra,72(sp)
 620:	6406                	ld	s0,64(sp)
 622:	7942                	ld	s2,48(sp)
 624:	6161                	addi	sp,sp,80
 626:	8082                	ret

0000000000000628 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 628:	715d                	addi	sp,sp,-80
 62a:	ec06                	sd	ra,24(sp)
 62c:	e822                	sd	s0,16(sp)
 62e:	1000                	addi	s0,sp,32
 630:	e010                	sd	a2,0(s0)
 632:	e414                	sd	a3,8(s0)
 634:	e818                	sd	a4,16(s0)
 636:	ec1c                	sd	a5,24(s0)
 638:	03043023          	sd	a6,32(s0)
 63c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 640:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 644:	8622                	mv	a2,s0
 646:	00000097          	auipc	ra,0x0
 64a:	e16080e7          	jalr	-490(ra) # 45c <vprintf>
}
 64e:	60e2                	ld	ra,24(sp)
 650:	6442                	ld	s0,16(sp)
 652:	6161                	addi	sp,sp,80
 654:	8082                	ret

0000000000000656 <printf>:

void
printf(const char *fmt, ...)
{
 656:	711d                	addi	sp,sp,-96
 658:	ec06                	sd	ra,24(sp)
 65a:	e822                	sd	s0,16(sp)
 65c:	1000                	addi	s0,sp,32
 65e:	e40c                	sd	a1,8(s0)
 660:	e810                	sd	a2,16(s0)
 662:	ec14                	sd	a3,24(s0)
 664:	f018                	sd	a4,32(s0)
 666:	f41c                	sd	a5,40(s0)
 668:	03043823          	sd	a6,48(s0)
 66c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 670:	00840613          	addi	a2,s0,8
 674:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 678:	85aa                	mv	a1,a0
 67a:	4505                	li	a0,1
 67c:	00000097          	auipc	ra,0x0
 680:	de0080e7          	jalr	-544(ra) # 45c <vprintf>
}
 684:	60e2                	ld	ra,24(sp)
 686:	6442                	ld	s0,16(sp)
 688:	6125                	addi	sp,sp,96
 68a:	8082                	ret

000000000000068c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 68c:	1141                	addi	sp,sp,-16
 68e:	e422                	sd	s0,8(sp)
 690:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 692:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 696:	00001797          	auipc	a5,0x1
 69a:	96a7b783          	ld	a5,-1686(a5) # 1000 <freep>
 69e:	a02d                	j	6c8 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6a0:	4618                	lw	a4,8(a2)
 6a2:	9f2d                	addw	a4,a4,a1
 6a4:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6a8:	6398                	ld	a4,0(a5)
 6aa:	6310                	ld	a2,0(a4)
 6ac:	a83d                	j	6ea <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6ae:	ff852703          	lw	a4,-8(a0)
 6b2:	9f31                	addw	a4,a4,a2
 6b4:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 6b6:	ff053683          	ld	a3,-16(a0)
 6ba:	a091                	j	6fe <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6bc:	6398                	ld	a4,0(a5)
 6be:	00e7e463          	bltu	a5,a4,6c6 <free+0x3a>
 6c2:	00e6ea63          	bltu	a3,a4,6d6 <free+0x4a>
{
 6c6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6c8:	fed7fae3          	bgeu	a5,a3,6bc <free+0x30>
 6cc:	6398                	ld	a4,0(a5)
 6ce:	00e6e463          	bltu	a3,a4,6d6 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6d2:	fee7eae3          	bltu	a5,a4,6c6 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 6d6:	ff852583          	lw	a1,-8(a0)
 6da:	6390                	ld	a2,0(a5)
 6dc:	02059813          	slli	a6,a1,0x20
 6e0:	01c85713          	srli	a4,a6,0x1c
 6e4:	9736                	add	a4,a4,a3
 6e6:	fae60de3          	beq	a2,a4,6a0 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 6ea:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6ee:	4790                	lw	a2,8(a5)
 6f0:	02061593          	slli	a1,a2,0x20
 6f4:	01c5d713          	srli	a4,a1,0x1c
 6f8:	973e                	add	a4,a4,a5
 6fa:	fae68ae3          	beq	a3,a4,6ae <free+0x22>
    p->s.ptr = bp->s.ptr;
 6fe:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 700:	00001717          	auipc	a4,0x1
 704:	90f73023          	sd	a5,-1792(a4) # 1000 <freep>
}
 708:	6422                	ld	s0,8(sp)
 70a:	0141                	addi	sp,sp,16
 70c:	8082                	ret

000000000000070e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 70e:	7139                	addi	sp,sp,-64
 710:	fc06                	sd	ra,56(sp)
 712:	f822                	sd	s0,48(sp)
 714:	f426                	sd	s1,40(sp)
 716:	ec4e                	sd	s3,24(sp)
 718:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 71a:	02051493          	slli	s1,a0,0x20
 71e:	9081                	srli	s1,s1,0x20
 720:	04bd                	addi	s1,s1,15
 722:	8091                	srli	s1,s1,0x4
 724:	0014899b          	addiw	s3,s1,1
 728:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 72a:	00001517          	auipc	a0,0x1
 72e:	8d653503          	ld	a0,-1834(a0) # 1000 <freep>
 732:	c915                	beqz	a0,766 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 734:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 736:	4798                	lw	a4,8(a5)
 738:	08977e63          	bgeu	a4,s1,7d4 <malloc+0xc6>
 73c:	f04a                	sd	s2,32(sp)
 73e:	e852                	sd	s4,16(sp)
 740:	e456                	sd	s5,8(sp)
 742:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 744:	8a4e                	mv	s4,s3
 746:	0009871b          	sext.w	a4,s3
 74a:	6685                	lui	a3,0x1
 74c:	00d77363          	bgeu	a4,a3,752 <malloc+0x44>
 750:	6a05                	lui	s4,0x1
 752:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 756:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 75a:	00001917          	auipc	s2,0x1
 75e:	8a690913          	addi	s2,s2,-1882 # 1000 <freep>
  if(p == (char*)-1)
 762:	5afd                	li	s5,-1
 764:	a091                	j	7a8 <malloc+0x9a>
 766:	f04a                	sd	s2,32(sp)
 768:	e852                	sd	s4,16(sp)
 76a:	e456                	sd	s5,8(sp)
 76c:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 76e:	00001797          	auipc	a5,0x1
 772:	8a278793          	addi	a5,a5,-1886 # 1010 <base>
 776:	00001717          	auipc	a4,0x1
 77a:	88f73523          	sd	a5,-1910(a4) # 1000 <freep>
 77e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 780:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 784:	b7c1                	j	744 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 786:	6398                	ld	a4,0(a5)
 788:	e118                	sd	a4,0(a0)
 78a:	a08d                	j	7ec <malloc+0xde>
  hp->s.size = nu;
 78c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 790:	0541                	addi	a0,a0,16
 792:	00000097          	auipc	ra,0x0
 796:	efa080e7          	jalr	-262(ra) # 68c <free>
  return freep;
 79a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 79e:	c13d                	beqz	a0,804 <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7a0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7a2:	4798                	lw	a4,8(a5)
 7a4:	02977463          	bgeu	a4,s1,7cc <malloc+0xbe>
    if(p == freep)
 7a8:	00093703          	ld	a4,0(s2)
 7ac:	853e                	mv	a0,a5
 7ae:	fef719e3          	bne	a4,a5,7a0 <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 7b2:	8552                	mv	a0,s4
 7b4:	00000097          	auipc	ra,0x0
 7b8:	bc2080e7          	jalr	-1086(ra) # 376 <sbrk>
  if(p == (char*)-1)
 7bc:	fd5518e3          	bne	a0,s5,78c <malloc+0x7e>
        return 0;
 7c0:	4501                	li	a0,0
 7c2:	7902                	ld	s2,32(sp)
 7c4:	6a42                	ld	s4,16(sp)
 7c6:	6aa2                	ld	s5,8(sp)
 7c8:	6b02                	ld	s6,0(sp)
 7ca:	a03d                	j	7f8 <malloc+0xea>
 7cc:	7902                	ld	s2,32(sp)
 7ce:	6a42                	ld	s4,16(sp)
 7d0:	6aa2                	ld	s5,8(sp)
 7d2:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 7d4:	fae489e3          	beq	s1,a4,786 <malloc+0x78>
        p->s.size -= nunits;
 7d8:	4137073b          	subw	a4,a4,s3
 7dc:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7de:	02071693          	slli	a3,a4,0x20
 7e2:	01c6d713          	srli	a4,a3,0x1c
 7e6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7e8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7ec:	00001717          	auipc	a4,0x1
 7f0:	80a73a23          	sd	a0,-2028(a4) # 1000 <freep>
      return (void*)(p + 1);
 7f4:	01078513          	addi	a0,a5,16
  }
}
 7f8:	70e2                	ld	ra,56(sp)
 7fa:	7442                	ld	s0,48(sp)
 7fc:	74a2                	ld	s1,40(sp)
 7fe:	69e2                	ld	s3,24(sp)
 800:	6121                	addi	sp,sp,64
 802:	8082                	ret
 804:	7902                	ld	s2,32(sp)
 806:	6a42                	ld	s4,16(sp)
 808:	6aa2                	ld	s5,8(sp)
 80a:	6b02                	ld	s6,0(sp)
 80c:	b7f5                	j	7f8 <malloc+0xea>
