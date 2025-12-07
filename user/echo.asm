
user/_echo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	e852                	sd	s4,16(sp)
   e:	e456                	sd	s5,8(sp)
  10:	0080                	addi	s0,sp,64
  int i;

  for(i = 1; i < argc; i++){
  12:	4785                	li	a5,1
  14:	06a7d863          	bge	a5,a0,84 <main+0x84>
  18:	00858493          	addi	s1,a1,8
  1c:	3579                	addiw	a0,a0,-2
  1e:	02051793          	slli	a5,a0,0x20
  22:	01d7d513          	srli	a0,a5,0x1d
  26:	00a48a33          	add	s4,s1,a0
  2a:	05c1                	addi	a1,a1,16
  2c:	00a589b3          	add	s3,a1,a0
    write(1, argv[i], strlen(argv[i]));
    if(i + 1 < argc){
      write(1, " ", 1);
  30:	00001a97          	auipc	s5,0x1
  34:	810a8a93          	addi	s5,s5,-2032 # 840 <malloc+0x10c>
  38:	a819                	j	4e <main+0x4e>
  3a:	4605                	li	a2,1
  3c:	85d6                	mv	a1,s5
  3e:	4505                	li	a0,1
  40:	00000097          	auipc	ra,0x0
  44:	2f4080e7          	jalr	756(ra) # 334 <write>
  for(i = 1; i < argc; i++){
  48:	04a1                	addi	s1,s1,8
  4a:	03348d63          	beq	s1,s3,84 <main+0x84>
    write(1, argv[i], strlen(argv[i]));
  4e:	0004b903          	ld	s2,0(s1)
  52:	854a                	mv	a0,s2
  54:	00000097          	auipc	ra,0x0
  58:	09c080e7          	jalr	156(ra) # f0 <strlen>
  5c:	0005061b          	sext.w	a2,a0
  60:	85ca                	mv	a1,s2
  62:	4505                	li	a0,1
  64:	00000097          	auipc	ra,0x0
  68:	2d0080e7          	jalr	720(ra) # 334 <write>
    if(i + 1 < argc){
  6c:	fd4497e3          	bne	s1,s4,3a <main+0x3a>
    } else {
      write(1, "\n", 1);
  70:	4605                	li	a2,1
  72:	00000597          	auipc	a1,0x0
  76:	7d658593          	addi	a1,a1,2006 # 848 <malloc+0x114>
  7a:	4505                	li	a0,1
  7c:	00000097          	auipc	ra,0x0
  80:	2b8080e7          	jalr	696(ra) # 334 <write>
    }
  }
  exit(0);
  84:	4501                	li	a0,0
  86:	00000097          	auipc	ra,0x0
  8a:	28e080e7          	jalr	654(ra) # 314 <exit>

000000000000008e <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  8e:	1141                	addi	sp,sp,-16
  90:	e406                	sd	ra,8(sp)
  92:	e022                	sd	s0,0(sp)
  94:	0800                	addi	s0,sp,16
  extern int main();
  main();
  96:	00000097          	auipc	ra,0x0
  9a:	f6a080e7          	jalr	-150(ra) # 0 <main>
  exit(0);
  9e:	4501                	li	a0,0
  a0:	00000097          	auipc	ra,0x0
  a4:	274080e7          	jalr	628(ra) # 314 <exit>

00000000000000a8 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  a8:	1141                	addi	sp,sp,-16
  aa:	e422                	sd	s0,8(sp)
  ac:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  ae:	87aa                	mv	a5,a0
  b0:	0585                	addi	a1,a1,1
  b2:	0785                	addi	a5,a5,1
  b4:	fff5c703          	lbu	a4,-1(a1)
  b8:	fee78fa3          	sb	a4,-1(a5)
  bc:	fb75                	bnez	a4,b0 <strcpy+0x8>
    ;
  return os;
}
  be:	6422                	ld	s0,8(sp)
  c0:	0141                	addi	sp,sp,16
  c2:	8082                	ret

00000000000000c4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  c4:	1141                	addi	sp,sp,-16
  c6:	e422                	sd	s0,8(sp)
  c8:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  ca:	00054783          	lbu	a5,0(a0)
  ce:	cb91                	beqz	a5,e2 <strcmp+0x1e>
  d0:	0005c703          	lbu	a4,0(a1)
  d4:	00f71763          	bne	a4,a5,e2 <strcmp+0x1e>
    p++, q++;
  d8:	0505                	addi	a0,a0,1
  da:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  dc:	00054783          	lbu	a5,0(a0)
  e0:	fbe5                	bnez	a5,d0 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  e2:	0005c503          	lbu	a0,0(a1)
}
  e6:	40a7853b          	subw	a0,a5,a0
  ea:	6422                	ld	s0,8(sp)
  ec:	0141                	addi	sp,sp,16
  ee:	8082                	ret

00000000000000f0 <strlen>:

uint
strlen(const char *s)
{
  f0:	1141                	addi	sp,sp,-16
  f2:	e422                	sd	s0,8(sp)
  f4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  f6:	00054783          	lbu	a5,0(a0)
  fa:	cf91                	beqz	a5,116 <strlen+0x26>
  fc:	0505                	addi	a0,a0,1
  fe:	87aa                	mv	a5,a0
 100:	86be                	mv	a3,a5
 102:	0785                	addi	a5,a5,1
 104:	fff7c703          	lbu	a4,-1(a5)
 108:	ff65                	bnez	a4,100 <strlen+0x10>
 10a:	40a6853b          	subw	a0,a3,a0
 10e:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 110:	6422                	ld	s0,8(sp)
 112:	0141                	addi	sp,sp,16
 114:	8082                	ret
  for(n = 0; s[n]; n++)
 116:	4501                	li	a0,0
 118:	bfe5                	j	110 <strlen+0x20>

000000000000011a <memset>:

void*
memset(void *dst, int c, uint n)
{
 11a:	1141                	addi	sp,sp,-16
 11c:	e422                	sd	s0,8(sp)
 11e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 120:	ca19                	beqz	a2,136 <memset+0x1c>
 122:	87aa                	mv	a5,a0
 124:	1602                	slli	a2,a2,0x20
 126:	9201                	srli	a2,a2,0x20
 128:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 12c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 130:	0785                	addi	a5,a5,1
 132:	fee79de3          	bne	a5,a4,12c <memset+0x12>
  }
  return dst;
}
 136:	6422                	ld	s0,8(sp)
 138:	0141                	addi	sp,sp,16
 13a:	8082                	ret

000000000000013c <strchr>:

char*
strchr(const char *s, char c)
{
 13c:	1141                	addi	sp,sp,-16
 13e:	e422                	sd	s0,8(sp)
 140:	0800                	addi	s0,sp,16
  for(; *s; s++)
 142:	00054783          	lbu	a5,0(a0)
 146:	cb99                	beqz	a5,15c <strchr+0x20>
    if(*s == c)
 148:	00f58763          	beq	a1,a5,156 <strchr+0x1a>
  for(; *s; s++)
 14c:	0505                	addi	a0,a0,1
 14e:	00054783          	lbu	a5,0(a0)
 152:	fbfd                	bnez	a5,148 <strchr+0xc>
      return (char*)s;
  return 0;
 154:	4501                	li	a0,0
}
 156:	6422                	ld	s0,8(sp)
 158:	0141                	addi	sp,sp,16
 15a:	8082                	ret
  return 0;
 15c:	4501                	li	a0,0
 15e:	bfe5                	j	156 <strchr+0x1a>

0000000000000160 <gets>:

char*
gets(char *buf, int max)
{
 160:	711d                	addi	sp,sp,-96
 162:	ec86                	sd	ra,88(sp)
 164:	e8a2                	sd	s0,80(sp)
 166:	e4a6                	sd	s1,72(sp)
 168:	e0ca                	sd	s2,64(sp)
 16a:	fc4e                	sd	s3,56(sp)
 16c:	f852                	sd	s4,48(sp)
 16e:	f456                	sd	s5,40(sp)
 170:	f05a                	sd	s6,32(sp)
 172:	ec5e                	sd	s7,24(sp)
 174:	1080                	addi	s0,sp,96
 176:	8baa                	mv	s7,a0
 178:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 17a:	892a                	mv	s2,a0
 17c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 17e:	4aa9                	li	s5,10
 180:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 182:	89a6                	mv	s3,s1
 184:	2485                	addiw	s1,s1,1
 186:	0344d863          	bge	s1,s4,1b6 <gets+0x56>
    cc = read(0, &c, 1);
 18a:	4605                	li	a2,1
 18c:	faf40593          	addi	a1,s0,-81
 190:	4501                	li	a0,0
 192:	00000097          	auipc	ra,0x0
 196:	19a080e7          	jalr	410(ra) # 32c <read>
    if(cc < 1)
 19a:	00a05e63          	blez	a0,1b6 <gets+0x56>
    buf[i++] = c;
 19e:	faf44783          	lbu	a5,-81(s0)
 1a2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1a6:	01578763          	beq	a5,s5,1b4 <gets+0x54>
 1aa:	0905                	addi	s2,s2,1
 1ac:	fd679be3          	bne	a5,s6,182 <gets+0x22>
    buf[i++] = c;
 1b0:	89a6                	mv	s3,s1
 1b2:	a011                	j	1b6 <gets+0x56>
 1b4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1b6:	99de                	add	s3,s3,s7
 1b8:	00098023          	sb	zero,0(s3)
  return buf;
}
 1bc:	855e                	mv	a0,s7
 1be:	60e6                	ld	ra,88(sp)
 1c0:	6446                	ld	s0,80(sp)
 1c2:	64a6                	ld	s1,72(sp)
 1c4:	6906                	ld	s2,64(sp)
 1c6:	79e2                	ld	s3,56(sp)
 1c8:	7a42                	ld	s4,48(sp)
 1ca:	7aa2                	ld	s5,40(sp)
 1cc:	7b02                	ld	s6,32(sp)
 1ce:	6be2                	ld	s7,24(sp)
 1d0:	6125                	addi	sp,sp,96
 1d2:	8082                	ret

00000000000001d4 <stat>:

int
stat(const char *n, struct stat *st)
{
 1d4:	1101                	addi	sp,sp,-32
 1d6:	ec06                	sd	ra,24(sp)
 1d8:	e822                	sd	s0,16(sp)
 1da:	e04a                	sd	s2,0(sp)
 1dc:	1000                	addi	s0,sp,32
 1de:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1e0:	4581                	li	a1,0
 1e2:	00000097          	auipc	ra,0x0
 1e6:	172080e7          	jalr	370(ra) # 354 <open>
  if(fd < 0)
 1ea:	02054663          	bltz	a0,216 <stat+0x42>
 1ee:	e426                	sd	s1,8(sp)
 1f0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1f2:	85ca                	mv	a1,s2
 1f4:	00000097          	auipc	ra,0x0
 1f8:	178080e7          	jalr	376(ra) # 36c <fstat>
 1fc:	892a                	mv	s2,a0
  close(fd);
 1fe:	8526                	mv	a0,s1
 200:	00000097          	auipc	ra,0x0
 204:	13c080e7          	jalr	316(ra) # 33c <close>
  return r;
 208:	64a2                	ld	s1,8(sp)
}
 20a:	854a                	mv	a0,s2
 20c:	60e2                	ld	ra,24(sp)
 20e:	6442                	ld	s0,16(sp)
 210:	6902                	ld	s2,0(sp)
 212:	6105                	addi	sp,sp,32
 214:	8082                	ret
    return -1;
 216:	597d                	li	s2,-1
 218:	bfcd                	j	20a <stat+0x36>

000000000000021a <atoi>:

int
atoi(const char *s)
{
 21a:	1141                	addi	sp,sp,-16
 21c:	e422                	sd	s0,8(sp)
 21e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 220:	00054683          	lbu	a3,0(a0)
 224:	fd06879b          	addiw	a5,a3,-48
 228:	0ff7f793          	zext.b	a5,a5
 22c:	4625                	li	a2,9
 22e:	02f66863          	bltu	a2,a5,25e <atoi+0x44>
 232:	872a                	mv	a4,a0
  n = 0;
 234:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 236:	0705                	addi	a4,a4,1
 238:	0025179b          	slliw	a5,a0,0x2
 23c:	9fa9                	addw	a5,a5,a0
 23e:	0017979b          	slliw	a5,a5,0x1
 242:	9fb5                	addw	a5,a5,a3
 244:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 248:	00074683          	lbu	a3,0(a4)
 24c:	fd06879b          	addiw	a5,a3,-48
 250:	0ff7f793          	zext.b	a5,a5
 254:	fef671e3          	bgeu	a2,a5,236 <atoi+0x1c>
  return n;
}
 258:	6422                	ld	s0,8(sp)
 25a:	0141                	addi	sp,sp,16
 25c:	8082                	ret
  n = 0;
 25e:	4501                	li	a0,0
 260:	bfe5                	j	258 <atoi+0x3e>

0000000000000262 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 262:	1141                	addi	sp,sp,-16
 264:	e422                	sd	s0,8(sp)
 266:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 268:	02b57463          	bgeu	a0,a1,290 <memmove+0x2e>
    while(n-- > 0)
 26c:	00c05f63          	blez	a2,28a <memmove+0x28>
 270:	1602                	slli	a2,a2,0x20
 272:	9201                	srli	a2,a2,0x20
 274:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 278:	872a                	mv	a4,a0
      *dst++ = *src++;
 27a:	0585                	addi	a1,a1,1
 27c:	0705                	addi	a4,a4,1
 27e:	fff5c683          	lbu	a3,-1(a1)
 282:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 286:	fef71ae3          	bne	a4,a5,27a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 28a:	6422                	ld	s0,8(sp)
 28c:	0141                	addi	sp,sp,16
 28e:	8082                	ret
    dst += n;
 290:	00c50733          	add	a4,a0,a2
    src += n;
 294:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 296:	fec05ae3          	blez	a2,28a <memmove+0x28>
 29a:	fff6079b          	addiw	a5,a2,-1
 29e:	1782                	slli	a5,a5,0x20
 2a0:	9381                	srli	a5,a5,0x20
 2a2:	fff7c793          	not	a5,a5
 2a6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2a8:	15fd                	addi	a1,a1,-1
 2aa:	177d                	addi	a4,a4,-1
 2ac:	0005c683          	lbu	a3,0(a1)
 2b0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2b4:	fee79ae3          	bne	a5,a4,2a8 <memmove+0x46>
 2b8:	bfc9                	j	28a <memmove+0x28>

00000000000002ba <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2ba:	1141                	addi	sp,sp,-16
 2bc:	e422                	sd	s0,8(sp)
 2be:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2c0:	ca05                	beqz	a2,2f0 <memcmp+0x36>
 2c2:	fff6069b          	addiw	a3,a2,-1
 2c6:	1682                	slli	a3,a3,0x20
 2c8:	9281                	srli	a3,a3,0x20
 2ca:	0685                	addi	a3,a3,1
 2cc:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2ce:	00054783          	lbu	a5,0(a0)
 2d2:	0005c703          	lbu	a4,0(a1)
 2d6:	00e79863          	bne	a5,a4,2e6 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2da:	0505                	addi	a0,a0,1
    p2++;
 2dc:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2de:	fed518e3          	bne	a0,a3,2ce <memcmp+0x14>
  }
  return 0;
 2e2:	4501                	li	a0,0
 2e4:	a019                	j	2ea <memcmp+0x30>
      return *p1 - *p2;
 2e6:	40e7853b          	subw	a0,a5,a4
}
 2ea:	6422                	ld	s0,8(sp)
 2ec:	0141                	addi	sp,sp,16
 2ee:	8082                	ret
  return 0;
 2f0:	4501                	li	a0,0
 2f2:	bfe5                	j	2ea <memcmp+0x30>

00000000000002f4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2f4:	1141                	addi	sp,sp,-16
 2f6:	e406                	sd	ra,8(sp)
 2f8:	e022                	sd	s0,0(sp)
 2fa:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2fc:	00000097          	auipc	ra,0x0
 300:	f66080e7          	jalr	-154(ra) # 262 <memmove>
}
 304:	60a2                	ld	ra,8(sp)
 306:	6402                	ld	s0,0(sp)
 308:	0141                	addi	sp,sp,16
 30a:	8082                	ret

000000000000030c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 30c:	4885                	li	a7,1
 ecall
 30e:	00000073          	ecall
 ret
 312:	8082                	ret

0000000000000314 <exit>:
.global exit
exit:
 li a7, SYS_exit
 314:	4889                	li	a7,2
 ecall
 316:	00000073          	ecall
 ret
 31a:	8082                	ret

000000000000031c <wait>:
.global wait
wait:
 li a7, SYS_wait
 31c:	488d                	li	a7,3
 ecall
 31e:	00000073          	ecall
 ret
 322:	8082                	ret

0000000000000324 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 324:	4891                	li	a7,4
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <read>:
.global read
read:
 li a7, SYS_read
 32c:	4895                	li	a7,5
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <write>:
.global write
write:
 li a7, SYS_write
 334:	48c1                	li	a7,16
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <close>:
.global close
close:
 li a7, SYS_close
 33c:	48d5                	li	a7,21
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <kill>:
.global kill
kill:
 li a7, SYS_kill
 344:	4899                	li	a7,6
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <exec>:
.global exec
exec:
 li a7, SYS_exec
 34c:	489d                	li	a7,7
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <open>:
.global open
open:
 li a7, SYS_open
 354:	48bd                	li	a7,15
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 35c:	48c5                	li	a7,17
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 364:	48c9                	li	a7,18
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 36c:	48a1                	li	a7,8
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <link>:
.global link
link:
 li a7, SYS_link
 374:	48cd                	li	a7,19
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 37c:	48d1                	li	a7,20
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 384:	48a5                	li	a7,9
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <dup>:
.global dup
dup:
 li a7, SYS_dup
 38c:	48a9                	li	a7,10
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 394:	48ad                	li	a7,11
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 39c:	48b1                	li	a7,12
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3a4:	48b5                	li	a7,13
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3ac:	48b9                	li	a7,14
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3b4:	1101                	addi	sp,sp,-32
 3b6:	ec06                	sd	ra,24(sp)
 3b8:	e822                	sd	s0,16(sp)
 3ba:	1000                	addi	s0,sp,32
 3bc:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3c0:	4605                	li	a2,1
 3c2:	fef40593          	addi	a1,s0,-17
 3c6:	00000097          	auipc	ra,0x0
 3ca:	f6e080e7          	jalr	-146(ra) # 334 <write>
}
 3ce:	60e2                	ld	ra,24(sp)
 3d0:	6442                	ld	s0,16(sp)
 3d2:	6105                	addi	sp,sp,32
 3d4:	8082                	ret

00000000000003d6 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3d6:	7139                	addi	sp,sp,-64
 3d8:	fc06                	sd	ra,56(sp)
 3da:	f822                	sd	s0,48(sp)
 3dc:	f426                	sd	s1,40(sp)
 3de:	0080                	addi	s0,sp,64
 3e0:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3e2:	c299                	beqz	a3,3e8 <printint+0x12>
 3e4:	0805cb63          	bltz	a1,47a <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3e8:	2581                	sext.w	a1,a1
  neg = 0;
 3ea:	4881                	li	a7,0
 3ec:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3f0:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3f2:	2601                	sext.w	a2,a2
 3f4:	00000517          	auipc	a0,0x0
 3f8:	4bc50513          	addi	a0,a0,1212 # 8b0 <digits>
 3fc:	883a                	mv	a6,a4
 3fe:	2705                	addiw	a4,a4,1
 400:	02c5f7bb          	remuw	a5,a1,a2
 404:	1782                	slli	a5,a5,0x20
 406:	9381                	srli	a5,a5,0x20
 408:	97aa                	add	a5,a5,a0
 40a:	0007c783          	lbu	a5,0(a5)
 40e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 412:	0005879b          	sext.w	a5,a1
 416:	02c5d5bb          	divuw	a1,a1,a2
 41a:	0685                	addi	a3,a3,1
 41c:	fec7f0e3          	bgeu	a5,a2,3fc <printint+0x26>
  if(neg)
 420:	00088c63          	beqz	a7,438 <printint+0x62>
    buf[i++] = '-';
 424:	fd070793          	addi	a5,a4,-48
 428:	00878733          	add	a4,a5,s0
 42c:	02d00793          	li	a5,45
 430:	fef70823          	sb	a5,-16(a4)
 434:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 438:	02e05c63          	blez	a4,470 <printint+0x9a>
 43c:	f04a                	sd	s2,32(sp)
 43e:	ec4e                	sd	s3,24(sp)
 440:	fc040793          	addi	a5,s0,-64
 444:	00e78933          	add	s2,a5,a4
 448:	fff78993          	addi	s3,a5,-1
 44c:	99ba                	add	s3,s3,a4
 44e:	377d                	addiw	a4,a4,-1
 450:	1702                	slli	a4,a4,0x20
 452:	9301                	srli	a4,a4,0x20
 454:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 458:	fff94583          	lbu	a1,-1(s2)
 45c:	8526                	mv	a0,s1
 45e:	00000097          	auipc	ra,0x0
 462:	f56080e7          	jalr	-170(ra) # 3b4 <putc>
  while(--i >= 0)
 466:	197d                	addi	s2,s2,-1
 468:	ff3918e3          	bne	s2,s3,458 <printint+0x82>
 46c:	7902                	ld	s2,32(sp)
 46e:	69e2                	ld	s3,24(sp)
}
 470:	70e2                	ld	ra,56(sp)
 472:	7442                	ld	s0,48(sp)
 474:	74a2                	ld	s1,40(sp)
 476:	6121                	addi	sp,sp,64
 478:	8082                	ret
    x = -xx;
 47a:	40b005bb          	negw	a1,a1
    neg = 1;
 47e:	4885                	li	a7,1
    x = -xx;
 480:	b7b5                	j	3ec <printint+0x16>

0000000000000482 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 482:	715d                	addi	sp,sp,-80
 484:	e486                	sd	ra,72(sp)
 486:	e0a2                	sd	s0,64(sp)
 488:	f84a                	sd	s2,48(sp)
 48a:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 48c:	0005c903          	lbu	s2,0(a1)
 490:	1a090a63          	beqz	s2,644 <vprintf+0x1c2>
 494:	fc26                	sd	s1,56(sp)
 496:	f44e                	sd	s3,40(sp)
 498:	f052                	sd	s4,32(sp)
 49a:	ec56                	sd	s5,24(sp)
 49c:	e85a                	sd	s6,16(sp)
 49e:	e45e                	sd	s7,8(sp)
 4a0:	8aaa                	mv	s5,a0
 4a2:	8bb2                	mv	s7,a2
 4a4:	00158493          	addi	s1,a1,1
  state = 0;
 4a8:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4aa:	02500a13          	li	s4,37
 4ae:	4b55                	li	s6,21
 4b0:	a839                	j	4ce <vprintf+0x4c>
        putc(fd, c);
 4b2:	85ca                	mv	a1,s2
 4b4:	8556                	mv	a0,s5
 4b6:	00000097          	auipc	ra,0x0
 4ba:	efe080e7          	jalr	-258(ra) # 3b4 <putc>
 4be:	a019                	j	4c4 <vprintf+0x42>
    } else if(state == '%'){
 4c0:	01498d63          	beq	s3,s4,4da <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 4c4:	0485                	addi	s1,s1,1
 4c6:	fff4c903          	lbu	s2,-1(s1)
 4ca:	16090763          	beqz	s2,638 <vprintf+0x1b6>
    if(state == 0){
 4ce:	fe0999e3          	bnez	s3,4c0 <vprintf+0x3e>
      if(c == '%'){
 4d2:	ff4910e3          	bne	s2,s4,4b2 <vprintf+0x30>
        state = '%';
 4d6:	89d2                	mv	s3,s4
 4d8:	b7f5                	j	4c4 <vprintf+0x42>
      if(c == 'd'){
 4da:	13490463          	beq	s2,s4,602 <vprintf+0x180>
 4de:	f9d9079b          	addiw	a5,s2,-99
 4e2:	0ff7f793          	zext.b	a5,a5
 4e6:	12fb6763          	bltu	s6,a5,614 <vprintf+0x192>
 4ea:	f9d9079b          	addiw	a5,s2,-99
 4ee:	0ff7f713          	zext.b	a4,a5
 4f2:	12eb6163          	bltu	s6,a4,614 <vprintf+0x192>
 4f6:	00271793          	slli	a5,a4,0x2
 4fa:	00000717          	auipc	a4,0x0
 4fe:	35e70713          	addi	a4,a4,862 # 858 <malloc+0x124>
 502:	97ba                	add	a5,a5,a4
 504:	439c                	lw	a5,0(a5)
 506:	97ba                	add	a5,a5,a4
 508:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 50a:	008b8913          	addi	s2,s7,8
 50e:	4685                	li	a3,1
 510:	4629                	li	a2,10
 512:	000ba583          	lw	a1,0(s7)
 516:	8556                	mv	a0,s5
 518:	00000097          	auipc	ra,0x0
 51c:	ebe080e7          	jalr	-322(ra) # 3d6 <printint>
 520:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 522:	4981                	li	s3,0
 524:	b745                	j	4c4 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 526:	008b8913          	addi	s2,s7,8
 52a:	4681                	li	a3,0
 52c:	4629                	li	a2,10
 52e:	000ba583          	lw	a1,0(s7)
 532:	8556                	mv	a0,s5
 534:	00000097          	auipc	ra,0x0
 538:	ea2080e7          	jalr	-350(ra) # 3d6 <printint>
 53c:	8bca                	mv	s7,s2
      state = 0;
 53e:	4981                	li	s3,0
 540:	b751                	j	4c4 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 542:	008b8913          	addi	s2,s7,8
 546:	4681                	li	a3,0
 548:	4641                	li	a2,16
 54a:	000ba583          	lw	a1,0(s7)
 54e:	8556                	mv	a0,s5
 550:	00000097          	auipc	ra,0x0
 554:	e86080e7          	jalr	-378(ra) # 3d6 <printint>
 558:	8bca                	mv	s7,s2
      state = 0;
 55a:	4981                	li	s3,0
 55c:	b7a5                	j	4c4 <vprintf+0x42>
 55e:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 560:	008b8c13          	addi	s8,s7,8
 564:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 568:	03000593          	li	a1,48
 56c:	8556                	mv	a0,s5
 56e:	00000097          	auipc	ra,0x0
 572:	e46080e7          	jalr	-442(ra) # 3b4 <putc>
  putc(fd, 'x');
 576:	07800593          	li	a1,120
 57a:	8556                	mv	a0,s5
 57c:	00000097          	auipc	ra,0x0
 580:	e38080e7          	jalr	-456(ra) # 3b4 <putc>
 584:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 586:	00000b97          	auipc	s7,0x0
 58a:	32ab8b93          	addi	s7,s7,810 # 8b0 <digits>
 58e:	03c9d793          	srli	a5,s3,0x3c
 592:	97de                	add	a5,a5,s7
 594:	0007c583          	lbu	a1,0(a5)
 598:	8556                	mv	a0,s5
 59a:	00000097          	auipc	ra,0x0
 59e:	e1a080e7          	jalr	-486(ra) # 3b4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5a2:	0992                	slli	s3,s3,0x4
 5a4:	397d                	addiw	s2,s2,-1
 5a6:	fe0914e3          	bnez	s2,58e <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 5aa:	8be2                	mv	s7,s8
      state = 0;
 5ac:	4981                	li	s3,0
 5ae:	6c02                	ld	s8,0(sp)
 5b0:	bf11                	j	4c4 <vprintf+0x42>
        s = va_arg(ap, char*);
 5b2:	008b8993          	addi	s3,s7,8
 5b6:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 5ba:	02090163          	beqz	s2,5dc <vprintf+0x15a>
        while(*s != 0){
 5be:	00094583          	lbu	a1,0(s2)
 5c2:	c9a5                	beqz	a1,632 <vprintf+0x1b0>
          putc(fd, *s);
 5c4:	8556                	mv	a0,s5
 5c6:	00000097          	auipc	ra,0x0
 5ca:	dee080e7          	jalr	-530(ra) # 3b4 <putc>
          s++;
 5ce:	0905                	addi	s2,s2,1
        while(*s != 0){
 5d0:	00094583          	lbu	a1,0(s2)
 5d4:	f9e5                	bnez	a1,5c4 <vprintf+0x142>
        s = va_arg(ap, char*);
 5d6:	8bce                	mv	s7,s3
      state = 0;
 5d8:	4981                	li	s3,0
 5da:	b5ed                	j	4c4 <vprintf+0x42>
          s = "(null)";
 5dc:	00000917          	auipc	s2,0x0
 5e0:	27490913          	addi	s2,s2,628 # 850 <malloc+0x11c>
        while(*s != 0){
 5e4:	02800593          	li	a1,40
 5e8:	bff1                	j	5c4 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 5ea:	008b8913          	addi	s2,s7,8
 5ee:	000bc583          	lbu	a1,0(s7)
 5f2:	8556                	mv	a0,s5
 5f4:	00000097          	auipc	ra,0x0
 5f8:	dc0080e7          	jalr	-576(ra) # 3b4 <putc>
 5fc:	8bca                	mv	s7,s2
      state = 0;
 5fe:	4981                	li	s3,0
 600:	b5d1                	j	4c4 <vprintf+0x42>
        putc(fd, c);
 602:	02500593          	li	a1,37
 606:	8556                	mv	a0,s5
 608:	00000097          	auipc	ra,0x0
 60c:	dac080e7          	jalr	-596(ra) # 3b4 <putc>
      state = 0;
 610:	4981                	li	s3,0
 612:	bd4d                	j	4c4 <vprintf+0x42>
        putc(fd, '%');
 614:	02500593          	li	a1,37
 618:	8556                	mv	a0,s5
 61a:	00000097          	auipc	ra,0x0
 61e:	d9a080e7          	jalr	-614(ra) # 3b4 <putc>
        putc(fd, c);
 622:	85ca                	mv	a1,s2
 624:	8556                	mv	a0,s5
 626:	00000097          	auipc	ra,0x0
 62a:	d8e080e7          	jalr	-626(ra) # 3b4 <putc>
      state = 0;
 62e:	4981                	li	s3,0
 630:	bd51                	j	4c4 <vprintf+0x42>
        s = va_arg(ap, char*);
 632:	8bce                	mv	s7,s3
      state = 0;
 634:	4981                	li	s3,0
 636:	b579                	j	4c4 <vprintf+0x42>
 638:	74e2                	ld	s1,56(sp)
 63a:	79a2                	ld	s3,40(sp)
 63c:	7a02                	ld	s4,32(sp)
 63e:	6ae2                	ld	s5,24(sp)
 640:	6b42                	ld	s6,16(sp)
 642:	6ba2                	ld	s7,8(sp)
    }
  }
}
 644:	60a6                	ld	ra,72(sp)
 646:	6406                	ld	s0,64(sp)
 648:	7942                	ld	s2,48(sp)
 64a:	6161                	addi	sp,sp,80
 64c:	8082                	ret

000000000000064e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 64e:	715d                	addi	sp,sp,-80
 650:	ec06                	sd	ra,24(sp)
 652:	e822                	sd	s0,16(sp)
 654:	1000                	addi	s0,sp,32
 656:	e010                	sd	a2,0(s0)
 658:	e414                	sd	a3,8(s0)
 65a:	e818                	sd	a4,16(s0)
 65c:	ec1c                	sd	a5,24(s0)
 65e:	03043023          	sd	a6,32(s0)
 662:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 666:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 66a:	8622                	mv	a2,s0
 66c:	00000097          	auipc	ra,0x0
 670:	e16080e7          	jalr	-490(ra) # 482 <vprintf>
}
 674:	60e2                	ld	ra,24(sp)
 676:	6442                	ld	s0,16(sp)
 678:	6161                	addi	sp,sp,80
 67a:	8082                	ret

000000000000067c <printf>:

void
printf(const char *fmt, ...)
{
 67c:	711d                	addi	sp,sp,-96
 67e:	ec06                	sd	ra,24(sp)
 680:	e822                	sd	s0,16(sp)
 682:	1000                	addi	s0,sp,32
 684:	e40c                	sd	a1,8(s0)
 686:	e810                	sd	a2,16(s0)
 688:	ec14                	sd	a3,24(s0)
 68a:	f018                	sd	a4,32(s0)
 68c:	f41c                	sd	a5,40(s0)
 68e:	03043823          	sd	a6,48(s0)
 692:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 696:	00840613          	addi	a2,s0,8
 69a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 69e:	85aa                	mv	a1,a0
 6a0:	4505                	li	a0,1
 6a2:	00000097          	auipc	ra,0x0
 6a6:	de0080e7          	jalr	-544(ra) # 482 <vprintf>
}
 6aa:	60e2                	ld	ra,24(sp)
 6ac:	6442                	ld	s0,16(sp)
 6ae:	6125                	addi	sp,sp,96
 6b0:	8082                	ret

00000000000006b2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6b2:	1141                	addi	sp,sp,-16
 6b4:	e422                	sd	s0,8(sp)
 6b6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6b8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6bc:	00001797          	auipc	a5,0x1
 6c0:	9447b783          	ld	a5,-1724(a5) # 1000 <freep>
 6c4:	a02d                	j	6ee <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6c6:	4618                	lw	a4,8(a2)
 6c8:	9f2d                	addw	a4,a4,a1
 6ca:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6ce:	6398                	ld	a4,0(a5)
 6d0:	6310                	ld	a2,0(a4)
 6d2:	a83d                	j	710 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6d4:	ff852703          	lw	a4,-8(a0)
 6d8:	9f31                	addw	a4,a4,a2
 6da:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 6dc:	ff053683          	ld	a3,-16(a0)
 6e0:	a091                	j	724 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6e2:	6398                	ld	a4,0(a5)
 6e4:	00e7e463          	bltu	a5,a4,6ec <free+0x3a>
 6e8:	00e6ea63          	bltu	a3,a4,6fc <free+0x4a>
{
 6ec:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6ee:	fed7fae3          	bgeu	a5,a3,6e2 <free+0x30>
 6f2:	6398                	ld	a4,0(a5)
 6f4:	00e6e463          	bltu	a3,a4,6fc <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6f8:	fee7eae3          	bltu	a5,a4,6ec <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 6fc:	ff852583          	lw	a1,-8(a0)
 700:	6390                	ld	a2,0(a5)
 702:	02059813          	slli	a6,a1,0x20
 706:	01c85713          	srli	a4,a6,0x1c
 70a:	9736                	add	a4,a4,a3
 70c:	fae60de3          	beq	a2,a4,6c6 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 710:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 714:	4790                	lw	a2,8(a5)
 716:	02061593          	slli	a1,a2,0x20
 71a:	01c5d713          	srli	a4,a1,0x1c
 71e:	973e                	add	a4,a4,a5
 720:	fae68ae3          	beq	a3,a4,6d4 <free+0x22>
    p->s.ptr = bp->s.ptr;
 724:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 726:	00001717          	auipc	a4,0x1
 72a:	8cf73d23          	sd	a5,-1830(a4) # 1000 <freep>
}
 72e:	6422                	ld	s0,8(sp)
 730:	0141                	addi	sp,sp,16
 732:	8082                	ret

0000000000000734 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 734:	7139                	addi	sp,sp,-64
 736:	fc06                	sd	ra,56(sp)
 738:	f822                	sd	s0,48(sp)
 73a:	f426                	sd	s1,40(sp)
 73c:	ec4e                	sd	s3,24(sp)
 73e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 740:	02051493          	slli	s1,a0,0x20
 744:	9081                	srli	s1,s1,0x20
 746:	04bd                	addi	s1,s1,15
 748:	8091                	srli	s1,s1,0x4
 74a:	0014899b          	addiw	s3,s1,1
 74e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 750:	00001517          	auipc	a0,0x1
 754:	8b053503          	ld	a0,-1872(a0) # 1000 <freep>
 758:	c915                	beqz	a0,78c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 75a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 75c:	4798                	lw	a4,8(a5)
 75e:	08977e63          	bgeu	a4,s1,7fa <malloc+0xc6>
 762:	f04a                	sd	s2,32(sp)
 764:	e852                	sd	s4,16(sp)
 766:	e456                	sd	s5,8(sp)
 768:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 76a:	8a4e                	mv	s4,s3
 76c:	0009871b          	sext.w	a4,s3
 770:	6685                	lui	a3,0x1
 772:	00d77363          	bgeu	a4,a3,778 <malloc+0x44>
 776:	6a05                	lui	s4,0x1
 778:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 77c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 780:	00001917          	auipc	s2,0x1
 784:	88090913          	addi	s2,s2,-1920 # 1000 <freep>
  if(p == (char*)-1)
 788:	5afd                	li	s5,-1
 78a:	a091                	j	7ce <malloc+0x9a>
 78c:	f04a                	sd	s2,32(sp)
 78e:	e852                	sd	s4,16(sp)
 790:	e456                	sd	s5,8(sp)
 792:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 794:	00001797          	auipc	a5,0x1
 798:	87c78793          	addi	a5,a5,-1924 # 1010 <base>
 79c:	00001717          	auipc	a4,0x1
 7a0:	86f73223          	sd	a5,-1948(a4) # 1000 <freep>
 7a4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7a6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7aa:	b7c1                	j	76a <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 7ac:	6398                	ld	a4,0(a5)
 7ae:	e118                	sd	a4,0(a0)
 7b0:	a08d                	j	812 <malloc+0xde>
  hp->s.size = nu;
 7b2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7b6:	0541                	addi	a0,a0,16
 7b8:	00000097          	auipc	ra,0x0
 7bc:	efa080e7          	jalr	-262(ra) # 6b2 <free>
  return freep;
 7c0:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7c4:	c13d                	beqz	a0,82a <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7c6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7c8:	4798                	lw	a4,8(a5)
 7ca:	02977463          	bgeu	a4,s1,7f2 <malloc+0xbe>
    if(p == freep)
 7ce:	00093703          	ld	a4,0(s2)
 7d2:	853e                	mv	a0,a5
 7d4:	fef719e3          	bne	a4,a5,7c6 <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 7d8:	8552                	mv	a0,s4
 7da:	00000097          	auipc	ra,0x0
 7de:	bc2080e7          	jalr	-1086(ra) # 39c <sbrk>
  if(p == (char*)-1)
 7e2:	fd5518e3          	bne	a0,s5,7b2 <malloc+0x7e>
        return 0;
 7e6:	4501                	li	a0,0
 7e8:	7902                	ld	s2,32(sp)
 7ea:	6a42                	ld	s4,16(sp)
 7ec:	6aa2                	ld	s5,8(sp)
 7ee:	6b02                	ld	s6,0(sp)
 7f0:	a03d                	j	81e <malloc+0xea>
 7f2:	7902                	ld	s2,32(sp)
 7f4:	6a42                	ld	s4,16(sp)
 7f6:	6aa2                	ld	s5,8(sp)
 7f8:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 7fa:	fae489e3          	beq	s1,a4,7ac <malloc+0x78>
        p->s.size -= nunits;
 7fe:	4137073b          	subw	a4,a4,s3
 802:	c798                	sw	a4,8(a5)
        p += p->s.size;
 804:	02071693          	slli	a3,a4,0x20
 808:	01c6d713          	srli	a4,a3,0x1c
 80c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 80e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 812:	00000717          	auipc	a4,0x0
 816:	7ea73723          	sd	a0,2030(a4) # 1000 <freep>
      return (void*)(p + 1);
 81a:	01078513          	addi	a0,a5,16
  }
}
 81e:	70e2                	ld	ra,56(sp)
 820:	7442                	ld	s0,48(sp)
 822:	74a2                	ld	s1,40(sp)
 824:	69e2                	ld	s3,24(sp)
 826:	6121                	addi	sp,sp,64
 828:	8082                	ret
 82a:	7902                	ld	s2,32(sp)
 82c:	6a42                	ld	s4,16(sp)
 82e:	6aa2                	ld	s5,8(sp)
 830:	6b02                	ld	s6,0(sp)
 832:	b7f5                	j	81e <malloc+0xea>
