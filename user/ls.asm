
user/_ls:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <fmtname>:
#include "user/user.h"
#include "kernel/fs.h"

char*
fmtname(char *path)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	1800                	addi	s0,sp,48
   a:	84aa                	mv	s1,a0
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
   c:	00000097          	auipc	ra,0x0
  10:	332080e7          	jalr	818(ra) # 33e <strlen>
  14:	02051793          	slli	a5,a0,0x20
  18:	9381                	srli	a5,a5,0x20
  1a:	97a6                	add	a5,a5,s1
  1c:	02f00693          	li	a3,47
  20:	0097e963          	bltu	a5,s1,32 <fmtname+0x32>
  24:	0007c703          	lbu	a4,0(a5)
  28:	00d70563          	beq	a4,a3,32 <fmtname+0x32>
  2c:	17fd                	addi	a5,a5,-1
  2e:	fe97fbe3          	bgeu	a5,s1,24 <fmtname+0x24>
    ;
  p++;
  32:	00178493          	addi	s1,a5,1

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  36:	8526                	mv	a0,s1
  38:	00000097          	auipc	ra,0x0
  3c:	306080e7          	jalr	774(ra) # 33e <strlen>
  40:	2501                	sext.w	a0,a0
  42:	47b5                	li	a5,13
  44:	00a7f863          	bgeu	a5,a0,54 <fmtname+0x54>
    return p;
  memmove(buf, p, strlen(p));
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  return buf;
}
  48:	8526                	mv	a0,s1
  4a:	70a2                	ld	ra,40(sp)
  4c:	7402                	ld	s0,32(sp)
  4e:	64e2                	ld	s1,24(sp)
  50:	6145                	addi	sp,sp,48
  52:	8082                	ret
  54:	e84a                	sd	s2,16(sp)
  56:	e44e                	sd	s3,8(sp)
  memmove(buf, p, strlen(p));
  58:	8526                	mv	a0,s1
  5a:	00000097          	auipc	ra,0x0
  5e:	2e4080e7          	jalr	740(ra) # 33e <strlen>
  62:	00001997          	auipc	s3,0x1
  66:	fae98993          	addi	s3,s3,-82 # 1010 <buf.0>
  6a:	0005061b          	sext.w	a2,a0
  6e:	85a6                	mv	a1,s1
  70:	854e                	mv	a0,s3
  72:	00000097          	auipc	ra,0x0
  76:	43e080e7          	jalr	1086(ra) # 4b0 <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  7a:	8526                	mv	a0,s1
  7c:	00000097          	auipc	ra,0x0
  80:	2c2080e7          	jalr	706(ra) # 33e <strlen>
  84:	0005091b          	sext.w	s2,a0
  88:	8526                	mv	a0,s1
  8a:	00000097          	auipc	ra,0x0
  8e:	2b4080e7          	jalr	692(ra) # 33e <strlen>
  92:	1902                	slli	s2,s2,0x20
  94:	02095913          	srli	s2,s2,0x20
  98:	4639                	li	a2,14
  9a:	9e09                	subw	a2,a2,a0
  9c:	02000593          	li	a1,32
  a0:	01298533          	add	a0,s3,s2
  a4:	00000097          	auipc	ra,0x0
  a8:	2c4080e7          	jalr	708(ra) # 368 <memset>
  return buf;
  ac:	84ce                	mv	s1,s3
  ae:	6942                	ld	s2,16(sp)
  b0:	69a2                	ld	s3,8(sp)
  b2:	bf59                	j	48 <fmtname+0x48>

00000000000000b4 <ls>:

void
ls(char *path)
{
  b4:	d9010113          	addi	sp,sp,-624
  b8:	26113423          	sd	ra,616(sp)
  bc:	26813023          	sd	s0,608(sp)
  c0:	25213823          	sd	s2,592(sp)
  c4:	1c80                	addi	s0,sp,624
  c6:	892a                	mv	s2,a0
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, 0)) < 0){
  c8:	4581                	li	a1,0
  ca:	00000097          	auipc	ra,0x0
  ce:	4d8080e7          	jalr	1240(ra) # 5a2 <open>
  d2:	06054b63          	bltz	a0,148 <ls+0x94>
  d6:	24913c23          	sd	s1,600(sp)
  da:	84aa                	mv	s1,a0
    fprintf(2, "ls: cannot open %s\n", path);
    return;
  }

  if(fstat(fd, &st) < 0){
  dc:	d9840593          	addi	a1,s0,-616
  e0:	00000097          	auipc	ra,0x0
  e4:	4da080e7          	jalr	1242(ra) # 5ba <fstat>
  e8:	06054b63          	bltz	a0,15e <ls+0xaa>
    fprintf(2, "ls: cannot stat %s\n", path);
    close(fd);
    return;
  }

  switch(st.type){
  ec:	da041783          	lh	a5,-608(s0)
  f0:	4705                	li	a4,1
  f2:	08e78863          	beq	a5,a4,182 <ls+0xce>
  f6:	37f9                	addiw	a5,a5,-2
  f8:	17c2                	slli	a5,a5,0x30
  fa:	93c1                	srli	a5,a5,0x30
  fc:	02f76663          	bltu	a4,a5,128 <ls+0x74>
  case T_DEVICE:
  case T_FILE:
    printf("%s %d %d %l\n", fmtname(path), st.type, st.ino, st.size);
 100:	854a                	mv	a0,s2
 102:	00000097          	auipc	ra,0x0
 106:	efe080e7          	jalr	-258(ra) # 0 <fmtname>
 10a:	85aa                	mv	a1,a0
 10c:	da843703          	ld	a4,-600(s0)
 110:	d9c42683          	lw	a3,-612(s0)
 114:	da041603          	lh	a2,-608(s0)
 118:	00001517          	auipc	a0,0x1
 11c:	9a850513          	addi	a0,a0,-1624 # ac0 <malloc+0x13e>
 120:	00000097          	auipc	ra,0x0
 124:	7aa080e7          	jalr	1962(ra) # 8ca <printf>
      }
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
    }
    break;
  }
  close(fd);
 128:	8526                	mv	a0,s1
 12a:	00000097          	auipc	ra,0x0
 12e:	460080e7          	jalr	1120(ra) # 58a <close>
 132:	25813483          	ld	s1,600(sp)
}
 136:	26813083          	ld	ra,616(sp)
 13a:	26013403          	ld	s0,608(sp)
 13e:	25013903          	ld	s2,592(sp)
 142:	27010113          	addi	sp,sp,624
 146:	8082                	ret
    fprintf(2, "ls: cannot open %s\n", path);
 148:	864a                	mv	a2,s2
 14a:	00001597          	auipc	a1,0x1
 14e:	94658593          	addi	a1,a1,-1722 # a90 <malloc+0x10e>
 152:	4509                	li	a0,2
 154:	00000097          	auipc	ra,0x0
 158:	748080e7          	jalr	1864(ra) # 89c <fprintf>
    return;
 15c:	bfe9                	j	136 <ls+0x82>
    fprintf(2, "ls: cannot stat %s\n", path);
 15e:	864a                	mv	a2,s2
 160:	00001597          	auipc	a1,0x1
 164:	94858593          	addi	a1,a1,-1720 # aa8 <malloc+0x126>
 168:	4509                	li	a0,2
 16a:	00000097          	auipc	ra,0x0
 16e:	732080e7          	jalr	1842(ra) # 89c <fprintf>
    close(fd);
 172:	8526                	mv	a0,s1
 174:	00000097          	auipc	ra,0x0
 178:	416080e7          	jalr	1046(ra) # 58a <close>
    return;
 17c:	25813483          	ld	s1,600(sp)
 180:	bf5d                	j	136 <ls+0x82>
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 182:	854a                	mv	a0,s2
 184:	00000097          	auipc	ra,0x0
 188:	1ba080e7          	jalr	442(ra) # 33e <strlen>
 18c:	2541                	addiw	a0,a0,16
 18e:	20000793          	li	a5,512
 192:	00a7fb63          	bgeu	a5,a0,1a8 <ls+0xf4>
      printf("ls: path too long\n");
 196:	00001517          	auipc	a0,0x1
 19a:	93a50513          	addi	a0,a0,-1734 # ad0 <malloc+0x14e>
 19e:	00000097          	auipc	ra,0x0
 1a2:	72c080e7          	jalr	1836(ra) # 8ca <printf>
      break;
 1a6:	b749                	j	128 <ls+0x74>
 1a8:	25313423          	sd	s3,584(sp)
 1ac:	25413023          	sd	s4,576(sp)
 1b0:	23513c23          	sd	s5,568(sp)
    strcpy(buf, path);
 1b4:	85ca                	mv	a1,s2
 1b6:	dc040513          	addi	a0,s0,-576
 1ba:	00000097          	auipc	ra,0x0
 1be:	13c080e7          	jalr	316(ra) # 2f6 <strcpy>
    p = buf+strlen(buf);
 1c2:	dc040513          	addi	a0,s0,-576
 1c6:	00000097          	auipc	ra,0x0
 1ca:	178080e7          	jalr	376(ra) # 33e <strlen>
 1ce:	1502                	slli	a0,a0,0x20
 1d0:	9101                	srli	a0,a0,0x20
 1d2:	dc040793          	addi	a5,s0,-576
 1d6:	00a78933          	add	s2,a5,a0
    *p++ = '/';
 1da:	00190993          	addi	s3,s2,1
 1de:	02f00793          	li	a5,47
 1e2:	00f90023          	sb	a5,0(s2)
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 1e6:	00001a17          	auipc	s4,0x1
 1ea:	902a0a13          	addi	s4,s4,-1790 # ae8 <malloc+0x166>
        printf("ls: cannot stat %s\n", buf);
 1ee:	00001a97          	auipc	s5,0x1
 1f2:	8baa8a93          	addi	s5,s5,-1862 # aa8 <malloc+0x126>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 1f6:	a801                	j	206 <ls+0x152>
        printf("ls: cannot stat %s\n", buf);
 1f8:	dc040593          	addi	a1,s0,-576
 1fc:	8556                	mv	a0,s5
 1fe:	00000097          	auipc	ra,0x0
 202:	6cc080e7          	jalr	1740(ra) # 8ca <printf>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 206:	4641                	li	a2,16
 208:	db040593          	addi	a1,s0,-592
 20c:	8526                	mv	a0,s1
 20e:	00000097          	auipc	ra,0x0
 212:	36c080e7          	jalr	876(ra) # 57a <read>
 216:	47c1                	li	a5,16
 218:	04f51c63          	bne	a0,a5,270 <ls+0x1bc>
      if(de.inum == 0)
 21c:	db045783          	lhu	a5,-592(s0)
 220:	d3fd                	beqz	a5,206 <ls+0x152>
      memmove(p, de.name, DIRSIZ);
 222:	4639                	li	a2,14
 224:	db240593          	addi	a1,s0,-590
 228:	854e                	mv	a0,s3
 22a:	00000097          	auipc	ra,0x0
 22e:	286080e7          	jalr	646(ra) # 4b0 <memmove>
      p[DIRSIZ] = 0;
 232:	000907a3          	sb	zero,15(s2)
      if(stat(buf, &st) < 0){
 236:	d9840593          	addi	a1,s0,-616
 23a:	dc040513          	addi	a0,s0,-576
 23e:	00000097          	auipc	ra,0x0
 242:	1e4080e7          	jalr	484(ra) # 422 <stat>
 246:	fa0549e3          	bltz	a0,1f8 <ls+0x144>
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 24a:	dc040513          	addi	a0,s0,-576
 24e:	00000097          	auipc	ra,0x0
 252:	db2080e7          	jalr	-590(ra) # 0 <fmtname>
 256:	85aa                	mv	a1,a0
 258:	da843703          	ld	a4,-600(s0)
 25c:	d9c42683          	lw	a3,-612(s0)
 260:	da041603          	lh	a2,-608(s0)
 264:	8552                	mv	a0,s4
 266:	00000097          	auipc	ra,0x0
 26a:	664080e7          	jalr	1636(ra) # 8ca <printf>
 26e:	bf61                	j	206 <ls+0x152>
 270:	24813983          	ld	s3,584(sp)
 274:	24013a03          	ld	s4,576(sp)
 278:	23813a83          	ld	s5,568(sp)
 27c:	b575                	j	128 <ls+0x74>

000000000000027e <main>:

int
main(int argc, char *argv[])
{
 27e:	1101                	addi	sp,sp,-32
 280:	ec06                	sd	ra,24(sp)
 282:	e822                	sd	s0,16(sp)
 284:	1000                	addi	s0,sp,32
  int i;

  if(argc < 2){
 286:	4785                	li	a5,1
 288:	02a7db63          	bge	a5,a0,2be <main+0x40>
 28c:	e426                	sd	s1,8(sp)
 28e:	e04a                	sd	s2,0(sp)
 290:	00858493          	addi	s1,a1,8
 294:	ffe5091b          	addiw	s2,a0,-2
 298:	02091793          	slli	a5,s2,0x20
 29c:	01d7d913          	srli	s2,a5,0x1d
 2a0:	05c1                	addi	a1,a1,16
 2a2:	992e                	add	s2,s2,a1
    ls(".");
    exit(0);
  }
  for(i=1; i<argc; i++)
    ls(argv[i]);
 2a4:	6088                	ld	a0,0(s1)
 2a6:	00000097          	auipc	ra,0x0
 2aa:	e0e080e7          	jalr	-498(ra) # b4 <ls>
  for(i=1; i<argc; i++)
 2ae:	04a1                	addi	s1,s1,8
 2b0:	ff249ae3          	bne	s1,s2,2a4 <main+0x26>
  exit(0);
 2b4:	4501                	li	a0,0
 2b6:	00000097          	auipc	ra,0x0
 2ba:	2ac080e7          	jalr	684(ra) # 562 <exit>
 2be:	e426                	sd	s1,8(sp)
 2c0:	e04a                	sd	s2,0(sp)
    ls(".");
 2c2:	00001517          	auipc	a0,0x1
 2c6:	83650513          	addi	a0,a0,-1994 # af8 <malloc+0x176>
 2ca:	00000097          	auipc	ra,0x0
 2ce:	dea080e7          	jalr	-534(ra) # b4 <ls>
    exit(0);
 2d2:	4501                	li	a0,0
 2d4:	00000097          	auipc	ra,0x0
 2d8:	28e080e7          	jalr	654(ra) # 562 <exit>

00000000000002dc <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 2dc:	1141                	addi	sp,sp,-16
 2de:	e406                	sd	ra,8(sp)
 2e0:	e022                	sd	s0,0(sp)
 2e2:	0800                	addi	s0,sp,16
  extern int main();
  main();
 2e4:	00000097          	auipc	ra,0x0
 2e8:	f9a080e7          	jalr	-102(ra) # 27e <main>
  exit(0);
 2ec:	4501                	li	a0,0
 2ee:	00000097          	auipc	ra,0x0
 2f2:	274080e7          	jalr	628(ra) # 562 <exit>

00000000000002f6 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 2f6:	1141                	addi	sp,sp,-16
 2f8:	e422                	sd	s0,8(sp)
 2fa:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2fc:	87aa                	mv	a5,a0
 2fe:	0585                	addi	a1,a1,1
 300:	0785                	addi	a5,a5,1
 302:	fff5c703          	lbu	a4,-1(a1)
 306:	fee78fa3          	sb	a4,-1(a5)
 30a:	fb75                	bnez	a4,2fe <strcpy+0x8>
    ;
  return os;
}
 30c:	6422                	ld	s0,8(sp)
 30e:	0141                	addi	sp,sp,16
 310:	8082                	ret

0000000000000312 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 312:	1141                	addi	sp,sp,-16
 314:	e422                	sd	s0,8(sp)
 316:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 318:	00054783          	lbu	a5,0(a0)
 31c:	cb91                	beqz	a5,330 <strcmp+0x1e>
 31e:	0005c703          	lbu	a4,0(a1)
 322:	00f71763          	bne	a4,a5,330 <strcmp+0x1e>
    p++, q++;
 326:	0505                	addi	a0,a0,1
 328:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 32a:	00054783          	lbu	a5,0(a0)
 32e:	fbe5                	bnez	a5,31e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 330:	0005c503          	lbu	a0,0(a1)
}
 334:	40a7853b          	subw	a0,a5,a0
 338:	6422                	ld	s0,8(sp)
 33a:	0141                	addi	sp,sp,16
 33c:	8082                	ret

000000000000033e <strlen>:

uint
strlen(const char *s)
{
 33e:	1141                	addi	sp,sp,-16
 340:	e422                	sd	s0,8(sp)
 342:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 344:	00054783          	lbu	a5,0(a0)
 348:	cf91                	beqz	a5,364 <strlen+0x26>
 34a:	0505                	addi	a0,a0,1
 34c:	87aa                	mv	a5,a0
 34e:	86be                	mv	a3,a5
 350:	0785                	addi	a5,a5,1
 352:	fff7c703          	lbu	a4,-1(a5)
 356:	ff65                	bnez	a4,34e <strlen+0x10>
 358:	40a6853b          	subw	a0,a3,a0
 35c:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 35e:	6422                	ld	s0,8(sp)
 360:	0141                	addi	sp,sp,16
 362:	8082                	ret
  for(n = 0; s[n]; n++)
 364:	4501                	li	a0,0
 366:	bfe5                	j	35e <strlen+0x20>

0000000000000368 <memset>:

void*
memset(void *dst, int c, uint n)
{
 368:	1141                	addi	sp,sp,-16
 36a:	e422                	sd	s0,8(sp)
 36c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 36e:	ca19                	beqz	a2,384 <memset+0x1c>
 370:	87aa                	mv	a5,a0
 372:	1602                	slli	a2,a2,0x20
 374:	9201                	srli	a2,a2,0x20
 376:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 37a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 37e:	0785                	addi	a5,a5,1
 380:	fee79de3          	bne	a5,a4,37a <memset+0x12>
  }
  return dst;
}
 384:	6422                	ld	s0,8(sp)
 386:	0141                	addi	sp,sp,16
 388:	8082                	ret

000000000000038a <strchr>:

char*
strchr(const char *s, char c)
{
 38a:	1141                	addi	sp,sp,-16
 38c:	e422                	sd	s0,8(sp)
 38e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 390:	00054783          	lbu	a5,0(a0)
 394:	cb99                	beqz	a5,3aa <strchr+0x20>
    if(*s == c)
 396:	00f58763          	beq	a1,a5,3a4 <strchr+0x1a>
  for(; *s; s++)
 39a:	0505                	addi	a0,a0,1
 39c:	00054783          	lbu	a5,0(a0)
 3a0:	fbfd                	bnez	a5,396 <strchr+0xc>
      return (char*)s;
  return 0;
 3a2:	4501                	li	a0,0
}
 3a4:	6422                	ld	s0,8(sp)
 3a6:	0141                	addi	sp,sp,16
 3a8:	8082                	ret
  return 0;
 3aa:	4501                	li	a0,0
 3ac:	bfe5                	j	3a4 <strchr+0x1a>

00000000000003ae <gets>:

char*
gets(char *buf, int max)
{
 3ae:	711d                	addi	sp,sp,-96
 3b0:	ec86                	sd	ra,88(sp)
 3b2:	e8a2                	sd	s0,80(sp)
 3b4:	e4a6                	sd	s1,72(sp)
 3b6:	e0ca                	sd	s2,64(sp)
 3b8:	fc4e                	sd	s3,56(sp)
 3ba:	f852                	sd	s4,48(sp)
 3bc:	f456                	sd	s5,40(sp)
 3be:	f05a                	sd	s6,32(sp)
 3c0:	ec5e                	sd	s7,24(sp)
 3c2:	1080                	addi	s0,sp,96
 3c4:	8baa                	mv	s7,a0
 3c6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3c8:	892a                	mv	s2,a0
 3ca:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 3cc:	4aa9                	li	s5,10
 3ce:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 3d0:	89a6                	mv	s3,s1
 3d2:	2485                	addiw	s1,s1,1
 3d4:	0344d863          	bge	s1,s4,404 <gets+0x56>
    cc = read(0, &c, 1);
 3d8:	4605                	li	a2,1
 3da:	faf40593          	addi	a1,s0,-81
 3de:	4501                	li	a0,0
 3e0:	00000097          	auipc	ra,0x0
 3e4:	19a080e7          	jalr	410(ra) # 57a <read>
    if(cc < 1)
 3e8:	00a05e63          	blez	a0,404 <gets+0x56>
    buf[i++] = c;
 3ec:	faf44783          	lbu	a5,-81(s0)
 3f0:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 3f4:	01578763          	beq	a5,s5,402 <gets+0x54>
 3f8:	0905                	addi	s2,s2,1
 3fa:	fd679be3          	bne	a5,s6,3d0 <gets+0x22>
    buf[i++] = c;
 3fe:	89a6                	mv	s3,s1
 400:	a011                	j	404 <gets+0x56>
 402:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 404:	99de                	add	s3,s3,s7
 406:	00098023          	sb	zero,0(s3)
  return buf;
}
 40a:	855e                	mv	a0,s7
 40c:	60e6                	ld	ra,88(sp)
 40e:	6446                	ld	s0,80(sp)
 410:	64a6                	ld	s1,72(sp)
 412:	6906                	ld	s2,64(sp)
 414:	79e2                	ld	s3,56(sp)
 416:	7a42                	ld	s4,48(sp)
 418:	7aa2                	ld	s5,40(sp)
 41a:	7b02                	ld	s6,32(sp)
 41c:	6be2                	ld	s7,24(sp)
 41e:	6125                	addi	sp,sp,96
 420:	8082                	ret

0000000000000422 <stat>:

int
stat(const char *n, struct stat *st)
{
 422:	1101                	addi	sp,sp,-32
 424:	ec06                	sd	ra,24(sp)
 426:	e822                	sd	s0,16(sp)
 428:	e04a                	sd	s2,0(sp)
 42a:	1000                	addi	s0,sp,32
 42c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 42e:	4581                	li	a1,0
 430:	00000097          	auipc	ra,0x0
 434:	172080e7          	jalr	370(ra) # 5a2 <open>
  if(fd < 0)
 438:	02054663          	bltz	a0,464 <stat+0x42>
 43c:	e426                	sd	s1,8(sp)
 43e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 440:	85ca                	mv	a1,s2
 442:	00000097          	auipc	ra,0x0
 446:	178080e7          	jalr	376(ra) # 5ba <fstat>
 44a:	892a                	mv	s2,a0
  close(fd);
 44c:	8526                	mv	a0,s1
 44e:	00000097          	auipc	ra,0x0
 452:	13c080e7          	jalr	316(ra) # 58a <close>
  return r;
 456:	64a2                	ld	s1,8(sp)
}
 458:	854a                	mv	a0,s2
 45a:	60e2                	ld	ra,24(sp)
 45c:	6442                	ld	s0,16(sp)
 45e:	6902                	ld	s2,0(sp)
 460:	6105                	addi	sp,sp,32
 462:	8082                	ret
    return -1;
 464:	597d                	li	s2,-1
 466:	bfcd                	j	458 <stat+0x36>

0000000000000468 <atoi>:

int
atoi(const char *s)
{
 468:	1141                	addi	sp,sp,-16
 46a:	e422                	sd	s0,8(sp)
 46c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 46e:	00054683          	lbu	a3,0(a0)
 472:	fd06879b          	addiw	a5,a3,-48
 476:	0ff7f793          	zext.b	a5,a5
 47a:	4625                	li	a2,9
 47c:	02f66863          	bltu	a2,a5,4ac <atoi+0x44>
 480:	872a                	mv	a4,a0
  n = 0;
 482:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 484:	0705                	addi	a4,a4,1
 486:	0025179b          	slliw	a5,a0,0x2
 48a:	9fa9                	addw	a5,a5,a0
 48c:	0017979b          	slliw	a5,a5,0x1
 490:	9fb5                	addw	a5,a5,a3
 492:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 496:	00074683          	lbu	a3,0(a4)
 49a:	fd06879b          	addiw	a5,a3,-48
 49e:	0ff7f793          	zext.b	a5,a5
 4a2:	fef671e3          	bgeu	a2,a5,484 <atoi+0x1c>
  return n;
}
 4a6:	6422                	ld	s0,8(sp)
 4a8:	0141                	addi	sp,sp,16
 4aa:	8082                	ret
  n = 0;
 4ac:	4501                	li	a0,0
 4ae:	bfe5                	j	4a6 <atoi+0x3e>

00000000000004b0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 4b0:	1141                	addi	sp,sp,-16
 4b2:	e422                	sd	s0,8(sp)
 4b4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 4b6:	02b57463          	bgeu	a0,a1,4de <memmove+0x2e>
    while(n-- > 0)
 4ba:	00c05f63          	blez	a2,4d8 <memmove+0x28>
 4be:	1602                	slli	a2,a2,0x20
 4c0:	9201                	srli	a2,a2,0x20
 4c2:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 4c6:	872a                	mv	a4,a0
      *dst++ = *src++;
 4c8:	0585                	addi	a1,a1,1
 4ca:	0705                	addi	a4,a4,1
 4cc:	fff5c683          	lbu	a3,-1(a1)
 4d0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 4d4:	fef71ae3          	bne	a4,a5,4c8 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 4d8:	6422                	ld	s0,8(sp)
 4da:	0141                	addi	sp,sp,16
 4dc:	8082                	ret
    dst += n;
 4de:	00c50733          	add	a4,a0,a2
    src += n;
 4e2:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 4e4:	fec05ae3          	blez	a2,4d8 <memmove+0x28>
 4e8:	fff6079b          	addiw	a5,a2,-1
 4ec:	1782                	slli	a5,a5,0x20
 4ee:	9381                	srli	a5,a5,0x20
 4f0:	fff7c793          	not	a5,a5
 4f4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 4f6:	15fd                	addi	a1,a1,-1
 4f8:	177d                	addi	a4,a4,-1
 4fa:	0005c683          	lbu	a3,0(a1)
 4fe:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 502:	fee79ae3          	bne	a5,a4,4f6 <memmove+0x46>
 506:	bfc9                	j	4d8 <memmove+0x28>

0000000000000508 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 508:	1141                	addi	sp,sp,-16
 50a:	e422                	sd	s0,8(sp)
 50c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 50e:	ca05                	beqz	a2,53e <memcmp+0x36>
 510:	fff6069b          	addiw	a3,a2,-1
 514:	1682                	slli	a3,a3,0x20
 516:	9281                	srli	a3,a3,0x20
 518:	0685                	addi	a3,a3,1
 51a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 51c:	00054783          	lbu	a5,0(a0)
 520:	0005c703          	lbu	a4,0(a1)
 524:	00e79863          	bne	a5,a4,534 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 528:	0505                	addi	a0,a0,1
    p2++;
 52a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 52c:	fed518e3          	bne	a0,a3,51c <memcmp+0x14>
  }
  return 0;
 530:	4501                	li	a0,0
 532:	a019                	j	538 <memcmp+0x30>
      return *p1 - *p2;
 534:	40e7853b          	subw	a0,a5,a4
}
 538:	6422                	ld	s0,8(sp)
 53a:	0141                	addi	sp,sp,16
 53c:	8082                	ret
  return 0;
 53e:	4501                	li	a0,0
 540:	bfe5                	j	538 <memcmp+0x30>

0000000000000542 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 542:	1141                	addi	sp,sp,-16
 544:	e406                	sd	ra,8(sp)
 546:	e022                	sd	s0,0(sp)
 548:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 54a:	00000097          	auipc	ra,0x0
 54e:	f66080e7          	jalr	-154(ra) # 4b0 <memmove>
}
 552:	60a2                	ld	ra,8(sp)
 554:	6402                	ld	s0,0(sp)
 556:	0141                	addi	sp,sp,16
 558:	8082                	ret

000000000000055a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 55a:	4885                	li	a7,1
 ecall
 55c:	00000073          	ecall
 ret
 560:	8082                	ret

0000000000000562 <exit>:
.global exit
exit:
 li a7, SYS_exit
 562:	4889                	li	a7,2
 ecall
 564:	00000073          	ecall
 ret
 568:	8082                	ret

000000000000056a <wait>:
.global wait
wait:
 li a7, SYS_wait
 56a:	488d                	li	a7,3
 ecall
 56c:	00000073          	ecall
 ret
 570:	8082                	ret

0000000000000572 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 572:	4891                	li	a7,4
 ecall
 574:	00000073          	ecall
 ret
 578:	8082                	ret

000000000000057a <read>:
.global read
read:
 li a7, SYS_read
 57a:	4895                	li	a7,5
 ecall
 57c:	00000073          	ecall
 ret
 580:	8082                	ret

0000000000000582 <write>:
.global write
write:
 li a7, SYS_write
 582:	48c1                	li	a7,16
 ecall
 584:	00000073          	ecall
 ret
 588:	8082                	ret

000000000000058a <close>:
.global close
close:
 li a7, SYS_close
 58a:	48d5                	li	a7,21
 ecall
 58c:	00000073          	ecall
 ret
 590:	8082                	ret

0000000000000592 <kill>:
.global kill
kill:
 li a7, SYS_kill
 592:	4899                	li	a7,6
 ecall
 594:	00000073          	ecall
 ret
 598:	8082                	ret

000000000000059a <exec>:
.global exec
exec:
 li a7, SYS_exec
 59a:	489d                	li	a7,7
 ecall
 59c:	00000073          	ecall
 ret
 5a0:	8082                	ret

00000000000005a2 <open>:
.global open
open:
 li a7, SYS_open
 5a2:	48bd                	li	a7,15
 ecall
 5a4:	00000073          	ecall
 ret
 5a8:	8082                	ret

00000000000005aa <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 5aa:	48c5                	li	a7,17
 ecall
 5ac:	00000073          	ecall
 ret
 5b0:	8082                	ret

00000000000005b2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 5b2:	48c9                	li	a7,18
 ecall
 5b4:	00000073          	ecall
 ret
 5b8:	8082                	ret

00000000000005ba <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 5ba:	48a1                	li	a7,8
 ecall
 5bc:	00000073          	ecall
 ret
 5c0:	8082                	ret

00000000000005c2 <link>:
.global link
link:
 li a7, SYS_link
 5c2:	48cd                	li	a7,19
 ecall
 5c4:	00000073          	ecall
 ret
 5c8:	8082                	ret

00000000000005ca <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 5ca:	48d1                	li	a7,20
 ecall
 5cc:	00000073          	ecall
 ret
 5d0:	8082                	ret

00000000000005d2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 5d2:	48a5                	li	a7,9
 ecall
 5d4:	00000073          	ecall
 ret
 5d8:	8082                	ret

00000000000005da <dup>:
.global dup
dup:
 li a7, SYS_dup
 5da:	48a9                	li	a7,10
 ecall
 5dc:	00000073          	ecall
 ret
 5e0:	8082                	ret

00000000000005e2 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 5e2:	48ad                	li	a7,11
 ecall
 5e4:	00000073          	ecall
 ret
 5e8:	8082                	ret

00000000000005ea <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 5ea:	48b1                	li	a7,12
 ecall
 5ec:	00000073          	ecall
 ret
 5f0:	8082                	ret

00000000000005f2 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 5f2:	48b5                	li	a7,13
 ecall
 5f4:	00000073          	ecall
 ret
 5f8:	8082                	ret

00000000000005fa <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5fa:	48b9                	li	a7,14
 ecall
 5fc:	00000073          	ecall
 ret
 600:	8082                	ret

0000000000000602 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 602:	1101                	addi	sp,sp,-32
 604:	ec06                	sd	ra,24(sp)
 606:	e822                	sd	s0,16(sp)
 608:	1000                	addi	s0,sp,32
 60a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 60e:	4605                	li	a2,1
 610:	fef40593          	addi	a1,s0,-17
 614:	00000097          	auipc	ra,0x0
 618:	f6e080e7          	jalr	-146(ra) # 582 <write>
}
 61c:	60e2                	ld	ra,24(sp)
 61e:	6442                	ld	s0,16(sp)
 620:	6105                	addi	sp,sp,32
 622:	8082                	ret

0000000000000624 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 624:	7139                	addi	sp,sp,-64
 626:	fc06                	sd	ra,56(sp)
 628:	f822                	sd	s0,48(sp)
 62a:	f426                	sd	s1,40(sp)
 62c:	0080                	addi	s0,sp,64
 62e:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 630:	c299                	beqz	a3,636 <printint+0x12>
 632:	0805cb63          	bltz	a1,6c8 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 636:	2581                	sext.w	a1,a1
  neg = 0;
 638:	4881                	li	a7,0
 63a:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 63e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 640:	2601                	sext.w	a2,a2
 642:	00000517          	auipc	a0,0x0
 646:	51e50513          	addi	a0,a0,1310 # b60 <digits>
 64a:	883a                	mv	a6,a4
 64c:	2705                	addiw	a4,a4,1
 64e:	02c5f7bb          	remuw	a5,a1,a2
 652:	1782                	slli	a5,a5,0x20
 654:	9381                	srli	a5,a5,0x20
 656:	97aa                	add	a5,a5,a0
 658:	0007c783          	lbu	a5,0(a5)
 65c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 660:	0005879b          	sext.w	a5,a1
 664:	02c5d5bb          	divuw	a1,a1,a2
 668:	0685                	addi	a3,a3,1
 66a:	fec7f0e3          	bgeu	a5,a2,64a <printint+0x26>
  if(neg)
 66e:	00088c63          	beqz	a7,686 <printint+0x62>
    buf[i++] = '-';
 672:	fd070793          	addi	a5,a4,-48
 676:	00878733          	add	a4,a5,s0
 67a:	02d00793          	li	a5,45
 67e:	fef70823          	sb	a5,-16(a4)
 682:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 686:	02e05c63          	blez	a4,6be <printint+0x9a>
 68a:	f04a                	sd	s2,32(sp)
 68c:	ec4e                	sd	s3,24(sp)
 68e:	fc040793          	addi	a5,s0,-64
 692:	00e78933          	add	s2,a5,a4
 696:	fff78993          	addi	s3,a5,-1
 69a:	99ba                	add	s3,s3,a4
 69c:	377d                	addiw	a4,a4,-1
 69e:	1702                	slli	a4,a4,0x20
 6a0:	9301                	srli	a4,a4,0x20
 6a2:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 6a6:	fff94583          	lbu	a1,-1(s2)
 6aa:	8526                	mv	a0,s1
 6ac:	00000097          	auipc	ra,0x0
 6b0:	f56080e7          	jalr	-170(ra) # 602 <putc>
  while(--i >= 0)
 6b4:	197d                	addi	s2,s2,-1
 6b6:	ff3918e3          	bne	s2,s3,6a6 <printint+0x82>
 6ba:	7902                	ld	s2,32(sp)
 6bc:	69e2                	ld	s3,24(sp)
}
 6be:	70e2                	ld	ra,56(sp)
 6c0:	7442                	ld	s0,48(sp)
 6c2:	74a2                	ld	s1,40(sp)
 6c4:	6121                	addi	sp,sp,64
 6c6:	8082                	ret
    x = -xx;
 6c8:	40b005bb          	negw	a1,a1
    neg = 1;
 6cc:	4885                	li	a7,1
    x = -xx;
 6ce:	b7b5                	j	63a <printint+0x16>

00000000000006d0 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 6d0:	715d                	addi	sp,sp,-80
 6d2:	e486                	sd	ra,72(sp)
 6d4:	e0a2                	sd	s0,64(sp)
 6d6:	f84a                	sd	s2,48(sp)
 6d8:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 6da:	0005c903          	lbu	s2,0(a1)
 6de:	1a090a63          	beqz	s2,892 <vprintf+0x1c2>
 6e2:	fc26                	sd	s1,56(sp)
 6e4:	f44e                	sd	s3,40(sp)
 6e6:	f052                	sd	s4,32(sp)
 6e8:	ec56                	sd	s5,24(sp)
 6ea:	e85a                	sd	s6,16(sp)
 6ec:	e45e                	sd	s7,8(sp)
 6ee:	8aaa                	mv	s5,a0
 6f0:	8bb2                	mv	s7,a2
 6f2:	00158493          	addi	s1,a1,1
  state = 0;
 6f6:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 6f8:	02500a13          	li	s4,37
 6fc:	4b55                	li	s6,21
 6fe:	a839                	j	71c <vprintf+0x4c>
        putc(fd, c);
 700:	85ca                	mv	a1,s2
 702:	8556                	mv	a0,s5
 704:	00000097          	auipc	ra,0x0
 708:	efe080e7          	jalr	-258(ra) # 602 <putc>
 70c:	a019                	j	712 <vprintf+0x42>
    } else if(state == '%'){
 70e:	01498d63          	beq	s3,s4,728 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 712:	0485                	addi	s1,s1,1
 714:	fff4c903          	lbu	s2,-1(s1)
 718:	16090763          	beqz	s2,886 <vprintf+0x1b6>
    if(state == 0){
 71c:	fe0999e3          	bnez	s3,70e <vprintf+0x3e>
      if(c == '%'){
 720:	ff4910e3          	bne	s2,s4,700 <vprintf+0x30>
        state = '%';
 724:	89d2                	mv	s3,s4
 726:	b7f5                	j	712 <vprintf+0x42>
      if(c == 'd'){
 728:	13490463          	beq	s2,s4,850 <vprintf+0x180>
 72c:	f9d9079b          	addiw	a5,s2,-99
 730:	0ff7f793          	zext.b	a5,a5
 734:	12fb6763          	bltu	s6,a5,862 <vprintf+0x192>
 738:	f9d9079b          	addiw	a5,s2,-99
 73c:	0ff7f713          	zext.b	a4,a5
 740:	12eb6163          	bltu	s6,a4,862 <vprintf+0x192>
 744:	00271793          	slli	a5,a4,0x2
 748:	00000717          	auipc	a4,0x0
 74c:	3c070713          	addi	a4,a4,960 # b08 <malloc+0x186>
 750:	97ba                	add	a5,a5,a4
 752:	439c                	lw	a5,0(a5)
 754:	97ba                	add	a5,a5,a4
 756:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 758:	008b8913          	addi	s2,s7,8
 75c:	4685                	li	a3,1
 75e:	4629                	li	a2,10
 760:	000ba583          	lw	a1,0(s7)
 764:	8556                	mv	a0,s5
 766:	00000097          	auipc	ra,0x0
 76a:	ebe080e7          	jalr	-322(ra) # 624 <printint>
 76e:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 770:	4981                	li	s3,0
 772:	b745                	j	712 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 774:	008b8913          	addi	s2,s7,8
 778:	4681                	li	a3,0
 77a:	4629                	li	a2,10
 77c:	000ba583          	lw	a1,0(s7)
 780:	8556                	mv	a0,s5
 782:	00000097          	auipc	ra,0x0
 786:	ea2080e7          	jalr	-350(ra) # 624 <printint>
 78a:	8bca                	mv	s7,s2
      state = 0;
 78c:	4981                	li	s3,0
 78e:	b751                	j	712 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 790:	008b8913          	addi	s2,s7,8
 794:	4681                	li	a3,0
 796:	4641                	li	a2,16
 798:	000ba583          	lw	a1,0(s7)
 79c:	8556                	mv	a0,s5
 79e:	00000097          	auipc	ra,0x0
 7a2:	e86080e7          	jalr	-378(ra) # 624 <printint>
 7a6:	8bca                	mv	s7,s2
      state = 0;
 7a8:	4981                	li	s3,0
 7aa:	b7a5                	j	712 <vprintf+0x42>
 7ac:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 7ae:	008b8c13          	addi	s8,s7,8
 7b2:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 7b6:	03000593          	li	a1,48
 7ba:	8556                	mv	a0,s5
 7bc:	00000097          	auipc	ra,0x0
 7c0:	e46080e7          	jalr	-442(ra) # 602 <putc>
  putc(fd, 'x');
 7c4:	07800593          	li	a1,120
 7c8:	8556                	mv	a0,s5
 7ca:	00000097          	auipc	ra,0x0
 7ce:	e38080e7          	jalr	-456(ra) # 602 <putc>
 7d2:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7d4:	00000b97          	auipc	s7,0x0
 7d8:	38cb8b93          	addi	s7,s7,908 # b60 <digits>
 7dc:	03c9d793          	srli	a5,s3,0x3c
 7e0:	97de                	add	a5,a5,s7
 7e2:	0007c583          	lbu	a1,0(a5)
 7e6:	8556                	mv	a0,s5
 7e8:	00000097          	auipc	ra,0x0
 7ec:	e1a080e7          	jalr	-486(ra) # 602 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7f0:	0992                	slli	s3,s3,0x4
 7f2:	397d                	addiw	s2,s2,-1
 7f4:	fe0914e3          	bnez	s2,7dc <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 7f8:	8be2                	mv	s7,s8
      state = 0;
 7fa:	4981                	li	s3,0
 7fc:	6c02                	ld	s8,0(sp)
 7fe:	bf11                	j	712 <vprintf+0x42>
        s = va_arg(ap, char*);
 800:	008b8993          	addi	s3,s7,8
 804:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 808:	02090163          	beqz	s2,82a <vprintf+0x15a>
        while(*s != 0){
 80c:	00094583          	lbu	a1,0(s2)
 810:	c9a5                	beqz	a1,880 <vprintf+0x1b0>
          putc(fd, *s);
 812:	8556                	mv	a0,s5
 814:	00000097          	auipc	ra,0x0
 818:	dee080e7          	jalr	-530(ra) # 602 <putc>
          s++;
 81c:	0905                	addi	s2,s2,1
        while(*s != 0){
 81e:	00094583          	lbu	a1,0(s2)
 822:	f9e5                	bnez	a1,812 <vprintf+0x142>
        s = va_arg(ap, char*);
 824:	8bce                	mv	s7,s3
      state = 0;
 826:	4981                	li	s3,0
 828:	b5ed                	j	712 <vprintf+0x42>
          s = "(null)";
 82a:	00000917          	auipc	s2,0x0
 82e:	2d690913          	addi	s2,s2,726 # b00 <malloc+0x17e>
        while(*s != 0){
 832:	02800593          	li	a1,40
 836:	bff1                	j	812 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 838:	008b8913          	addi	s2,s7,8
 83c:	000bc583          	lbu	a1,0(s7)
 840:	8556                	mv	a0,s5
 842:	00000097          	auipc	ra,0x0
 846:	dc0080e7          	jalr	-576(ra) # 602 <putc>
 84a:	8bca                	mv	s7,s2
      state = 0;
 84c:	4981                	li	s3,0
 84e:	b5d1                	j	712 <vprintf+0x42>
        putc(fd, c);
 850:	02500593          	li	a1,37
 854:	8556                	mv	a0,s5
 856:	00000097          	auipc	ra,0x0
 85a:	dac080e7          	jalr	-596(ra) # 602 <putc>
      state = 0;
 85e:	4981                	li	s3,0
 860:	bd4d                	j	712 <vprintf+0x42>
        putc(fd, '%');
 862:	02500593          	li	a1,37
 866:	8556                	mv	a0,s5
 868:	00000097          	auipc	ra,0x0
 86c:	d9a080e7          	jalr	-614(ra) # 602 <putc>
        putc(fd, c);
 870:	85ca                	mv	a1,s2
 872:	8556                	mv	a0,s5
 874:	00000097          	auipc	ra,0x0
 878:	d8e080e7          	jalr	-626(ra) # 602 <putc>
      state = 0;
 87c:	4981                	li	s3,0
 87e:	bd51                	j	712 <vprintf+0x42>
        s = va_arg(ap, char*);
 880:	8bce                	mv	s7,s3
      state = 0;
 882:	4981                	li	s3,0
 884:	b579                	j	712 <vprintf+0x42>
 886:	74e2                	ld	s1,56(sp)
 888:	79a2                	ld	s3,40(sp)
 88a:	7a02                	ld	s4,32(sp)
 88c:	6ae2                	ld	s5,24(sp)
 88e:	6b42                	ld	s6,16(sp)
 890:	6ba2                	ld	s7,8(sp)
    }
  }
}
 892:	60a6                	ld	ra,72(sp)
 894:	6406                	ld	s0,64(sp)
 896:	7942                	ld	s2,48(sp)
 898:	6161                	addi	sp,sp,80
 89a:	8082                	ret

000000000000089c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 89c:	715d                	addi	sp,sp,-80
 89e:	ec06                	sd	ra,24(sp)
 8a0:	e822                	sd	s0,16(sp)
 8a2:	1000                	addi	s0,sp,32
 8a4:	e010                	sd	a2,0(s0)
 8a6:	e414                	sd	a3,8(s0)
 8a8:	e818                	sd	a4,16(s0)
 8aa:	ec1c                	sd	a5,24(s0)
 8ac:	03043023          	sd	a6,32(s0)
 8b0:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8b4:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8b8:	8622                	mv	a2,s0
 8ba:	00000097          	auipc	ra,0x0
 8be:	e16080e7          	jalr	-490(ra) # 6d0 <vprintf>
}
 8c2:	60e2                	ld	ra,24(sp)
 8c4:	6442                	ld	s0,16(sp)
 8c6:	6161                	addi	sp,sp,80
 8c8:	8082                	ret

00000000000008ca <printf>:

void
printf(const char *fmt, ...)
{
 8ca:	711d                	addi	sp,sp,-96
 8cc:	ec06                	sd	ra,24(sp)
 8ce:	e822                	sd	s0,16(sp)
 8d0:	1000                	addi	s0,sp,32
 8d2:	e40c                	sd	a1,8(s0)
 8d4:	e810                	sd	a2,16(s0)
 8d6:	ec14                	sd	a3,24(s0)
 8d8:	f018                	sd	a4,32(s0)
 8da:	f41c                	sd	a5,40(s0)
 8dc:	03043823          	sd	a6,48(s0)
 8e0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8e4:	00840613          	addi	a2,s0,8
 8e8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8ec:	85aa                	mv	a1,a0
 8ee:	4505                	li	a0,1
 8f0:	00000097          	auipc	ra,0x0
 8f4:	de0080e7          	jalr	-544(ra) # 6d0 <vprintf>
}
 8f8:	60e2                	ld	ra,24(sp)
 8fa:	6442                	ld	s0,16(sp)
 8fc:	6125                	addi	sp,sp,96
 8fe:	8082                	ret

0000000000000900 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 900:	1141                	addi	sp,sp,-16
 902:	e422                	sd	s0,8(sp)
 904:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 906:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 90a:	00000797          	auipc	a5,0x0
 90e:	6f67b783          	ld	a5,1782(a5) # 1000 <freep>
 912:	a02d                	j	93c <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 914:	4618                	lw	a4,8(a2)
 916:	9f2d                	addw	a4,a4,a1
 918:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 91c:	6398                	ld	a4,0(a5)
 91e:	6310                	ld	a2,0(a4)
 920:	a83d                	j	95e <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 922:	ff852703          	lw	a4,-8(a0)
 926:	9f31                	addw	a4,a4,a2
 928:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 92a:	ff053683          	ld	a3,-16(a0)
 92e:	a091                	j	972 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 930:	6398                	ld	a4,0(a5)
 932:	00e7e463          	bltu	a5,a4,93a <free+0x3a>
 936:	00e6ea63          	bltu	a3,a4,94a <free+0x4a>
{
 93a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 93c:	fed7fae3          	bgeu	a5,a3,930 <free+0x30>
 940:	6398                	ld	a4,0(a5)
 942:	00e6e463          	bltu	a3,a4,94a <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 946:	fee7eae3          	bltu	a5,a4,93a <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 94a:	ff852583          	lw	a1,-8(a0)
 94e:	6390                	ld	a2,0(a5)
 950:	02059813          	slli	a6,a1,0x20
 954:	01c85713          	srli	a4,a6,0x1c
 958:	9736                	add	a4,a4,a3
 95a:	fae60de3          	beq	a2,a4,914 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 95e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 962:	4790                	lw	a2,8(a5)
 964:	02061593          	slli	a1,a2,0x20
 968:	01c5d713          	srli	a4,a1,0x1c
 96c:	973e                	add	a4,a4,a5
 96e:	fae68ae3          	beq	a3,a4,922 <free+0x22>
    p->s.ptr = bp->s.ptr;
 972:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 974:	00000717          	auipc	a4,0x0
 978:	68f73623          	sd	a5,1676(a4) # 1000 <freep>
}
 97c:	6422                	ld	s0,8(sp)
 97e:	0141                	addi	sp,sp,16
 980:	8082                	ret

0000000000000982 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 982:	7139                	addi	sp,sp,-64
 984:	fc06                	sd	ra,56(sp)
 986:	f822                	sd	s0,48(sp)
 988:	f426                	sd	s1,40(sp)
 98a:	ec4e                	sd	s3,24(sp)
 98c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 98e:	02051493          	slli	s1,a0,0x20
 992:	9081                	srli	s1,s1,0x20
 994:	04bd                	addi	s1,s1,15
 996:	8091                	srli	s1,s1,0x4
 998:	0014899b          	addiw	s3,s1,1
 99c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 99e:	00000517          	auipc	a0,0x0
 9a2:	66253503          	ld	a0,1634(a0) # 1000 <freep>
 9a6:	c915                	beqz	a0,9da <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9a8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9aa:	4798                	lw	a4,8(a5)
 9ac:	08977e63          	bgeu	a4,s1,a48 <malloc+0xc6>
 9b0:	f04a                	sd	s2,32(sp)
 9b2:	e852                	sd	s4,16(sp)
 9b4:	e456                	sd	s5,8(sp)
 9b6:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 9b8:	8a4e                	mv	s4,s3
 9ba:	0009871b          	sext.w	a4,s3
 9be:	6685                	lui	a3,0x1
 9c0:	00d77363          	bgeu	a4,a3,9c6 <malloc+0x44>
 9c4:	6a05                	lui	s4,0x1
 9c6:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9ca:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9ce:	00000917          	auipc	s2,0x0
 9d2:	63290913          	addi	s2,s2,1586 # 1000 <freep>
  if(p == (char*)-1)
 9d6:	5afd                	li	s5,-1
 9d8:	a091                	j	a1c <malloc+0x9a>
 9da:	f04a                	sd	s2,32(sp)
 9dc:	e852                	sd	s4,16(sp)
 9de:	e456                	sd	s5,8(sp)
 9e0:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 9e2:	00000797          	auipc	a5,0x0
 9e6:	63e78793          	addi	a5,a5,1598 # 1020 <base>
 9ea:	00000717          	auipc	a4,0x0
 9ee:	60f73b23          	sd	a5,1558(a4) # 1000 <freep>
 9f2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9f4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9f8:	b7c1                	j	9b8 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 9fa:	6398                	ld	a4,0(a5)
 9fc:	e118                	sd	a4,0(a0)
 9fe:	a08d                	j	a60 <malloc+0xde>
  hp->s.size = nu;
 a00:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a04:	0541                	addi	a0,a0,16
 a06:	00000097          	auipc	ra,0x0
 a0a:	efa080e7          	jalr	-262(ra) # 900 <free>
  return freep;
 a0e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a12:	c13d                	beqz	a0,a78 <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a14:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a16:	4798                	lw	a4,8(a5)
 a18:	02977463          	bgeu	a4,s1,a40 <malloc+0xbe>
    if(p == freep)
 a1c:	00093703          	ld	a4,0(s2)
 a20:	853e                	mv	a0,a5
 a22:	fef719e3          	bne	a4,a5,a14 <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 a26:	8552                	mv	a0,s4
 a28:	00000097          	auipc	ra,0x0
 a2c:	bc2080e7          	jalr	-1086(ra) # 5ea <sbrk>
  if(p == (char*)-1)
 a30:	fd5518e3          	bne	a0,s5,a00 <malloc+0x7e>
        return 0;
 a34:	4501                	li	a0,0
 a36:	7902                	ld	s2,32(sp)
 a38:	6a42                	ld	s4,16(sp)
 a3a:	6aa2                	ld	s5,8(sp)
 a3c:	6b02                	ld	s6,0(sp)
 a3e:	a03d                	j	a6c <malloc+0xea>
 a40:	7902                	ld	s2,32(sp)
 a42:	6a42                	ld	s4,16(sp)
 a44:	6aa2                	ld	s5,8(sp)
 a46:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 a48:	fae489e3          	beq	s1,a4,9fa <malloc+0x78>
        p->s.size -= nunits;
 a4c:	4137073b          	subw	a4,a4,s3
 a50:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a52:	02071693          	slli	a3,a4,0x20
 a56:	01c6d713          	srli	a4,a3,0x1c
 a5a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a5c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a60:	00000717          	auipc	a4,0x0
 a64:	5aa73023          	sd	a0,1440(a4) # 1000 <freep>
      return (void*)(p + 1);
 a68:	01078513          	addi	a0,a5,16
  }
}
 a6c:	70e2                	ld	ra,56(sp)
 a6e:	7442                	ld	s0,48(sp)
 a70:	74a2                	ld	s1,40(sp)
 a72:	69e2                	ld	s3,24(sp)
 a74:	6121                	addi	sp,sp,64
 a76:	8082                	ret
 a78:	7902                	ld	s2,32(sp)
 a7a:	6a42                	ld	s4,16(sp)
 a7c:	6aa2                	ld	s5,8(sp)
 a7e:	6b02                	ld	s6,0(sp)
 a80:	b7f5                	j	a6c <malloc+0xea>
