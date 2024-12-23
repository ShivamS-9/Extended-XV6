
user/_syscount:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <syscall_name>:
    }

    exit(0);
}
char *syscall_name(int mask)
{
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
    switch (mask)
   6:	8005071b          	addiw	a4,a0,-2048
   a:	14070c63          	beqz	a4,162 <syscall_name+0x162>
   e:	87aa                	mv	a5,a0
  10:	6705                	lui	a4,0x1
  12:	80070713          	addi	a4,a4,-2048 # 800 <vprintf+0x144>
  16:	08a74a63          	blt	a4,a0,aa <syscall_name+0xaa>
  1a:	04000713          	li	a4,64
  1e:	14e50763          	beq	a0,a4,16c <syscall_name+0x16c>
  22:	02a75563          	bge	a4,a0,4c <syscall_name+0x4c>
  26:	20000713          	li	a4,512
    case (1 << 7):
        return "exec";
    case (1 << 8):
        return "fstat";
    case (1 << 9):
        return "chdir";
  2a:	00001517          	auipc	a0,0x1
  2e:	a7650513          	addi	a0,a0,-1418 # aa0 <malloc+0x11a>
    switch (mask)
  32:	06e78963          	beq	a5,a4,a4 <syscall_name+0xa4>
  36:	04f75763          	bge	a4,a5,84 <syscall_name+0x84>
  3a:	40000713          	li	a4,1024
  3e:	14e79b63          	bne	a5,a4,194 <syscall_name+0x194>
    case (1 << 10):
        return "dup";
  42:	00001517          	auipc	a0,0x1
  46:	aae50513          	addi	a0,a0,-1362 # af0 <malloc+0x16a>
  4a:	a8a9                	j	a4 <syscall_name+0xa4>
    switch (mask)
  4c:	ffe5071b          	addiw	a4,a0,-2
  50:	46f9                	li	a3,30
  52:	12e6e263          	bltu	a3,a4,176 <syscall_name+0x176>
  56:	02000713          	li	a4,32
  5a:	02a76063          	bltu	a4,a0,7a <syscall_name+0x7a>
  5e:	050a                	slli	a0,a0,0x2
  60:	00001717          	auipc	a4,0x1
  64:	b2870713          	addi	a4,a4,-1240 # b88 <malloc+0x202>
  68:	953a                	add	a0,a0,a4
  6a:	411c                	lw	a5,0(a0)
  6c:	97ba                	add	a5,a5,a4
  6e:	8782                	jr	a5
  70:	00001517          	auipc	a0,0x1
  74:	a4050513          	addi	a0,a0,-1472 # ab0 <malloc+0x12a>
  78:	a035                	j	a4 <syscall_name+0xa4>
    case (1 << 20):
        return "mkdir";
    case (1 << 21):
        return "close";
    default:
        return "unknown";
  7a:	00001517          	auipc	a0,0x1
  7e:	9f650513          	addi	a0,a0,-1546 # a70 <malloc+0xea>
  82:	a00d                	j	a4 <syscall_name+0xa4>
    switch (mask)
  84:	08000713          	li	a4,128
        return "exec";
  88:	00001517          	auipc	a0,0x1
  8c:	a2050513          	addi	a0,a0,-1504 # aa8 <malloc+0x122>
    switch (mask)
  90:	00e78a63          	beq	a5,a4,a4 <syscall_name+0xa4>
  94:	10000713          	li	a4,256
  98:	0ee79963          	bne	a5,a4,18a <syscall_name+0x18a>
        return "fstat";
  9c:	00001517          	auipc	a0,0x1
  a0:	a1c50513          	addi	a0,a0,-1508 # ab8 <malloc+0x132>
    }
  a4:	6422                	ld	s0,8(sp)
  a6:	0141                	addi	sp,sp,16
  a8:	8082                	ret
    switch (mask)
  aa:	00020737          	lui	a4,0x20
  ae:	0ee50863          	beq	a0,a4,19e <syscall_name+0x19e>
  b2:	02a75563          	bge	a4,a0,dc <syscall_name+0xdc>
  b6:	00100737          	lui	a4,0x100
        return "mkdir";
  ba:	00001517          	auipc	a0,0x1
  be:	a3e50513          	addi	a0,a0,-1474 # af8 <malloc+0x172>
    switch (mask)
  c2:	fee781e3          	beq	a5,a4,a4 <syscall_name+0xa4>
  c6:	04f75e63          	bge	a4,a5,122 <syscall_name+0x122>
  ca:	00200737          	lui	a4,0x200
  ce:	10e79163          	bne	a5,a4,1d0 <syscall_name+0x1d0>
        return "close";
  d2:	00001517          	auipc	a0,0x1
  d6:	a4650513          	addi	a0,a0,-1466 # b18 <malloc+0x192>
  da:	b7e9                	j	a4 <syscall_name+0xa4>
    switch (mask)
  dc:	6711                	lui	a4,0x4
  de:	0ce50563          	beq	a0,a4,1a8 <syscall_name+0x1a8>
  e2:	02a75163          	bge	a4,a0,104 <syscall_name+0x104>
  e6:	6721                	lui	a4,0x8
        return "open";
  e8:	00001517          	auipc	a0,0x1
  ec:	a0050513          	addi	a0,a0,-1536 # ae8 <malloc+0x162>
    switch (mask)
  f0:	fae78ae3          	beq	a5,a4,a4 <syscall_name+0xa4>
  f4:	6741                	lui	a4,0x10
  f6:	0ce79363          	bne	a5,a4,1bc <syscall_name+0x1bc>
        return "write";
  fa:	00001517          	auipc	a0,0x1
  fe:	a0e50513          	addi	a0,a0,-1522 # b08 <malloc+0x182>
 102:	b74d                	j	a4 <syscall_name+0xa4>
    switch (mask)
 104:	6705                	lui	a4,0x1
        return "sbrk";
 106:	00001517          	auipc	a0,0x1
 10a:	9ca50513          	addi	a0,a0,-1590 # ad0 <malloc+0x14a>
    switch (mask)
 10e:	f8e78be3          	beq	a5,a4,a4 <syscall_name+0xa4>
 112:	6709                	lui	a4,0x2
 114:	08e79f63          	bne	a5,a4,1b2 <syscall_name+0x1b2>
        return "sleep";
 118:	00001517          	auipc	a0,0x1
 11c:	9c850513          	addi	a0,a0,-1592 # ae0 <malloc+0x15a>
 120:	b751                	j	a4 <syscall_name+0xa4>
    switch (mask)
 122:	00040737          	lui	a4,0x40
        return "unlink";
 126:	00001517          	auipc	a0,0x1
 12a:	9da50513          	addi	a0,a0,-1574 # b00 <malloc+0x17a>
    switch (mask)
 12e:	f6e78be3          	beq	a5,a4,a4 <syscall_name+0xa4>
 132:	00080737          	lui	a4,0x80
 136:	08e79863          	bne	a5,a4,1c6 <syscall_name+0x1c6>
        return "link";
 13a:	00001517          	auipc	a0,0x1
 13e:	9d650513          	addi	a0,a0,-1578 # b10 <malloc+0x18a>
 142:	b78d                	j	a4 <syscall_name+0xa4>
        return "wait";
 144:	00001517          	auipc	a0,0x1
 148:	93c50513          	addi	a0,a0,-1732 # a80 <malloc+0xfa>
 14c:	bfa1                	j	a4 <syscall_name+0xa4>
        return "pipe";
 14e:	00001517          	auipc	a0,0x1
 152:	93a50513          	addi	a0,a0,-1734 # a88 <malloc+0x102>
 156:	b7b9                	j	a4 <syscall_name+0xa4>
        return "read";
 158:	00001517          	auipc	a0,0x1
 15c:	93850513          	addi	a0,a0,-1736 # a90 <malloc+0x10a>
 160:	b791                	j	a4 <syscall_name+0xa4>
        return "getpid";
 162:	00001517          	auipc	a0,0x1
 166:	93650513          	addi	a0,a0,-1738 # a98 <malloc+0x112>
 16a:	bf2d                	j	a4 <syscall_name+0xa4>
        return "kill";
 16c:	00001517          	auipc	a0,0x1
 170:	95450513          	addi	a0,a0,-1708 # ac0 <malloc+0x13a>
 174:	bf05                	j	a4 <syscall_name+0xa4>
        return "unknown";
 176:	00001517          	auipc	a0,0x1
 17a:	8fa50513          	addi	a0,a0,-1798 # a70 <malloc+0xea>
 17e:	b71d                	j	a4 <syscall_name+0xa4>
        return "fork";
 180:	00001517          	auipc	a0,0x1
 184:	8f850513          	addi	a0,a0,-1800 # a78 <malloc+0xf2>
 188:	bf31                	j	a4 <syscall_name+0xa4>
        return "unknown";
 18a:	00001517          	auipc	a0,0x1
 18e:	8e650513          	addi	a0,a0,-1818 # a70 <malloc+0xea>
 192:	bf09                	j	a4 <syscall_name+0xa4>
 194:	00001517          	auipc	a0,0x1
 198:	8dc50513          	addi	a0,a0,-1828 # a70 <malloc+0xea>
 19c:	b721                	j	a4 <syscall_name+0xa4>
        return "mknod";
 19e:	00001517          	auipc	a0,0x1
 1a2:	93a50513          	addi	a0,a0,-1734 # ad8 <malloc+0x152>
 1a6:	bdfd                	j	a4 <syscall_name+0xa4>
        return "uptime";
 1a8:	00001517          	auipc	a0,0x1
 1ac:	92050513          	addi	a0,a0,-1760 # ac8 <malloc+0x142>
 1b0:	bdd5                	j	a4 <syscall_name+0xa4>
        return "unknown";
 1b2:	00001517          	auipc	a0,0x1
 1b6:	8be50513          	addi	a0,a0,-1858 # a70 <malloc+0xea>
 1ba:	b5ed                	j	a4 <syscall_name+0xa4>
 1bc:	00001517          	auipc	a0,0x1
 1c0:	8b450513          	addi	a0,a0,-1868 # a70 <malloc+0xea>
 1c4:	b5c5                	j	a4 <syscall_name+0xa4>
 1c6:	00001517          	auipc	a0,0x1
 1ca:	8aa50513          	addi	a0,a0,-1878 # a70 <malloc+0xea>
 1ce:	bdd9                	j	a4 <syscall_name+0xa4>
 1d0:	00001517          	auipc	a0,0x1
 1d4:	8a050513          	addi	a0,a0,-1888 # a70 <malloc+0xea>
 1d8:	b5f1                	j	a4 <syscall_name+0xa4>

00000000000001da <main>:
{
 1da:	7139                	addi	sp,sp,-64
 1dc:	fc06                	sd	ra,56(sp)
 1de:	f822                	sd	s0,48(sp)
 1e0:	f426                	sd	s1,40(sp)
 1e2:	f04a                	sd	s2,32(sp)
 1e4:	ec4e                	sd	s3,24(sp)
 1e6:	e852                	sd	s4,16(sp)
 1e8:	0080                	addi	s0,sp,64
    if (argc < 3)
 1ea:	4789                	li	a5,2
 1ec:	02a7c063          	blt	a5,a0,20c <main+0x32>
        fprintf(2, "Usage: syscount <mask> command [args]\n");
 1f0:	00001597          	auipc	a1,0x1
 1f4:	93058593          	addi	a1,a1,-1744 # b20 <malloc+0x19a>
 1f8:	4509                	li	a0,2
 1fa:	00000097          	auipc	ra,0x0
 1fe:	6a0080e7          	jalr	1696(ra) # 89a <fprintf>
        exit(0);
 202:	4501                	li	a0,0
 204:	00000097          	auipc	ra,0x0
 208:	33c080e7          	jalr	828(ra) # 540 <exit>
 20c:	84aa                	mv	s1,a0
 20e:	892e                	mv	s2,a1
    int mask = atoi(argv[1]);
 210:	6588                	ld	a0,8(a1)
 212:	00000097          	auipc	ra,0x0
 216:	232080e7          	jalr	562(ra) # 444 <atoi>
 21a:	8a2a                	mv	s4,a0
    int pid = fork();
 21c:	00000097          	auipc	ra,0x0
 220:	31c080e7          	jalr	796(ra) # 538 <fork>
 224:	89aa                	mv	s3,a0
    if (pid == 0)
 226:	c529                	beqz	a0,270 <main+0x96>
    else if (pid > 0)
 228:	06a05e63          	blez	a0,2a4 <main+0xca>
        wait(&status); // Wait for the child to exit
 22c:	fcc40513          	addi	a0,s0,-52
 230:	00000097          	auipc	ra,0x0
 234:	318080e7          	jalr	792(ra) # 548 <wait>
        int count = getSysCount(mask);
 238:	8552                	mv	a0,s4
 23a:	00000097          	auipc	ra,0x0
 23e:	3ae080e7          	jalr	942(ra) # 5e8 <getSysCount>
 242:	84aa                	mv	s1,a0
        fprintf(1, "PID %d called %s %d times.\n", pid, syscall_name(mask), count);
 244:	8552                	mv	a0,s4
 246:	00000097          	auipc	ra,0x0
 24a:	dba080e7          	jalr	-582(ra) # 0 <syscall_name>
 24e:	86aa                	mv	a3,a0
 250:	8726                	mv	a4,s1
 252:	864e                	mv	a2,s3
 254:	00001597          	auipc	a1,0x1
 258:	90458593          	addi	a1,a1,-1788 # b58 <malloc+0x1d2>
 25c:	4505                	li	a0,1
 25e:	00000097          	auipc	ra,0x0
 262:	63c080e7          	jalr	1596(ra) # 89a <fprintf>
    exit(0);
 266:	4501                	li	a0,0
 268:	00000097          	auipc	ra,0x0
 26c:	2d8080e7          	jalr	728(ra) # 540 <exit>
        argv[argc] = 0;                                 // Null-terminate the arguments
 270:	048e                	slli	s1,s1,0x3
 272:	94ca                	add	s1,s1,s2
 274:	0004b023          	sd	zero,0(s1)
        exec(argv[2], argv + 2);
 278:	01090593          	addi	a1,s2,16
 27c:	01093503          	ld	a0,16(s2)
 280:	00000097          	auipc	ra,0x0
 284:	2f8080e7          	jalr	760(ra) # 578 <exec>
        fprintf(2, "exec failed\n");
 288:	00001597          	auipc	a1,0x1
 28c:	8c058593          	addi	a1,a1,-1856 # b48 <malloc+0x1c2>
 290:	4509                	li	a0,2
 292:	00000097          	auipc	ra,0x0
 296:	608080e7          	jalr	1544(ra) # 89a <fprintf>
        exit(0);
 29a:	4501                	li	a0,0
 29c:	00000097          	auipc	ra,0x0
 2a0:	2a4080e7          	jalr	676(ra) # 540 <exit>
        fprintf(2, "fork failed\n");
 2a4:	00001597          	auipc	a1,0x1
 2a8:	8d458593          	addi	a1,a1,-1836 # b78 <malloc+0x1f2>
 2ac:	4509                	li	a0,2
 2ae:	00000097          	auipc	ra,0x0
 2b2:	5ec080e7          	jalr	1516(ra) # 89a <fprintf>
 2b6:	bf45                	j	266 <main+0x8c>

00000000000002b8 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 2b8:	1141                	addi	sp,sp,-16
 2ba:	e406                	sd	ra,8(sp)
 2bc:	e022                	sd	s0,0(sp)
 2be:	0800                	addi	s0,sp,16
  extern int main();
  main();
 2c0:	00000097          	auipc	ra,0x0
 2c4:	f1a080e7          	jalr	-230(ra) # 1da <main>
  exit(0);
 2c8:	4501                	li	a0,0
 2ca:	00000097          	auipc	ra,0x0
 2ce:	276080e7          	jalr	630(ra) # 540 <exit>

00000000000002d2 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 2d2:	1141                	addi	sp,sp,-16
 2d4:	e422                	sd	s0,8(sp)
 2d6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2d8:	87aa                	mv	a5,a0
 2da:	0585                	addi	a1,a1,1
 2dc:	0785                	addi	a5,a5,1
 2de:	fff5c703          	lbu	a4,-1(a1)
 2e2:	fee78fa3          	sb	a4,-1(a5)
 2e6:	fb75                	bnez	a4,2da <strcpy+0x8>
    ;
  return os;
}
 2e8:	6422                	ld	s0,8(sp)
 2ea:	0141                	addi	sp,sp,16
 2ec:	8082                	ret

00000000000002ee <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2ee:	1141                	addi	sp,sp,-16
 2f0:	e422                	sd	s0,8(sp)
 2f2:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 2f4:	00054783          	lbu	a5,0(a0)
 2f8:	cb91                	beqz	a5,30c <strcmp+0x1e>
 2fa:	0005c703          	lbu	a4,0(a1)
 2fe:	00f71763          	bne	a4,a5,30c <strcmp+0x1e>
    p++, q++;
 302:	0505                	addi	a0,a0,1
 304:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 306:	00054783          	lbu	a5,0(a0)
 30a:	fbe5                	bnez	a5,2fa <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 30c:	0005c503          	lbu	a0,0(a1)
}
 310:	40a7853b          	subw	a0,a5,a0
 314:	6422                	ld	s0,8(sp)
 316:	0141                	addi	sp,sp,16
 318:	8082                	ret

000000000000031a <strlen>:

uint
strlen(const char *s)
{
 31a:	1141                	addi	sp,sp,-16
 31c:	e422                	sd	s0,8(sp)
 31e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 320:	00054783          	lbu	a5,0(a0)
 324:	cf91                	beqz	a5,340 <strlen+0x26>
 326:	0505                	addi	a0,a0,1
 328:	87aa                	mv	a5,a0
 32a:	4685                	li	a3,1
 32c:	9e89                	subw	a3,a3,a0
 32e:	00f6853b          	addw	a0,a3,a5
 332:	0785                	addi	a5,a5,1
 334:	fff7c703          	lbu	a4,-1(a5)
 338:	fb7d                	bnez	a4,32e <strlen+0x14>
    ;
  return n;
}
 33a:	6422                	ld	s0,8(sp)
 33c:	0141                	addi	sp,sp,16
 33e:	8082                	ret
  for(n = 0; s[n]; n++)
 340:	4501                	li	a0,0
 342:	bfe5                	j	33a <strlen+0x20>

0000000000000344 <memset>:

void*
memset(void *dst, int c, uint n)
{
 344:	1141                	addi	sp,sp,-16
 346:	e422                	sd	s0,8(sp)
 348:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 34a:	ca19                	beqz	a2,360 <memset+0x1c>
 34c:	87aa                	mv	a5,a0
 34e:	1602                	slli	a2,a2,0x20
 350:	9201                	srli	a2,a2,0x20
 352:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 356:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 35a:	0785                	addi	a5,a5,1
 35c:	fee79de3          	bne	a5,a4,356 <memset+0x12>
  }
  return dst;
}
 360:	6422                	ld	s0,8(sp)
 362:	0141                	addi	sp,sp,16
 364:	8082                	ret

0000000000000366 <strchr>:

char*
strchr(const char *s, char c)
{
 366:	1141                	addi	sp,sp,-16
 368:	e422                	sd	s0,8(sp)
 36a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 36c:	00054783          	lbu	a5,0(a0)
 370:	cb99                	beqz	a5,386 <strchr+0x20>
    if(*s == c)
 372:	00f58763          	beq	a1,a5,380 <strchr+0x1a>
  for(; *s; s++)
 376:	0505                	addi	a0,a0,1
 378:	00054783          	lbu	a5,0(a0)
 37c:	fbfd                	bnez	a5,372 <strchr+0xc>
      return (char*)s;
  return 0;
 37e:	4501                	li	a0,0
}
 380:	6422                	ld	s0,8(sp)
 382:	0141                	addi	sp,sp,16
 384:	8082                	ret
  return 0;
 386:	4501                	li	a0,0
 388:	bfe5                	j	380 <strchr+0x1a>

000000000000038a <gets>:

char*
gets(char *buf, int max)
{
 38a:	711d                	addi	sp,sp,-96
 38c:	ec86                	sd	ra,88(sp)
 38e:	e8a2                	sd	s0,80(sp)
 390:	e4a6                	sd	s1,72(sp)
 392:	e0ca                	sd	s2,64(sp)
 394:	fc4e                	sd	s3,56(sp)
 396:	f852                	sd	s4,48(sp)
 398:	f456                	sd	s5,40(sp)
 39a:	f05a                	sd	s6,32(sp)
 39c:	ec5e                	sd	s7,24(sp)
 39e:	1080                	addi	s0,sp,96
 3a0:	8baa                	mv	s7,a0
 3a2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3a4:	892a                	mv	s2,a0
 3a6:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 3a8:	4aa9                	li	s5,10
 3aa:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 3ac:	89a6                	mv	s3,s1
 3ae:	2485                	addiw	s1,s1,1
 3b0:	0344d863          	bge	s1,s4,3e0 <gets+0x56>
    cc = read(0, &c, 1);
 3b4:	4605                	li	a2,1
 3b6:	faf40593          	addi	a1,s0,-81
 3ba:	4501                	li	a0,0
 3bc:	00000097          	auipc	ra,0x0
 3c0:	19c080e7          	jalr	412(ra) # 558 <read>
    if(cc < 1)
 3c4:	00a05e63          	blez	a0,3e0 <gets+0x56>
    buf[i++] = c;
 3c8:	faf44783          	lbu	a5,-81(s0)
 3cc:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 3d0:	01578763          	beq	a5,s5,3de <gets+0x54>
 3d4:	0905                	addi	s2,s2,1
 3d6:	fd679be3          	bne	a5,s6,3ac <gets+0x22>
  for(i=0; i+1 < max; ){
 3da:	89a6                	mv	s3,s1
 3dc:	a011                	j	3e0 <gets+0x56>
 3de:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 3e0:	99de                	add	s3,s3,s7
 3e2:	00098023          	sb	zero,0(s3)
  return buf;
}
 3e6:	855e                	mv	a0,s7
 3e8:	60e6                	ld	ra,88(sp)
 3ea:	6446                	ld	s0,80(sp)
 3ec:	64a6                	ld	s1,72(sp)
 3ee:	6906                	ld	s2,64(sp)
 3f0:	79e2                	ld	s3,56(sp)
 3f2:	7a42                	ld	s4,48(sp)
 3f4:	7aa2                	ld	s5,40(sp)
 3f6:	7b02                	ld	s6,32(sp)
 3f8:	6be2                	ld	s7,24(sp)
 3fa:	6125                	addi	sp,sp,96
 3fc:	8082                	ret

00000000000003fe <stat>:

int
stat(const char *n, struct stat *st)
{
 3fe:	1101                	addi	sp,sp,-32
 400:	ec06                	sd	ra,24(sp)
 402:	e822                	sd	s0,16(sp)
 404:	e426                	sd	s1,8(sp)
 406:	e04a                	sd	s2,0(sp)
 408:	1000                	addi	s0,sp,32
 40a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 40c:	4581                	li	a1,0
 40e:	00000097          	auipc	ra,0x0
 412:	172080e7          	jalr	370(ra) # 580 <open>
  if(fd < 0)
 416:	02054563          	bltz	a0,440 <stat+0x42>
 41a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 41c:	85ca                	mv	a1,s2
 41e:	00000097          	auipc	ra,0x0
 422:	17a080e7          	jalr	378(ra) # 598 <fstat>
 426:	892a                	mv	s2,a0
  close(fd);
 428:	8526                	mv	a0,s1
 42a:	00000097          	auipc	ra,0x0
 42e:	13e080e7          	jalr	318(ra) # 568 <close>
  return r;
}
 432:	854a                	mv	a0,s2
 434:	60e2                	ld	ra,24(sp)
 436:	6442                	ld	s0,16(sp)
 438:	64a2                	ld	s1,8(sp)
 43a:	6902                	ld	s2,0(sp)
 43c:	6105                	addi	sp,sp,32
 43e:	8082                	ret
    return -1;
 440:	597d                	li	s2,-1
 442:	bfc5                	j	432 <stat+0x34>

0000000000000444 <atoi>:

int
atoi(const char *s)
{
 444:	1141                	addi	sp,sp,-16
 446:	e422                	sd	s0,8(sp)
 448:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 44a:	00054603          	lbu	a2,0(a0)
 44e:	fd06079b          	addiw	a5,a2,-48
 452:	0ff7f793          	andi	a5,a5,255
 456:	4725                	li	a4,9
 458:	02f76963          	bltu	a4,a5,48a <atoi+0x46>
 45c:	86aa                	mv	a3,a0
  n = 0;
 45e:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 460:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 462:	0685                	addi	a3,a3,1
 464:	0025179b          	slliw	a5,a0,0x2
 468:	9fa9                	addw	a5,a5,a0
 46a:	0017979b          	slliw	a5,a5,0x1
 46e:	9fb1                	addw	a5,a5,a2
 470:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 474:	0006c603          	lbu	a2,0(a3)
 478:	fd06071b          	addiw	a4,a2,-48
 47c:	0ff77713          	andi	a4,a4,255
 480:	fee5f1e3          	bgeu	a1,a4,462 <atoi+0x1e>
  return n;
}
 484:	6422                	ld	s0,8(sp)
 486:	0141                	addi	sp,sp,16
 488:	8082                	ret
  n = 0;
 48a:	4501                	li	a0,0
 48c:	bfe5                	j	484 <atoi+0x40>

000000000000048e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 48e:	1141                	addi	sp,sp,-16
 490:	e422                	sd	s0,8(sp)
 492:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 494:	02b57463          	bgeu	a0,a1,4bc <memmove+0x2e>
    while(n-- > 0)
 498:	00c05f63          	blez	a2,4b6 <memmove+0x28>
 49c:	1602                	slli	a2,a2,0x20
 49e:	9201                	srli	a2,a2,0x20
 4a0:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 4a4:	872a                	mv	a4,a0
      *dst++ = *src++;
 4a6:	0585                	addi	a1,a1,1
 4a8:	0705                	addi	a4,a4,1
 4aa:	fff5c683          	lbu	a3,-1(a1)
 4ae:	fed70fa3          	sb	a3,-1(a4) # 7ffff <base+0x7efef>
    while(n-- > 0)
 4b2:	fee79ae3          	bne	a5,a4,4a6 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 4b6:	6422                	ld	s0,8(sp)
 4b8:	0141                	addi	sp,sp,16
 4ba:	8082                	ret
    dst += n;
 4bc:	00c50733          	add	a4,a0,a2
    src += n;
 4c0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 4c2:	fec05ae3          	blez	a2,4b6 <memmove+0x28>
 4c6:	fff6079b          	addiw	a5,a2,-1
 4ca:	1782                	slli	a5,a5,0x20
 4cc:	9381                	srli	a5,a5,0x20
 4ce:	fff7c793          	not	a5,a5
 4d2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 4d4:	15fd                	addi	a1,a1,-1
 4d6:	177d                	addi	a4,a4,-1
 4d8:	0005c683          	lbu	a3,0(a1)
 4dc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 4e0:	fee79ae3          	bne	a5,a4,4d4 <memmove+0x46>
 4e4:	bfc9                	j	4b6 <memmove+0x28>

00000000000004e6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 4e6:	1141                	addi	sp,sp,-16
 4e8:	e422                	sd	s0,8(sp)
 4ea:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 4ec:	ca05                	beqz	a2,51c <memcmp+0x36>
 4ee:	fff6069b          	addiw	a3,a2,-1
 4f2:	1682                	slli	a3,a3,0x20
 4f4:	9281                	srli	a3,a3,0x20
 4f6:	0685                	addi	a3,a3,1
 4f8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 4fa:	00054783          	lbu	a5,0(a0)
 4fe:	0005c703          	lbu	a4,0(a1)
 502:	00e79863          	bne	a5,a4,512 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 506:	0505                	addi	a0,a0,1
    p2++;
 508:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 50a:	fed518e3          	bne	a0,a3,4fa <memcmp+0x14>
  }
  return 0;
 50e:	4501                	li	a0,0
 510:	a019                	j	516 <memcmp+0x30>
      return *p1 - *p2;
 512:	40e7853b          	subw	a0,a5,a4
}
 516:	6422                	ld	s0,8(sp)
 518:	0141                	addi	sp,sp,16
 51a:	8082                	ret
  return 0;
 51c:	4501                	li	a0,0
 51e:	bfe5                	j	516 <memcmp+0x30>

0000000000000520 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 520:	1141                	addi	sp,sp,-16
 522:	e406                	sd	ra,8(sp)
 524:	e022                	sd	s0,0(sp)
 526:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 528:	00000097          	auipc	ra,0x0
 52c:	f66080e7          	jalr	-154(ra) # 48e <memmove>
}
 530:	60a2                	ld	ra,8(sp)
 532:	6402                	ld	s0,0(sp)
 534:	0141                	addi	sp,sp,16
 536:	8082                	ret

0000000000000538 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 538:	4885                	li	a7,1
 ecall
 53a:	00000073          	ecall
 ret
 53e:	8082                	ret

0000000000000540 <exit>:
.global exit
exit:
 li a7, SYS_exit
 540:	4889                	li	a7,2
 ecall
 542:	00000073          	ecall
 ret
 546:	8082                	ret

0000000000000548 <wait>:
.global wait
wait:
 li a7, SYS_wait
 548:	488d                	li	a7,3
 ecall
 54a:	00000073          	ecall
 ret
 54e:	8082                	ret

0000000000000550 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 550:	4891                	li	a7,4
 ecall
 552:	00000073          	ecall
 ret
 556:	8082                	ret

0000000000000558 <read>:
.global read
read:
 li a7, SYS_read
 558:	4895                	li	a7,5
 ecall
 55a:	00000073          	ecall
 ret
 55e:	8082                	ret

0000000000000560 <write>:
.global write
write:
 li a7, SYS_write
 560:	48c1                	li	a7,16
 ecall
 562:	00000073          	ecall
 ret
 566:	8082                	ret

0000000000000568 <close>:
.global close
close:
 li a7, SYS_close
 568:	48d5                	li	a7,21
 ecall
 56a:	00000073          	ecall
 ret
 56e:	8082                	ret

0000000000000570 <kill>:
.global kill
kill:
 li a7, SYS_kill
 570:	4899                	li	a7,6
 ecall
 572:	00000073          	ecall
 ret
 576:	8082                	ret

0000000000000578 <exec>:
.global exec
exec:
 li a7, SYS_exec
 578:	489d                	li	a7,7
 ecall
 57a:	00000073          	ecall
 ret
 57e:	8082                	ret

0000000000000580 <open>:
.global open
open:
 li a7, SYS_open
 580:	48bd                	li	a7,15
 ecall
 582:	00000073          	ecall
 ret
 586:	8082                	ret

0000000000000588 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 588:	48c5                	li	a7,17
 ecall
 58a:	00000073          	ecall
 ret
 58e:	8082                	ret

0000000000000590 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 590:	48c9                	li	a7,18
 ecall
 592:	00000073          	ecall
 ret
 596:	8082                	ret

0000000000000598 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 598:	48a1                	li	a7,8
 ecall
 59a:	00000073          	ecall
 ret
 59e:	8082                	ret

00000000000005a0 <link>:
.global link
link:
 li a7, SYS_link
 5a0:	48cd                	li	a7,19
 ecall
 5a2:	00000073          	ecall
 ret
 5a6:	8082                	ret

00000000000005a8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 5a8:	48d1                	li	a7,20
 ecall
 5aa:	00000073          	ecall
 ret
 5ae:	8082                	ret

00000000000005b0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 5b0:	48a5                	li	a7,9
 ecall
 5b2:	00000073          	ecall
 ret
 5b6:	8082                	ret

00000000000005b8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 5b8:	48a9                	li	a7,10
 ecall
 5ba:	00000073          	ecall
 ret
 5be:	8082                	ret

00000000000005c0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 5c0:	48ad                	li	a7,11
 ecall
 5c2:	00000073          	ecall
 ret
 5c6:	8082                	ret

00000000000005c8 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 5c8:	48b1                	li	a7,12
 ecall
 5ca:	00000073          	ecall
 ret
 5ce:	8082                	ret

00000000000005d0 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 5d0:	48b5                	li	a7,13
 ecall
 5d2:	00000073          	ecall
 ret
 5d6:	8082                	ret

00000000000005d8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5d8:	48b9                	li	a7,14
 ecall
 5da:	00000073          	ecall
 ret
 5de:	8082                	ret

00000000000005e0 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 5e0:	48d9                	li	a7,22
 ecall
 5e2:	00000073          	ecall
 ret
 5e6:	8082                	ret

00000000000005e8 <getSysCount>:
.global getSysCount
getSysCount:
 li a7, SYS_getSysCount
 5e8:	48dd                	li	a7,23
 ecall
 5ea:	00000073          	ecall
 ret
 5ee:	8082                	ret

00000000000005f0 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5f0:	1101                	addi	sp,sp,-32
 5f2:	ec06                	sd	ra,24(sp)
 5f4:	e822                	sd	s0,16(sp)
 5f6:	1000                	addi	s0,sp,32
 5f8:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5fc:	4605                	li	a2,1
 5fe:	fef40593          	addi	a1,s0,-17
 602:	00000097          	auipc	ra,0x0
 606:	f5e080e7          	jalr	-162(ra) # 560 <write>
}
 60a:	60e2                	ld	ra,24(sp)
 60c:	6442                	ld	s0,16(sp)
 60e:	6105                	addi	sp,sp,32
 610:	8082                	ret

0000000000000612 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 612:	7139                	addi	sp,sp,-64
 614:	fc06                	sd	ra,56(sp)
 616:	f822                	sd	s0,48(sp)
 618:	f426                	sd	s1,40(sp)
 61a:	f04a                	sd	s2,32(sp)
 61c:	ec4e                	sd	s3,24(sp)
 61e:	0080                	addi	s0,sp,64
 620:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 622:	c299                	beqz	a3,628 <printint+0x16>
 624:	0805c863          	bltz	a1,6b4 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 628:	2581                	sext.w	a1,a1
  neg = 0;
 62a:	4881                	li	a7,0
 62c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 630:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 632:	2601                	sext.w	a2,a2
 634:	00000517          	auipc	a0,0x0
 638:	5e450513          	addi	a0,a0,1508 # c18 <digits>
 63c:	883a                	mv	a6,a4
 63e:	2705                	addiw	a4,a4,1
 640:	02c5f7bb          	remuw	a5,a1,a2
 644:	1782                	slli	a5,a5,0x20
 646:	9381                	srli	a5,a5,0x20
 648:	97aa                	add	a5,a5,a0
 64a:	0007c783          	lbu	a5,0(a5)
 64e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 652:	0005879b          	sext.w	a5,a1
 656:	02c5d5bb          	divuw	a1,a1,a2
 65a:	0685                	addi	a3,a3,1
 65c:	fec7f0e3          	bgeu	a5,a2,63c <printint+0x2a>
  if(neg)
 660:	00088b63          	beqz	a7,676 <printint+0x64>
    buf[i++] = '-';
 664:	fd040793          	addi	a5,s0,-48
 668:	973e                	add	a4,a4,a5
 66a:	02d00793          	li	a5,45
 66e:	fef70823          	sb	a5,-16(a4)
 672:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 676:	02e05863          	blez	a4,6a6 <printint+0x94>
 67a:	fc040793          	addi	a5,s0,-64
 67e:	00e78933          	add	s2,a5,a4
 682:	fff78993          	addi	s3,a5,-1
 686:	99ba                	add	s3,s3,a4
 688:	377d                	addiw	a4,a4,-1
 68a:	1702                	slli	a4,a4,0x20
 68c:	9301                	srli	a4,a4,0x20
 68e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 692:	fff94583          	lbu	a1,-1(s2)
 696:	8526                	mv	a0,s1
 698:	00000097          	auipc	ra,0x0
 69c:	f58080e7          	jalr	-168(ra) # 5f0 <putc>
  while(--i >= 0)
 6a0:	197d                	addi	s2,s2,-1
 6a2:	ff3918e3          	bne	s2,s3,692 <printint+0x80>
}
 6a6:	70e2                	ld	ra,56(sp)
 6a8:	7442                	ld	s0,48(sp)
 6aa:	74a2                	ld	s1,40(sp)
 6ac:	7902                	ld	s2,32(sp)
 6ae:	69e2                	ld	s3,24(sp)
 6b0:	6121                	addi	sp,sp,64
 6b2:	8082                	ret
    x = -xx;
 6b4:	40b005bb          	negw	a1,a1
    neg = 1;
 6b8:	4885                	li	a7,1
    x = -xx;
 6ba:	bf8d                	j	62c <printint+0x1a>

00000000000006bc <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 6bc:	7119                	addi	sp,sp,-128
 6be:	fc86                	sd	ra,120(sp)
 6c0:	f8a2                	sd	s0,112(sp)
 6c2:	f4a6                	sd	s1,104(sp)
 6c4:	f0ca                	sd	s2,96(sp)
 6c6:	ecce                	sd	s3,88(sp)
 6c8:	e8d2                	sd	s4,80(sp)
 6ca:	e4d6                	sd	s5,72(sp)
 6cc:	e0da                	sd	s6,64(sp)
 6ce:	fc5e                	sd	s7,56(sp)
 6d0:	f862                	sd	s8,48(sp)
 6d2:	f466                	sd	s9,40(sp)
 6d4:	f06a                	sd	s10,32(sp)
 6d6:	ec6e                	sd	s11,24(sp)
 6d8:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 6da:	0005c903          	lbu	s2,0(a1)
 6de:	18090f63          	beqz	s2,87c <vprintf+0x1c0>
 6e2:	8aaa                	mv	s5,a0
 6e4:	8b32                	mv	s6,a2
 6e6:	00158493          	addi	s1,a1,1
  state = 0;
 6ea:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 6ec:	02500a13          	li	s4,37
      if(c == 'd'){
 6f0:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 6f4:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 6f8:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 6fc:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 700:	00000b97          	auipc	s7,0x0
 704:	518b8b93          	addi	s7,s7,1304 # c18 <digits>
 708:	a839                	j	726 <vprintf+0x6a>
        putc(fd, c);
 70a:	85ca                	mv	a1,s2
 70c:	8556                	mv	a0,s5
 70e:	00000097          	auipc	ra,0x0
 712:	ee2080e7          	jalr	-286(ra) # 5f0 <putc>
 716:	a019                	j	71c <vprintf+0x60>
    } else if(state == '%'){
 718:	01498f63          	beq	s3,s4,736 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 71c:	0485                	addi	s1,s1,1
 71e:	fff4c903          	lbu	s2,-1(s1)
 722:	14090d63          	beqz	s2,87c <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 726:	0009079b          	sext.w	a5,s2
    if(state == 0){
 72a:	fe0997e3          	bnez	s3,718 <vprintf+0x5c>
      if(c == '%'){
 72e:	fd479ee3          	bne	a5,s4,70a <vprintf+0x4e>
        state = '%';
 732:	89be                	mv	s3,a5
 734:	b7e5                	j	71c <vprintf+0x60>
      if(c == 'd'){
 736:	05878063          	beq	a5,s8,776 <vprintf+0xba>
      } else if(c == 'l') {
 73a:	05978c63          	beq	a5,s9,792 <vprintf+0xd6>
      } else if(c == 'x') {
 73e:	07a78863          	beq	a5,s10,7ae <vprintf+0xf2>
      } else if(c == 'p') {
 742:	09b78463          	beq	a5,s11,7ca <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 746:	07300713          	li	a4,115
 74a:	0ce78663          	beq	a5,a4,816 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 74e:	06300713          	li	a4,99
 752:	0ee78e63          	beq	a5,a4,84e <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 756:	11478863          	beq	a5,s4,866 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 75a:	85d2                	mv	a1,s4
 75c:	8556                	mv	a0,s5
 75e:	00000097          	auipc	ra,0x0
 762:	e92080e7          	jalr	-366(ra) # 5f0 <putc>
        putc(fd, c);
 766:	85ca                	mv	a1,s2
 768:	8556                	mv	a0,s5
 76a:	00000097          	auipc	ra,0x0
 76e:	e86080e7          	jalr	-378(ra) # 5f0 <putc>
      }
      state = 0;
 772:	4981                	li	s3,0
 774:	b765                	j	71c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 776:	008b0913          	addi	s2,s6,8
 77a:	4685                	li	a3,1
 77c:	4629                	li	a2,10
 77e:	000b2583          	lw	a1,0(s6)
 782:	8556                	mv	a0,s5
 784:	00000097          	auipc	ra,0x0
 788:	e8e080e7          	jalr	-370(ra) # 612 <printint>
 78c:	8b4a                	mv	s6,s2
      state = 0;
 78e:	4981                	li	s3,0
 790:	b771                	j	71c <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 792:	008b0913          	addi	s2,s6,8
 796:	4681                	li	a3,0
 798:	4629                	li	a2,10
 79a:	000b2583          	lw	a1,0(s6)
 79e:	8556                	mv	a0,s5
 7a0:	00000097          	auipc	ra,0x0
 7a4:	e72080e7          	jalr	-398(ra) # 612 <printint>
 7a8:	8b4a                	mv	s6,s2
      state = 0;
 7aa:	4981                	li	s3,0
 7ac:	bf85                	j	71c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 7ae:	008b0913          	addi	s2,s6,8
 7b2:	4681                	li	a3,0
 7b4:	4641                	li	a2,16
 7b6:	000b2583          	lw	a1,0(s6)
 7ba:	8556                	mv	a0,s5
 7bc:	00000097          	auipc	ra,0x0
 7c0:	e56080e7          	jalr	-426(ra) # 612 <printint>
 7c4:	8b4a                	mv	s6,s2
      state = 0;
 7c6:	4981                	li	s3,0
 7c8:	bf91                	j	71c <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 7ca:	008b0793          	addi	a5,s6,8
 7ce:	f8f43423          	sd	a5,-120(s0)
 7d2:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 7d6:	03000593          	li	a1,48
 7da:	8556                	mv	a0,s5
 7dc:	00000097          	auipc	ra,0x0
 7e0:	e14080e7          	jalr	-492(ra) # 5f0 <putc>
  putc(fd, 'x');
 7e4:	85ea                	mv	a1,s10
 7e6:	8556                	mv	a0,s5
 7e8:	00000097          	auipc	ra,0x0
 7ec:	e08080e7          	jalr	-504(ra) # 5f0 <putc>
 7f0:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7f2:	03c9d793          	srli	a5,s3,0x3c
 7f6:	97de                	add	a5,a5,s7
 7f8:	0007c583          	lbu	a1,0(a5)
 7fc:	8556                	mv	a0,s5
 7fe:	00000097          	auipc	ra,0x0
 802:	df2080e7          	jalr	-526(ra) # 5f0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 806:	0992                	slli	s3,s3,0x4
 808:	397d                	addiw	s2,s2,-1
 80a:	fe0914e3          	bnez	s2,7f2 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 80e:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 812:	4981                	li	s3,0
 814:	b721                	j	71c <vprintf+0x60>
        s = va_arg(ap, char*);
 816:	008b0993          	addi	s3,s6,8
 81a:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 81e:	02090163          	beqz	s2,840 <vprintf+0x184>
        while(*s != 0){
 822:	00094583          	lbu	a1,0(s2)
 826:	c9a1                	beqz	a1,876 <vprintf+0x1ba>
          putc(fd, *s);
 828:	8556                	mv	a0,s5
 82a:	00000097          	auipc	ra,0x0
 82e:	dc6080e7          	jalr	-570(ra) # 5f0 <putc>
          s++;
 832:	0905                	addi	s2,s2,1
        while(*s != 0){
 834:	00094583          	lbu	a1,0(s2)
 838:	f9e5                	bnez	a1,828 <vprintf+0x16c>
        s = va_arg(ap, char*);
 83a:	8b4e                	mv	s6,s3
      state = 0;
 83c:	4981                	li	s3,0
 83e:	bdf9                	j	71c <vprintf+0x60>
          s = "(null)";
 840:	00000917          	auipc	s2,0x0
 844:	3d090913          	addi	s2,s2,976 # c10 <malloc+0x28a>
        while(*s != 0){
 848:	02800593          	li	a1,40
 84c:	bff1                	j	828 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 84e:	008b0913          	addi	s2,s6,8
 852:	000b4583          	lbu	a1,0(s6)
 856:	8556                	mv	a0,s5
 858:	00000097          	auipc	ra,0x0
 85c:	d98080e7          	jalr	-616(ra) # 5f0 <putc>
 860:	8b4a                	mv	s6,s2
      state = 0;
 862:	4981                	li	s3,0
 864:	bd65                	j	71c <vprintf+0x60>
        putc(fd, c);
 866:	85d2                	mv	a1,s4
 868:	8556                	mv	a0,s5
 86a:	00000097          	auipc	ra,0x0
 86e:	d86080e7          	jalr	-634(ra) # 5f0 <putc>
      state = 0;
 872:	4981                	li	s3,0
 874:	b565                	j	71c <vprintf+0x60>
        s = va_arg(ap, char*);
 876:	8b4e                	mv	s6,s3
      state = 0;
 878:	4981                	li	s3,0
 87a:	b54d                	j	71c <vprintf+0x60>
    }
  }
}
 87c:	70e6                	ld	ra,120(sp)
 87e:	7446                	ld	s0,112(sp)
 880:	74a6                	ld	s1,104(sp)
 882:	7906                	ld	s2,96(sp)
 884:	69e6                	ld	s3,88(sp)
 886:	6a46                	ld	s4,80(sp)
 888:	6aa6                	ld	s5,72(sp)
 88a:	6b06                	ld	s6,64(sp)
 88c:	7be2                	ld	s7,56(sp)
 88e:	7c42                	ld	s8,48(sp)
 890:	7ca2                	ld	s9,40(sp)
 892:	7d02                	ld	s10,32(sp)
 894:	6de2                	ld	s11,24(sp)
 896:	6109                	addi	sp,sp,128
 898:	8082                	ret

000000000000089a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 89a:	715d                	addi	sp,sp,-80
 89c:	ec06                	sd	ra,24(sp)
 89e:	e822                	sd	s0,16(sp)
 8a0:	1000                	addi	s0,sp,32
 8a2:	e010                	sd	a2,0(s0)
 8a4:	e414                	sd	a3,8(s0)
 8a6:	e818                	sd	a4,16(s0)
 8a8:	ec1c                	sd	a5,24(s0)
 8aa:	03043023          	sd	a6,32(s0)
 8ae:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8b2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8b6:	8622                	mv	a2,s0
 8b8:	00000097          	auipc	ra,0x0
 8bc:	e04080e7          	jalr	-508(ra) # 6bc <vprintf>
}
 8c0:	60e2                	ld	ra,24(sp)
 8c2:	6442                	ld	s0,16(sp)
 8c4:	6161                	addi	sp,sp,80
 8c6:	8082                	ret

00000000000008c8 <printf>:

void
printf(const char *fmt, ...)
{
 8c8:	711d                	addi	sp,sp,-96
 8ca:	ec06                	sd	ra,24(sp)
 8cc:	e822                	sd	s0,16(sp)
 8ce:	1000                	addi	s0,sp,32
 8d0:	e40c                	sd	a1,8(s0)
 8d2:	e810                	sd	a2,16(s0)
 8d4:	ec14                	sd	a3,24(s0)
 8d6:	f018                	sd	a4,32(s0)
 8d8:	f41c                	sd	a5,40(s0)
 8da:	03043823          	sd	a6,48(s0)
 8de:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8e2:	00840613          	addi	a2,s0,8
 8e6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8ea:	85aa                	mv	a1,a0
 8ec:	4505                	li	a0,1
 8ee:	00000097          	auipc	ra,0x0
 8f2:	dce080e7          	jalr	-562(ra) # 6bc <vprintf>
}
 8f6:	60e2                	ld	ra,24(sp)
 8f8:	6442                	ld	s0,16(sp)
 8fa:	6125                	addi	sp,sp,96
 8fc:	8082                	ret

00000000000008fe <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8fe:	1141                	addi	sp,sp,-16
 900:	e422                	sd	s0,8(sp)
 902:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 904:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 908:	00000797          	auipc	a5,0x0
 90c:	6f87b783          	ld	a5,1784(a5) # 1000 <freep>
 910:	a805                	j	940 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 912:	4618                	lw	a4,8(a2)
 914:	9db9                	addw	a1,a1,a4
 916:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 91a:	6398                	ld	a4,0(a5)
 91c:	6318                	ld	a4,0(a4)
 91e:	fee53823          	sd	a4,-16(a0)
 922:	a091                	j	966 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 924:	ff852703          	lw	a4,-8(a0)
 928:	9e39                	addw	a2,a2,a4
 92a:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 92c:	ff053703          	ld	a4,-16(a0)
 930:	e398                	sd	a4,0(a5)
 932:	a099                	j	978 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 934:	6398                	ld	a4,0(a5)
 936:	00e7e463          	bltu	a5,a4,93e <free+0x40>
 93a:	00e6ea63          	bltu	a3,a4,94e <free+0x50>
{
 93e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 940:	fed7fae3          	bgeu	a5,a3,934 <free+0x36>
 944:	6398                	ld	a4,0(a5)
 946:	00e6e463          	bltu	a3,a4,94e <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 94a:	fee7eae3          	bltu	a5,a4,93e <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 94e:	ff852583          	lw	a1,-8(a0)
 952:	6390                	ld	a2,0(a5)
 954:	02059713          	slli	a4,a1,0x20
 958:	9301                	srli	a4,a4,0x20
 95a:	0712                	slli	a4,a4,0x4
 95c:	9736                	add	a4,a4,a3
 95e:	fae60ae3          	beq	a2,a4,912 <free+0x14>
    bp->s.ptr = p->s.ptr;
 962:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 966:	4790                	lw	a2,8(a5)
 968:	02061713          	slli	a4,a2,0x20
 96c:	9301                	srli	a4,a4,0x20
 96e:	0712                	slli	a4,a4,0x4
 970:	973e                	add	a4,a4,a5
 972:	fae689e3          	beq	a3,a4,924 <free+0x26>
  } else
    p->s.ptr = bp;
 976:	e394                	sd	a3,0(a5)
  freep = p;
 978:	00000717          	auipc	a4,0x0
 97c:	68f73423          	sd	a5,1672(a4) # 1000 <freep>
}
 980:	6422                	ld	s0,8(sp)
 982:	0141                	addi	sp,sp,16
 984:	8082                	ret

0000000000000986 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 986:	7139                	addi	sp,sp,-64
 988:	fc06                	sd	ra,56(sp)
 98a:	f822                	sd	s0,48(sp)
 98c:	f426                	sd	s1,40(sp)
 98e:	f04a                	sd	s2,32(sp)
 990:	ec4e                	sd	s3,24(sp)
 992:	e852                	sd	s4,16(sp)
 994:	e456                	sd	s5,8(sp)
 996:	e05a                	sd	s6,0(sp)
 998:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 99a:	02051493          	slli	s1,a0,0x20
 99e:	9081                	srli	s1,s1,0x20
 9a0:	04bd                	addi	s1,s1,15
 9a2:	8091                	srli	s1,s1,0x4
 9a4:	0014899b          	addiw	s3,s1,1
 9a8:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 9aa:	00000517          	auipc	a0,0x0
 9ae:	65653503          	ld	a0,1622(a0) # 1000 <freep>
 9b2:	c515                	beqz	a0,9de <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9b4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9b6:	4798                	lw	a4,8(a5)
 9b8:	02977f63          	bgeu	a4,s1,9f6 <malloc+0x70>
 9bc:	8a4e                	mv	s4,s3
 9be:	0009871b          	sext.w	a4,s3
 9c2:	6685                	lui	a3,0x1
 9c4:	00d77363          	bgeu	a4,a3,9ca <malloc+0x44>
 9c8:	6a05                	lui	s4,0x1
 9ca:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9ce:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9d2:	00000917          	auipc	s2,0x0
 9d6:	62e90913          	addi	s2,s2,1582 # 1000 <freep>
  if(p == (char*)-1)
 9da:	5afd                	li	s5,-1
 9dc:	a88d                	j	a4e <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 9de:	00000797          	auipc	a5,0x0
 9e2:	63278793          	addi	a5,a5,1586 # 1010 <base>
 9e6:	00000717          	auipc	a4,0x0
 9ea:	60f73d23          	sd	a5,1562(a4) # 1000 <freep>
 9ee:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9f0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9f4:	b7e1                	j	9bc <malloc+0x36>
      if(p->s.size == nunits)
 9f6:	02e48b63          	beq	s1,a4,a2c <malloc+0xa6>
        p->s.size -= nunits;
 9fa:	4137073b          	subw	a4,a4,s3
 9fe:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a00:	1702                	slli	a4,a4,0x20
 a02:	9301                	srli	a4,a4,0x20
 a04:	0712                	slli	a4,a4,0x4
 a06:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a08:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a0c:	00000717          	auipc	a4,0x0
 a10:	5ea73a23          	sd	a0,1524(a4) # 1000 <freep>
      return (void*)(p + 1);
 a14:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a18:	70e2                	ld	ra,56(sp)
 a1a:	7442                	ld	s0,48(sp)
 a1c:	74a2                	ld	s1,40(sp)
 a1e:	7902                	ld	s2,32(sp)
 a20:	69e2                	ld	s3,24(sp)
 a22:	6a42                	ld	s4,16(sp)
 a24:	6aa2                	ld	s5,8(sp)
 a26:	6b02                	ld	s6,0(sp)
 a28:	6121                	addi	sp,sp,64
 a2a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a2c:	6398                	ld	a4,0(a5)
 a2e:	e118                	sd	a4,0(a0)
 a30:	bff1                	j	a0c <malloc+0x86>
  hp->s.size = nu;
 a32:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a36:	0541                	addi	a0,a0,16
 a38:	00000097          	auipc	ra,0x0
 a3c:	ec6080e7          	jalr	-314(ra) # 8fe <free>
  return freep;
 a40:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a44:	d971                	beqz	a0,a18 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a46:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a48:	4798                	lw	a4,8(a5)
 a4a:	fa9776e3          	bgeu	a4,s1,9f6 <malloc+0x70>
    if(p == freep)
 a4e:	00093703          	ld	a4,0(s2)
 a52:	853e                	mv	a0,a5
 a54:	fef719e3          	bne	a4,a5,a46 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 a58:	8552                	mv	a0,s4
 a5a:	00000097          	auipc	ra,0x0
 a5e:	b6e080e7          	jalr	-1170(ra) # 5c8 <sbrk>
  if(p == (char*)-1)
 a62:	fd5518e3          	bne	a0,s5,a32 <malloc+0xac>
        return 0;
 a66:	4501                	li	a0,0
 a68:	bf45                	j	a18 <malloc+0x92>
