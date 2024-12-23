
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	a2010113          	addi	sp,sp,-1504 # 80008a20 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

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
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	88e70713          	addi	a4,a4,-1906 # 800088e0 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	e8c78793          	addi	a5,a5,-372 # 80005ef0 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffda8af>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	dca78793          	addi	a5,a5,-566 # 80000e78 <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d8:	57fd                	li	a5,-1
    800000da:	83a9                	srli	a5,a5,0xa
    800000dc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000e0:	47bd                	li	a5,15
    800000e2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	f36080e7          	jalr	-202(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ee:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f6:	30200073          	mret
}
    800000fa:	60a2                	ld	ra,8(sp)
    800000fc:	6402                	ld	s0,0(sp)
    800000fe:	0141                	addi	sp,sp,16
    80000100:	8082                	ret

0000000080000102 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000102:	715d                	addi	sp,sp,-80
    80000104:	e486                	sd	ra,72(sp)
    80000106:	e0a2                	sd	s0,64(sp)
    80000108:	fc26                	sd	s1,56(sp)
    8000010a:	f84a                	sd	s2,48(sp)
    8000010c:	f44e                	sd	s3,40(sp)
    8000010e:	f052                	sd	s4,32(sp)
    80000110:	ec56                	sd	s5,24(sp)
    80000112:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000114:	04c05663          	blez	a2,80000160 <consolewrite+0x5e>
    80000118:	8a2a                	mv	s4,a0
    8000011a:	84ae                	mv	s1,a1
    8000011c:	89b2                	mv	s3,a2
    8000011e:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000120:	5afd                	li	s5,-1
    80000122:	4685                	li	a3,1
    80000124:	8626                	mv	a2,s1
    80000126:	85d2                	mv	a1,s4
    80000128:	fbf40513          	addi	a0,s0,-65
    8000012c:	00002097          	auipc	ra,0x2
    80000130:	3a6080e7          	jalr	934(ra) # 800024d2 <either_copyin>
    80000134:	01550c63          	beq	a0,s5,8000014c <consolewrite+0x4a>
      break;
    uartputc(c);
    80000138:	fbf44503          	lbu	a0,-65(s0)
    8000013c:	00000097          	auipc	ra,0x0
    80000140:	780080e7          	jalr	1920(ra) # 800008bc <uartputc>
  for(i = 0; i < n; i++){
    80000144:	2905                	addiw	s2,s2,1
    80000146:	0485                	addi	s1,s1,1
    80000148:	fd299de3          	bne	s3,s2,80000122 <consolewrite+0x20>
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4a>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
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
    8000018e:	89650513          	addi	a0,a0,-1898 # 80010a20 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	88648493          	addi	s1,s1,-1914 # 80010a20 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	91690913          	addi	s2,s2,-1770 # 80010ab8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    800001aa:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001ae:	4ca9                	li	s9,10
  while(n > 0){
    800001b0:	07305b63          	blez	s3,80000226 <consoleread+0xc2>
    while(cons.r == cons.w){
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71763          	bne	a4,a5,800001ea <consoleread+0x86>
      if(killed(myproc())){
    800001c0:	00001097          	auipc	ra,0x1
    800001c4:	7ec080e7          	jalr	2028(ra) # 800019ac <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	154080e7          	jalr	340(ra) # 8000231c <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	e92080e7          	jalr	-366(ra) # 80002068 <sleep>
    while(cons.r == cons.w){
    800001de:	0984a783          	lw	a5,152(s1)
    800001e2:	09c4a703          	lw	a4,156(s1)
    800001e6:	fcf70de3          	beq	a4,a5,800001c0 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ea:	0017871b          	addiw	a4,a5,1
    800001ee:	08e4ac23          	sw	a4,152(s1)
    800001f2:	07f7f713          	andi	a4,a5,127
    800001f6:	9726                	add	a4,a4,s1
    800001f8:	01874703          	lbu	a4,24(a4)
    800001fc:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80000200:	077d0563          	beq	s10,s7,8000026a <consoleread+0x106>
    cbuf = c;
    80000204:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000208:	4685                	li	a3,1
    8000020a:	f9f40613          	addi	a2,s0,-97
    8000020e:	85d2                	mv	a1,s4
    80000210:	8556                	mv	a0,s5
    80000212:	00002097          	auipc	ra,0x2
    80000216:	26a080e7          	jalr	618(ra) # 8000247c <either_copyout>
    8000021a:	01850663          	beq	a0,s8,80000226 <consoleread+0xc2>
    dst++;
    8000021e:	0a05                	addi	s4,s4,1
    --n;
    80000220:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80000222:	f99d17e3          	bne	s10,s9,800001b0 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000226:	00010517          	auipc	a0,0x10
    8000022a:	7fa50513          	addi	a0,a0,2042 # 80010a20 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00010517          	auipc	a0,0x10
    80000240:	7e450513          	addi	a0,a0,2020 # 80010a20 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	a46080e7          	jalr	-1466(ra) # 80000c8a <release>
        return -1;
    8000024c:	557d                	li	a0,-1
}
    8000024e:	70a6                	ld	ra,104(sp)
    80000250:	7406                	ld	s0,96(sp)
    80000252:	64e6                	ld	s1,88(sp)
    80000254:	6946                	ld	s2,80(sp)
    80000256:	69a6                	ld	s3,72(sp)
    80000258:	6a06                	ld	s4,64(sp)
    8000025a:	7ae2                	ld	s5,56(sp)
    8000025c:	7b42                	ld	s6,48(sp)
    8000025e:	7ba2                	ld	s7,40(sp)
    80000260:	7c02                	ld	s8,32(sp)
    80000262:	6ce2                	ld	s9,24(sp)
    80000264:	6d42                	ld	s10,16(sp)
    80000266:	6165                	addi	sp,sp,112
    80000268:	8082                	ret
      if(n < target){
    8000026a:	0009871b          	sext.w	a4,s3
    8000026e:	fb677ce3          	bgeu	a4,s6,80000226 <consoleread+0xc2>
        cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	84f72323          	sw	a5,-1978(a4) # 80010ab8 <cons+0x98>
    8000027a:	b775                	j	80000226 <consoleread+0xc2>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
    uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	55e080e7          	jalr	1374(ra) # 800007ea <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	54c080e7          	jalr	1356(ra) # 800007ea <uartputc_sync>
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	540080e7          	jalr	1344(ra) # 800007ea <uartputc_sync>
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	536080e7          	jalr	1334(ra) # 800007ea <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002cc:	00010517          	auipc	a0,0x10
    800002d0:	75450513          	addi	a0,a0,1876 # 80010a20 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	902080e7          	jalr	-1790(ra) # 80000bd6 <acquire>

  switch(c){
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f2:	00002097          	auipc	ra,0x2
    800002f6:	236080e7          	jalr	566(ra) # 80002528 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00010517          	auipc	a0,0x10
    800002fe:	72650513          	addi	a0,a0,1830 # 80010a20 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	988080e7          	jalr	-1656(ra) # 80000c8a <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
  switch(c){
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031e:	00010717          	auipc	a4,0x10
    80000322:	70270713          	addi	a4,a4,1794 # 80010a20 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
      consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000348:	00010797          	auipc	a5,0x10
    8000034c:	6d878793          	addi	a5,a5,1752 # 80010a20 <cons>
    80000350:	0a07a683          	lw	a3,160(a5)
    80000354:	0016871b          	addiw	a4,a3,1
    80000358:	0007061b          	sext.w	a2,a4
    8000035c:	0ae7a023          	sw	a4,160(a5)
    80000360:	07f6f693          	andi	a3,a3,127
    80000364:	97b6                	add	a5,a5,a3
    80000366:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00010797          	auipc	a5,0x10
    8000037a:	7427a783          	lw	a5,1858(a5) # 80010ab8 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00010717          	auipc	a4,0x10
    8000038e:	69670713          	addi	a4,a4,1686 # 80010a20 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	68648493          	addi	s1,s1,1670 # 80010a20 <cons>
    while(cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
      cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
    while(cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d6:	00010717          	auipc	a4,0x10
    800003da:	64a70713          	addi	a4,a4,1610 # 80010a20 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00010717          	auipc	a4,0x10
    800003f0:	6cf72a23          	sw	a5,1748(a4) # 80010ac0 <cons+0xa0>
      consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
      consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000412:	00010797          	auipc	a5,0x10
    80000416:	60e78793          	addi	a5,a5,1550 # 80010a20 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000436:	00010797          	auipc	a5,0x10
    8000043a:	68c7a323          	sw	a2,1670(a5) # 80010abc <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	67a50513          	addi	a0,a0,1658 # 80010ab8 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	c86080e7          	jalr	-890(ra) # 800020cc <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void
consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bb858593          	addi	a1,a1,-1096 # 80008010 <etext+0x10>
    80000460:	00010517          	auipc	a0,0x10
    80000464:	5c050513          	addi	a0,a0,1472 # 80010a20 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32a080e7          	jalr	810(ra) # 8000079a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00023797          	auipc	a5,0x23
    8000047c:	94078793          	addi	a5,a5,-1728 # 80022db8 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7870713          	addi	a4,a4,-904 # 80000102 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054663          	bltz	a0,80000536 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b8660613          	addi	a2,a2,-1146 # 80008040 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

  if(sign)
    800004e6:	00088b63          	beqz	a7,800004fc <printint+0x60>
    buf[i++] = '-';
    800004ea:	fe040793          	addi	a5,s0,-32
    800004ee:	973e                	add	a4,a4,a5
    800004f0:	02d00793          	li	a5,45
    800004f4:	fef70823          	sb	a5,-16(a4)
    800004f8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fc:	02e05763          	blez	a4,8000052a <printint+0x8e>
    80000500:	fd040793          	addi	a5,s0,-48
    80000504:	00e784b3          	add	s1,a5,a4
    80000508:	fff78913          	addi	s2,a5,-1
    8000050c:	993a                	add	s2,s2,a4
    8000050e:	377d                	addiw	a4,a4,-1
    80000510:	1702                	slli	a4,a4,0x20
    80000512:	9301                	srli	a4,a4,0x20
    80000514:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000518:	fff4c503          	lbu	a0,-1(s1)
    8000051c:	00000097          	auipc	ra,0x0
    80000520:	d60080e7          	jalr	-672(ra) # 8000027c <consputc>
  while(--i >= 0)
    80000524:	14fd                	addi	s1,s1,-1
    80000526:	ff2499e3          	bne	s1,s2,80000518 <printint+0x7c>
}
    8000052a:	70a2                	ld	ra,40(sp)
    8000052c:	7402                	ld	s0,32(sp)
    8000052e:	64e2                	ld	s1,24(sp)
    80000530:	6942                	ld	s2,16(sp)
    80000532:	6145                	addi	sp,sp,48
    80000534:	8082                	ret
    x = -xx;
    80000536:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053a:	4885                	li	a7,1
    x = -xx;
    8000053c:	bf9d                	j	800004b2 <printint+0x16>

000000008000053e <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053e:	1101                	addi	sp,sp,-32
    80000540:	ec06                	sd	ra,24(sp)
    80000542:	e822                	sd	s0,16(sp)
    80000544:	e426                	sd	s1,8(sp)
    80000546:	1000                	addi	s0,sp,32
    80000548:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054a:	00010797          	auipc	a5,0x10
    8000054e:	5807ab23          	sw	zero,1430(a5) # 80010ae0 <pr+0x18>
  printf("panic: ");
    80000552:	00008517          	auipc	a0,0x8
    80000556:	ac650513          	addi	a0,a0,-1338 # 80008018 <etext+0x18>
    8000055a:	00000097          	auipc	ra,0x0
    8000055e:	02e080e7          	jalr	46(ra) # 80000588 <printf>
  printf(s);
    80000562:	8526                	mv	a0,s1
    80000564:	00000097          	auipc	ra,0x0
    80000568:	024080e7          	jalr	36(ra) # 80000588 <printf>
  printf("\n");
    8000056c:	00008517          	auipc	a0,0x8
    80000570:	b5c50513          	addi	a0,a0,-1188 # 800080c8 <digits+0x88>
    80000574:	00000097          	auipc	ra,0x0
    80000578:	014080e7          	jalr	20(ra) # 80000588 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057c:	4785                	li	a5,1
    8000057e:	00008717          	auipc	a4,0x8
    80000582:	32f72123          	sw	a5,802(a4) # 800088a0 <panicked>
  for(;;)
    80000586:	a001                	j	80000586 <panic+0x48>

0000000080000588 <printf>:
{
    80000588:	7131                	addi	sp,sp,-192
    8000058a:	fc86                	sd	ra,120(sp)
    8000058c:	f8a2                	sd	s0,112(sp)
    8000058e:	f4a6                	sd	s1,104(sp)
    80000590:	f0ca                	sd	s2,96(sp)
    80000592:	ecce                	sd	s3,88(sp)
    80000594:	e8d2                	sd	s4,80(sp)
    80000596:	e4d6                	sd	s5,72(sp)
    80000598:	e0da                	sd	s6,64(sp)
    8000059a:	fc5e                	sd	s7,56(sp)
    8000059c:	f862                	sd	s8,48(sp)
    8000059e:	f466                	sd	s9,40(sp)
    800005a0:	f06a                	sd	s10,32(sp)
    800005a2:	ec6e                	sd	s11,24(sp)
    800005a4:	0100                	addi	s0,sp,128
    800005a6:	8a2a                	mv	s4,a0
    800005a8:	e40c                	sd	a1,8(s0)
    800005aa:	e810                	sd	a2,16(s0)
    800005ac:	ec14                	sd	a3,24(s0)
    800005ae:	f018                	sd	a4,32(s0)
    800005b0:	f41c                	sd	a5,40(s0)
    800005b2:	03043823          	sd	a6,48(s0)
    800005b6:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005ba:	00010d97          	auipc	s11,0x10
    800005be:	526dad83          	lw	s11,1318(s11) # 80010ae0 <pr+0x18>
  if(locking)
    800005c2:	020d9b63          	bnez	s11,800005f8 <printf+0x70>
  if (fmt == 0)
    800005c6:	040a0263          	beqz	s4,8000060a <printf+0x82>
  va_start(ap, fmt);
    800005ca:	00840793          	addi	a5,s0,8
    800005ce:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d2:	000a4503          	lbu	a0,0(s4)
    800005d6:	14050f63          	beqz	a0,80000734 <printf+0x1ac>
    800005da:	4981                	li	s3,0
    if(c != '%'){
    800005dc:	02500a93          	li	s5,37
    switch(c){
    800005e0:	07000b93          	li	s7,112
  consputc('x');
    800005e4:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e6:	00008b17          	auipc	s6,0x8
    800005ea:	a5ab0b13          	addi	s6,s6,-1446 # 80008040 <digits>
    switch(c){
    800005ee:	07300c93          	li	s9,115
    800005f2:	06400c13          	li	s8,100
    800005f6:	a82d                	j	80000630 <printf+0xa8>
    acquire(&pr.lock);
    800005f8:	00010517          	auipc	a0,0x10
    800005fc:	4d050513          	addi	a0,a0,1232 # 80010ac8 <pr>
    80000600:	00000097          	auipc	ra,0x0
    80000604:	5d6080e7          	jalr	1494(ra) # 80000bd6 <acquire>
    80000608:	bf7d                	j	800005c6 <printf+0x3e>
    panic("null fmt");
    8000060a:	00008517          	auipc	a0,0x8
    8000060e:	a1e50513          	addi	a0,a0,-1506 # 80008028 <etext+0x28>
    80000612:	00000097          	auipc	ra,0x0
    80000616:	f2c080e7          	jalr	-212(ra) # 8000053e <panic>
      consputc(c);
    8000061a:	00000097          	auipc	ra,0x0
    8000061e:	c62080e7          	jalr	-926(ra) # 8000027c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000622:	2985                	addiw	s3,s3,1
    80000624:	013a07b3          	add	a5,s4,s3
    80000628:	0007c503          	lbu	a0,0(a5)
    8000062c:	10050463          	beqz	a0,80000734 <printf+0x1ac>
    if(c != '%'){
    80000630:	ff5515e3          	bne	a0,s5,8000061a <printf+0x92>
    c = fmt[++i] & 0xff;
    80000634:	2985                	addiw	s3,s3,1
    80000636:	013a07b3          	add	a5,s4,s3
    8000063a:	0007c783          	lbu	a5,0(a5)
    8000063e:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000642:	cbed                	beqz	a5,80000734 <printf+0x1ac>
    switch(c){
    80000644:	05778a63          	beq	a5,s7,80000698 <printf+0x110>
    80000648:	02fbf663          	bgeu	s7,a5,80000674 <printf+0xec>
    8000064c:	09978863          	beq	a5,s9,800006dc <printf+0x154>
    80000650:	07800713          	li	a4,120
    80000654:	0ce79563          	bne	a5,a4,8000071e <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000658:	f8843783          	ld	a5,-120(s0)
    8000065c:	00878713          	addi	a4,a5,8
    80000660:	f8e43423          	sd	a4,-120(s0)
    80000664:	4605                	li	a2,1
    80000666:	85ea                	mv	a1,s10
    80000668:	4388                	lw	a0,0(a5)
    8000066a:	00000097          	auipc	ra,0x0
    8000066e:	e32080e7          	jalr	-462(ra) # 8000049c <printint>
      break;
    80000672:	bf45                	j	80000622 <printf+0x9a>
    switch(c){
    80000674:	09578f63          	beq	a5,s5,80000712 <printf+0x18a>
    80000678:	0b879363          	bne	a5,s8,8000071e <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067c:	f8843783          	ld	a5,-120(s0)
    80000680:	00878713          	addi	a4,a5,8
    80000684:	f8e43423          	sd	a4,-120(s0)
    80000688:	4605                	li	a2,1
    8000068a:	45a9                	li	a1,10
    8000068c:	4388                	lw	a0,0(a5)
    8000068e:	00000097          	auipc	ra,0x0
    80000692:	e0e080e7          	jalr	-498(ra) # 8000049c <printint>
      break;
    80000696:	b771                	j	80000622 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000698:	f8843783          	ld	a5,-120(s0)
    8000069c:	00878713          	addi	a4,a5,8
    800006a0:	f8e43423          	sd	a4,-120(s0)
    800006a4:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006a8:	03000513          	li	a0,48
    800006ac:	00000097          	auipc	ra,0x0
    800006b0:	bd0080e7          	jalr	-1072(ra) # 8000027c <consputc>
  consputc('x');
    800006b4:	07800513          	li	a0,120
    800006b8:	00000097          	auipc	ra,0x0
    800006bc:	bc4080e7          	jalr	-1084(ra) # 8000027c <consputc>
    800006c0:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c2:	03c95793          	srli	a5,s2,0x3c
    800006c6:	97da                	add	a5,a5,s6
    800006c8:	0007c503          	lbu	a0,0(a5)
    800006cc:	00000097          	auipc	ra,0x0
    800006d0:	bb0080e7          	jalr	-1104(ra) # 8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d4:	0912                	slli	s2,s2,0x4
    800006d6:	34fd                	addiw	s1,s1,-1
    800006d8:	f4ed                	bnez	s1,800006c2 <printf+0x13a>
    800006da:	b7a1                	j	80000622 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006dc:	f8843783          	ld	a5,-120(s0)
    800006e0:	00878713          	addi	a4,a5,8
    800006e4:	f8e43423          	sd	a4,-120(s0)
    800006e8:	6384                	ld	s1,0(a5)
    800006ea:	cc89                	beqz	s1,80000704 <printf+0x17c>
      for(; *s; s++)
    800006ec:	0004c503          	lbu	a0,0(s1)
    800006f0:	d90d                	beqz	a0,80000622 <printf+0x9a>
        consputc(*s);
    800006f2:	00000097          	auipc	ra,0x0
    800006f6:	b8a080e7          	jalr	-1142(ra) # 8000027c <consputc>
      for(; *s; s++)
    800006fa:	0485                	addi	s1,s1,1
    800006fc:	0004c503          	lbu	a0,0(s1)
    80000700:	f96d                	bnez	a0,800006f2 <printf+0x16a>
    80000702:	b705                	j	80000622 <printf+0x9a>
        s = "(null)";
    80000704:	00008497          	auipc	s1,0x8
    80000708:	91c48493          	addi	s1,s1,-1764 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070c:	02800513          	li	a0,40
    80000710:	b7cd                	j	800006f2 <printf+0x16a>
      consputc('%');
    80000712:	8556                	mv	a0,s5
    80000714:	00000097          	auipc	ra,0x0
    80000718:	b68080e7          	jalr	-1176(ra) # 8000027c <consputc>
      break;
    8000071c:	b719                	j	80000622 <printf+0x9a>
      consputc('%');
    8000071e:	8556                	mv	a0,s5
    80000720:	00000097          	auipc	ra,0x0
    80000724:	b5c080e7          	jalr	-1188(ra) # 8000027c <consputc>
      consputc(c);
    80000728:	8526                	mv	a0,s1
    8000072a:	00000097          	auipc	ra,0x0
    8000072e:	b52080e7          	jalr	-1198(ra) # 8000027c <consputc>
      break;
    80000732:	bdc5                	j	80000622 <printf+0x9a>
  if(locking)
    80000734:	020d9163          	bnez	s11,80000756 <printf+0x1ce>
}
    80000738:	70e6                	ld	ra,120(sp)
    8000073a:	7446                	ld	s0,112(sp)
    8000073c:	74a6                	ld	s1,104(sp)
    8000073e:	7906                	ld	s2,96(sp)
    80000740:	69e6                	ld	s3,88(sp)
    80000742:	6a46                	ld	s4,80(sp)
    80000744:	6aa6                	ld	s5,72(sp)
    80000746:	6b06                	ld	s6,64(sp)
    80000748:	7be2                	ld	s7,56(sp)
    8000074a:	7c42                	ld	s8,48(sp)
    8000074c:	7ca2                	ld	s9,40(sp)
    8000074e:	7d02                	ld	s10,32(sp)
    80000750:	6de2                	ld	s11,24(sp)
    80000752:	6129                	addi	sp,sp,192
    80000754:	8082                	ret
    release(&pr.lock);
    80000756:	00010517          	auipc	a0,0x10
    8000075a:	37250513          	addi	a0,a0,882 # 80010ac8 <pr>
    8000075e:	00000097          	auipc	ra,0x0
    80000762:	52c080e7          	jalr	1324(ra) # 80000c8a <release>
}
    80000766:	bfc9                	j	80000738 <printf+0x1b0>

0000000080000768 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000768:	1101                	addi	sp,sp,-32
    8000076a:	ec06                	sd	ra,24(sp)
    8000076c:	e822                	sd	s0,16(sp)
    8000076e:	e426                	sd	s1,8(sp)
    80000770:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000772:	00010497          	auipc	s1,0x10
    80000776:	35648493          	addi	s1,s1,854 # 80010ac8 <pr>
    8000077a:	00008597          	auipc	a1,0x8
    8000077e:	8be58593          	addi	a1,a1,-1858 # 80008038 <etext+0x38>
    80000782:	8526                	mv	a0,s1
    80000784:	00000097          	auipc	ra,0x0
    80000788:	3c2080e7          	jalr	962(ra) # 80000b46 <initlock>
  pr.locking = 1;
    8000078c:	4785                	li	a5,1
    8000078e:	cc9c                	sw	a5,24(s1)
}
    80000790:	60e2                	ld	ra,24(sp)
    80000792:	6442                	ld	s0,16(sp)
    80000794:	64a2                	ld	s1,8(sp)
    80000796:	6105                	addi	sp,sp,32
    80000798:	8082                	ret

000000008000079a <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000079a:	1141                	addi	sp,sp,-16
    8000079c:	e406                	sd	ra,8(sp)
    8000079e:	e022                	sd	s0,0(sp)
    800007a0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a2:	100007b7          	lui	a5,0x10000
    800007a6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007aa:	f8000713          	li	a4,-128
    800007ae:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b2:	470d                	li	a4,3
    800007b4:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b8:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007bc:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c0:	469d                	li	a3,7
    800007c2:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c6:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007ca:	00008597          	auipc	a1,0x8
    800007ce:	88e58593          	addi	a1,a1,-1906 # 80008058 <digits+0x18>
    800007d2:	00010517          	auipc	a0,0x10
    800007d6:	31650513          	addi	a0,a0,790 # 80010ae8 <uart_tx_lock>
    800007da:	00000097          	auipc	ra,0x0
    800007de:	36c080e7          	jalr	876(ra) # 80000b46 <initlock>
}
    800007e2:	60a2                	ld	ra,8(sp)
    800007e4:	6402                	ld	s0,0(sp)
    800007e6:	0141                	addi	sp,sp,16
    800007e8:	8082                	ret

00000000800007ea <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007ea:	1101                	addi	sp,sp,-32
    800007ec:	ec06                	sd	ra,24(sp)
    800007ee:	e822                	sd	s0,16(sp)
    800007f0:	e426                	sd	s1,8(sp)
    800007f2:	1000                	addi	s0,sp,32
    800007f4:	84aa                	mv	s1,a0
  push_off();
    800007f6:	00000097          	auipc	ra,0x0
    800007fa:	394080e7          	jalr	916(ra) # 80000b8a <push_off>

  if(panicked){
    800007fe:	00008797          	auipc	a5,0x8
    80000802:	0a27a783          	lw	a5,162(a5) # 800088a0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000806:	10000737          	lui	a4,0x10000
  if(panicked){
    8000080a:	c391                	beqz	a5,8000080e <uartputc_sync+0x24>
    for(;;)
    8000080c:	a001                	j	8000080c <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080e:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000812:	0207f793          	andi	a5,a5,32
    80000816:	dfe5                	beqz	a5,8000080e <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000818:	0ff4f513          	andi	a0,s1,255
    8000081c:	100007b7          	lui	a5,0x10000
    80000820:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000824:	00000097          	auipc	ra,0x0
    80000828:	406080e7          	jalr	1030(ra) # 80000c2a <pop_off>
}
    8000082c:	60e2                	ld	ra,24(sp)
    8000082e:	6442                	ld	s0,16(sp)
    80000830:	64a2                	ld	s1,8(sp)
    80000832:	6105                	addi	sp,sp,32
    80000834:	8082                	ret

0000000080000836 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000836:	00008797          	auipc	a5,0x8
    8000083a:	0727b783          	ld	a5,114(a5) # 800088a8 <uart_tx_r>
    8000083e:	00008717          	auipc	a4,0x8
    80000842:	07273703          	ld	a4,114(a4) # 800088b0 <uart_tx_w>
    80000846:	06f70a63          	beq	a4,a5,800008ba <uartstart+0x84>
{
    8000084a:	7139                	addi	sp,sp,-64
    8000084c:	fc06                	sd	ra,56(sp)
    8000084e:	f822                	sd	s0,48(sp)
    80000850:	f426                	sd	s1,40(sp)
    80000852:	f04a                	sd	s2,32(sp)
    80000854:	ec4e                	sd	s3,24(sp)
    80000856:	e852                	sd	s4,16(sp)
    80000858:	e456                	sd	s5,8(sp)
    8000085a:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085c:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000860:	00010a17          	auipc	s4,0x10
    80000864:	288a0a13          	addi	s4,s4,648 # 80010ae8 <uart_tx_lock>
    uart_tx_r += 1;
    80000868:	00008497          	auipc	s1,0x8
    8000086c:	04048493          	addi	s1,s1,64 # 800088a8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000870:	00008997          	auipc	s3,0x8
    80000874:	04098993          	addi	s3,s3,64 # 800088b0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000878:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087c:	02077713          	andi	a4,a4,32
    80000880:	c705                	beqz	a4,800008a8 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000882:	01f7f713          	andi	a4,a5,31
    80000886:	9752                	add	a4,a4,s4
    80000888:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088c:	0785                	addi	a5,a5,1
    8000088e:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80000890:	8526                	mv	a0,s1
    80000892:	00002097          	auipc	ra,0x2
    80000896:	83a080e7          	jalr	-1990(ra) # 800020cc <wakeup>
    
    WriteReg(THR, c);
    8000089a:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000089e:	609c                	ld	a5,0(s1)
    800008a0:	0009b703          	ld	a4,0(s3)
    800008a4:	fcf71ae3          	bne	a4,a5,80000878 <uartstart+0x42>
  }
}
    800008a8:	70e2                	ld	ra,56(sp)
    800008aa:	7442                	ld	s0,48(sp)
    800008ac:	74a2                	ld	s1,40(sp)
    800008ae:	7902                	ld	s2,32(sp)
    800008b0:	69e2                	ld	s3,24(sp)
    800008b2:	6a42                	ld	s4,16(sp)
    800008b4:	6aa2                	ld	s5,8(sp)
    800008b6:	6121                	addi	sp,sp,64
    800008b8:	8082                	ret
    800008ba:	8082                	ret

00000000800008bc <uartputc>:
{
    800008bc:	7179                	addi	sp,sp,-48
    800008be:	f406                	sd	ra,40(sp)
    800008c0:	f022                	sd	s0,32(sp)
    800008c2:	ec26                	sd	s1,24(sp)
    800008c4:	e84a                	sd	s2,16(sp)
    800008c6:	e44e                	sd	s3,8(sp)
    800008c8:	e052                	sd	s4,0(sp)
    800008ca:	1800                	addi	s0,sp,48
    800008cc:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008ce:	00010517          	auipc	a0,0x10
    800008d2:	21a50513          	addi	a0,a0,538 # 80010ae8 <uart_tx_lock>
    800008d6:	00000097          	auipc	ra,0x0
    800008da:	300080e7          	jalr	768(ra) # 80000bd6 <acquire>
  if(panicked){
    800008de:	00008797          	auipc	a5,0x8
    800008e2:	fc27a783          	lw	a5,-62(a5) # 800088a0 <panicked>
    800008e6:	e7c9                	bnez	a5,80000970 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e8:	00008717          	auipc	a4,0x8
    800008ec:	fc873703          	ld	a4,-56(a4) # 800088b0 <uart_tx_w>
    800008f0:	00008797          	auipc	a5,0x8
    800008f4:	fb87b783          	ld	a5,-72(a5) # 800088a8 <uart_tx_r>
    800008f8:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fc:	00010997          	auipc	s3,0x10
    80000900:	1ec98993          	addi	s3,s3,492 # 80010ae8 <uart_tx_lock>
    80000904:	00008497          	auipc	s1,0x8
    80000908:	fa448493          	addi	s1,s1,-92 # 800088a8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090c:	00008917          	auipc	s2,0x8
    80000910:	fa490913          	addi	s2,s2,-92 # 800088b0 <uart_tx_w>
    80000914:	00e79f63          	bne	a5,a4,80000932 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000918:	85ce                	mv	a1,s3
    8000091a:	8526                	mv	a0,s1
    8000091c:	00001097          	auipc	ra,0x1
    80000920:	74c080e7          	jalr	1868(ra) # 80002068 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000924:	00093703          	ld	a4,0(s2)
    80000928:	609c                	ld	a5,0(s1)
    8000092a:	02078793          	addi	a5,a5,32
    8000092e:	fee785e3          	beq	a5,a4,80000918 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000932:	00010497          	auipc	s1,0x10
    80000936:	1b648493          	addi	s1,s1,438 # 80010ae8 <uart_tx_lock>
    8000093a:	01f77793          	andi	a5,a4,31
    8000093e:	97a6                	add	a5,a5,s1
    80000940:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000944:	0705                	addi	a4,a4,1
    80000946:	00008797          	auipc	a5,0x8
    8000094a:	f6e7b523          	sd	a4,-150(a5) # 800088b0 <uart_tx_w>
  uartstart();
    8000094e:	00000097          	auipc	ra,0x0
    80000952:	ee8080e7          	jalr	-280(ra) # 80000836 <uartstart>
  release(&uart_tx_lock);
    80000956:	8526                	mv	a0,s1
    80000958:	00000097          	auipc	ra,0x0
    8000095c:	332080e7          	jalr	818(ra) # 80000c8a <release>
}
    80000960:	70a2                	ld	ra,40(sp)
    80000962:	7402                	ld	s0,32(sp)
    80000964:	64e2                	ld	s1,24(sp)
    80000966:	6942                	ld	s2,16(sp)
    80000968:	69a2                	ld	s3,8(sp)
    8000096a:	6a02                	ld	s4,0(sp)
    8000096c:	6145                	addi	sp,sp,48
    8000096e:	8082                	ret
    for(;;)
    80000970:	a001                	j	80000970 <uartputc+0xb4>

0000000080000972 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000972:	1141                	addi	sp,sp,-16
    80000974:	e422                	sd	s0,8(sp)
    80000976:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000978:	100007b7          	lui	a5,0x10000
    8000097c:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000980:	8b85                	andi	a5,a5,1
    80000982:	cb91                	beqz	a5,80000996 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000984:	100007b7          	lui	a5,0x10000
    80000988:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    8000098c:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    80000990:	6422                	ld	s0,8(sp)
    80000992:	0141                	addi	sp,sp,16
    80000994:	8082                	ret
    return -1;
    80000996:	557d                	li	a0,-1
    80000998:	bfe5                	j	80000990 <uartgetc+0x1e>

000000008000099a <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    8000099a:	1101                	addi	sp,sp,-32
    8000099c:	ec06                	sd	ra,24(sp)
    8000099e:	e822                	sd	s0,16(sp)
    800009a0:	e426                	sd	s1,8(sp)
    800009a2:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009a4:	54fd                	li	s1,-1
    800009a6:	a029                	j	800009b0 <uartintr+0x16>
      break;
    consoleintr(c);
    800009a8:	00000097          	auipc	ra,0x0
    800009ac:	916080e7          	jalr	-1770(ra) # 800002be <consoleintr>
    int c = uartgetc();
    800009b0:	00000097          	auipc	ra,0x0
    800009b4:	fc2080e7          	jalr	-62(ra) # 80000972 <uartgetc>
    if(c == -1)
    800009b8:	fe9518e3          	bne	a0,s1,800009a8 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009bc:	00010497          	auipc	s1,0x10
    800009c0:	12c48493          	addi	s1,s1,300 # 80010ae8 <uart_tx_lock>
    800009c4:	8526                	mv	a0,s1
    800009c6:	00000097          	auipc	ra,0x0
    800009ca:	210080e7          	jalr	528(ra) # 80000bd6 <acquire>
  uartstart();
    800009ce:	00000097          	auipc	ra,0x0
    800009d2:	e68080e7          	jalr	-408(ra) # 80000836 <uartstart>
  release(&uart_tx_lock);
    800009d6:	8526                	mv	a0,s1
    800009d8:	00000097          	auipc	ra,0x0
    800009dc:	2b2080e7          	jalr	690(ra) # 80000c8a <release>
}
    800009e0:	60e2                	ld	ra,24(sp)
    800009e2:	6442                	ld	s0,16(sp)
    800009e4:	64a2                	ld	s1,8(sp)
    800009e6:	6105                	addi	sp,sp,32
    800009e8:	8082                	ret

00000000800009ea <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009ea:	1101                	addi	sp,sp,-32
    800009ec:	ec06                	sd	ra,24(sp)
    800009ee:	e822                	sd	s0,16(sp)
    800009f0:	e426                	sd	s1,8(sp)
    800009f2:	e04a                	sd	s2,0(sp)
    800009f4:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f6:	03451793          	slli	a5,a0,0x34
    800009fa:	ebb9                	bnez	a5,80000a50 <kfree+0x66>
    800009fc:	84aa                	mv	s1,a0
    800009fe:	00023797          	auipc	a5,0x23
    80000a02:	55278793          	addi	a5,a5,1362 # 80023f50 <end>
    80000a06:	04f56563          	bltu	a0,a5,80000a50 <kfree+0x66>
    80000a0a:	47c5                	li	a5,17
    80000a0c:	07ee                	slli	a5,a5,0x1b
    80000a0e:	04f57163          	bgeu	a0,a5,80000a50 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a12:	6605                	lui	a2,0x1
    80000a14:	4585                	li	a1,1
    80000a16:	00000097          	auipc	ra,0x0
    80000a1a:	2bc080e7          	jalr	700(ra) # 80000cd2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a1e:	00010917          	auipc	s2,0x10
    80000a22:	10290913          	addi	s2,s2,258 # 80010b20 <kmem>
    80000a26:	854a                	mv	a0,s2
    80000a28:	00000097          	auipc	ra,0x0
    80000a2c:	1ae080e7          	jalr	430(ra) # 80000bd6 <acquire>
  r->next = kmem.freelist;
    80000a30:	01893783          	ld	a5,24(s2)
    80000a34:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a36:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a3a:	854a                	mv	a0,s2
    80000a3c:	00000097          	auipc	ra,0x0
    80000a40:	24e080e7          	jalr	590(ra) # 80000c8a <release>
}
    80000a44:	60e2                	ld	ra,24(sp)
    80000a46:	6442                	ld	s0,16(sp)
    80000a48:	64a2                	ld	s1,8(sp)
    80000a4a:	6902                	ld	s2,0(sp)
    80000a4c:	6105                	addi	sp,sp,32
    80000a4e:	8082                	ret
    panic("kfree");
    80000a50:	00007517          	auipc	a0,0x7
    80000a54:	61050513          	addi	a0,a0,1552 # 80008060 <digits+0x20>
    80000a58:	00000097          	auipc	ra,0x0
    80000a5c:	ae6080e7          	jalr	-1306(ra) # 8000053e <panic>

0000000080000a60 <freerange>:
{
    80000a60:	7179                	addi	sp,sp,-48
    80000a62:	f406                	sd	ra,40(sp)
    80000a64:	f022                	sd	s0,32(sp)
    80000a66:	ec26                	sd	s1,24(sp)
    80000a68:	e84a                	sd	s2,16(sp)
    80000a6a:	e44e                	sd	s3,8(sp)
    80000a6c:	e052                	sd	s4,0(sp)
    80000a6e:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a70:	6785                	lui	a5,0x1
    80000a72:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a76:	94aa                	add	s1,s1,a0
    80000a78:	757d                	lui	a0,0xfffff
    80000a7a:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a7c:	94be                	add	s1,s1,a5
    80000a7e:	0095ee63          	bltu	a1,s1,80000a9a <freerange+0x3a>
    80000a82:	892e                	mv	s2,a1
    kfree(p);
    80000a84:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a86:	6985                	lui	s3,0x1
    kfree(p);
    80000a88:	01448533          	add	a0,s1,s4
    80000a8c:	00000097          	auipc	ra,0x0
    80000a90:	f5e080e7          	jalr	-162(ra) # 800009ea <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a94:	94ce                	add	s1,s1,s3
    80000a96:	fe9979e3          	bgeu	s2,s1,80000a88 <freerange+0x28>
}
    80000a9a:	70a2                	ld	ra,40(sp)
    80000a9c:	7402                	ld	s0,32(sp)
    80000a9e:	64e2                	ld	s1,24(sp)
    80000aa0:	6942                	ld	s2,16(sp)
    80000aa2:	69a2                	ld	s3,8(sp)
    80000aa4:	6a02                	ld	s4,0(sp)
    80000aa6:	6145                	addi	sp,sp,48
    80000aa8:	8082                	ret

0000000080000aaa <kinit>:
{
    80000aaa:	1141                	addi	sp,sp,-16
    80000aac:	e406                	sd	ra,8(sp)
    80000aae:	e022                	sd	s0,0(sp)
    80000ab0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ab2:	00007597          	auipc	a1,0x7
    80000ab6:	5b658593          	addi	a1,a1,1462 # 80008068 <digits+0x28>
    80000aba:	00010517          	auipc	a0,0x10
    80000abe:	06650513          	addi	a0,a0,102 # 80010b20 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00023517          	auipc	a0,0x23
    80000ad2:	48250513          	addi	a0,a0,1154 # 80023f50 <end>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	f8a080e7          	jalr	-118(ra) # 80000a60 <freerange>
}
    80000ade:	60a2                	ld	ra,8(sp)
    80000ae0:	6402                	ld	s0,0(sp)
    80000ae2:	0141                	addi	sp,sp,16
    80000ae4:	8082                	ret

0000000080000ae6 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae6:	1101                	addi	sp,sp,-32
    80000ae8:	ec06                	sd	ra,24(sp)
    80000aea:	e822                	sd	s0,16(sp)
    80000aec:	e426                	sd	s1,8(sp)
    80000aee:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000af0:	00010497          	auipc	s1,0x10
    80000af4:	03048493          	addi	s1,s1,48 # 80010b20 <kmem>
    80000af8:	8526                	mv	a0,s1
    80000afa:	00000097          	auipc	ra,0x0
    80000afe:	0dc080e7          	jalr	220(ra) # 80000bd6 <acquire>
  r = kmem.freelist;
    80000b02:	6c84                	ld	s1,24(s1)
  if(r)
    80000b04:	c885                	beqz	s1,80000b34 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b06:	609c                	ld	a5,0(s1)
    80000b08:	00010517          	auipc	a0,0x10
    80000b0c:	01850513          	addi	a0,a0,24 # 80010b20 <kmem>
    80000b10:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b12:	00000097          	auipc	ra,0x0
    80000b16:	178080e7          	jalr	376(ra) # 80000c8a <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b1a:	6605                	lui	a2,0x1
    80000b1c:	4595                	li	a1,5
    80000b1e:	8526                	mv	a0,s1
    80000b20:	00000097          	auipc	ra,0x0
    80000b24:	1b2080e7          	jalr	434(ra) # 80000cd2 <memset>
  return (void*)r;
}
    80000b28:	8526                	mv	a0,s1
    80000b2a:	60e2                	ld	ra,24(sp)
    80000b2c:	6442                	ld	s0,16(sp)
    80000b2e:	64a2                	ld	s1,8(sp)
    80000b30:	6105                	addi	sp,sp,32
    80000b32:	8082                	ret
  release(&kmem.lock);
    80000b34:	00010517          	auipc	a0,0x10
    80000b38:	fec50513          	addi	a0,a0,-20 # 80010b20 <kmem>
    80000b3c:	00000097          	auipc	ra,0x0
    80000b40:	14e080e7          	jalr	334(ra) # 80000c8a <release>
  if(r)
    80000b44:	b7d5                	j	80000b28 <kalloc+0x42>

0000000080000b46 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b46:	1141                	addi	sp,sp,-16
    80000b48:	e422                	sd	s0,8(sp)
    80000b4a:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b4c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4e:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b52:	00053823          	sd	zero,16(a0)
}
    80000b56:	6422                	ld	s0,8(sp)
    80000b58:	0141                	addi	sp,sp,16
    80000b5a:	8082                	ret

0000000080000b5c <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b5c:	411c                	lw	a5,0(a0)
    80000b5e:	e399                	bnez	a5,80000b64 <holding+0x8>
    80000b60:	4501                	li	a0,0
  return r;
}
    80000b62:	8082                	ret
{
    80000b64:	1101                	addi	sp,sp,-32
    80000b66:	ec06                	sd	ra,24(sp)
    80000b68:	e822                	sd	s0,16(sp)
    80000b6a:	e426                	sd	s1,8(sp)
    80000b6c:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6e:	6904                	ld	s1,16(a0)
    80000b70:	00001097          	auipc	ra,0x1
    80000b74:	e20080e7          	jalr	-480(ra) # 80001990 <mycpu>
    80000b78:	40a48533          	sub	a0,s1,a0
    80000b7c:	00153513          	seqz	a0,a0
}
    80000b80:	60e2                	ld	ra,24(sp)
    80000b82:	6442                	ld	s0,16(sp)
    80000b84:	64a2                	ld	s1,8(sp)
    80000b86:	6105                	addi	sp,sp,32
    80000b88:	8082                	ret

0000000080000b8a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b8a:	1101                	addi	sp,sp,-32
    80000b8c:	ec06                	sd	ra,24(sp)
    80000b8e:	e822                	sd	s0,16(sp)
    80000b90:	e426                	sd	s1,8(sp)
    80000b92:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b94:	100024f3          	csrr	s1,sstatus
    80000b98:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b9c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9e:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000ba2:	00001097          	auipc	ra,0x1
    80000ba6:	dee080e7          	jalr	-530(ra) # 80001990 <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cf89                	beqz	a5,80000bc6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	00001097          	auipc	ra,0x1
    80000bb2:	de2080e7          	jalr	-542(ra) # 80001990 <mycpu>
    80000bb6:	5d3c                	lw	a5,120(a0)
    80000bb8:	2785                	addiw	a5,a5,1
    80000bba:	dd3c                	sw	a5,120(a0)
}
    80000bbc:	60e2                	ld	ra,24(sp)
    80000bbe:	6442                	ld	s0,16(sp)
    80000bc0:	64a2                	ld	s1,8(sp)
    80000bc2:	6105                	addi	sp,sp,32
    80000bc4:	8082                	ret
    mycpu()->intena = old;
    80000bc6:	00001097          	auipc	ra,0x1
    80000bca:	dca080e7          	jalr	-566(ra) # 80001990 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bce:	8085                	srli	s1,s1,0x1
    80000bd0:	8885                	andi	s1,s1,1
    80000bd2:	dd64                	sw	s1,124(a0)
    80000bd4:	bfe9                	j	80000bae <push_off+0x24>

0000000080000bd6 <acquire>:
{
    80000bd6:	1101                	addi	sp,sp,-32
    80000bd8:	ec06                	sd	ra,24(sp)
    80000bda:	e822                	sd	s0,16(sp)
    80000bdc:	e426                	sd	s1,8(sp)
    80000bde:	1000                	addi	s0,sp,32
    80000be0:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000be2:	00000097          	auipc	ra,0x0
    80000be6:	fa8080e7          	jalr	-88(ra) # 80000b8a <push_off>
  if(holding(lk))
    80000bea:	8526                	mv	a0,s1
    80000bec:	00000097          	auipc	ra,0x0
    80000bf0:	f70080e7          	jalr	-144(ra) # 80000b5c <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	4705                	li	a4,1
  if(holding(lk))
    80000bf6:	e115                	bnez	a0,80000c1a <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf8:	87ba                	mv	a5,a4
    80000bfa:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfe:	2781                	sext.w	a5,a5
    80000c00:	ffe5                	bnez	a5,80000bf8 <acquire+0x22>
  __sync_synchronize();
    80000c02:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c06:	00001097          	auipc	ra,0x1
    80000c0a:	d8a080e7          	jalr	-630(ra) # 80001990 <mycpu>
    80000c0e:	e888                	sd	a0,16(s1)
}
    80000c10:	60e2                	ld	ra,24(sp)
    80000c12:	6442                	ld	s0,16(sp)
    80000c14:	64a2                	ld	s1,8(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	8082                	ret
    panic("acquire");
    80000c1a:	00007517          	auipc	a0,0x7
    80000c1e:	45650513          	addi	a0,a0,1110 # 80008070 <digits+0x30>
    80000c22:	00000097          	auipc	ra,0x0
    80000c26:	91c080e7          	jalr	-1764(ra) # 8000053e <panic>

0000000080000c2a <pop_off>:

void
pop_off(void)
{
    80000c2a:	1141                	addi	sp,sp,-16
    80000c2c:	e406                	sd	ra,8(sp)
    80000c2e:	e022                	sd	s0,0(sp)
    80000c30:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c32:	00001097          	auipc	ra,0x1
    80000c36:	d5e080e7          	jalr	-674(ra) # 80001990 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c3a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c40:	e78d                	bnez	a5,80000c6a <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c42:	5d3c                	lw	a5,120(a0)
    80000c44:	02f05b63          	blez	a5,80000c7a <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c48:	37fd                	addiw	a5,a5,-1
    80000c4a:	0007871b          	sext.w	a4,a5
    80000c4e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c50:	eb09                	bnez	a4,80000c62 <pop_off+0x38>
    80000c52:	5d7c                	lw	a5,124(a0)
    80000c54:	c799                	beqz	a5,80000c62 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c56:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c5a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c62:	60a2                	ld	ra,8(sp)
    80000c64:	6402                	ld	s0,0(sp)
    80000c66:	0141                	addi	sp,sp,16
    80000c68:	8082                	ret
    panic("pop_off - interruptible");
    80000c6a:	00007517          	auipc	a0,0x7
    80000c6e:	40e50513          	addi	a0,a0,1038 # 80008078 <digits+0x38>
    80000c72:	00000097          	auipc	ra,0x0
    80000c76:	8cc080e7          	jalr	-1844(ra) # 8000053e <panic>
    panic("pop_off");
    80000c7a:	00007517          	auipc	a0,0x7
    80000c7e:	41650513          	addi	a0,a0,1046 # 80008090 <digits+0x50>
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	8bc080e7          	jalr	-1860(ra) # 8000053e <panic>

0000000080000c8a <release>:
{
    80000c8a:	1101                	addi	sp,sp,-32
    80000c8c:	ec06                	sd	ra,24(sp)
    80000c8e:	e822                	sd	s0,16(sp)
    80000c90:	e426                	sd	s1,8(sp)
    80000c92:	1000                	addi	s0,sp,32
    80000c94:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c96:	00000097          	auipc	ra,0x0
    80000c9a:	ec6080e7          	jalr	-314(ra) # 80000b5c <holding>
    80000c9e:	c115                	beqz	a0,80000cc2 <release+0x38>
  lk->cpu = 0;
    80000ca0:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca4:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca8:	0f50000f          	fence	iorw,ow
    80000cac:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cb0:	00000097          	auipc	ra,0x0
    80000cb4:	f7a080e7          	jalr	-134(ra) # 80000c2a <pop_off>
}
    80000cb8:	60e2                	ld	ra,24(sp)
    80000cba:	6442                	ld	s0,16(sp)
    80000cbc:	64a2                	ld	s1,8(sp)
    80000cbe:	6105                	addi	sp,sp,32
    80000cc0:	8082                	ret
    panic("release");
    80000cc2:	00007517          	auipc	a0,0x7
    80000cc6:	3d650513          	addi	a0,a0,982 # 80008098 <digits+0x58>
    80000cca:	00000097          	auipc	ra,0x0
    80000cce:	874080e7          	jalr	-1932(ra) # 8000053e <panic>

0000000080000cd2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cd2:	1141                	addi	sp,sp,-16
    80000cd4:	e422                	sd	s0,8(sp)
    80000cd6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd8:	ca19                	beqz	a2,80000cee <memset+0x1c>
    80000cda:	87aa                	mv	a5,a0
    80000cdc:	1602                	slli	a2,a2,0x20
    80000cde:	9201                	srli	a2,a2,0x20
    80000ce0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce8:	0785                	addi	a5,a5,1
    80000cea:	fee79de3          	bne	a5,a4,80000ce4 <memset+0x12>
  }
  return dst;
}
    80000cee:	6422                	ld	s0,8(sp)
    80000cf0:	0141                	addi	sp,sp,16
    80000cf2:	8082                	ret

0000000080000cf4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf4:	1141                	addi	sp,sp,-16
    80000cf6:	e422                	sd	s0,8(sp)
    80000cf8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cfa:	ca05                	beqz	a2,80000d2a <memcmp+0x36>
    80000cfc:	fff6069b          	addiw	a3,a2,-1
    80000d00:	1682                	slli	a3,a3,0x20
    80000d02:	9281                	srli	a3,a3,0x20
    80000d04:	0685                	addi	a3,a3,1
    80000d06:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d08:	00054783          	lbu	a5,0(a0)
    80000d0c:	0005c703          	lbu	a4,0(a1)
    80000d10:	00e79863          	bne	a5,a4,80000d20 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d14:	0505                	addi	a0,a0,1
    80000d16:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d18:	fed518e3          	bne	a0,a3,80000d08 <memcmp+0x14>
  }

  return 0;
    80000d1c:	4501                	li	a0,0
    80000d1e:	a019                	j	80000d24 <memcmp+0x30>
      return *s1 - *s2;
    80000d20:	40e7853b          	subw	a0,a5,a4
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
  return 0;
    80000d2a:	4501                	li	a0,0
    80000d2c:	bfe5                	j	80000d24 <memcmp+0x30>

0000000080000d2e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2e:	1141                	addi	sp,sp,-16
    80000d30:	e422                	sd	s0,8(sp)
    80000d32:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d34:	c205                	beqz	a2,80000d54 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d36:	02a5e263          	bltu	a1,a0,80000d5a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d3a:	1602                	slli	a2,a2,0x20
    80000d3c:	9201                	srli	a2,a2,0x20
    80000d3e:	00c587b3          	add	a5,a1,a2
{
    80000d42:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d44:	0585                	addi	a1,a1,1
    80000d46:	0705                	addi	a4,a4,1
    80000d48:	fff5c683          	lbu	a3,-1(a1)
    80000d4c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d50:	fef59ae3          	bne	a1,a5,80000d44 <memmove+0x16>

  return dst;
}
    80000d54:	6422                	ld	s0,8(sp)
    80000d56:	0141                	addi	sp,sp,16
    80000d58:	8082                	ret
  if(s < d && s + n > d){
    80000d5a:	02061693          	slli	a3,a2,0x20
    80000d5e:	9281                	srli	a3,a3,0x20
    80000d60:	00d58733          	add	a4,a1,a3
    80000d64:	fce57be3          	bgeu	a0,a4,80000d3a <memmove+0xc>
    d += n;
    80000d68:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d6a:	fff6079b          	addiw	a5,a2,-1
    80000d6e:	1782                	slli	a5,a5,0x20
    80000d70:	9381                	srli	a5,a5,0x20
    80000d72:	fff7c793          	not	a5,a5
    80000d76:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d78:	177d                	addi	a4,a4,-1
    80000d7a:	16fd                	addi	a3,a3,-1
    80000d7c:	00074603          	lbu	a2,0(a4)
    80000d80:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d84:	fee79ae3          	bne	a5,a4,80000d78 <memmove+0x4a>
    80000d88:	b7f1                	j	80000d54 <memmove+0x26>

0000000080000d8a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d8a:	1141                	addi	sp,sp,-16
    80000d8c:	e406                	sd	ra,8(sp)
    80000d8e:	e022                	sd	s0,0(sp)
    80000d90:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d92:	00000097          	auipc	ra,0x0
    80000d96:	f9c080e7          	jalr	-100(ra) # 80000d2e <memmove>
}
    80000d9a:	60a2                	ld	ra,8(sp)
    80000d9c:	6402                	ld	s0,0(sp)
    80000d9e:	0141                	addi	sp,sp,16
    80000da0:	8082                	ret

0000000080000da2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000da2:	1141                	addi	sp,sp,-16
    80000da4:	e422                	sd	s0,8(sp)
    80000da6:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da8:	ce11                	beqz	a2,80000dc4 <strncmp+0x22>
    80000daa:	00054783          	lbu	a5,0(a0)
    80000dae:	cf89                	beqz	a5,80000dc8 <strncmp+0x26>
    80000db0:	0005c703          	lbu	a4,0(a1)
    80000db4:	00f71a63          	bne	a4,a5,80000dc8 <strncmp+0x26>
    n--, p++, q++;
    80000db8:	367d                	addiw	a2,a2,-1
    80000dba:	0505                	addi	a0,a0,1
    80000dbc:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dbe:	f675                	bnez	a2,80000daa <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dc0:	4501                	li	a0,0
    80000dc2:	a809                	j	80000dd4 <strncmp+0x32>
    80000dc4:	4501                	li	a0,0
    80000dc6:	a039                	j	80000dd4 <strncmp+0x32>
  if(n == 0)
    80000dc8:	ca09                	beqz	a2,80000dda <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dca:	00054503          	lbu	a0,0(a0)
    80000dce:	0005c783          	lbu	a5,0(a1)
    80000dd2:	9d1d                	subw	a0,a0,a5
}
    80000dd4:	6422                	ld	s0,8(sp)
    80000dd6:	0141                	addi	sp,sp,16
    80000dd8:	8082                	ret
    return 0;
    80000dda:	4501                	li	a0,0
    80000ddc:	bfe5                	j	80000dd4 <strncmp+0x32>

0000000080000dde <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dde:	1141                	addi	sp,sp,-16
    80000de0:	e422                	sd	s0,8(sp)
    80000de2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de4:	872a                	mv	a4,a0
    80000de6:	8832                	mv	a6,a2
    80000de8:	367d                	addiw	a2,a2,-1
    80000dea:	01005963          	blez	a6,80000dfc <strncpy+0x1e>
    80000dee:	0705                	addi	a4,a4,1
    80000df0:	0005c783          	lbu	a5,0(a1)
    80000df4:	fef70fa3          	sb	a5,-1(a4)
    80000df8:	0585                	addi	a1,a1,1
    80000dfa:	f7f5                	bnez	a5,80000de6 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000dfc:	86ba                	mv	a3,a4
    80000dfe:	00c05c63          	blez	a2,80000e16 <strncpy+0x38>
    *s++ = 0;
    80000e02:	0685                	addi	a3,a3,1
    80000e04:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e08:	fff6c793          	not	a5,a3
    80000e0c:	9fb9                	addw	a5,a5,a4
    80000e0e:	010787bb          	addw	a5,a5,a6
    80000e12:	fef048e3          	bgtz	a5,80000e02 <strncpy+0x24>
  return os;
}
    80000e16:	6422                	ld	s0,8(sp)
    80000e18:	0141                	addi	sp,sp,16
    80000e1a:	8082                	ret

0000000080000e1c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e1c:	1141                	addi	sp,sp,-16
    80000e1e:	e422                	sd	s0,8(sp)
    80000e20:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e22:	02c05363          	blez	a2,80000e48 <safestrcpy+0x2c>
    80000e26:	fff6069b          	addiw	a3,a2,-1
    80000e2a:	1682                	slli	a3,a3,0x20
    80000e2c:	9281                	srli	a3,a3,0x20
    80000e2e:	96ae                	add	a3,a3,a1
    80000e30:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e32:	00d58963          	beq	a1,a3,80000e44 <safestrcpy+0x28>
    80000e36:	0585                	addi	a1,a1,1
    80000e38:	0785                	addi	a5,a5,1
    80000e3a:	fff5c703          	lbu	a4,-1(a1)
    80000e3e:	fee78fa3          	sb	a4,-1(a5)
    80000e42:	fb65                	bnez	a4,80000e32 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e44:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e48:	6422                	ld	s0,8(sp)
    80000e4a:	0141                	addi	sp,sp,16
    80000e4c:	8082                	ret

0000000080000e4e <strlen>:

int
strlen(const char *s)
{
    80000e4e:	1141                	addi	sp,sp,-16
    80000e50:	e422                	sd	s0,8(sp)
    80000e52:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e54:	00054783          	lbu	a5,0(a0)
    80000e58:	cf91                	beqz	a5,80000e74 <strlen+0x26>
    80000e5a:	0505                	addi	a0,a0,1
    80000e5c:	87aa                	mv	a5,a0
    80000e5e:	4685                	li	a3,1
    80000e60:	9e89                	subw	a3,a3,a0
    80000e62:	00f6853b          	addw	a0,a3,a5
    80000e66:	0785                	addi	a5,a5,1
    80000e68:	fff7c703          	lbu	a4,-1(a5)
    80000e6c:	fb7d                	bnez	a4,80000e62 <strlen+0x14>
    ;
  return n;
}
    80000e6e:	6422                	ld	s0,8(sp)
    80000e70:	0141                	addi	sp,sp,16
    80000e72:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e74:	4501                	li	a0,0
    80000e76:	bfe5                	j	80000e6e <strlen+0x20>

0000000080000e78 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e78:	1141                	addi	sp,sp,-16
    80000e7a:	e406                	sd	ra,8(sp)
    80000e7c:	e022                	sd	s0,0(sp)
    80000e7e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e80:	00001097          	auipc	ra,0x1
    80000e84:	b00080e7          	jalr	-1280(ra) # 80001980 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e88:	00008717          	auipc	a4,0x8
    80000e8c:	a3070713          	addi	a4,a4,-1488 # 800088b8 <started>
  if(cpuid() == 0){
    80000e90:	c139                	beqz	a0,80000ed6 <main+0x5e>
    while(started == 0)
    80000e92:	431c                	lw	a5,0(a4)
    80000e94:	2781                	sext.w	a5,a5
    80000e96:	dff5                	beqz	a5,80000e92 <main+0x1a>
      ;
    __sync_synchronize();
    80000e98:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e9c:	00001097          	auipc	ra,0x1
    80000ea0:	ae4080e7          	jalr	-1308(ra) # 80001980 <cpuid>
    80000ea4:	85aa                	mv	a1,a0
    80000ea6:	00007517          	auipc	a0,0x7
    80000eaa:	21250513          	addi	a0,a0,530 # 800080b8 <digits+0x78>
    80000eae:	fffff097          	auipc	ra,0xfffff
    80000eb2:	6da080e7          	jalr	1754(ra) # 80000588 <printf>
    kvminithart();    // turn on paging
    80000eb6:	00000097          	auipc	ra,0x0
    80000eba:	0d8080e7          	jalr	216(ra) # 80000f8e <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ebe:	00002097          	auipc	ra,0x2
    80000ec2:	954080e7          	jalr	-1708(ra) # 80002812 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	06a080e7          	jalr	106(ra) # 80005f30 <plicinithart>
  }

  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	fe8080e7          	jalr	-24(ra) # 80001eb6 <scheduler>
    consoleinit();
    80000ed6:	fffff097          	auipc	ra,0xfffff
    80000eda:	57a080e7          	jalr	1402(ra) # 80000450 <consoleinit>
    printfinit();
    80000ede:	00000097          	auipc	ra,0x0
    80000ee2:	88a080e7          	jalr	-1910(ra) # 80000768 <printfinit>
    printf("\n");
    80000ee6:	00007517          	auipc	a0,0x7
    80000eea:	1e250513          	addi	a0,a0,482 # 800080c8 <digits+0x88>
    80000eee:	fffff097          	auipc	ra,0xfffff
    80000ef2:	69a080e7          	jalr	1690(ra) # 80000588 <printf>
    printf("xv6 kernel is booting\n");
    80000ef6:	00007517          	auipc	a0,0x7
    80000efa:	1aa50513          	addi	a0,a0,426 # 800080a0 <digits+0x60>
    80000efe:	fffff097          	auipc	ra,0xfffff
    80000f02:	68a080e7          	jalr	1674(ra) # 80000588 <printf>
    printf("\n");
    80000f06:	00007517          	auipc	a0,0x7
    80000f0a:	1c250513          	addi	a0,a0,450 # 800080c8 <digits+0x88>
    80000f0e:	fffff097          	auipc	ra,0xfffff
    80000f12:	67a080e7          	jalr	1658(ra) # 80000588 <printf>
    kinit();         // physical page allocator
    80000f16:	00000097          	auipc	ra,0x0
    80000f1a:	b94080e7          	jalr	-1132(ra) # 80000aaa <kinit>
    kvminit();       // create kernel page table
    80000f1e:	00000097          	auipc	ra,0x0
    80000f22:	326080e7          	jalr	806(ra) # 80001244 <kvminit>
    kvminithart();   // turn on paging
    80000f26:	00000097          	auipc	ra,0x0
    80000f2a:	068080e7          	jalr	104(ra) # 80000f8e <kvminithart>
    procinit();      // process table
    80000f2e:	00001097          	auipc	ra,0x1
    80000f32:	99e080e7          	jalr	-1634(ra) # 800018cc <procinit>
    trapinit();      // trap vectors
    80000f36:	00002097          	auipc	ra,0x2
    80000f3a:	8b4080e7          	jalr	-1868(ra) # 800027ea <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00002097          	auipc	ra,0x2
    80000f42:	8d4080e7          	jalr	-1836(ra) # 80002812 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	fd4080e7          	jalr	-44(ra) # 80005f1a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	fe2080e7          	jalr	-30(ra) # 80005f30 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	184080e7          	jalr	388(ra) # 800030da <binit>
    iinit();         // inode table
    80000f5e:	00003097          	auipc	ra,0x3
    80000f62:	828080e7          	jalr	-2008(ra) # 80003786 <iinit>
    fileinit();      // file table
    80000f66:	00003097          	auipc	ra,0x3
    80000f6a:	7c6080e7          	jalr	1990(ra) # 8000472c <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	0ca080e7          	jalr	202(ra) # 80006038 <virtio_disk_init>
    userinit();      // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	d22080e7          	jalr	-734(ra) # 80001c98 <userinit>
    __sync_synchronize();
    80000f7e:	0ff0000f          	fence
    started = 1;
    80000f82:	4785                	li	a5,1
    80000f84:	00008717          	auipc	a4,0x8
    80000f88:	92f72a23          	sw	a5,-1740(a4) # 800088b8 <started>
    80000f8c:	b789                	j	80000ece <main+0x56>

0000000080000f8e <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f8e:	1141                	addi	sp,sp,-16
    80000f90:	e422                	sd	s0,8(sp)
    80000f92:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f94:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f98:	00008797          	auipc	a5,0x8
    80000f9c:	9287b783          	ld	a5,-1752(a5) # 800088c0 <kernel_pagetable>
    80000fa0:	83b1                	srli	a5,a5,0xc
    80000fa2:	577d                	li	a4,-1
    80000fa4:	177e                	slli	a4,a4,0x3f
    80000fa6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fa8:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fac:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fb0:	6422                	ld	s0,8(sp)
    80000fb2:	0141                	addi	sp,sp,16
    80000fb4:	8082                	ret

0000000080000fb6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fb6:	7139                	addi	sp,sp,-64
    80000fb8:	fc06                	sd	ra,56(sp)
    80000fba:	f822                	sd	s0,48(sp)
    80000fbc:	f426                	sd	s1,40(sp)
    80000fbe:	f04a                	sd	s2,32(sp)
    80000fc0:	ec4e                	sd	s3,24(sp)
    80000fc2:	e852                	sd	s4,16(sp)
    80000fc4:	e456                	sd	s5,8(sp)
    80000fc6:	e05a                	sd	s6,0(sp)
    80000fc8:	0080                	addi	s0,sp,64
    80000fca:	84aa                	mv	s1,a0
    80000fcc:	89ae                	mv	s3,a1
    80000fce:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fd0:	57fd                	li	a5,-1
    80000fd2:	83e9                	srli	a5,a5,0x1a
    80000fd4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fd6:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fd8:	04b7f263          	bgeu	a5,a1,8000101c <walk+0x66>
    panic("walk");
    80000fdc:	00007517          	auipc	a0,0x7
    80000fe0:	0f450513          	addi	a0,a0,244 # 800080d0 <digits+0x90>
    80000fe4:	fffff097          	auipc	ra,0xfffff
    80000fe8:	55a080e7          	jalr	1370(ra) # 8000053e <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fec:	060a8663          	beqz	s5,80001058 <walk+0xa2>
    80000ff0:	00000097          	auipc	ra,0x0
    80000ff4:	af6080e7          	jalr	-1290(ra) # 80000ae6 <kalloc>
    80000ff8:	84aa                	mv	s1,a0
    80000ffa:	c529                	beqz	a0,80001044 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ffc:	6605                	lui	a2,0x1
    80000ffe:	4581                	li	a1,0
    80001000:	00000097          	auipc	ra,0x0
    80001004:	cd2080e7          	jalr	-814(ra) # 80000cd2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001008:	00c4d793          	srli	a5,s1,0xc
    8000100c:	07aa                	slli	a5,a5,0xa
    8000100e:	0017e793          	ori	a5,a5,1
    80001012:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001016:	3a5d                	addiw	s4,s4,-9
    80001018:	036a0063          	beq	s4,s6,80001038 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000101c:	0149d933          	srl	s2,s3,s4
    80001020:	1ff97913          	andi	s2,s2,511
    80001024:	090e                	slli	s2,s2,0x3
    80001026:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001028:	00093483          	ld	s1,0(s2)
    8000102c:	0014f793          	andi	a5,s1,1
    80001030:	dfd5                	beqz	a5,80000fec <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001032:	80a9                	srli	s1,s1,0xa
    80001034:	04b2                	slli	s1,s1,0xc
    80001036:	b7c5                	j	80001016 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001038:	00c9d513          	srli	a0,s3,0xc
    8000103c:	1ff57513          	andi	a0,a0,511
    80001040:	050e                	slli	a0,a0,0x3
    80001042:	9526                	add	a0,a0,s1
}
    80001044:	70e2                	ld	ra,56(sp)
    80001046:	7442                	ld	s0,48(sp)
    80001048:	74a2                	ld	s1,40(sp)
    8000104a:	7902                	ld	s2,32(sp)
    8000104c:	69e2                	ld	s3,24(sp)
    8000104e:	6a42                	ld	s4,16(sp)
    80001050:	6aa2                	ld	s5,8(sp)
    80001052:	6b02                	ld	s6,0(sp)
    80001054:	6121                	addi	sp,sp,64
    80001056:	8082                	ret
        return 0;
    80001058:	4501                	li	a0,0
    8000105a:	b7ed                	j	80001044 <walk+0x8e>

000000008000105c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000105c:	57fd                	li	a5,-1
    8000105e:	83e9                	srli	a5,a5,0x1a
    80001060:	00b7f463          	bgeu	a5,a1,80001068 <walkaddr+0xc>
    return 0;
    80001064:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001066:	8082                	ret
{
    80001068:	1141                	addi	sp,sp,-16
    8000106a:	e406                	sd	ra,8(sp)
    8000106c:	e022                	sd	s0,0(sp)
    8000106e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001070:	4601                	li	a2,0
    80001072:	00000097          	auipc	ra,0x0
    80001076:	f44080e7          	jalr	-188(ra) # 80000fb6 <walk>
  if(pte == 0)
    8000107a:	c105                	beqz	a0,8000109a <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000107c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000107e:	0117f693          	andi	a3,a5,17
    80001082:	4745                	li	a4,17
    return 0;
    80001084:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001086:	00e68663          	beq	a3,a4,80001092 <walkaddr+0x36>
}
    8000108a:	60a2                	ld	ra,8(sp)
    8000108c:	6402                	ld	s0,0(sp)
    8000108e:	0141                	addi	sp,sp,16
    80001090:	8082                	ret
  pa = PTE2PA(*pte);
    80001092:	00a7d513          	srli	a0,a5,0xa
    80001096:	0532                	slli	a0,a0,0xc
  return pa;
    80001098:	bfcd                	j	8000108a <walkaddr+0x2e>
    return 0;
    8000109a:	4501                	li	a0,0
    8000109c:	b7fd                	j	8000108a <walkaddr+0x2e>

000000008000109e <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000109e:	715d                	addi	sp,sp,-80
    800010a0:	e486                	sd	ra,72(sp)
    800010a2:	e0a2                	sd	s0,64(sp)
    800010a4:	fc26                	sd	s1,56(sp)
    800010a6:	f84a                	sd	s2,48(sp)
    800010a8:	f44e                	sd	s3,40(sp)
    800010aa:	f052                	sd	s4,32(sp)
    800010ac:	ec56                	sd	s5,24(sp)
    800010ae:	e85a                	sd	s6,16(sp)
    800010b0:	e45e                	sd	s7,8(sp)
    800010b2:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010b4:	c639                	beqz	a2,80001102 <mappages+0x64>
    800010b6:	8aaa                	mv	s5,a0
    800010b8:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010ba:	77fd                	lui	a5,0xfffff
    800010bc:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800010c0:	15fd                	addi	a1,a1,-1
    800010c2:	00c589b3          	add	s3,a1,a2
    800010c6:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    800010ca:	8952                	mv	s2,s4
    800010cc:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010d0:	6b85                	lui	s7,0x1
    800010d2:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d6:	4605                	li	a2,1
    800010d8:	85ca                	mv	a1,s2
    800010da:	8556                	mv	a0,s5
    800010dc:	00000097          	auipc	ra,0x0
    800010e0:	eda080e7          	jalr	-294(ra) # 80000fb6 <walk>
    800010e4:	cd1d                	beqz	a0,80001122 <mappages+0x84>
    if(*pte & PTE_V)
    800010e6:	611c                	ld	a5,0(a0)
    800010e8:	8b85                	andi	a5,a5,1
    800010ea:	e785                	bnez	a5,80001112 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010ec:	80b1                	srli	s1,s1,0xc
    800010ee:	04aa                	slli	s1,s1,0xa
    800010f0:	0164e4b3          	or	s1,s1,s6
    800010f4:	0014e493          	ori	s1,s1,1
    800010f8:	e104                	sd	s1,0(a0)
    if(a == last)
    800010fa:	05390063          	beq	s2,s3,8000113a <mappages+0x9c>
    a += PGSIZE;
    800010fe:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001100:	bfc9                	j	800010d2 <mappages+0x34>
    panic("mappages: size");
    80001102:	00007517          	auipc	a0,0x7
    80001106:	fd650513          	addi	a0,a0,-42 # 800080d8 <digits+0x98>
    8000110a:	fffff097          	auipc	ra,0xfffff
    8000110e:	434080e7          	jalr	1076(ra) # 8000053e <panic>
      panic("mappages: remap");
    80001112:	00007517          	auipc	a0,0x7
    80001116:	fd650513          	addi	a0,a0,-42 # 800080e8 <digits+0xa8>
    8000111a:	fffff097          	auipc	ra,0xfffff
    8000111e:	424080e7          	jalr	1060(ra) # 8000053e <panic>
      return -1;
    80001122:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001124:	60a6                	ld	ra,72(sp)
    80001126:	6406                	ld	s0,64(sp)
    80001128:	74e2                	ld	s1,56(sp)
    8000112a:	7942                	ld	s2,48(sp)
    8000112c:	79a2                	ld	s3,40(sp)
    8000112e:	7a02                	ld	s4,32(sp)
    80001130:	6ae2                	ld	s5,24(sp)
    80001132:	6b42                	ld	s6,16(sp)
    80001134:	6ba2                	ld	s7,8(sp)
    80001136:	6161                	addi	sp,sp,80
    80001138:	8082                	ret
  return 0;
    8000113a:	4501                	li	a0,0
    8000113c:	b7e5                	j	80001124 <mappages+0x86>

000000008000113e <kvmmap>:
{
    8000113e:	1141                	addi	sp,sp,-16
    80001140:	e406                	sd	ra,8(sp)
    80001142:	e022                	sd	s0,0(sp)
    80001144:	0800                	addi	s0,sp,16
    80001146:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001148:	86b2                	mv	a3,a2
    8000114a:	863e                	mv	a2,a5
    8000114c:	00000097          	auipc	ra,0x0
    80001150:	f52080e7          	jalr	-174(ra) # 8000109e <mappages>
    80001154:	e509                	bnez	a0,8000115e <kvmmap+0x20>
}
    80001156:	60a2                	ld	ra,8(sp)
    80001158:	6402                	ld	s0,0(sp)
    8000115a:	0141                	addi	sp,sp,16
    8000115c:	8082                	ret
    panic("kvmmap");
    8000115e:	00007517          	auipc	a0,0x7
    80001162:	f9a50513          	addi	a0,a0,-102 # 800080f8 <digits+0xb8>
    80001166:	fffff097          	auipc	ra,0xfffff
    8000116a:	3d8080e7          	jalr	984(ra) # 8000053e <panic>

000000008000116e <kvmmake>:
{
    8000116e:	1101                	addi	sp,sp,-32
    80001170:	ec06                	sd	ra,24(sp)
    80001172:	e822                	sd	s0,16(sp)
    80001174:	e426                	sd	s1,8(sp)
    80001176:	e04a                	sd	s2,0(sp)
    80001178:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000117a:	00000097          	auipc	ra,0x0
    8000117e:	96c080e7          	jalr	-1684(ra) # 80000ae6 <kalloc>
    80001182:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001184:	6605                	lui	a2,0x1
    80001186:	4581                	li	a1,0
    80001188:	00000097          	auipc	ra,0x0
    8000118c:	b4a080e7          	jalr	-1206(ra) # 80000cd2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001190:	4719                	li	a4,6
    80001192:	6685                	lui	a3,0x1
    80001194:	10000637          	lui	a2,0x10000
    80001198:	100005b7          	lui	a1,0x10000
    8000119c:	8526                	mv	a0,s1
    8000119e:	00000097          	auipc	ra,0x0
    800011a2:	fa0080e7          	jalr	-96(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a6:	4719                	li	a4,6
    800011a8:	6685                	lui	a3,0x1
    800011aa:	10001637          	lui	a2,0x10001
    800011ae:	100015b7          	lui	a1,0x10001
    800011b2:	8526                	mv	a0,s1
    800011b4:	00000097          	auipc	ra,0x0
    800011b8:	f8a080e7          	jalr	-118(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011bc:	4719                	li	a4,6
    800011be:	004006b7          	lui	a3,0x400
    800011c2:	0c000637          	lui	a2,0xc000
    800011c6:	0c0005b7          	lui	a1,0xc000
    800011ca:	8526                	mv	a0,s1
    800011cc:	00000097          	auipc	ra,0x0
    800011d0:	f72080e7          	jalr	-142(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011d4:	00007917          	auipc	s2,0x7
    800011d8:	e2c90913          	addi	s2,s2,-468 # 80008000 <etext>
    800011dc:	4729                	li	a4,10
    800011de:	80007697          	auipc	a3,0x80007
    800011e2:	e2268693          	addi	a3,a3,-478 # 8000 <_entry-0x7fff8000>
    800011e6:	4605                	li	a2,1
    800011e8:	067e                	slli	a2,a2,0x1f
    800011ea:	85b2                	mv	a1,a2
    800011ec:	8526                	mv	a0,s1
    800011ee:	00000097          	auipc	ra,0x0
    800011f2:	f50080e7          	jalr	-176(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f6:	4719                	li	a4,6
    800011f8:	46c5                	li	a3,17
    800011fa:	06ee                	slli	a3,a3,0x1b
    800011fc:	412686b3          	sub	a3,a3,s2
    80001200:	864a                	mv	a2,s2
    80001202:	85ca                	mv	a1,s2
    80001204:	8526                	mv	a0,s1
    80001206:	00000097          	auipc	ra,0x0
    8000120a:	f38080e7          	jalr	-200(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000120e:	4729                	li	a4,10
    80001210:	6685                	lui	a3,0x1
    80001212:	00006617          	auipc	a2,0x6
    80001216:	dee60613          	addi	a2,a2,-530 # 80007000 <_trampoline>
    8000121a:	040005b7          	lui	a1,0x4000
    8000121e:	15fd                	addi	a1,a1,-1
    80001220:	05b2                	slli	a1,a1,0xc
    80001222:	8526                	mv	a0,s1
    80001224:	00000097          	auipc	ra,0x0
    80001228:	f1a080e7          	jalr	-230(ra) # 8000113e <kvmmap>
  proc_mapstacks(kpgtbl);
    8000122c:	8526                	mv	a0,s1
    8000122e:	00000097          	auipc	ra,0x0
    80001232:	608080e7          	jalr	1544(ra) # 80001836 <proc_mapstacks>
}
    80001236:	8526                	mv	a0,s1
    80001238:	60e2                	ld	ra,24(sp)
    8000123a:	6442                	ld	s0,16(sp)
    8000123c:	64a2                	ld	s1,8(sp)
    8000123e:	6902                	ld	s2,0(sp)
    80001240:	6105                	addi	sp,sp,32
    80001242:	8082                	ret

0000000080001244 <kvminit>:
{
    80001244:	1141                	addi	sp,sp,-16
    80001246:	e406                	sd	ra,8(sp)
    80001248:	e022                	sd	s0,0(sp)
    8000124a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000124c:	00000097          	auipc	ra,0x0
    80001250:	f22080e7          	jalr	-222(ra) # 8000116e <kvmmake>
    80001254:	00007797          	auipc	a5,0x7
    80001258:	66a7b623          	sd	a0,1644(a5) # 800088c0 <kernel_pagetable>
}
    8000125c:	60a2                	ld	ra,8(sp)
    8000125e:	6402                	ld	s0,0(sp)
    80001260:	0141                	addi	sp,sp,16
    80001262:	8082                	ret

0000000080001264 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001264:	715d                	addi	sp,sp,-80
    80001266:	e486                	sd	ra,72(sp)
    80001268:	e0a2                	sd	s0,64(sp)
    8000126a:	fc26                	sd	s1,56(sp)
    8000126c:	f84a                	sd	s2,48(sp)
    8000126e:	f44e                	sd	s3,40(sp)
    80001270:	f052                	sd	s4,32(sp)
    80001272:	ec56                	sd	s5,24(sp)
    80001274:	e85a                	sd	s6,16(sp)
    80001276:	e45e                	sd	s7,8(sp)
    80001278:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000127a:	03459793          	slli	a5,a1,0x34
    8000127e:	e795                	bnez	a5,800012aa <uvmunmap+0x46>
    80001280:	8a2a                	mv	s4,a0
    80001282:	892e                	mv	s2,a1
    80001284:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001286:	0632                	slli	a2,a2,0xc
    80001288:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000128c:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000128e:	6b05                	lui	s6,0x1
    80001290:	0735e263          	bltu	a1,s3,800012f4 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001294:	60a6                	ld	ra,72(sp)
    80001296:	6406                	ld	s0,64(sp)
    80001298:	74e2                	ld	s1,56(sp)
    8000129a:	7942                	ld	s2,48(sp)
    8000129c:	79a2                	ld	s3,40(sp)
    8000129e:	7a02                	ld	s4,32(sp)
    800012a0:	6ae2                	ld	s5,24(sp)
    800012a2:	6b42                	ld	s6,16(sp)
    800012a4:	6ba2                	ld	s7,8(sp)
    800012a6:	6161                	addi	sp,sp,80
    800012a8:	8082                	ret
    panic("uvmunmap: not aligned");
    800012aa:	00007517          	auipc	a0,0x7
    800012ae:	e5650513          	addi	a0,a0,-426 # 80008100 <digits+0xc0>
    800012b2:	fffff097          	auipc	ra,0xfffff
    800012b6:	28c080e7          	jalr	652(ra) # 8000053e <panic>
      panic("uvmunmap: walk");
    800012ba:	00007517          	auipc	a0,0x7
    800012be:	e5e50513          	addi	a0,a0,-418 # 80008118 <digits+0xd8>
    800012c2:	fffff097          	auipc	ra,0xfffff
    800012c6:	27c080e7          	jalr	636(ra) # 8000053e <panic>
      panic("uvmunmap: not mapped");
    800012ca:	00007517          	auipc	a0,0x7
    800012ce:	e5e50513          	addi	a0,a0,-418 # 80008128 <digits+0xe8>
    800012d2:	fffff097          	auipc	ra,0xfffff
    800012d6:	26c080e7          	jalr	620(ra) # 8000053e <panic>
      panic("uvmunmap: not a leaf");
    800012da:	00007517          	auipc	a0,0x7
    800012de:	e6650513          	addi	a0,a0,-410 # 80008140 <digits+0x100>
    800012e2:	fffff097          	auipc	ra,0xfffff
    800012e6:	25c080e7          	jalr	604(ra) # 8000053e <panic>
    *pte = 0;
    800012ea:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012ee:	995a                	add	s2,s2,s6
    800012f0:	fb3972e3          	bgeu	s2,s3,80001294 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012f4:	4601                	li	a2,0
    800012f6:	85ca                	mv	a1,s2
    800012f8:	8552                	mv	a0,s4
    800012fa:	00000097          	auipc	ra,0x0
    800012fe:	cbc080e7          	jalr	-836(ra) # 80000fb6 <walk>
    80001302:	84aa                	mv	s1,a0
    80001304:	d95d                	beqz	a0,800012ba <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001306:	6108                	ld	a0,0(a0)
    80001308:	00157793          	andi	a5,a0,1
    8000130c:	dfdd                	beqz	a5,800012ca <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000130e:	3ff57793          	andi	a5,a0,1023
    80001312:	fd7784e3          	beq	a5,s7,800012da <uvmunmap+0x76>
    if(do_free){
    80001316:	fc0a8ae3          	beqz	s5,800012ea <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    8000131a:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000131c:	0532                	slli	a0,a0,0xc
    8000131e:	fffff097          	auipc	ra,0xfffff
    80001322:	6cc080e7          	jalr	1740(ra) # 800009ea <kfree>
    80001326:	b7d1                	j	800012ea <uvmunmap+0x86>

0000000080001328 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001328:	1101                	addi	sp,sp,-32
    8000132a:	ec06                	sd	ra,24(sp)
    8000132c:	e822                	sd	s0,16(sp)
    8000132e:	e426                	sd	s1,8(sp)
    80001330:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001332:	fffff097          	auipc	ra,0xfffff
    80001336:	7b4080e7          	jalr	1972(ra) # 80000ae6 <kalloc>
    8000133a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000133c:	c519                	beqz	a0,8000134a <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000133e:	6605                	lui	a2,0x1
    80001340:	4581                	li	a1,0
    80001342:	00000097          	auipc	ra,0x0
    80001346:	990080e7          	jalr	-1648(ra) # 80000cd2 <memset>
  return pagetable;
}
    8000134a:	8526                	mv	a0,s1
    8000134c:	60e2                	ld	ra,24(sp)
    8000134e:	6442                	ld	s0,16(sp)
    80001350:	64a2                	ld	s1,8(sp)
    80001352:	6105                	addi	sp,sp,32
    80001354:	8082                	ret

0000000080001356 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001356:	7179                	addi	sp,sp,-48
    80001358:	f406                	sd	ra,40(sp)
    8000135a:	f022                	sd	s0,32(sp)
    8000135c:	ec26                	sd	s1,24(sp)
    8000135e:	e84a                	sd	s2,16(sp)
    80001360:	e44e                	sd	s3,8(sp)
    80001362:	e052                	sd	s4,0(sp)
    80001364:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001366:	6785                	lui	a5,0x1
    80001368:	04f67863          	bgeu	a2,a5,800013b8 <uvmfirst+0x62>
    8000136c:	8a2a                	mv	s4,a0
    8000136e:	89ae                	mv	s3,a1
    80001370:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001372:	fffff097          	auipc	ra,0xfffff
    80001376:	774080e7          	jalr	1908(ra) # 80000ae6 <kalloc>
    8000137a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000137c:	6605                	lui	a2,0x1
    8000137e:	4581                	li	a1,0
    80001380:	00000097          	auipc	ra,0x0
    80001384:	952080e7          	jalr	-1710(ra) # 80000cd2 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001388:	4779                	li	a4,30
    8000138a:	86ca                	mv	a3,s2
    8000138c:	6605                	lui	a2,0x1
    8000138e:	4581                	li	a1,0
    80001390:	8552                	mv	a0,s4
    80001392:	00000097          	auipc	ra,0x0
    80001396:	d0c080e7          	jalr	-756(ra) # 8000109e <mappages>
  memmove(mem, src, sz);
    8000139a:	8626                	mv	a2,s1
    8000139c:	85ce                	mv	a1,s3
    8000139e:	854a                	mv	a0,s2
    800013a0:	00000097          	auipc	ra,0x0
    800013a4:	98e080e7          	jalr	-1650(ra) # 80000d2e <memmove>
}
    800013a8:	70a2                	ld	ra,40(sp)
    800013aa:	7402                	ld	s0,32(sp)
    800013ac:	64e2                	ld	s1,24(sp)
    800013ae:	6942                	ld	s2,16(sp)
    800013b0:	69a2                	ld	s3,8(sp)
    800013b2:	6a02                	ld	s4,0(sp)
    800013b4:	6145                	addi	sp,sp,48
    800013b6:	8082                	ret
    panic("uvmfirst: more than a page");
    800013b8:	00007517          	auipc	a0,0x7
    800013bc:	da050513          	addi	a0,a0,-608 # 80008158 <digits+0x118>
    800013c0:	fffff097          	auipc	ra,0xfffff
    800013c4:	17e080e7          	jalr	382(ra) # 8000053e <panic>

00000000800013c8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013c8:	1101                	addi	sp,sp,-32
    800013ca:	ec06                	sd	ra,24(sp)
    800013cc:	e822                	sd	s0,16(sp)
    800013ce:	e426                	sd	s1,8(sp)
    800013d0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013d2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013d4:	00b67d63          	bgeu	a2,a1,800013ee <uvmdealloc+0x26>
    800013d8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013da:	6785                	lui	a5,0x1
    800013dc:	17fd                	addi	a5,a5,-1
    800013de:	00f60733          	add	a4,a2,a5
    800013e2:	767d                	lui	a2,0xfffff
    800013e4:	8f71                	and	a4,a4,a2
    800013e6:	97ae                	add	a5,a5,a1
    800013e8:	8ff1                	and	a5,a5,a2
    800013ea:	00f76863          	bltu	a4,a5,800013fa <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013ee:	8526                	mv	a0,s1
    800013f0:	60e2                	ld	ra,24(sp)
    800013f2:	6442                	ld	s0,16(sp)
    800013f4:	64a2                	ld	s1,8(sp)
    800013f6:	6105                	addi	sp,sp,32
    800013f8:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013fa:	8f99                	sub	a5,a5,a4
    800013fc:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013fe:	4685                	li	a3,1
    80001400:	0007861b          	sext.w	a2,a5
    80001404:	85ba                	mv	a1,a4
    80001406:	00000097          	auipc	ra,0x0
    8000140a:	e5e080e7          	jalr	-418(ra) # 80001264 <uvmunmap>
    8000140e:	b7c5                	j	800013ee <uvmdealloc+0x26>

0000000080001410 <uvmalloc>:
  if(newsz < oldsz)
    80001410:	0ab66563          	bltu	a2,a1,800014ba <uvmalloc+0xaa>
{
    80001414:	7139                	addi	sp,sp,-64
    80001416:	fc06                	sd	ra,56(sp)
    80001418:	f822                	sd	s0,48(sp)
    8000141a:	f426                	sd	s1,40(sp)
    8000141c:	f04a                	sd	s2,32(sp)
    8000141e:	ec4e                	sd	s3,24(sp)
    80001420:	e852                	sd	s4,16(sp)
    80001422:	e456                	sd	s5,8(sp)
    80001424:	e05a                	sd	s6,0(sp)
    80001426:	0080                	addi	s0,sp,64
    80001428:	8aaa                	mv	s5,a0
    8000142a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000142c:	6985                	lui	s3,0x1
    8000142e:	19fd                	addi	s3,s3,-1
    80001430:	95ce                	add	a1,a1,s3
    80001432:	79fd                	lui	s3,0xfffff
    80001434:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001438:	08c9f363          	bgeu	s3,a2,800014be <uvmalloc+0xae>
    8000143c:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000143e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001442:	fffff097          	auipc	ra,0xfffff
    80001446:	6a4080e7          	jalr	1700(ra) # 80000ae6 <kalloc>
    8000144a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000144c:	c51d                	beqz	a0,8000147a <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    8000144e:	6605                	lui	a2,0x1
    80001450:	4581                	li	a1,0
    80001452:	00000097          	auipc	ra,0x0
    80001456:	880080e7          	jalr	-1920(ra) # 80000cd2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000145a:	875a                	mv	a4,s6
    8000145c:	86a6                	mv	a3,s1
    8000145e:	6605                	lui	a2,0x1
    80001460:	85ca                	mv	a1,s2
    80001462:	8556                	mv	a0,s5
    80001464:	00000097          	auipc	ra,0x0
    80001468:	c3a080e7          	jalr	-966(ra) # 8000109e <mappages>
    8000146c:	e90d                	bnez	a0,8000149e <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000146e:	6785                	lui	a5,0x1
    80001470:	993e                	add	s2,s2,a5
    80001472:	fd4968e3          	bltu	s2,s4,80001442 <uvmalloc+0x32>
  return newsz;
    80001476:	8552                	mv	a0,s4
    80001478:	a809                	j	8000148a <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    8000147a:	864e                	mv	a2,s3
    8000147c:	85ca                	mv	a1,s2
    8000147e:	8556                	mv	a0,s5
    80001480:	00000097          	auipc	ra,0x0
    80001484:	f48080e7          	jalr	-184(ra) # 800013c8 <uvmdealloc>
      return 0;
    80001488:	4501                	li	a0,0
}
    8000148a:	70e2                	ld	ra,56(sp)
    8000148c:	7442                	ld	s0,48(sp)
    8000148e:	74a2                	ld	s1,40(sp)
    80001490:	7902                	ld	s2,32(sp)
    80001492:	69e2                	ld	s3,24(sp)
    80001494:	6a42                	ld	s4,16(sp)
    80001496:	6aa2                	ld	s5,8(sp)
    80001498:	6b02                	ld	s6,0(sp)
    8000149a:	6121                	addi	sp,sp,64
    8000149c:	8082                	ret
      kfree(mem);
    8000149e:	8526                	mv	a0,s1
    800014a0:	fffff097          	auipc	ra,0xfffff
    800014a4:	54a080e7          	jalr	1354(ra) # 800009ea <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014a8:	864e                	mv	a2,s3
    800014aa:	85ca                	mv	a1,s2
    800014ac:	8556                	mv	a0,s5
    800014ae:	00000097          	auipc	ra,0x0
    800014b2:	f1a080e7          	jalr	-230(ra) # 800013c8 <uvmdealloc>
      return 0;
    800014b6:	4501                	li	a0,0
    800014b8:	bfc9                	j	8000148a <uvmalloc+0x7a>
    return oldsz;
    800014ba:	852e                	mv	a0,a1
}
    800014bc:	8082                	ret
  return newsz;
    800014be:	8532                	mv	a0,a2
    800014c0:	b7e9                	j	8000148a <uvmalloc+0x7a>

00000000800014c2 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014c2:	7179                	addi	sp,sp,-48
    800014c4:	f406                	sd	ra,40(sp)
    800014c6:	f022                	sd	s0,32(sp)
    800014c8:	ec26                	sd	s1,24(sp)
    800014ca:	e84a                	sd	s2,16(sp)
    800014cc:	e44e                	sd	s3,8(sp)
    800014ce:	e052                	sd	s4,0(sp)
    800014d0:	1800                	addi	s0,sp,48
    800014d2:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014d4:	84aa                	mv	s1,a0
    800014d6:	6905                	lui	s2,0x1
    800014d8:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014da:	4985                	li	s3,1
    800014dc:	a821                	j	800014f4 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014de:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014e0:	0532                	slli	a0,a0,0xc
    800014e2:	00000097          	auipc	ra,0x0
    800014e6:	fe0080e7          	jalr	-32(ra) # 800014c2 <freewalk>
      pagetable[i] = 0;
    800014ea:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014ee:	04a1                	addi	s1,s1,8
    800014f0:	03248163          	beq	s1,s2,80001512 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800014f4:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f6:	00f57793          	andi	a5,a0,15
    800014fa:	ff3782e3          	beq	a5,s3,800014de <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014fe:	8905                	andi	a0,a0,1
    80001500:	d57d                	beqz	a0,800014ee <freewalk+0x2c>
      panic("freewalk: leaf");
    80001502:	00007517          	auipc	a0,0x7
    80001506:	c7650513          	addi	a0,a0,-906 # 80008178 <digits+0x138>
    8000150a:	fffff097          	auipc	ra,0xfffff
    8000150e:	034080e7          	jalr	52(ra) # 8000053e <panic>
    }
  }
  kfree((void*)pagetable);
    80001512:	8552                	mv	a0,s4
    80001514:	fffff097          	auipc	ra,0xfffff
    80001518:	4d6080e7          	jalr	1238(ra) # 800009ea <kfree>
}
    8000151c:	70a2                	ld	ra,40(sp)
    8000151e:	7402                	ld	s0,32(sp)
    80001520:	64e2                	ld	s1,24(sp)
    80001522:	6942                	ld	s2,16(sp)
    80001524:	69a2                	ld	s3,8(sp)
    80001526:	6a02                	ld	s4,0(sp)
    80001528:	6145                	addi	sp,sp,48
    8000152a:	8082                	ret

000000008000152c <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000152c:	1101                	addi	sp,sp,-32
    8000152e:	ec06                	sd	ra,24(sp)
    80001530:	e822                	sd	s0,16(sp)
    80001532:	e426                	sd	s1,8(sp)
    80001534:	1000                	addi	s0,sp,32
    80001536:	84aa                	mv	s1,a0
  if(sz > 0)
    80001538:	e999                	bnez	a1,8000154e <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000153a:	8526                	mv	a0,s1
    8000153c:	00000097          	auipc	ra,0x0
    80001540:	f86080e7          	jalr	-122(ra) # 800014c2 <freewalk>
}
    80001544:	60e2                	ld	ra,24(sp)
    80001546:	6442                	ld	s0,16(sp)
    80001548:	64a2                	ld	s1,8(sp)
    8000154a:	6105                	addi	sp,sp,32
    8000154c:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000154e:	6605                	lui	a2,0x1
    80001550:	167d                	addi	a2,a2,-1
    80001552:	962e                	add	a2,a2,a1
    80001554:	4685                	li	a3,1
    80001556:	8231                	srli	a2,a2,0xc
    80001558:	4581                	li	a1,0
    8000155a:	00000097          	auipc	ra,0x0
    8000155e:	d0a080e7          	jalr	-758(ra) # 80001264 <uvmunmap>
    80001562:	bfe1                	j	8000153a <uvmfree+0xe>

0000000080001564 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001564:	c679                	beqz	a2,80001632 <uvmcopy+0xce>
{
    80001566:	715d                	addi	sp,sp,-80
    80001568:	e486                	sd	ra,72(sp)
    8000156a:	e0a2                	sd	s0,64(sp)
    8000156c:	fc26                	sd	s1,56(sp)
    8000156e:	f84a                	sd	s2,48(sp)
    80001570:	f44e                	sd	s3,40(sp)
    80001572:	f052                	sd	s4,32(sp)
    80001574:	ec56                	sd	s5,24(sp)
    80001576:	e85a                	sd	s6,16(sp)
    80001578:	e45e                	sd	s7,8(sp)
    8000157a:	0880                	addi	s0,sp,80
    8000157c:	8b2a                	mv	s6,a0
    8000157e:	8aae                	mv	s5,a1
    80001580:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001582:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001584:	4601                	li	a2,0
    80001586:	85ce                	mv	a1,s3
    80001588:	855a                	mv	a0,s6
    8000158a:	00000097          	auipc	ra,0x0
    8000158e:	a2c080e7          	jalr	-1492(ra) # 80000fb6 <walk>
    80001592:	c531                	beqz	a0,800015de <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001594:	6118                	ld	a4,0(a0)
    80001596:	00177793          	andi	a5,a4,1
    8000159a:	cbb1                	beqz	a5,800015ee <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000159c:	00a75593          	srli	a1,a4,0xa
    800015a0:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015a4:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015a8:	fffff097          	auipc	ra,0xfffff
    800015ac:	53e080e7          	jalr	1342(ra) # 80000ae6 <kalloc>
    800015b0:	892a                	mv	s2,a0
    800015b2:	c939                	beqz	a0,80001608 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015b4:	6605                	lui	a2,0x1
    800015b6:	85de                	mv	a1,s7
    800015b8:	fffff097          	auipc	ra,0xfffff
    800015bc:	776080e7          	jalr	1910(ra) # 80000d2e <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015c0:	8726                	mv	a4,s1
    800015c2:	86ca                	mv	a3,s2
    800015c4:	6605                	lui	a2,0x1
    800015c6:	85ce                	mv	a1,s3
    800015c8:	8556                	mv	a0,s5
    800015ca:	00000097          	auipc	ra,0x0
    800015ce:	ad4080e7          	jalr	-1324(ra) # 8000109e <mappages>
    800015d2:	e515                	bnez	a0,800015fe <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015d4:	6785                	lui	a5,0x1
    800015d6:	99be                	add	s3,s3,a5
    800015d8:	fb49e6e3          	bltu	s3,s4,80001584 <uvmcopy+0x20>
    800015dc:	a081                	j	8000161c <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015de:	00007517          	auipc	a0,0x7
    800015e2:	baa50513          	addi	a0,a0,-1110 # 80008188 <digits+0x148>
    800015e6:	fffff097          	auipc	ra,0xfffff
    800015ea:	f58080e7          	jalr	-168(ra) # 8000053e <panic>
      panic("uvmcopy: page not present");
    800015ee:	00007517          	auipc	a0,0x7
    800015f2:	bba50513          	addi	a0,a0,-1094 # 800081a8 <digits+0x168>
    800015f6:	fffff097          	auipc	ra,0xfffff
    800015fa:	f48080e7          	jalr	-184(ra) # 8000053e <panic>
      kfree(mem);
    800015fe:	854a                	mv	a0,s2
    80001600:	fffff097          	auipc	ra,0xfffff
    80001604:	3ea080e7          	jalr	1002(ra) # 800009ea <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001608:	4685                	li	a3,1
    8000160a:	00c9d613          	srli	a2,s3,0xc
    8000160e:	4581                	li	a1,0
    80001610:	8556                	mv	a0,s5
    80001612:	00000097          	auipc	ra,0x0
    80001616:	c52080e7          	jalr	-942(ra) # 80001264 <uvmunmap>
  return -1;
    8000161a:	557d                	li	a0,-1
}
    8000161c:	60a6                	ld	ra,72(sp)
    8000161e:	6406                	ld	s0,64(sp)
    80001620:	74e2                	ld	s1,56(sp)
    80001622:	7942                	ld	s2,48(sp)
    80001624:	79a2                	ld	s3,40(sp)
    80001626:	7a02                	ld	s4,32(sp)
    80001628:	6ae2                	ld	s5,24(sp)
    8000162a:	6b42                	ld	s6,16(sp)
    8000162c:	6ba2                	ld	s7,8(sp)
    8000162e:	6161                	addi	sp,sp,80
    80001630:	8082                	ret
  return 0;
    80001632:	4501                	li	a0,0
}
    80001634:	8082                	ret

0000000080001636 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001636:	1141                	addi	sp,sp,-16
    80001638:	e406                	sd	ra,8(sp)
    8000163a:	e022                	sd	s0,0(sp)
    8000163c:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000163e:	4601                	li	a2,0
    80001640:	00000097          	auipc	ra,0x0
    80001644:	976080e7          	jalr	-1674(ra) # 80000fb6 <walk>
  if(pte == 0)
    80001648:	c901                	beqz	a0,80001658 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000164a:	611c                	ld	a5,0(a0)
    8000164c:	9bbd                	andi	a5,a5,-17
    8000164e:	e11c                	sd	a5,0(a0)
}
    80001650:	60a2                	ld	ra,8(sp)
    80001652:	6402                	ld	s0,0(sp)
    80001654:	0141                	addi	sp,sp,16
    80001656:	8082                	ret
    panic("uvmclear");
    80001658:	00007517          	auipc	a0,0x7
    8000165c:	b7050513          	addi	a0,a0,-1168 # 800081c8 <digits+0x188>
    80001660:	fffff097          	auipc	ra,0xfffff
    80001664:	ede080e7          	jalr	-290(ra) # 8000053e <panic>

0000000080001668 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001668:	c6bd                	beqz	a3,800016d6 <copyout+0x6e>
{
    8000166a:	715d                	addi	sp,sp,-80
    8000166c:	e486                	sd	ra,72(sp)
    8000166e:	e0a2                	sd	s0,64(sp)
    80001670:	fc26                	sd	s1,56(sp)
    80001672:	f84a                	sd	s2,48(sp)
    80001674:	f44e                	sd	s3,40(sp)
    80001676:	f052                	sd	s4,32(sp)
    80001678:	ec56                	sd	s5,24(sp)
    8000167a:	e85a                	sd	s6,16(sp)
    8000167c:	e45e                	sd	s7,8(sp)
    8000167e:	e062                	sd	s8,0(sp)
    80001680:	0880                	addi	s0,sp,80
    80001682:	8b2a                	mv	s6,a0
    80001684:	8c2e                	mv	s8,a1
    80001686:	8a32                	mv	s4,a2
    80001688:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000168a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000168c:	6a85                	lui	s5,0x1
    8000168e:	a015                	j	800016b2 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001690:	9562                	add	a0,a0,s8
    80001692:	0004861b          	sext.w	a2,s1
    80001696:	85d2                	mv	a1,s4
    80001698:	41250533          	sub	a0,a0,s2
    8000169c:	fffff097          	auipc	ra,0xfffff
    800016a0:	692080e7          	jalr	1682(ra) # 80000d2e <memmove>

    len -= n;
    800016a4:	409989b3          	sub	s3,s3,s1
    src += n;
    800016a8:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016aa:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016ae:	02098263          	beqz	s3,800016d2 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016b2:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016b6:	85ca                	mv	a1,s2
    800016b8:	855a                	mv	a0,s6
    800016ba:	00000097          	auipc	ra,0x0
    800016be:	9a2080e7          	jalr	-1630(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800016c2:	cd01                	beqz	a0,800016da <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016c4:	418904b3          	sub	s1,s2,s8
    800016c8:	94d6                	add	s1,s1,s5
    if(n > len)
    800016ca:	fc99f3e3          	bgeu	s3,s1,80001690 <copyout+0x28>
    800016ce:	84ce                	mv	s1,s3
    800016d0:	b7c1                	j	80001690 <copyout+0x28>
  }
  return 0;
    800016d2:	4501                	li	a0,0
    800016d4:	a021                	j	800016dc <copyout+0x74>
    800016d6:	4501                	li	a0,0
}
    800016d8:	8082                	ret
      return -1;
    800016da:	557d                	li	a0,-1
}
    800016dc:	60a6                	ld	ra,72(sp)
    800016de:	6406                	ld	s0,64(sp)
    800016e0:	74e2                	ld	s1,56(sp)
    800016e2:	7942                	ld	s2,48(sp)
    800016e4:	79a2                	ld	s3,40(sp)
    800016e6:	7a02                	ld	s4,32(sp)
    800016e8:	6ae2                	ld	s5,24(sp)
    800016ea:	6b42                	ld	s6,16(sp)
    800016ec:	6ba2                	ld	s7,8(sp)
    800016ee:	6c02                	ld	s8,0(sp)
    800016f0:	6161                	addi	sp,sp,80
    800016f2:	8082                	ret

00000000800016f4 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016f4:	caa5                	beqz	a3,80001764 <copyin+0x70>
{
    800016f6:	715d                	addi	sp,sp,-80
    800016f8:	e486                	sd	ra,72(sp)
    800016fa:	e0a2                	sd	s0,64(sp)
    800016fc:	fc26                	sd	s1,56(sp)
    800016fe:	f84a                	sd	s2,48(sp)
    80001700:	f44e                	sd	s3,40(sp)
    80001702:	f052                	sd	s4,32(sp)
    80001704:	ec56                	sd	s5,24(sp)
    80001706:	e85a                	sd	s6,16(sp)
    80001708:	e45e                	sd	s7,8(sp)
    8000170a:	e062                	sd	s8,0(sp)
    8000170c:	0880                	addi	s0,sp,80
    8000170e:	8b2a                	mv	s6,a0
    80001710:	8a2e                	mv	s4,a1
    80001712:	8c32                	mv	s8,a2
    80001714:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001716:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001718:	6a85                	lui	s5,0x1
    8000171a:	a01d                	j	80001740 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000171c:	018505b3          	add	a1,a0,s8
    80001720:	0004861b          	sext.w	a2,s1
    80001724:	412585b3          	sub	a1,a1,s2
    80001728:	8552                	mv	a0,s4
    8000172a:	fffff097          	auipc	ra,0xfffff
    8000172e:	604080e7          	jalr	1540(ra) # 80000d2e <memmove>

    len -= n;
    80001732:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001736:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001738:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000173c:	02098263          	beqz	s3,80001760 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001740:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001744:	85ca                	mv	a1,s2
    80001746:	855a                	mv	a0,s6
    80001748:	00000097          	auipc	ra,0x0
    8000174c:	914080e7          	jalr	-1772(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    80001750:	cd01                	beqz	a0,80001768 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001752:	418904b3          	sub	s1,s2,s8
    80001756:	94d6                	add	s1,s1,s5
    if(n > len)
    80001758:	fc99f2e3          	bgeu	s3,s1,8000171c <copyin+0x28>
    8000175c:	84ce                	mv	s1,s3
    8000175e:	bf7d                	j	8000171c <copyin+0x28>
  }
  return 0;
    80001760:	4501                	li	a0,0
    80001762:	a021                	j	8000176a <copyin+0x76>
    80001764:	4501                	li	a0,0
}
    80001766:	8082                	ret
      return -1;
    80001768:	557d                	li	a0,-1
}
    8000176a:	60a6                	ld	ra,72(sp)
    8000176c:	6406                	ld	s0,64(sp)
    8000176e:	74e2                	ld	s1,56(sp)
    80001770:	7942                	ld	s2,48(sp)
    80001772:	79a2                	ld	s3,40(sp)
    80001774:	7a02                	ld	s4,32(sp)
    80001776:	6ae2                	ld	s5,24(sp)
    80001778:	6b42                	ld	s6,16(sp)
    8000177a:	6ba2                	ld	s7,8(sp)
    8000177c:	6c02                	ld	s8,0(sp)
    8000177e:	6161                	addi	sp,sp,80
    80001780:	8082                	ret

0000000080001782 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001782:	c6c5                	beqz	a3,8000182a <copyinstr+0xa8>
{
    80001784:	715d                	addi	sp,sp,-80
    80001786:	e486                	sd	ra,72(sp)
    80001788:	e0a2                	sd	s0,64(sp)
    8000178a:	fc26                	sd	s1,56(sp)
    8000178c:	f84a                	sd	s2,48(sp)
    8000178e:	f44e                	sd	s3,40(sp)
    80001790:	f052                	sd	s4,32(sp)
    80001792:	ec56                	sd	s5,24(sp)
    80001794:	e85a                	sd	s6,16(sp)
    80001796:	e45e                	sd	s7,8(sp)
    80001798:	0880                	addi	s0,sp,80
    8000179a:	8a2a                	mv	s4,a0
    8000179c:	8b2e                	mv	s6,a1
    8000179e:	8bb2                	mv	s7,a2
    800017a0:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017a2:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017a4:	6985                	lui	s3,0x1
    800017a6:	a035                	j	800017d2 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017a8:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017ac:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017ae:	0017b793          	seqz	a5,a5
    800017b2:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017b6:	60a6                	ld	ra,72(sp)
    800017b8:	6406                	ld	s0,64(sp)
    800017ba:	74e2                	ld	s1,56(sp)
    800017bc:	7942                	ld	s2,48(sp)
    800017be:	79a2                	ld	s3,40(sp)
    800017c0:	7a02                	ld	s4,32(sp)
    800017c2:	6ae2                	ld	s5,24(sp)
    800017c4:	6b42                	ld	s6,16(sp)
    800017c6:	6ba2                	ld	s7,8(sp)
    800017c8:	6161                	addi	sp,sp,80
    800017ca:	8082                	ret
    srcva = va0 + PGSIZE;
    800017cc:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017d0:	c8a9                	beqz	s1,80001822 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017d2:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017d6:	85ca                	mv	a1,s2
    800017d8:	8552                	mv	a0,s4
    800017da:	00000097          	auipc	ra,0x0
    800017de:	882080e7          	jalr	-1918(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800017e2:	c131                	beqz	a0,80001826 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017e4:	41790833          	sub	a6,s2,s7
    800017e8:	984e                	add	a6,a6,s3
    if(n > max)
    800017ea:	0104f363          	bgeu	s1,a6,800017f0 <copyinstr+0x6e>
    800017ee:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017f0:	955e                	add	a0,a0,s7
    800017f2:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017f6:	fc080be3          	beqz	a6,800017cc <copyinstr+0x4a>
    800017fa:	985a                	add	a6,a6,s6
    800017fc:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017fe:	41650633          	sub	a2,a0,s6
    80001802:	14fd                	addi	s1,s1,-1
    80001804:	9b26                	add	s6,s6,s1
    80001806:	00f60733          	add	a4,a2,a5
    8000180a:	00074703          	lbu	a4,0(a4)
    8000180e:	df49                	beqz	a4,800017a8 <copyinstr+0x26>
        *dst = *p;
    80001810:	00e78023          	sb	a4,0(a5)
      --max;
    80001814:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001818:	0785                	addi	a5,a5,1
    while(n > 0){
    8000181a:	ff0796e3          	bne	a5,a6,80001806 <copyinstr+0x84>
      dst++;
    8000181e:	8b42                	mv	s6,a6
    80001820:	b775                	j	800017cc <copyinstr+0x4a>
    80001822:	4781                	li	a5,0
    80001824:	b769                	j	800017ae <copyinstr+0x2c>
      return -1;
    80001826:	557d                	li	a0,-1
    80001828:	b779                	j	800017b6 <copyinstr+0x34>
  int got_null = 0;
    8000182a:	4781                	li	a5,0
  if(got_null){
    8000182c:	0017b793          	seqz	a5,a5
    80001830:	40f00533          	neg	a0,a5
}
    80001834:	8082                	ret

0000000080001836 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl)
{
    80001836:	7139                	addi	sp,sp,-64
    80001838:	fc06                	sd	ra,56(sp)
    8000183a:	f822                	sd	s0,48(sp)
    8000183c:	f426                	sd	s1,40(sp)
    8000183e:	f04a                	sd	s2,32(sp)
    80001840:	ec4e                	sd	s3,24(sp)
    80001842:	e852                	sd	s4,16(sp)
    80001844:	e456                	sd	s5,8(sp)
    80001846:	e05a                	sd	s6,0(sp)
    80001848:	0080                	addi	s0,sp,64
    8000184a:	89aa                	mv	s3,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    8000184c:	0000f497          	auipc	s1,0xf
    80001850:	72448493          	addi	s1,s1,1828 # 80010f70 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    80001854:	8b26                	mv	s6,s1
    80001856:	00006a97          	auipc	s5,0x6
    8000185a:	7aaa8a93          	addi	s5,s5,1962 # 80008000 <etext>
    8000185e:	04000937          	lui	s2,0x4000
    80001862:	197d                	addi	s2,s2,-1
    80001864:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001866:	00017a17          	auipc	s4,0x17
    8000186a:	30aa0a13          	addi	s4,s4,778 # 80018b70 <tickslock>
    char *pa = kalloc();
    8000186e:	fffff097          	auipc	ra,0xfffff
    80001872:	278080e7          	jalr	632(ra) # 80000ae6 <kalloc>
    80001876:	862a                	mv	a2,a0
    if (pa == 0)
    80001878:	c131                	beqz	a0,800018bc <proc_mapstacks+0x86>
    uint64 va = KSTACK((int)(p - proc));
    8000187a:	416485b3          	sub	a1,s1,s6
    8000187e:	8591                	srai	a1,a1,0x4
    80001880:	000ab783          	ld	a5,0(s5)
    80001884:	02f585b3          	mul	a1,a1,a5
    80001888:	2585                	addiw	a1,a1,1
    8000188a:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000188e:	4719                	li	a4,6
    80001890:	6685                	lui	a3,0x1
    80001892:	40b905b3          	sub	a1,s2,a1
    80001896:	854e                	mv	a0,s3
    80001898:	00000097          	auipc	ra,0x0
    8000189c:	8a6080e7          	jalr	-1882(ra) # 8000113e <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++)
    800018a0:	1f048493          	addi	s1,s1,496
    800018a4:	fd4495e3          	bne	s1,s4,8000186e <proc_mapstacks+0x38>
  }
}
    800018a8:	70e2                	ld	ra,56(sp)
    800018aa:	7442                	ld	s0,48(sp)
    800018ac:	74a2                	ld	s1,40(sp)
    800018ae:	7902                	ld	s2,32(sp)
    800018b0:	69e2                	ld	s3,24(sp)
    800018b2:	6a42                	ld	s4,16(sp)
    800018b4:	6aa2                	ld	s5,8(sp)
    800018b6:	6b02                	ld	s6,0(sp)
    800018b8:	6121                	addi	sp,sp,64
    800018ba:	8082                	ret
      panic("kalloc");
    800018bc:	00007517          	auipc	a0,0x7
    800018c0:	91c50513          	addi	a0,a0,-1764 # 800081d8 <digits+0x198>
    800018c4:	fffff097          	auipc	ra,0xfffff
    800018c8:	c7a080e7          	jalr	-902(ra) # 8000053e <panic>

00000000800018cc <procinit>:

// initialize the proc table.
void procinit(void)
{
    800018cc:	7139                	addi	sp,sp,-64
    800018ce:	fc06                	sd	ra,56(sp)
    800018d0:	f822                	sd	s0,48(sp)
    800018d2:	f426                	sd	s1,40(sp)
    800018d4:	f04a                	sd	s2,32(sp)
    800018d6:	ec4e                	sd	s3,24(sp)
    800018d8:	e852                	sd	s4,16(sp)
    800018da:	e456                	sd	s5,8(sp)
    800018dc:	e05a                	sd	s6,0(sp)
    800018de:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    800018e0:	00007597          	auipc	a1,0x7
    800018e4:	90058593          	addi	a1,a1,-1792 # 800081e0 <digits+0x1a0>
    800018e8:	0000f517          	auipc	a0,0xf
    800018ec:	25850513          	addi	a0,a0,600 # 80010b40 <pid_lock>
    800018f0:	fffff097          	auipc	ra,0xfffff
    800018f4:	256080e7          	jalr	598(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018f8:	00007597          	auipc	a1,0x7
    800018fc:	8f058593          	addi	a1,a1,-1808 # 800081e8 <digits+0x1a8>
    80001900:	0000f517          	auipc	a0,0xf
    80001904:	25850513          	addi	a0,a0,600 # 80010b58 <wait_lock>
    80001908:	fffff097          	auipc	ra,0xfffff
    8000190c:	23e080e7          	jalr	574(ra) # 80000b46 <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    80001910:	0000f497          	auipc	s1,0xf
    80001914:	66048493          	addi	s1,s1,1632 # 80010f70 <proc>
  {
    initlock(&p->lock, "proc");
    80001918:	00007b17          	auipc	s6,0x7
    8000191c:	8e0b0b13          	addi	s6,s6,-1824 # 800081f8 <digits+0x1b8>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    80001920:	8aa6                	mv	s5,s1
    80001922:	00006a17          	auipc	s4,0x6
    80001926:	6dea0a13          	addi	s4,s4,1758 # 80008000 <etext>
    8000192a:	04000937          	lui	s2,0x4000
    8000192e:	197d                	addi	s2,s2,-1
    80001930:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001932:	00017997          	auipc	s3,0x17
    80001936:	23e98993          	addi	s3,s3,574 # 80018b70 <tickslock>
    initlock(&p->lock, "proc");
    8000193a:	85da                	mv	a1,s6
    8000193c:	8526                	mv	a0,s1
    8000193e:	fffff097          	auipc	ra,0xfffff
    80001942:	208080e7          	jalr	520(ra) # 80000b46 <initlock>
    p->state = UNUSED;
    80001946:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    8000194a:	415487b3          	sub	a5,s1,s5
    8000194e:	8791                	srai	a5,a5,0x4
    80001950:	000a3703          	ld	a4,0(s4)
    80001954:	02e787b3          	mul	a5,a5,a4
    80001958:	2785                	addiw	a5,a5,1
    8000195a:	00d7979b          	slliw	a5,a5,0xd
    8000195e:	40f907b3          	sub	a5,s2,a5
    80001962:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    80001964:	1f048493          	addi	s1,s1,496
    80001968:	fd3499e3          	bne	s1,s3,8000193a <procinit+0x6e>
  }
}
    8000196c:	70e2                	ld	ra,56(sp)
    8000196e:	7442                	ld	s0,48(sp)
    80001970:	74a2                	ld	s1,40(sp)
    80001972:	7902                	ld	s2,32(sp)
    80001974:	69e2                	ld	s3,24(sp)
    80001976:	6a42                	ld	s4,16(sp)
    80001978:	6aa2                	ld	s5,8(sp)
    8000197a:	6b02                	ld	s6,0(sp)
    8000197c:	6121                	addi	sp,sp,64
    8000197e:	8082                	ret

0000000080001980 <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    80001980:	1141                	addi	sp,sp,-16
    80001982:	e422                	sd	s0,8(sp)
    80001984:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001986:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001988:	2501                	sext.w	a0,a0
    8000198a:	6422                	ld	s0,8(sp)
    8000198c:	0141                	addi	sp,sp,16
    8000198e:	8082                	ret

0000000080001990 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001990:	1141                	addi	sp,sp,-16
    80001992:	e422                	sd	s0,8(sp)
    80001994:	0800                	addi	s0,sp,16
    80001996:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001998:	2781                	sext.w	a5,a5
    8000199a:	079e                	slli	a5,a5,0x7
  return c;
}
    8000199c:	0000f517          	auipc	a0,0xf
    800019a0:	1d450513          	addi	a0,a0,468 # 80010b70 <cpus>
    800019a4:	953e                	add	a0,a0,a5
    800019a6:	6422                	ld	s0,8(sp)
    800019a8:	0141                	addi	sp,sp,16
    800019aa:	8082                	ret

00000000800019ac <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    800019ac:	1101                	addi	sp,sp,-32
    800019ae:	ec06                	sd	ra,24(sp)
    800019b0:	e822                	sd	s0,16(sp)
    800019b2:	e426                	sd	s1,8(sp)
    800019b4:	1000                	addi	s0,sp,32
  push_off();
    800019b6:	fffff097          	auipc	ra,0xfffff
    800019ba:	1d4080e7          	jalr	468(ra) # 80000b8a <push_off>
    800019be:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019c0:	2781                	sext.w	a5,a5
    800019c2:	079e                	slli	a5,a5,0x7
    800019c4:	0000f717          	auipc	a4,0xf
    800019c8:	17c70713          	addi	a4,a4,380 # 80010b40 <pid_lock>
    800019cc:	97ba                	add	a5,a5,a4
    800019ce:	7b84                	ld	s1,48(a5)
  pop_off();
    800019d0:	fffff097          	auipc	ra,0xfffff
    800019d4:	25a080e7          	jalr	602(ra) # 80000c2a <pop_off>
  return p;
}
    800019d8:	8526                	mv	a0,s1
    800019da:	60e2                	ld	ra,24(sp)
    800019dc:	6442                	ld	s0,16(sp)
    800019de:	64a2                	ld	s1,8(sp)
    800019e0:	6105                	addi	sp,sp,32
    800019e2:	8082                	ret

00000000800019e4 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    800019e4:	1141                	addi	sp,sp,-16
    800019e6:	e406                	sd	ra,8(sp)
    800019e8:	e022                	sd	s0,0(sp)
    800019ea:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019ec:	00000097          	auipc	ra,0x0
    800019f0:	fc0080e7          	jalr	-64(ra) # 800019ac <myproc>
    800019f4:	fffff097          	auipc	ra,0xfffff
    800019f8:	296080e7          	jalr	662(ra) # 80000c8a <release>

  if (first)
    800019fc:	00007797          	auipc	a5,0x7
    80001a00:	e547a783          	lw	a5,-428(a5) # 80008850 <first.1>
    80001a04:	eb89                	bnez	a5,80001a16 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a06:	00001097          	auipc	ra,0x1
    80001a0a:	e24080e7          	jalr	-476(ra) # 8000282a <usertrapret>
}
    80001a0e:	60a2                	ld	ra,8(sp)
    80001a10:	6402                	ld	s0,0(sp)
    80001a12:	0141                	addi	sp,sp,16
    80001a14:	8082                	ret
    first = 0;
    80001a16:	00007797          	auipc	a5,0x7
    80001a1a:	e207ad23          	sw	zero,-454(a5) # 80008850 <first.1>
    fsinit(ROOTDEV);
    80001a1e:	4505                	li	a0,1
    80001a20:	00002097          	auipc	ra,0x2
    80001a24:	ce6080e7          	jalr	-794(ra) # 80003706 <fsinit>
    80001a28:	bff9                	j	80001a06 <forkret+0x22>

0000000080001a2a <allocpid>:
{
    80001a2a:	1101                	addi	sp,sp,-32
    80001a2c:	ec06                	sd	ra,24(sp)
    80001a2e:	e822                	sd	s0,16(sp)
    80001a30:	e426                	sd	s1,8(sp)
    80001a32:	e04a                	sd	s2,0(sp)
    80001a34:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a36:	0000f917          	auipc	s2,0xf
    80001a3a:	10a90913          	addi	s2,s2,266 # 80010b40 <pid_lock>
    80001a3e:	854a                	mv	a0,s2
    80001a40:	fffff097          	auipc	ra,0xfffff
    80001a44:	196080e7          	jalr	406(ra) # 80000bd6 <acquire>
  pid = nextpid;
    80001a48:	00007797          	auipc	a5,0x7
    80001a4c:	e0c78793          	addi	a5,a5,-500 # 80008854 <nextpid>
    80001a50:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a52:	0014871b          	addiw	a4,s1,1
    80001a56:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a58:	854a                	mv	a0,s2
    80001a5a:	fffff097          	auipc	ra,0xfffff
    80001a5e:	230080e7          	jalr	560(ra) # 80000c8a <release>
}
    80001a62:	8526                	mv	a0,s1
    80001a64:	60e2                	ld	ra,24(sp)
    80001a66:	6442                	ld	s0,16(sp)
    80001a68:	64a2                	ld	s1,8(sp)
    80001a6a:	6902                	ld	s2,0(sp)
    80001a6c:	6105                	addi	sp,sp,32
    80001a6e:	8082                	ret

0000000080001a70 <proc_pagetable>:
{
    80001a70:	1101                	addi	sp,sp,-32
    80001a72:	ec06                	sd	ra,24(sp)
    80001a74:	e822                	sd	s0,16(sp)
    80001a76:	e426                	sd	s1,8(sp)
    80001a78:	e04a                	sd	s2,0(sp)
    80001a7a:	1000                	addi	s0,sp,32
    80001a7c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a7e:	00000097          	auipc	ra,0x0
    80001a82:	8aa080e7          	jalr	-1878(ra) # 80001328 <uvmcreate>
    80001a86:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001a88:	c121                	beqz	a0,80001ac8 <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a8a:	4729                	li	a4,10
    80001a8c:	00005697          	auipc	a3,0x5
    80001a90:	57468693          	addi	a3,a3,1396 # 80007000 <_trampoline>
    80001a94:	6605                	lui	a2,0x1
    80001a96:	040005b7          	lui	a1,0x4000
    80001a9a:	15fd                	addi	a1,a1,-1
    80001a9c:	05b2                	slli	a1,a1,0xc
    80001a9e:	fffff097          	auipc	ra,0xfffff
    80001aa2:	600080e7          	jalr	1536(ra) # 8000109e <mappages>
    80001aa6:	02054863          	bltz	a0,80001ad6 <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001aaa:	4719                	li	a4,6
    80001aac:	05893683          	ld	a3,88(s2)
    80001ab0:	6605                	lui	a2,0x1
    80001ab2:	020005b7          	lui	a1,0x2000
    80001ab6:	15fd                	addi	a1,a1,-1
    80001ab8:	05b6                	slli	a1,a1,0xd
    80001aba:	8526                	mv	a0,s1
    80001abc:	fffff097          	auipc	ra,0xfffff
    80001ac0:	5e2080e7          	jalr	1506(ra) # 8000109e <mappages>
    80001ac4:	02054163          	bltz	a0,80001ae6 <proc_pagetable+0x76>
}
    80001ac8:	8526                	mv	a0,s1
    80001aca:	60e2                	ld	ra,24(sp)
    80001acc:	6442                	ld	s0,16(sp)
    80001ace:	64a2                	ld	s1,8(sp)
    80001ad0:	6902                	ld	s2,0(sp)
    80001ad2:	6105                	addi	sp,sp,32
    80001ad4:	8082                	ret
    uvmfree(pagetable, 0);
    80001ad6:	4581                	li	a1,0
    80001ad8:	8526                	mv	a0,s1
    80001ada:	00000097          	auipc	ra,0x0
    80001ade:	a52080e7          	jalr	-1454(ra) # 8000152c <uvmfree>
    return 0;
    80001ae2:	4481                	li	s1,0
    80001ae4:	b7d5                	j	80001ac8 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ae6:	4681                	li	a3,0
    80001ae8:	4605                	li	a2,1
    80001aea:	040005b7          	lui	a1,0x4000
    80001aee:	15fd                	addi	a1,a1,-1
    80001af0:	05b2                	slli	a1,a1,0xc
    80001af2:	8526                	mv	a0,s1
    80001af4:	fffff097          	auipc	ra,0xfffff
    80001af8:	770080e7          	jalr	1904(ra) # 80001264 <uvmunmap>
    uvmfree(pagetable, 0);
    80001afc:	4581                	li	a1,0
    80001afe:	8526                	mv	a0,s1
    80001b00:	00000097          	auipc	ra,0x0
    80001b04:	a2c080e7          	jalr	-1492(ra) # 8000152c <uvmfree>
    return 0;
    80001b08:	4481                	li	s1,0
    80001b0a:	bf7d                	j	80001ac8 <proc_pagetable+0x58>

0000000080001b0c <proc_freepagetable>:
{
    80001b0c:	1101                	addi	sp,sp,-32
    80001b0e:	ec06                	sd	ra,24(sp)
    80001b10:	e822                	sd	s0,16(sp)
    80001b12:	e426                	sd	s1,8(sp)
    80001b14:	e04a                	sd	s2,0(sp)
    80001b16:	1000                	addi	s0,sp,32
    80001b18:	84aa                	mv	s1,a0
    80001b1a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b1c:	4681                	li	a3,0
    80001b1e:	4605                	li	a2,1
    80001b20:	040005b7          	lui	a1,0x4000
    80001b24:	15fd                	addi	a1,a1,-1
    80001b26:	05b2                	slli	a1,a1,0xc
    80001b28:	fffff097          	auipc	ra,0xfffff
    80001b2c:	73c080e7          	jalr	1852(ra) # 80001264 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b30:	4681                	li	a3,0
    80001b32:	4605                	li	a2,1
    80001b34:	020005b7          	lui	a1,0x2000
    80001b38:	15fd                	addi	a1,a1,-1
    80001b3a:	05b6                	slli	a1,a1,0xd
    80001b3c:	8526                	mv	a0,s1
    80001b3e:	fffff097          	auipc	ra,0xfffff
    80001b42:	726080e7          	jalr	1830(ra) # 80001264 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b46:	85ca                	mv	a1,s2
    80001b48:	8526                	mv	a0,s1
    80001b4a:	00000097          	auipc	ra,0x0
    80001b4e:	9e2080e7          	jalr	-1566(ra) # 8000152c <uvmfree>
}
    80001b52:	60e2                	ld	ra,24(sp)
    80001b54:	6442                	ld	s0,16(sp)
    80001b56:	64a2                	ld	s1,8(sp)
    80001b58:	6902                	ld	s2,0(sp)
    80001b5a:	6105                	addi	sp,sp,32
    80001b5c:	8082                	ret

0000000080001b5e <freeproc>:
{
    80001b5e:	1101                	addi	sp,sp,-32
    80001b60:	ec06                	sd	ra,24(sp)
    80001b62:	e822                	sd	s0,16(sp)
    80001b64:	e426                	sd	s1,8(sp)
    80001b66:	1000                	addi	s0,sp,32
    80001b68:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001b6a:	6d28                	ld	a0,88(a0)
    80001b6c:	c509                	beqz	a0,80001b76 <freeproc+0x18>
    kfree((void *)p->trapframe);
    80001b6e:	fffff097          	auipc	ra,0xfffff
    80001b72:	e7c080e7          	jalr	-388(ra) # 800009ea <kfree>
  p->trapframe = 0;
    80001b76:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001b7a:	68a8                	ld	a0,80(s1)
    80001b7c:	c511                	beqz	a0,80001b88 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b7e:	64ac                	ld	a1,72(s1)
    80001b80:	00000097          	auipc	ra,0x0
    80001b84:	f8c080e7          	jalr	-116(ra) # 80001b0c <proc_freepagetable>
  p->pagetable = 0;
    80001b88:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b8c:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b90:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b94:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b98:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b9c:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001ba0:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001ba4:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001ba8:	0004ac23          	sw	zero,24(s1)
}
    80001bac:	60e2                	ld	ra,24(sp)
    80001bae:	6442                	ld	s0,16(sp)
    80001bb0:	64a2                	ld	s1,8(sp)
    80001bb2:	6105                	addi	sp,sp,32
    80001bb4:	8082                	ret

0000000080001bb6 <allocproc>:
{
    80001bb6:	1101                	addi	sp,sp,-32
    80001bb8:	ec06                	sd	ra,24(sp)
    80001bba:	e822                	sd	s0,16(sp)
    80001bbc:	e426                	sd	s1,8(sp)
    80001bbe:	e04a                	sd	s2,0(sp)
    80001bc0:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    80001bc2:	0000f497          	auipc	s1,0xf
    80001bc6:	3ae48493          	addi	s1,s1,942 # 80010f70 <proc>
    80001bca:	00017917          	auipc	s2,0x17
    80001bce:	fa690913          	addi	s2,s2,-90 # 80018b70 <tickslock>
    acquire(&p->lock);
    80001bd2:	8526                	mv	a0,s1
    80001bd4:	fffff097          	auipc	ra,0xfffff
    80001bd8:	002080e7          	jalr	2(ra) # 80000bd6 <acquire>
    if (p->state == UNUSED)
    80001bdc:	4c9c                	lw	a5,24(s1)
    80001bde:	cf81                	beqz	a5,80001bf6 <allocproc+0x40>
      release(&p->lock);
    80001be0:	8526                	mv	a0,s1
    80001be2:	fffff097          	auipc	ra,0xfffff
    80001be6:	0a8080e7          	jalr	168(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001bea:	1f048493          	addi	s1,s1,496
    80001bee:	ff2492e3          	bne	s1,s2,80001bd2 <allocproc+0x1c>
  return 0;
    80001bf2:	4481                	li	s1,0
    80001bf4:	a09d                	j	80001c5a <allocproc+0xa4>
  p->pid = allocpid();
    80001bf6:	00000097          	auipc	ra,0x0
    80001bfa:	e34080e7          	jalr	-460(ra) # 80001a2a <allocpid>
    80001bfe:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c00:	4785                	li	a5,1
    80001c02:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001c04:	fffff097          	auipc	ra,0xfffff
    80001c08:	ee2080e7          	jalr	-286(ra) # 80000ae6 <kalloc>
    80001c0c:	892a                	mv	s2,a0
    80001c0e:	eca8                	sd	a0,88(s1)
    80001c10:	cd21                	beqz	a0,80001c68 <allocproc+0xb2>
  p->pagetable = proc_pagetable(p);
    80001c12:	8526                	mv	a0,s1
    80001c14:	00000097          	auipc	ra,0x0
    80001c18:	e5c080e7          	jalr	-420(ra) # 80001a70 <proc_pagetable>
    80001c1c:	892a                	mv	s2,a0
    80001c1e:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0)
    80001c20:	c125                	beqz	a0,80001c80 <allocproc+0xca>
  memset(&p->context, 0, sizeof(p->context));
    80001c22:	07000613          	li	a2,112
    80001c26:	4581                	li	a1,0
    80001c28:	06048513          	addi	a0,s1,96
    80001c2c:	fffff097          	auipc	ra,0xfffff
    80001c30:	0a6080e7          	jalr	166(ra) # 80000cd2 <memset>
  p->context.ra = (uint64)forkret;
    80001c34:	00000797          	auipc	a5,0x0
    80001c38:	db078793          	addi	a5,a5,-592 # 800019e4 <forkret>
    80001c3c:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c3e:	60bc                	ld	a5,64(s1)
    80001c40:	6705                	lui	a4,0x1
    80001c42:	97ba                	add	a5,a5,a4
    80001c44:	f4bc                	sd	a5,104(s1)
  p->rtime = 0;
    80001c46:	1604a423          	sw	zero,360(s1)
  p->etime = 0;
    80001c4a:	1604a823          	sw	zero,368(s1)
  p->ctime = ticks;
    80001c4e:	00007797          	auipc	a5,0x7
    80001c52:	c827a783          	lw	a5,-894(a5) # 800088d0 <ticks>
    80001c56:	16f4a623          	sw	a5,364(s1)
}
    80001c5a:	8526                	mv	a0,s1
    80001c5c:	60e2                	ld	ra,24(sp)
    80001c5e:	6442                	ld	s0,16(sp)
    80001c60:	64a2                	ld	s1,8(sp)
    80001c62:	6902                	ld	s2,0(sp)
    80001c64:	6105                	addi	sp,sp,32
    80001c66:	8082                	ret
    freeproc(p);
    80001c68:	8526                	mv	a0,s1
    80001c6a:	00000097          	auipc	ra,0x0
    80001c6e:	ef4080e7          	jalr	-268(ra) # 80001b5e <freeproc>
    release(&p->lock);
    80001c72:	8526                	mv	a0,s1
    80001c74:	fffff097          	auipc	ra,0xfffff
    80001c78:	016080e7          	jalr	22(ra) # 80000c8a <release>
    return 0;
    80001c7c:	84ca                	mv	s1,s2
    80001c7e:	bff1                	j	80001c5a <allocproc+0xa4>
    freeproc(p);
    80001c80:	8526                	mv	a0,s1
    80001c82:	00000097          	auipc	ra,0x0
    80001c86:	edc080e7          	jalr	-292(ra) # 80001b5e <freeproc>
    release(&p->lock);
    80001c8a:	8526                	mv	a0,s1
    80001c8c:	fffff097          	auipc	ra,0xfffff
    80001c90:	ffe080e7          	jalr	-2(ra) # 80000c8a <release>
    return 0;
    80001c94:	84ca                	mv	s1,s2
    80001c96:	b7d1                	j	80001c5a <allocproc+0xa4>

0000000080001c98 <userinit>:
{
    80001c98:	1101                	addi	sp,sp,-32
    80001c9a:	ec06                	sd	ra,24(sp)
    80001c9c:	e822                	sd	s0,16(sp)
    80001c9e:	e426                	sd	s1,8(sp)
    80001ca0:	1000                	addi	s0,sp,32
  p = allocproc();
    80001ca2:	00000097          	auipc	ra,0x0
    80001ca6:	f14080e7          	jalr	-236(ra) # 80001bb6 <allocproc>
    80001caa:	84aa                	mv	s1,a0
  initproc = p;
    80001cac:	00007797          	auipc	a5,0x7
    80001cb0:	c0a7be23          	sd	a0,-996(a5) # 800088c8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001cb4:	03400613          	li	a2,52
    80001cb8:	00007597          	auipc	a1,0x7
    80001cbc:	ba858593          	addi	a1,a1,-1112 # 80008860 <initcode>
    80001cc0:	6928                	ld	a0,80(a0)
    80001cc2:	fffff097          	auipc	ra,0xfffff
    80001cc6:	694080e7          	jalr	1684(ra) # 80001356 <uvmfirst>
  p->sz = PGSIZE;
    80001cca:	6785                	lui	a5,0x1
    80001ccc:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;     // user program counter
    80001cce:	6cb8                	ld	a4,88(s1)
    80001cd0:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001cd4:	6cb8                	ld	a4,88(s1)
    80001cd6:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cd8:	4641                	li	a2,16
    80001cda:	00006597          	auipc	a1,0x6
    80001cde:	52658593          	addi	a1,a1,1318 # 80008200 <digits+0x1c0>
    80001ce2:	15848513          	addi	a0,s1,344
    80001ce6:	fffff097          	auipc	ra,0xfffff
    80001cea:	136080e7          	jalr	310(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80001cee:	00006517          	auipc	a0,0x6
    80001cf2:	52250513          	addi	a0,a0,1314 # 80008210 <digits+0x1d0>
    80001cf6:	00002097          	auipc	ra,0x2
    80001cfa:	432080e7          	jalr	1074(ra) # 80004128 <namei>
    80001cfe:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d02:	478d                	li	a5,3
    80001d04:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d06:	8526                	mv	a0,s1
    80001d08:	fffff097          	auipc	ra,0xfffff
    80001d0c:	f82080e7          	jalr	-126(ra) # 80000c8a <release>
}
    80001d10:	60e2                	ld	ra,24(sp)
    80001d12:	6442                	ld	s0,16(sp)
    80001d14:	64a2                	ld	s1,8(sp)
    80001d16:	6105                	addi	sp,sp,32
    80001d18:	8082                	ret

0000000080001d1a <growproc>:
{
    80001d1a:	1101                	addi	sp,sp,-32
    80001d1c:	ec06                	sd	ra,24(sp)
    80001d1e:	e822                	sd	s0,16(sp)
    80001d20:	e426                	sd	s1,8(sp)
    80001d22:	e04a                	sd	s2,0(sp)
    80001d24:	1000                	addi	s0,sp,32
    80001d26:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d28:	00000097          	auipc	ra,0x0
    80001d2c:	c84080e7          	jalr	-892(ra) # 800019ac <myproc>
    80001d30:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d32:	652c                	ld	a1,72(a0)
  if (n > 0)
    80001d34:	01204c63          	bgtz	s2,80001d4c <growproc+0x32>
  else if (n < 0)
    80001d38:	02094663          	bltz	s2,80001d64 <growproc+0x4a>
  p->sz = sz;
    80001d3c:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d3e:	4501                	li	a0,0
}
    80001d40:	60e2                	ld	ra,24(sp)
    80001d42:	6442                	ld	s0,16(sp)
    80001d44:	64a2                	ld	s1,8(sp)
    80001d46:	6902                	ld	s2,0(sp)
    80001d48:	6105                	addi	sp,sp,32
    80001d4a:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001d4c:	4691                	li	a3,4
    80001d4e:	00b90633          	add	a2,s2,a1
    80001d52:	6928                	ld	a0,80(a0)
    80001d54:	fffff097          	auipc	ra,0xfffff
    80001d58:	6bc080e7          	jalr	1724(ra) # 80001410 <uvmalloc>
    80001d5c:	85aa                	mv	a1,a0
    80001d5e:	fd79                	bnez	a0,80001d3c <growproc+0x22>
      return -1;
    80001d60:	557d                	li	a0,-1
    80001d62:	bff9                	j	80001d40 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d64:	00b90633          	add	a2,s2,a1
    80001d68:	6928                	ld	a0,80(a0)
    80001d6a:	fffff097          	auipc	ra,0xfffff
    80001d6e:	65e080e7          	jalr	1630(ra) # 800013c8 <uvmdealloc>
    80001d72:	85aa                	mv	a1,a0
    80001d74:	b7e1                	j	80001d3c <growproc+0x22>

0000000080001d76 <fork>:
{
    80001d76:	7139                	addi	sp,sp,-64
    80001d78:	fc06                	sd	ra,56(sp)
    80001d7a:	f822                	sd	s0,48(sp)
    80001d7c:	f426                	sd	s1,40(sp)
    80001d7e:	f04a                	sd	s2,32(sp)
    80001d80:	ec4e                	sd	s3,24(sp)
    80001d82:	e852                	sd	s4,16(sp)
    80001d84:	e456                	sd	s5,8(sp)
    80001d86:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d88:	00000097          	auipc	ra,0x0
    80001d8c:	c24080e7          	jalr	-988(ra) # 800019ac <myproc>
    80001d90:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0)
    80001d92:	00000097          	auipc	ra,0x0
    80001d96:	e24080e7          	jalr	-476(ra) # 80001bb6 <allocproc>
    80001d9a:	10050c63          	beqz	a0,80001eb2 <fork+0x13c>
    80001d9e:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001da0:	048ab603          	ld	a2,72(s5)
    80001da4:	692c                	ld	a1,80(a0)
    80001da6:	050ab503          	ld	a0,80(s5)
    80001daa:	fffff097          	auipc	ra,0xfffff
    80001dae:	7ba080e7          	jalr	1978(ra) # 80001564 <uvmcopy>
    80001db2:	04054863          	bltz	a0,80001e02 <fork+0x8c>
  np->sz = p->sz;
    80001db6:	048ab783          	ld	a5,72(s5)
    80001dba:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001dbe:	058ab683          	ld	a3,88(s5)
    80001dc2:	87b6                	mv	a5,a3
    80001dc4:	058a3703          	ld	a4,88(s4)
    80001dc8:	12068693          	addi	a3,a3,288
    80001dcc:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001dd0:	6788                	ld	a0,8(a5)
    80001dd2:	6b8c                	ld	a1,16(a5)
    80001dd4:	6f90                	ld	a2,24(a5)
    80001dd6:	01073023          	sd	a6,0(a4)
    80001dda:	e708                	sd	a0,8(a4)
    80001ddc:	eb0c                	sd	a1,16(a4)
    80001dde:	ef10                	sd	a2,24(a4)
    80001de0:	02078793          	addi	a5,a5,32
    80001de4:	02070713          	addi	a4,a4,32
    80001de8:	fed792e3          	bne	a5,a3,80001dcc <fork+0x56>
  np->trapframe->a0 = 0;
    80001dec:	058a3783          	ld	a5,88(s4)
    80001df0:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001df4:	0d0a8493          	addi	s1,s5,208
    80001df8:	0d0a0913          	addi	s2,s4,208
    80001dfc:	150a8993          	addi	s3,s5,336
    80001e00:	a00d                	j	80001e22 <fork+0xac>
    freeproc(np);
    80001e02:	8552                	mv	a0,s4
    80001e04:	00000097          	auipc	ra,0x0
    80001e08:	d5a080e7          	jalr	-678(ra) # 80001b5e <freeproc>
    release(&np->lock);
    80001e0c:	8552                	mv	a0,s4
    80001e0e:	fffff097          	auipc	ra,0xfffff
    80001e12:	e7c080e7          	jalr	-388(ra) # 80000c8a <release>
    return -1;
    80001e16:	597d                	li	s2,-1
    80001e18:	a059                	j	80001e9e <fork+0x128>
  for (i = 0; i < NOFILE; i++)
    80001e1a:	04a1                	addi	s1,s1,8
    80001e1c:	0921                	addi	s2,s2,8
    80001e1e:	01348b63          	beq	s1,s3,80001e34 <fork+0xbe>
    if (p->ofile[i])
    80001e22:	6088                	ld	a0,0(s1)
    80001e24:	d97d                	beqz	a0,80001e1a <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e26:	00003097          	auipc	ra,0x3
    80001e2a:	998080e7          	jalr	-1640(ra) # 800047be <filedup>
    80001e2e:	00a93023          	sd	a0,0(s2)
    80001e32:	b7e5                	j	80001e1a <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e34:	150ab503          	ld	a0,336(s5)
    80001e38:	00002097          	auipc	ra,0x2
    80001e3c:	b0c080e7          	jalr	-1268(ra) # 80003944 <idup>
    80001e40:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e44:	4641                	li	a2,16
    80001e46:	158a8593          	addi	a1,s5,344
    80001e4a:	158a0513          	addi	a0,s4,344
    80001e4e:	fffff097          	auipc	ra,0xfffff
    80001e52:	fce080e7          	jalr	-50(ra) # 80000e1c <safestrcpy>
  pid = np->pid;
    80001e56:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001e5a:	8552                	mv	a0,s4
    80001e5c:	fffff097          	auipc	ra,0xfffff
    80001e60:	e2e080e7          	jalr	-466(ra) # 80000c8a <release>
  acquire(&wait_lock);
    80001e64:	0000f497          	auipc	s1,0xf
    80001e68:	cf448493          	addi	s1,s1,-780 # 80010b58 <wait_lock>
    80001e6c:	8526                	mv	a0,s1
    80001e6e:	fffff097          	auipc	ra,0xfffff
    80001e72:	d68080e7          	jalr	-664(ra) # 80000bd6 <acquire>
  np->parent = p;
    80001e76:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001e7a:	8526                	mv	a0,s1
    80001e7c:	fffff097          	auipc	ra,0xfffff
    80001e80:	e0e080e7          	jalr	-498(ra) # 80000c8a <release>
  acquire(&np->lock);
    80001e84:	8552                	mv	a0,s4
    80001e86:	fffff097          	auipc	ra,0xfffff
    80001e8a:	d50080e7          	jalr	-688(ra) # 80000bd6 <acquire>
  np->state = RUNNABLE;
    80001e8e:	478d                	li	a5,3
    80001e90:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001e94:	8552                	mv	a0,s4
    80001e96:	fffff097          	auipc	ra,0xfffff
    80001e9a:	df4080e7          	jalr	-524(ra) # 80000c8a <release>
}
    80001e9e:	854a                	mv	a0,s2
    80001ea0:	70e2                	ld	ra,56(sp)
    80001ea2:	7442                	ld	s0,48(sp)
    80001ea4:	74a2                	ld	s1,40(sp)
    80001ea6:	7902                	ld	s2,32(sp)
    80001ea8:	69e2                	ld	s3,24(sp)
    80001eaa:	6a42                	ld	s4,16(sp)
    80001eac:	6aa2                	ld	s5,8(sp)
    80001eae:	6121                	addi	sp,sp,64
    80001eb0:	8082                	ret
    return -1;
    80001eb2:	597d                	li	s2,-1
    80001eb4:	b7ed                	j	80001e9e <fork+0x128>

0000000080001eb6 <scheduler>:
{
    80001eb6:	7139                	addi	sp,sp,-64
    80001eb8:	fc06                	sd	ra,56(sp)
    80001eba:	f822                	sd	s0,48(sp)
    80001ebc:	f426                	sd	s1,40(sp)
    80001ebe:	f04a                	sd	s2,32(sp)
    80001ec0:	ec4e                	sd	s3,24(sp)
    80001ec2:	e852                	sd	s4,16(sp)
    80001ec4:	e456                	sd	s5,8(sp)
    80001ec6:	e05a                	sd	s6,0(sp)
    80001ec8:	0080                	addi	s0,sp,64
    80001eca:	8792                	mv	a5,tp
  int id = r_tp();
    80001ecc:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001ece:	00779a93          	slli	s5,a5,0x7
    80001ed2:	0000f717          	auipc	a4,0xf
    80001ed6:	c6e70713          	addi	a4,a4,-914 # 80010b40 <pid_lock>
    80001eda:	9756                	add	a4,a4,s5
    80001edc:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001ee0:	0000f717          	auipc	a4,0xf
    80001ee4:	c9870713          	addi	a4,a4,-872 # 80010b78 <cpus+0x8>
    80001ee8:	9aba                	add	s5,s5,a4
      if (p->state == RUNNABLE)
    80001eea:	498d                	li	s3,3
        p->state = RUNNING;
    80001eec:	4b11                	li	s6,4
        c->proc = p;
    80001eee:	079e                	slli	a5,a5,0x7
    80001ef0:	0000fa17          	auipc	s4,0xf
    80001ef4:	c50a0a13          	addi	s4,s4,-944 # 80010b40 <pid_lock>
    80001ef8:	9a3e                	add	s4,s4,a5
    for (p = proc; p < &proc[NPROC]; p++)
    80001efa:	00017917          	auipc	s2,0x17
    80001efe:	c7690913          	addi	s2,s2,-906 # 80018b70 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f02:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f06:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f0a:	10079073          	csrw	sstatus,a5
    80001f0e:	0000f497          	auipc	s1,0xf
    80001f12:	06248493          	addi	s1,s1,98 # 80010f70 <proc>
    80001f16:	a811                	j	80001f2a <scheduler+0x74>
      release(&p->lock);
    80001f18:	8526                	mv	a0,s1
    80001f1a:	fffff097          	auipc	ra,0xfffff
    80001f1e:	d70080e7          	jalr	-656(ra) # 80000c8a <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80001f22:	1f048493          	addi	s1,s1,496
    80001f26:	fd248ee3          	beq	s1,s2,80001f02 <scheduler+0x4c>
      acquire(&p->lock);
    80001f2a:	8526                	mv	a0,s1
    80001f2c:	fffff097          	auipc	ra,0xfffff
    80001f30:	caa080e7          	jalr	-854(ra) # 80000bd6 <acquire>
      if (p->state == RUNNABLE)
    80001f34:	4c9c                	lw	a5,24(s1)
    80001f36:	ff3791e3          	bne	a5,s3,80001f18 <scheduler+0x62>
        p->state = RUNNING;
    80001f3a:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001f3e:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001f42:	06048593          	addi	a1,s1,96
    80001f46:	8556                	mv	a0,s5
    80001f48:	00001097          	auipc	ra,0x1
    80001f4c:	838080e7          	jalr	-1992(ra) # 80002780 <swtch>
        c->proc = 0;
    80001f50:	020a3823          	sd	zero,48(s4)
    80001f54:	b7d1                	j	80001f18 <scheduler+0x62>

0000000080001f56 <sched>:
{
    80001f56:	7179                	addi	sp,sp,-48
    80001f58:	f406                	sd	ra,40(sp)
    80001f5a:	f022                	sd	s0,32(sp)
    80001f5c:	ec26                	sd	s1,24(sp)
    80001f5e:	e84a                	sd	s2,16(sp)
    80001f60:	e44e                	sd	s3,8(sp)
    80001f62:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f64:	00000097          	auipc	ra,0x0
    80001f68:	a48080e7          	jalr	-1464(ra) # 800019ac <myproc>
    80001f6c:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001f6e:	fffff097          	auipc	ra,0xfffff
    80001f72:	bee080e7          	jalr	-1042(ra) # 80000b5c <holding>
    80001f76:	c93d                	beqz	a0,80001fec <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f78:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001f7a:	2781                	sext.w	a5,a5
    80001f7c:	079e                	slli	a5,a5,0x7
    80001f7e:	0000f717          	auipc	a4,0xf
    80001f82:	bc270713          	addi	a4,a4,-1086 # 80010b40 <pid_lock>
    80001f86:	97ba                	add	a5,a5,a4
    80001f88:	0a87a703          	lw	a4,168(a5)
    80001f8c:	4785                	li	a5,1
    80001f8e:	06f71763          	bne	a4,a5,80001ffc <sched+0xa6>
  if (p->state == RUNNING)
    80001f92:	4c98                	lw	a4,24(s1)
    80001f94:	4791                	li	a5,4
    80001f96:	06f70b63          	beq	a4,a5,8000200c <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f9a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f9e:	8b89                	andi	a5,a5,2
  if (intr_get())
    80001fa0:	efb5                	bnez	a5,8000201c <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fa2:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001fa4:	0000f917          	auipc	s2,0xf
    80001fa8:	b9c90913          	addi	s2,s2,-1124 # 80010b40 <pid_lock>
    80001fac:	2781                	sext.w	a5,a5
    80001fae:	079e                	slli	a5,a5,0x7
    80001fb0:	97ca                	add	a5,a5,s2
    80001fb2:	0ac7a983          	lw	s3,172(a5)
    80001fb6:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001fb8:	2781                	sext.w	a5,a5
    80001fba:	079e                	slli	a5,a5,0x7
    80001fbc:	0000f597          	auipc	a1,0xf
    80001fc0:	bbc58593          	addi	a1,a1,-1092 # 80010b78 <cpus+0x8>
    80001fc4:	95be                	add	a1,a1,a5
    80001fc6:	06048513          	addi	a0,s1,96
    80001fca:	00000097          	auipc	ra,0x0
    80001fce:	7b6080e7          	jalr	1974(ra) # 80002780 <swtch>
    80001fd2:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001fd4:	2781                	sext.w	a5,a5
    80001fd6:	079e                	slli	a5,a5,0x7
    80001fd8:	97ca                	add	a5,a5,s2
    80001fda:	0b37a623          	sw	s3,172(a5)
}
    80001fde:	70a2                	ld	ra,40(sp)
    80001fe0:	7402                	ld	s0,32(sp)
    80001fe2:	64e2                	ld	s1,24(sp)
    80001fe4:	6942                	ld	s2,16(sp)
    80001fe6:	69a2                	ld	s3,8(sp)
    80001fe8:	6145                	addi	sp,sp,48
    80001fea:	8082                	ret
    panic("sched p->lock");
    80001fec:	00006517          	auipc	a0,0x6
    80001ff0:	22c50513          	addi	a0,a0,556 # 80008218 <digits+0x1d8>
    80001ff4:	ffffe097          	auipc	ra,0xffffe
    80001ff8:	54a080e7          	jalr	1354(ra) # 8000053e <panic>
    panic("sched locks");
    80001ffc:	00006517          	auipc	a0,0x6
    80002000:	22c50513          	addi	a0,a0,556 # 80008228 <digits+0x1e8>
    80002004:	ffffe097          	auipc	ra,0xffffe
    80002008:	53a080e7          	jalr	1338(ra) # 8000053e <panic>
    panic("sched running");
    8000200c:	00006517          	auipc	a0,0x6
    80002010:	22c50513          	addi	a0,a0,556 # 80008238 <digits+0x1f8>
    80002014:	ffffe097          	auipc	ra,0xffffe
    80002018:	52a080e7          	jalr	1322(ra) # 8000053e <panic>
    panic("sched interruptible");
    8000201c:	00006517          	auipc	a0,0x6
    80002020:	22c50513          	addi	a0,a0,556 # 80008248 <digits+0x208>
    80002024:	ffffe097          	auipc	ra,0xffffe
    80002028:	51a080e7          	jalr	1306(ra) # 8000053e <panic>

000000008000202c <yield>:
{
    8000202c:	1101                	addi	sp,sp,-32
    8000202e:	ec06                	sd	ra,24(sp)
    80002030:	e822                	sd	s0,16(sp)
    80002032:	e426                	sd	s1,8(sp)
    80002034:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002036:	00000097          	auipc	ra,0x0
    8000203a:	976080e7          	jalr	-1674(ra) # 800019ac <myproc>
    8000203e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002040:	fffff097          	auipc	ra,0xfffff
    80002044:	b96080e7          	jalr	-1130(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    80002048:	478d                	li	a5,3
    8000204a:	cc9c                	sw	a5,24(s1)
  sched();
    8000204c:	00000097          	auipc	ra,0x0
    80002050:	f0a080e7          	jalr	-246(ra) # 80001f56 <sched>
  release(&p->lock);
    80002054:	8526                	mv	a0,s1
    80002056:	fffff097          	auipc	ra,0xfffff
    8000205a:	c34080e7          	jalr	-972(ra) # 80000c8a <release>
}
    8000205e:	60e2                	ld	ra,24(sp)
    80002060:	6442                	ld	s0,16(sp)
    80002062:	64a2                	ld	s1,8(sp)
    80002064:	6105                	addi	sp,sp,32
    80002066:	8082                	ret

0000000080002068 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    80002068:	7179                	addi	sp,sp,-48
    8000206a:	f406                	sd	ra,40(sp)
    8000206c:	f022                	sd	s0,32(sp)
    8000206e:	ec26                	sd	s1,24(sp)
    80002070:	e84a                	sd	s2,16(sp)
    80002072:	e44e                	sd	s3,8(sp)
    80002074:	1800                	addi	s0,sp,48
    80002076:	89aa                	mv	s3,a0
    80002078:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000207a:	00000097          	auipc	ra,0x0
    8000207e:	932080e7          	jalr	-1742(ra) # 800019ac <myproc>
    80002082:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    80002084:	fffff097          	auipc	ra,0xfffff
    80002088:	b52080e7          	jalr	-1198(ra) # 80000bd6 <acquire>
  release(lk);
    8000208c:	854a                	mv	a0,s2
    8000208e:	fffff097          	auipc	ra,0xfffff
    80002092:	bfc080e7          	jalr	-1028(ra) # 80000c8a <release>

  // Go to sleep.
  p->chan = chan;
    80002096:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000209a:	4789                	li	a5,2
    8000209c:	cc9c                	sw	a5,24(s1)

  sched();
    8000209e:	00000097          	auipc	ra,0x0
    800020a2:	eb8080e7          	jalr	-328(ra) # 80001f56 <sched>

  // Tidy up.
  p->chan = 0;
    800020a6:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800020aa:	8526                	mv	a0,s1
    800020ac:	fffff097          	auipc	ra,0xfffff
    800020b0:	bde080e7          	jalr	-1058(ra) # 80000c8a <release>
  acquire(lk);
    800020b4:	854a                	mv	a0,s2
    800020b6:	fffff097          	auipc	ra,0xfffff
    800020ba:	b20080e7          	jalr	-1248(ra) # 80000bd6 <acquire>
}
    800020be:	70a2                	ld	ra,40(sp)
    800020c0:	7402                	ld	s0,32(sp)
    800020c2:	64e2                	ld	s1,24(sp)
    800020c4:	6942                	ld	s2,16(sp)
    800020c6:	69a2                	ld	s3,8(sp)
    800020c8:	6145                	addi	sp,sp,48
    800020ca:	8082                	ret

00000000800020cc <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    800020cc:	7139                	addi	sp,sp,-64
    800020ce:	fc06                	sd	ra,56(sp)
    800020d0:	f822                	sd	s0,48(sp)
    800020d2:	f426                	sd	s1,40(sp)
    800020d4:	f04a                	sd	s2,32(sp)
    800020d6:	ec4e                	sd	s3,24(sp)
    800020d8:	e852                	sd	s4,16(sp)
    800020da:	e456                	sd	s5,8(sp)
    800020dc:	0080                	addi	s0,sp,64
    800020de:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800020e0:	0000f497          	auipc	s1,0xf
    800020e4:	e9048493          	addi	s1,s1,-368 # 80010f70 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    800020e8:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    800020ea:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    800020ec:	00017917          	auipc	s2,0x17
    800020f0:	a8490913          	addi	s2,s2,-1404 # 80018b70 <tickslock>
    800020f4:	a811                	j	80002108 <wakeup+0x3c>
      }
      release(&p->lock);
    800020f6:	8526                	mv	a0,s1
    800020f8:	fffff097          	auipc	ra,0xfffff
    800020fc:	b92080e7          	jalr	-1134(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002100:	1f048493          	addi	s1,s1,496
    80002104:	03248663          	beq	s1,s2,80002130 <wakeup+0x64>
    if (p != myproc())
    80002108:	00000097          	auipc	ra,0x0
    8000210c:	8a4080e7          	jalr	-1884(ra) # 800019ac <myproc>
    80002110:	fea488e3          	beq	s1,a0,80002100 <wakeup+0x34>
      acquire(&p->lock);
    80002114:	8526                	mv	a0,s1
    80002116:	fffff097          	auipc	ra,0xfffff
    8000211a:	ac0080e7          	jalr	-1344(ra) # 80000bd6 <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    8000211e:	4c9c                	lw	a5,24(s1)
    80002120:	fd379be3          	bne	a5,s3,800020f6 <wakeup+0x2a>
    80002124:	709c                	ld	a5,32(s1)
    80002126:	fd4798e3          	bne	a5,s4,800020f6 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000212a:	0154ac23          	sw	s5,24(s1)
    8000212e:	b7e1                	j	800020f6 <wakeup+0x2a>
    }
  }
}
    80002130:	70e2                	ld	ra,56(sp)
    80002132:	7442                	ld	s0,48(sp)
    80002134:	74a2                	ld	s1,40(sp)
    80002136:	7902                	ld	s2,32(sp)
    80002138:	69e2                	ld	s3,24(sp)
    8000213a:	6a42                	ld	s4,16(sp)
    8000213c:	6aa2                	ld	s5,8(sp)
    8000213e:	6121                	addi	sp,sp,64
    80002140:	8082                	ret

0000000080002142 <reparent>:
{
    80002142:	7179                	addi	sp,sp,-48
    80002144:	f406                	sd	ra,40(sp)
    80002146:	f022                	sd	s0,32(sp)
    80002148:	ec26                	sd	s1,24(sp)
    8000214a:	e84a                	sd	s2,16(sp)
    8000214c:	e44e                	sd	s3,8(sp)
    8000214e:	e052                	sd	s4,0(sp)
    80002150:	1800                	addi	s0,sp,48
    80002152:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002154:	0000f497          	auipc	s1,0xf
    80002158:	e1c48493          	addi	s1,s1,-484 # 80010f70 <proc>
      pp->parent = initproc;
    8000215c:	00006a17          	auipc	s4,0x6
    80002160:	76ca0a13          	addi	s4,s4,1900 # 800088c8 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002164:	00017997          	auipc	s3,0x17
    80002168:	a0c98993          	addi	s3,s3,-1524 # 80018b70 <tickslock>
    8000216c:	a029                	j	80002176 <reparent+0x34>
    8000216e:	1f048493          	addi	s1,s1,496
    80002172:	01348d63          	beq	s1,s3,8000218c <reparent+0x4a>
    if (pp->parent == p)
    80002176:	7c9c                	ld	a5,56(s1)
    80002178:	ff279be3          	bne	a5,s2,8000216e <reparent+0x2c>
      pp->parent = initproc;
    8000217c:	000a3503          	ld	a0,0(s4)
    80002180:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002182:	00000097          	auipc	ra,0x0
    80002186:	f4a080e7          	jalr	-182(ra) # 800020cc <wakeup>
    8000218a:	b7d5                	j	8000216e <reparent+0x2c>
}
    8000218c:	70a2                	ld	ra,40(sp)
    8000218e:	7402                	ld	s0,32(sp)
    80002190:	64e2                	ld	s1,24(sp)
    80002192:	6942                	ld	s2,16(sp)
    80002194:	69a2                	ld	s3,8(sp)
    80002196:	6a02                	ld	s4,0(sp)
    80002198:	6145                	addi	sp,sp,48
    8000219a:	8082                	ret

000000008000219c <exit>:
{
    8000219c:	7179                	addi	sp,sp,-48
    8000219e:	f406                	sd	ra,40(sp)
    800021a0:	f022                	sd	s0,32(sp)
    800021a2:	ec26                	sd	s1,24(sp)
    800021a4:	e84a                	sd	s2,16(sp)
    800021a6:	e44e                	sd	s3,8(sp)
    800021a8:	e052                	sd	s4,0(sp)
    800021aa:	1800                	addi	s0,sp,48
    800021ac:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800021ae:	fffff097          	auipc	ra,0xfffff
    800021b2:	7fe080e7          	jalr	2046(ra) # 800019ac <myproc>
    800021b6:	89aa                	mv	s3,a0
  if (p == initproc)
    800021b8:	00006797          	auipc	a5,0x6
    800021bc:	7107b783          	ld	a5,1808(a5) # 800088c8 <initproc>
    800021c0:	0d050493          	addi	s1,a0,208
    800021c4:	15050913          	addi	s2,a0,336
    800021c8:	02a79363          	bne	a5,a0,800021ee <exit+0x52>
    panic("init exiting");
    800021cc:	00006517          	auipc	a0,0x6
    800021d0:	09450513          	addi	a0,a0,148 # 80008260 <digits+0x220>
    800021d4:	ffffe097          	auipc	ra,0xffffe
    800021d8:	36a080e7          	jalr	874(ra) # 8000053e <panic>
      fileclose(f);
    800021dc:	00002097          	auipc	ra,0x2
    800021e0:	634080e7          	jalr	1588(ra) # 80004810 <fileclose>
      p->ofile[fd] = 0;
    800021e4:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    800021e8:	04a1                	addi	s1,s1,8
    800021ea:	01248563          	beq	s1,s2,800021f4 <exit+0x58>
    if (p->ofile[fd])
    800021ee:	6088                	ld	a0,0(s1)
    800021f0:	f575                	bnez	a0,800021dc <exit+0x40>
    800021f2:	bfdd                	j	800021e8 <exit+0x4c>
  begin_op();
    800021f4:	00002097          	auipc	ra,0x2
    800021f8:	150080e7          	jalr	336(ra) # 80004344 <begin_op>
  iput(p->cwd);
    800021fc:	1509b503          	ld	a0,336(s3)
    80002200:	00002097          	auipc	ra,0x2
    80002204:	93c080e7          	jalr	-1732(ra) # 80003b3c <iput>
  end_op();
    80002208:	00002097          	auipc	ra,0x2
    8000220c:	1bc080e7          	jalr	444(ra) # 800043c4 <end_op>
  p->cwd = 0;
    80002210:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002214:	0000f497          	auipc	s1,0xf
    80002218:	94448493          	addi	s1,s1,-1724 # 80010b58 <wait_lock>
    8000221c:	8526                	mv	a0,s1
    8000221e:	fffff097          	auipc	ra,0xfffff
    80002222:	9b8080e7          	jalr	-1608(ra) # 80000bd6 <acquire>
  reparent(p);
    80002226:	854e                	mv	a0,s3
    80002228:	00000097          	auipc	ra,0x0
    8000222c:	f1a080e7          	jalr	-230(ra) # 80002142 <reparent>
  wakeup(p->parent);
    80002230:	0389b503          	ld	a0,56(s3)
    80002234:	00000097          	auipc	ra,0x0
    80002238:	e98080e7          	jalr	-360(ra) # 800020cc <wakeup>
  acquire(&p->lock);
    8000223c:	854e                	mv	a0,s3
    8000223e:	fffff097          	auipc	ra,0xfffff
    80002242:	998080e7          	jalr	-1640(ra) # 80000bd6 <acquire>
  p->xstate = status;
    80002246:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000224a:	4795                	li	a5,5
    8000224c:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    80002250:	00006797          	auipc	a5,0x6
    80002254:	6807a783          	lw	a5,1664(a5) # 800088d0 <ticks>
    80002258:	16f9a823          	sw	a5,368(s3)
  release(&wait_lock);
    8000225c:	8526                	mv	a0,s1
    8000225e:	fffff097          	auipc	ra,0xfffff
    80002262:	a2c080e7          	jalr	-1492(ra) # 80000c8a <release>
  sched();
    80002266:	00000097          	auipc	ra,0x0
    8000226a:	cf0080e7          	jalr	-784(ra) # 80001f56 <sched>
  panic("zombie exit");
    8000226e:	00006517          	auipc	a0,0x6
    80002272:	00250513          	addi	a0,a0,2 # 80008270 <digits+0x230>
    80002276:	ffffe097          	auipc	ra,0xffffe
    8000227a:	2c8080e7          	jalr	712(ra) # 8000053e <panic>

000000008000227e <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    8000227e:	7179                	addi	sp,sp,-48
    80002280:	f406                	sd	ra,40(sp)
    80002282:	f022                	sd	s0,32(sp)
    80002284:	ec26                	sd	s1,24(sp)
    80002286:	e84a                	sd	s2,16(sp)
    80002288:	e44e                	sd	s3,8(sp)
    8000228a:	1800                	addi	s0,sp,48
    8000228c:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    8000228e:	0000f497          	auipc	s1,0xf
    80002292:	ce248493          	addi	s1,s1,-798 # 80010f70 <proc>
    80002296:	00017997          	auipc	s3,0x17
    8000229a:	8da98993          	addi	s3,s3,-1830 # 80018b70 <tickslock>
  {
    acquire(&p->lock);
    8000229e:	8526                	mv	a0,s1
    800022a0:	fffff097          	auipc	ra,0xfffff
    800022a4:	936080e7          	jalr	-1738(ra) # 80000bd6 <acquire>
    if (p->pid == pid)
    800022a8:	589c                	lw	a5,48(s1)
    800022aa:	01278d63          	beq	a5,s2,800022c4 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800022ae:	8526                	mv	a0,s1
    800022b0:	fffff097          	auipc	ra,0xfffff
    800022b4:	9da080e7          	jalr	-1574(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800022b8:	1f048493          	addi	s1,s1,496
    800022bc:	ff3491e3          	bne	s1,s3,8000229e <kill+0x20>
  }
  return -1;
    800022c0:	557d                	li	a0,-1
    800022c2:	a829                	j	800022dc <kill+0x5e>
      p->killed = 1;
    800022c4:	4785                	li	a5,1
    800022c6:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    800022c8:	4c98                	lw	a4,24(s1)
    800022ca:	4789                	li	a5,2
    800022cc:	00f70f63          	beq	a4,a5,800022ea <kill+0x6c>
      release(&p->lock);
    800022d0:	8526                	mv	a0,s1
    800022d2:	fffff097          	auipc	ra,0xfffff
    800022d6:	9b8080e7          	jalr	-1608(ra) # 80000c8a <release>
      return 0;
    800022da:	4501                	li	a0,0
}
    800022dc:	70a2                	ld	ra,40(sp)
    800022de:	7402                	ld	s0,32(sp)
    800022e0:	64e2                	ld	s1,24(sp)
    800022e2:	6942                	ld	s2,16(sp)
    800022e4:	69a2                	ld	s3,8(sp)
    800022e6:	6145                	addi	sp,sp,48
    800022e8:	8082                	ret
        p->state = RUNNABLE;
    800022ea:	478d                	li	a5,3
    800022ec:	cc9c                	sw	a5,24(s1)
    800022ee:	b7cd                	j	800022d0 <kill+0x52>

00000000800022f0 <setkilled>:

void setkilled(struct proc *p)
{
    800022f0:	1101                	addi	sp,sp,-32
    800022f2:	ec06                	sd	ra,24(sp)
    800022f4:	e822                	sd	s0,16(sp)
    800022f6:	e426                	sd	s1,8(sp)
    800022f8:	1000                	addi	s0,sp,32
    800022fa:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022fc:	fffff097          	auipc	ra,0xfffff
    80002300:	8da080e7          	jalr	-1830(ra) # 80000bd6 <acquire>
  p->killed = 1;
    80002304:	4785                	li	a5,1
    80002306:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002308:	8526                	mv	a0,s1
    8000230a:	fffff097          	auipc	ra,0xfffff
    8000230e:	980080e7          	jalr	-1664(ra) # 80000c8a <release>
}
    80002312:	60e2                	ld	ra,24(sp)
    80002314:	6442                	ld	s0,16(sp)
    80002316:	64a2                	ld	s1,8(sp)
    80002318:	6105                	addi	sp,sp,32
    8000231a:	8082                	ret

000000008000231c <killed>:

int killed(struct proc *p)
{
    8000231c:	1101                	addi	sp,sp,-32
    8000231e:	ec06                	sd	ra,24(sp)
    80002320:	e822                	sd	s0,16(sp)
    80002322:	e426                	sd	s1,8(sp)
    80002324:	e04a                	sd	s2,0(sp)
    80002326:	1000                	addi	s0,sp,32
    80002328:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    8000232a:	fffff097          	auipc	ra,0xfffff
    8000232e:	8ac080e7          	jalr	-1876(ra) # 80000bd6 <acquire>
  k = p->killed;
    80002332:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002336:	8526                	mv	a0,s1
    80002338:	fffff097          	auipc	ra,0xfffff
    8000233c:	952080e7          	jalr	-1710(ra) # 80000c8a <release>
  return k;
}
    80002340:	854a                	mv	a0,s2
    80002342:	60e2                	ld	ra,24(sp)
    80002344:	6442                	ld	s0,16(sp)
    80002346:	64a2                	ld	s1,8(sp)
    80002348:	6902                	ld	s2,0(sp)
    8000234a:	6105                	addi	sp,sp,32
    8000234c:	8082                	ret

000000008000234e <wait>:
{
    8000234e:	715d                	addi	sp,sp,-80
    80002350:	e486                	sd	ra,72(sp)
    80002352:	e0a2                	sd	s0,64(sp)
    80002354:	fc26                	sd	s1,56(sp)
    80002356:	f84a                	sd	s2,48(sp)
    80002358:	f44e                	sd	s3,40(sp)
    8000235a:	f052                	sd	s4,32(sp)
    8000235c:	ec56                	sd	s5,24(sp)
    8000235e:	e85a                	sd	s6,16(sp)
    80002360:	e45e                	sd	s7,8(sp)
    80002362:	e062                	sd	s8,0(sp)
    80002364:	0880                	addi	s0,sp,80
    80002366:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002368:	fffff097          	auipc	ra,0xfffff
    8000236c:	644080e7          	jalr	1604(ra) # 800019ac <myproc>
    80002370:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002372:	0000e517          	auipc	a0,0xe
    80002376:	7e650513          	addi	a0,a0,2022 # 80010b58 <wait_lock>
    8000237a:	fffff097          	auipc	ra,0xfffff
    8000237e:	85c080e7          	jalr	-1956(ra) # 80000bd6 <acquire>
    havekids = 0;
    80002382:	4b81                	li	s7,0
        if (pp->state == ZOMBIE)
    80002384:	4a15                	li	s4,5
        havekids = 1;
    80002386:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002388:	00016997          	auipc	s3,0x16
    8000238c:	7e898993          	addi	s3,s3,2024 # 80018b70 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002390:	0000ec17          	auipc	s8,0xe
    80002394:	7c8c0c13          	addi	s8,s8,1992 # 80010b58 <wait_lock>
    havekids = 0;
    80002398:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++)
    8000239a:	0000f497          	auipc	s1,0xf
    8000239e:	bd648493          	addi	s1,s1,-1066 # 80010f70 <proc>
    800023a2:	a0bd                	j	80002410 <wait+0xc2>
          pid = pp->pid;
    800023a4:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800023a8:	000b0e63          	beqz	s6,800023c4 <wait+0x76>
    800023ac:	4691                	li	a3,4
    800023ae:	02c48613          	addi	a2,s1,44
    800023b2:	85da                	mv	a1,s6
    800023b4:	05093503          	ld	a0,80(s2)
    800023b8:	fffff097          	auipc	ra,0xfffff
    800023bc:	2b0080e7          	jalr	688(ra) # 80001668 <copyout>
    800023c0:	02054563          	bltz	a0,800023ea <wait+0x9c>
          freeproc(pp);
    800023c4:	8526                	mv	a0,s1
    800023c6:	fffff097          	auipc	ra,0xfffff
    800023ca:	798080e7          	jalr	1944(ra) # 80001b5e <freeproc>
          release(&pp->lock);
    800023ce:	8526                	mv	a0,s1
    800023d0:	fffff097          	auipc	ra,0xfffff
    800023d4:	8ba080e7          	jalr	-1862(ra) # 80000c8a <release>
          release(&wait_lock);
    800023d8:	0000e517          	auipc	a0,0xe
    800023dc:	78050513          	addi	a0,a0,1920 # 80010b58 <wait_lock>
    800023e0:	fffff097          	auipc	ra,0xfffff
    800023e4:	8aa080e7          	jalr	-1878(ra) # 80000c8a <release>
          return pid;
    800023e8:	a0b5                	j	80002454 <wait+0x106>
            release(&pp->lock);
    800023ea:	8526                	mv	a0,s1
    800023ec:	fffff097          	auipc	ra,0xfffff
    800023f0:	89e080e7          	jalr	-1890(ra) # 80000c8a <release>
            release(&wait_lock);
    800023f4:	0000e517          	auipc	a0,0xe
    800023f8:	76450513          	addi	a0,a0,1892 # 80010b58 <wait_lock>
    800023fc:	fffff097          	auipc	ra,0xfffff
    80002400:	88e080e7          	jalr	-1906(ra) # 80000c8a <release>
            return -1;
    80002404:	59fd                	li	s3,-1
    80002406:	a0b9                	j	80002454 <wait+0x106>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002408:	1f048493          	addi	s1,s1,496
    8000240c:	03348463          	beq	s1,s3,80002434 <wait+0xe6>
      if (pp->parent == p)
    80002410:	7c9c                	ld	a5,56(s1)
    80002412:	ff279be3          	bne	a5,s2,80002408 <wait+0xba>
        acquire(&pp->lock);
    80002416:	8526                	mv	a0,s1
    80002418:	ffffe097          	auipc	ra,0xffffe
    8000241c:	7be080e7          	jalr	1982(ra) # 80000bd6 <acquire>
        if (pp->state == ZOMBIE)
    80002420:	4c9c                	lw	a5,24(s1)
    80002422:	f94781e3          	beq	a5,s4,800023a4 <wait+0x56>
        release(&pp->lock);
    80002426:	8526                	mv	a0,s1
    80002428:	fffff097          	auipc	ra,0xfffff
    8000242c:	862080e7          	jalr	-1950(ra) # 80000c8a <release>
        havekids = 1;
    80002430:	8756                	mv	a4,s5
    80002432:	bfd9                	j	80002408 <wait+0xba>
    if (!havekids || killed(p))
    80002434:	c719                	beqz	a4,80002442 <wait+0xf4>
    80002436:	854a                	mv	a0,s2
    80002438:	00000097          	auipc	ra,0x0
    8000243c:	ee4080e7          	jalr	-284(ra) # 8000231c <killed>
    80002440:	c51d                	beqz	a0,8000246e <wait+0x120>
      release(&wait_lock);
    80002442:	0000e517          	auipc	a0,0xe
    80002446:	71650513          	addi	a0,a0,1814 # 80010b58 <wait_lock>
    8000244a:	fffff097          	auipc	ra,0xfffff
    8000244e:	840080e7          	jalr	-1984(ra) # 80000c8a <release>
      return -1;
    80002452:	59fd                	li	s3,-1
}
    80002454:	854e                	mv	a0,s3
    80002456:	60a6                	ld	ra,72(sp)
    80002458:	6406                	ld	s0,64(sp)
    8000245a:	74e2                	ld	s1,56(sp)
    8000245c:	7942                	ld	s2,48(sp)
    8000245e:	79a2                	ld	s3,40(sp)
    80002460:	7a02                	ld	s4,32(sp)
    80002462:	6ae2                	ld	s5,24(sp)
    80002464:	6b42                	ld	s6,16(sp)
    80002466:	6ba2                	ld	s7,8(sp)
    80002468:	6c02                	ld	s8,0(sp)
    8000246a:	6161                	addi	sp,sp,80
    8000246c:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000246e:	85e2                	mv	a1,s8
    80002470:	854a                	mv	a0,s2
    80002472:	00000097          	auipc	ra,0x0
    80002476:	bf6080e7          	jalr	-1034(ra) # 80002068 <sleep>
    havekids = 0;
    8000247a:	bf39                	j	80002398 <wait+0x4a>

000000008000247c <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000247c:	7179                	addi	sp,sp,-48
    8000247e:	f406                	sd	ra,40(sp)
    80002480:	f022                	sd	s0,32(sp)
    80002482:	ec26                	sd	s1,24(sp)
    80002484:	e84a                	sd	s2,16(sp)
    80002486:	e44e                	sd	s3,8(sp)
    80002488:	e052                	sd	s4,0(sp)
    8000248a:	1800                	addi	s0,sp,48
    8000248c:	84aa                	mv	s1,a0
    8000248e:	892e                	mv	s2,a1
    80002490:	89b2                	mv	s3,a2
    80002492:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002494:	fffff097          	auipc	ra,0xfffff
    80002498:	518080e7          	jalr	1304(ra) # 800019ac <myproc>
  if (user_dst)
    8000249c:	c08d                	beqz	s1,800024be <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    8000249e:	86d2                	mv	a3,s4
    800024a0:	864e                	mv	a2,s3
    800024a2:	85ca                	mv	a1,s2
    800024a4:	6928                	ld	a0,80(a0)
    800024a6:	fffff097          	auipc	ra,0xfffff
    800024aa:	1c2080e7          	jalr	450(ra) # 80001668 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800024ae:	70a2                	ld	ra,40(sp)
    800024b0:	7402                	ld	s0,32(sp)
    800024b2:	64e2                	ld	s1,24(sp)
    800024b4:	6942                	ld	s2,16(sp)
    800024b6:	69a2                	ld	s3,8(sp)
    800024b8:	6a02                	ld	s4,0(sp)
    800024ba:	6145                	addi	sp,sp,48
    800024bc:	8082                	ret
    memmove((char *)dst, src, len);
    800024be:	000a061b          	sext.w	a2,s4
    800024c2:	85ce                	mv	a1,s3
    800024c4:	854a                	mv	a0,s2
    800024c6:	fffff097          	auipc	ra,0xfffff
    800024ca:	868080e7          	jalr	-1944(ra) # 80000d2e <memmove>
    return 0;
    800024ce:	8526                	mv	a0,s1
    800024d0:	bff9                	j	800024ae <either_copyout+0x32>

00000000800024d2 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024d2:	7179                	addi	sp,sp,-48
    800024d4:	f406                	sd	ra,40(sp)
    800024d6:	f022                	sd	s0,32(sp)
    800024d8:	ec26                	sd	s1,24(sp)
    800024da:	e84a                	sd	s2,16(sp)
    800024dc:	e44e                	sd	s3,8(sp)
    800024de:	e052                	sd	s4,0(sp)
    800024e0:	1800                	addi	s0,sp,48
    800024e2:	892a                	mv	s2,a0
    800024e4:	84ae                	mv	s1,a1
    800024e6:	89b2                	mv	s3,a2
    800024e8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024ea:	fffff097          	auipc	ra,0xfffff
    800024ee:	4c2080e7          	jalr	1218(ra) # 800019ac <myproc>
  if (user_src)
    800024f2:	c08d                	beqz	s1,80002514 <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    800024f4:	86d2                	mv	a3,s4
    800024f6:	864e                	mv	a2,s3
    800024f8:	85ca                	mv	a1,s2
    800024fa:	6928                	ld	a0,80(a0)
    800024fc:	fffff097          	auipc	ra,0xfffff
    80002500:	1f8080e7          	jalr	504(ra) # 800016f4 <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    80002504:	70a2                	ld	ra,40(sp)
    80002506:	7402                	ld	s0,32(sp)
    80002508:	64e2                	ld	s1,24(sp)
    8000250a:	6942                	ld	s2,16(sp)
    8000250c:	69a2                	ld	s3,8(sp)
    8000250e:	6a02                	ld	s4,0(sp)
    80002510:	6145                	addi	sp,sp,48
    80002512:	8082                	ret
    memmove(dst, (char *)src, len);
    80002514:	000a061b          	sext.w	a2,s4
    80002518:	85ce                	mv	a1,s3
    8000251a:	854a                	mv	a0,s2
    8000251c:	fffff097          	auipc	ra,0xfffff
    80002520:	812080e7          	jalr	-2030(ra) # 80000d2e <memmove>
    return 0;
    80002524:	8526                	mv	a0,s1
    80002526:	bff9                	j	80002504 <either_copyin+0x32>

0000000080002528 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002528:	715d                	addi	sp,sp,-80
    8000252a:	e486                	sd	ra,72(sp)
    8000252c:	e0a2                	sd	s0,64(sp)
    8000252e:	fc26                	sd	s1,56(sp)
    80002530:	f84a                	sd	s2,48(sp)
    80002532:	f44e                	sd	s3,40(sp)
    80002534:	f052                	sd	s4,32(sp)
    80002536:	ec56                	sd	s5,24(sp)
    80002538:	e85a                	sd	s6,16(sp)
    8000253a:	e45e                	sd	s7,8(sp)
    8000253c:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    8000253e:	00006517          	auipc	a0,0x6
    80002542:	b8a50513          	addi	a0,a0,-1142 # 800080c8 <digits+0x88>
    80002546:	ffffe097          	auipc	ra,0xffffe
    8000254a:	042080e7          	jalr	66(ra) # 80000588 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    8000254e:	0000f497          	auipc	s1,0xf
    80002552:	b7a48493          	addi	s1,s1,-1158 # 800110c8 <proc+0x158>
    80002556:	00016917          	auipc	s2,0x16
    8000255a:	77290913          	addi	s2,s2,1906 # 80018cc8 <bcache+0x140>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000255e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002560:	00006997          	auipc	s3,0x6
    80002564:	d2098993          	addi	s3,s3,-736 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    80002568:	00006a97          	auipc	s5,0x6
    8000256c:	d20a8a93          	addi	s5,s5,-736 # 80008288 <digits+0x248>
    printf("\n");
    80002570:	00006a17          	auipc	s4,0x6
    80002574:	b58a0a13          	addi	s4,s4,-1192 # 800080c8 <digits+0x88>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002578:	00006b97          	auipc	s7,0x6
    8000257c:	d50b8b93          	addi	s7,s7,-688 # 800082c8 <states.0>
    80002580:	a00d                	j	800025a2 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002582:	ed86a583          	lw	a1,-296(a3)
    80002586:	8556                	mv	a0,s5
    80002588:	ffffe097          	auipc	ra,0xffffe
    8000258c:	000080e7          	jalr	ra # 80000588 <printf>
    printf("\n");
    80002590:	8552                	mv	a0,s4
    80002592:	ffffe097          	auipc	ra,0xffffe
    80002596:	ff6080e7          	jalr	-10(ra) # 80000588 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    8000259a:	1f048493          	addi	s1,s1,496
    8000259e:	03248163          	beq	s1,s2,800025c0 <procdump+0x98>
    if (p->state == UNUSED)
    800025a2:	86a6                	mv	a3,s1
    800025a4:	ec04a783          	lw	a5,-320(s1)
    800025a8:	dbed                	beqz	a5,8000259a <procdump+0x72>
      state = "???";
    800025aa:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025ac:	fcfb6be3          	bltu	s6,a5,80002582 <procdump+0x5a>
    800025b0:	1782                	slli	a5,a5,0x20
    800025b2:	9381                	srli	a5,a5,0x20
    800025b4:	078e                	slli	a5,a5,0x3
    800025b6:	97de                	add	a5,a5,s7
    800025b8:	6390                	ld	a2,0(a5)
    800025ba:	f661                	bnez	a2,80002582 <procdump+0x5a>
      state = "???";
    800025bc:	864e                	mv	a2,s3
    800025be:	b7d1                	j	80002582 <procdump+0x5a>
  }
}
    800025c0:	60a6                	ld	ra,72(sp)
    800025c2:	6406                	ld	s0,64(sp)
    800025c4:	74e2                	ld	s1,56(sp)
    800025c6:	7942                	ld	s2,48(sp)
    800025c8:	79a2                	ld	s3,40(sp)
    800025ca:	7a02                	ld	s4,32(sp)
    800025cc:	6ae2                	ld	s5,24(sp)
    800025ce:	6b42                	ld	s6,16(sp)
    800025d0:	6ba2                	ld	s7,8(sp)
    800025d2:	6161                	addi	sp,sp,80
    800025d4:	8082                	ret

00000000800025d6 <waitx>:

// waitx
int waitx(uint64 addr, uint *wtime, uint *rtime)
{
    800025d6:	711d                	addi	sp,sp,-96
    800025d8:	ec86                	sd	ra,88(sp)
    800025da:	e8a2                	sd	s0,80(sp)
    800025dc:	e4a6                	sd	s1,72(sp)
    800025de:	e0ca                	sd	s2,64(sp)
    800025e0:	fc4e                	sd	s3,56(sp)
    800025e2:	f852                	sd	s4,48(sp)
    800025e4:	f456                	sd	s5,40(sp)
    800025e6:	f05a                	sd	s6,32(sp)
    800025e8:	ec5e                	sd	s7,24(sp)
    800025ea:	e862                	sd	s8,16(sp)
    800025ec:	e466                	sd	s9,8(sp)
    800025ee:	e06a                	sd	s10,0(sp)
    800025f0:	1080                	addi	s0,sp,96
    800025f2:	8b2a                	mv	s6,a0
    800025f4:	8bae                	mv	s7,a1
    800025f6:	8c32                	mv	s8,a2
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    800025f8:	fffff097          	auipc	ra,0xfffff
    800025fc:	3b4080e7          	jalr	948(ra) # 800019ac <myproc>
    80002600:	892a                	mv	s2,a0

  acquire(&wait_lock);
    80002602:	0000e517          	auipc	a0,0xe
    80002606:	55650513          	addi	a0,a0,1366 # 80010b58 <wait_lock>
    8000260a:	ffffe097          	auipc	ra,0xffffe
    8000260e:	5cc080e7          	jalr	1484(ra) # 80000bd6 <acquire>

  for (;;)
  {
    // Scan through table looking for exited children.
    havekids = 0;
    80002612:	4c81                	li	s9,0
      {
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if (np->state == ZOMBIE)
    80002614:	4a15                	li	s4,5
        havekids = 1;
    80002616:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    80002618:	00016997          	auipc	s3,0x16
    8000261c:	55898993          	addi	s3,s3,1368 # 80018b70 <tickslock>
      release(&wait_lock);
      return -1;
    }

    // Wait for a child to exit.
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002620:	0000ed17          	auipc	s10,0xe
    80002624:	538d0d13          	addi	s10,s10,1336 # 80010b58 <wait_lock>
    havekids = 0;
    80002628:	8766                	mv	a4,s9
    for (np = proc; np < &proc[NPROC]; np++)
    8000262a:	0000f497          	auipc	s1,0xf
    8000262e:	94648493          	addi	s1,s1,-1722 # 80010f70 <proc>
    80002632:	a059                	j	800026b8 <waitx+0xe2>
          pid = np->pid;
    80002634:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    80002638:	1684a703          	lw	a4,360(s1)
    8000263c:	00ec2023          	sw	a4,0(s8)
          *wtime = np->etime - np->ctime - np->rtime;
    80002640:	16c4a783          	lw	a5,364(s1)
    80002644:	9f3d                	addw	a4,a4,a5
    80002646:	1704a783          	lw	a5,368(s1)
    8000264a:	9f99                	subw	a5,a5,a4
    8000264c:	00fba023          	sw	a5,0(s7)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002650:	000b0e63          	beqz	s6,8000266c <waitx+0x96>
    80002654:	4691                	li	a3,4
    80002656:	02c48613          	addi	a2,s1,44
    8000265a:	85da                	mv	a1,s6
    8000265c:	05093503          	ld	a0,80(s2)
    80002660:	fffff097          	auipc	ra,0xfffff
    80002664:	008080e7          	jalr	8(ra) # 80001668 <copyout>
    80002668:	02054563          	bltz	a0,80002692 <waitx+0xbc>
          freeproc(np);
    8000266c:	8526                	mv	a0,s1
    8000266e:	fffff097          	auipc	ra,0xfffff
    80002672:	4f0080e7          	jalr	1264(ra) # 80001b5e <freeproc>
          release(&np->lock);
    80002676:	8526                	mv	a0,s1
    80002678:	ffffe097          	auipc	ra,0xffffe
    8000267c:	612080e7          	jalr	1554(ra) # 80000c8a <release>
          release(&wait_lock);
    80002680:	0000e517          	auipc	a0,0xe
    80002684:	4d850513          	addi	a0,a0,1240 # 80010b58 <wait_lock>
    80002688:	ffffe097          	auipc	ra,0xffffe
    8000268c:	602080e7          	jalr	1538(ra) # 80000c8a <release>
          return pid;
    80002690:	a09d                	j	800026f6 <waitx+0x120>
            release(&np->lock);
    80002692:	8526                	mv	a0,s1
    80002694:	ffffe097          	auipc	ra,0xffffe
    80002698:	5f6080e7          	jalr	1526(ra) # 80000c8a <release>
            release(&wait_lock);
    8000269c:	0000e517          	auipc	a0,0xe
    800026a0:	4bc50513          	addi	a0,a0,1212 # 80010b58 <wait_lock>
    800026a4:	ffffe097          	auipc	ra,0xffffe
    800026a8:	5e6080e7          	jalr	1510(ra) # 80000c8a <release>
            return -1;
    800026ac:	59fd                	li	s3,-1
    800026ae:	a0a1                	j	800026f6 <waitx+0x120>
    for (np = proc; np < &proc[NPROC]; np++)
    800026b0:	1f048493          	addi	s1,s1,496
    800026b4:	03348463          	beq	s1,s3,800026dc <waitx+0x106>
      if (np->parent == p)
    800026b8:	7c9c                	ld	a5,56(s1)
    800026ba:	ff279be3          	bne	a5,s2,800026b0 <waitx+0xda>
        acquire(&np->lock);
    800026be:	8526                	mv	a0,s1
    800026c0:	ffffe097          	auipc	ra,0xffffe
    800026c4:	516080e7          	jalr	1302(ra) # 80000bd6 <acquire>
        if (np->state == ZOMBIE)
    800026c8:	4c9c                	lw	a5,24(s1)
    800026ca:	f74785e3          	beq	a5,s4,80002634 <waitx+0x5e>
        release(&np->lock);
    800026ce:	8526                	mv	a0,s1
    800026d0:	ffffe097          	auipc	ra,0xffffe
    800026d4:	5ba080e7          	jalr	1466(ra) # 80000c8a <release>
        havekids = 1;
    800026d8:	8756                	mv	a4,s5
    800026da:	bfd9                	j	800026b0 <waitx+0xda>
    if (!havekids || p->killed)
    800026dc:	c701                	beqz	a4,800026e4 <waitx+0x10e>
    800026de:	02892783          	lw	a5,40(s2)
    800026e2:	cb8d                	beqz	a5,80002714 <waitx+0x13e>
      release(&wait_lock);
    800026e4:	0000e517          	auipc	a0,0xe
    800026e8:	47450513          	addi	a0,a0,1140 # 80010b58 <wait_lock>
    800026ec:	ffffe097          	auipc	ra,0xffffe
    800026f0:	59e080e7          	jalr	1438(ra) # 80000c8a <release>
      return -1;
    800026f4:	59fd                	li	s3,-1
  }
}
    800026f6:	854e                	mv	a0,s3
    800026f8:	60e6                	ld	ra,88(sp)
    800026fa:	6446                	ld	s0,80(sp)
    800026fc:	64a6                	ld	s1,72(sp)
    800026fe:	6906                	ld	s2,64(sp)
    80002700:	79e2                	ld	s3,56(sp)
    80002702:	7a42                	ld	s4,48(sp)
    80002704:	7aa2                	ld	s5,40(sp)
    80002706:	7b02                	ld	s6,32(sp)
    80002708:	6be2                	ld	s7,24(sp)
    8000270a:	6c42                	ld	s8,16(sp)
    8000270c:	6ca2                	ld	s9,8(sp)
    8000270e:	6d02                	ld	s10,0(sp)
    80002710:	6125                	addi	sp,sp,96
    80002712:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002714:	85ea                	mv	a1,s10
    80002716:	854a                	mv	a0,s2
    80002718:	00000097          	auipc	ra,0x0
    8000271c:	950080e7          	jalr	-1712(ra) # 80002068 <sleep>
    havekids = 0;
    80002720:	b721                	j	80002628 <waitx+0x52>

0000000080002722 <update_time>:

void update_time()
{
    80002722:	7179                	addi	sp,sp,-48
    80002724:	f406                	sd	ra,40(sp)
    80002726:	f022                	sd	s0,32(sp)
    80002728:	ec26                	sd	s1,24(sp)
    8000272a:	e84a                	sd	s2,16(sp)
    8000272c:	e44e                	sd	s3,8(sp)
    8000272e:	1800                	addi	s0,sp,48
  struct proc *p;
  for (p = proc; p < &proc[NPROC]; p++)
    80002730:	0000f497          	auipc	s1,0xf
    80002734:	84048493          	addi	s1,s1,-1984 # 80010f70 <proc>
  {
    acquire(&p->lock);
    if (p->state == RUNNING)
    80002738:	4991                	li	s3,4
  for (p = proc; p < &proc[NPROC]; p++)
    8000273a:	00016917          	auipc	s2,0x16
    8000273e:	43690913          	addi	s2,s2,1078 # 80018b70 <tickslock>
    80002742:	a811                	j	80002756 <update_time+0x34>
    {
      p->rtime++;
    }
    release(&p->lock);
    80002744:	8526                	mv	a0,s1
    80002746:	ffffe097          	auipc	ra,0xffffe
    8000274a:	544080e7          	jalr	1348(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    8000274e:	1f048493          	addi	s1,s1,496
    80002752:	03248063          	beq	s1,s2,80002772 <update_time+0x50>
    acquire(&p->lock);
    80002756:	8526                	mv	a0,s1
    80002758:	ffffe097          	auipc	ra,0xffffe
    8000275c:	47e080e7          	jalr	1150(ra) # 80000bd6 <acquire>
    if (p->state == RUNNING)
    80002760:	4c9c                	lw	a5,24(s1)
    80002762:	ff3791e3          	bne	a5,s3,80002744 <update_time+0x22>
      p->rtime++;
    80002766:	1684a783          	lw	a5,360(s1)
    8000276a:	2785                	addiw	a5,a5,1
    8000276c:	16f4a423          	sw	a5,360(s1)
    80002770:	bfd1                	j	80002744 <update_time+0x22>
  }
}
    80002772:	70a2                	ld	ra,40(sp)
    80002774:	7402                	ld	s0,32(sp)
    80002776:	64e2                	ld	s1,24(sp)
    80002778:	6942                	ld	s2,16(sp)
    8000277a:	69a2                	ld	s3,8(sp)
    8000277c:	6145                	addi	sp,sp,48
    8000277e:	8082                	ret

0000000080002780 <swtch>:
    80002780:	00153023          	sd	ra,0(a0)
    80002784:	00253423          	sd	sp,8(a0)
    80002788:	e900                	sd	s0,16(a0)
    8000278a:	ed04                	sd	s1,24(a0)
    8000278c:	03253023          	sd	s2,32(a0)
    80002790:	03353423          	sd	s3,40(a0)
    80002794:	03453823          	sd	s4,48(a0)
    80002798:	03553c23          	sd	s5,56(a0)
    8000279c:	05653023          	sd	s6,64(a0)
    800027a0:	05753423          	sd	s7,72(a0)
    800027a4:	05853823          	sd	s8,80(a0)
    800027a8:	05953c23          	sd	s9,88(a0)
    800027ac:	07a53023          	sd	s10,96(a0)
    800027b0:	07b53423          	sd	s11,104(a0)
    800027b4:	0005b083          	ld	ra,0(a1)
    800027b8:	0085b103          	ld	sp,8(a1)
    800027bc:	6980                	ld	s0,16(a1)
    800027be:	6d84                	ld	s1,24(a1)
    800027c0:	0205b903          	ld	s2,32(a1)
    800027c4:	0285b983          	ld	s3,40(a1)
    800027c8:	0305ba03          	ld	s4,48(a1)
    800027cc:	0385ba83          	ld	s5,56(a1)
    800027d0:	0405bb03          	ld	s6,64(a1)
    800027d4:	0485bb83          	ld	s7,72(a1)
    800027d8:	0505bc03          	ld	s8,80(a1)
    800027dc:	0585bc83          	ld	s9,88(a1)
    800027e0:	0605bd03          	ld	s10,96(a1)
    800027e4:	0685bd83          	ld	s11,104(a1)
    800027e8:	8082                	ret

00000000800027ea <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    800027ea:	1141                	addi	sp,sp,-16
    800027ec:	e406                	sd	ra,8(sp)
    800027ee:	e022                	sd	s0,0(sp)
    800027f0:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800027f2:	00006597          	auipc	a1,0x6
    800027f6:	b0658593          	addi	a1,a1,-1274 # 800082f8 <states.0+0x30>
    800027fa:	00016517          	auipc	a0,0x16
    800027fe:	37650513          	addi	a0,a0,886 # 80018b70 <tickslock>
    80002802:	ffffe097          	auipc	ra,0xffffe
    80002806:	344080e7          	jalr	836(ra) # 80000b46 <initlock>
}
    8000280a:	60a2                	ld	ra,8(sp)
    8000280c:	6402                	ld	s0,0(sp)
    8000280e:	0141                	addi	sp,sp,16
    80002810:	8082                	ret

0000000080002812 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002812:	1141                	addi	sp,sp,-16
    80002814:	e422                	sd	s0,8(sp)
    80002816:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002818:	00003797          	auipc	a5,0x3
    8000281c:	64878793          	addi	a5,a5,1608 # 80005e60 <kernelvec>
    80002820:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002824:	6422                	ld	s0,8(sp)
    80002826:	0141                	addi	sp,sp,16
    80002828:	8082                	ret

000000008000282a <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    8000282a:	1141                	addi	sp,sp,-16
    8000282c:	e406                	sd	ra,8(sp)
    8000282e:	e022                	sd	s0,0(sp)
    80002830:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002832:	fffff097          	auipc	ra,0xfffff
    80002836:	17a080e7          	jalr	378(ra) # 800019ac <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000283a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000283e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002840:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002844:	00004617          	auipc	a2,0x4
    80002848:	7bc60613          	addi	a2,a2,1980 # 80007000 <_trampoline>
    8000284c:	00004697          	auipc	a3,0x4
    80002850:	7b468693          	addi	a3,a3,1972 # 80007000 <_trampoline>
    80002854:	8e91                	sub	a3,a3,a2
    80002856:	040007b7          	lui	a5,0x4000
    8000285a:	17fd                	addi	a5,a5,-1
    8000285c:	07b2                	slli	a5,a5,0xc
    8000285e:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002860:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002864:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002866:	180026f3          	csrr	a3,satp
    8000286a:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000286c:	6d38                	ld	a4,88(a0)
    8000286e:	6134                	ld	a3,64(a0)
    80002870:	6585                	lui	a1,0x1
    80002872:	96ae                	add	a3,a3,a1
    80002874:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002876:	6d38                	ld	a4,88(a0)
    80002878:	00000697          	auipc	a3,0x0
    8000287c:	13e68693          	addi	a3,a3,318 # 800029b6 <usertrap>
    80002880:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002882:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002884:	8692                	mv	a3,tp
    80002886:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002888:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000288c:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002890:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002894:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002898:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000289a:	6f18                	ld	a4,24(a4)
    8000289c:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800028a0:	6928                	ld	a0,80(a0)
    800028a2:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800028a4:	00004717          	auipc	a4,0x4
    800028a8:	7f870713          	addi	a4,a4,2040 # 8000709c <userret>
    800028ac:	8f11                	sub	a4,a4,a2
    800028ae:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800028b0:	577d                	li	a4,-1
    800028b2:	177e                	slli	a4,a4,0x3f
    800028b4:	8d59                	or	a0,a0,a4
    800028b6:	9782                	jalr	a5
}
    800028b8:	60a2                	ld	ra,8(sp)
    800028ba:	6402                	ld	s0,0(sp)
    800028bc:	0141                	addi	sp,sp,16
    800028be:	8082                	ret

00000000800028c0 <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    800028c0:	1101                	addi	sp,sp,-32
    800028c2:	ec06                	sd	ra,24(sp)
    800028c4:	e822                	sd	s0,16(sp)
    800028c6:	e426                	sd	s1,8(sp)
    800028c8:	e04a                	sd	s2,0(sp)
    800028ca:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800028cc:	00016917          	auipc	s2,0x16
    800028d0:	2a490913          	addi	s2,s2,676 # 80018b70 <tickslock>
    800028d4:	854a                	mv	a0,s2
    800028d6:	ffffe097          	auipc	ra,0xffffe
    800028da:	300080e7          	jalr	768(ra) # 80000bd6 <acquire>
  ticks++;
    800028de:	00006497          	auipc	s1,0x6
    800028e2:	ff248493          	addi	s1,s1,-14 # 800088d0 <ticks>
    800028e6:	409c                	lw	a5,0(s1)
    800028e8:	2785                	addiw	a5,a5,1
    800028ea:	c09c                	sw	a5,0(s1)
  update_time();
    800028ec:	00000097          	auipc	ra,0x0
    800028f0:	e36080e7          	jalr	-458(ra) # 80002722 <update_time>
  //   // {
  //   //   p->wtime++;
  //   // }
  //   release(&p->lock);
  // }
  wakeup(&ticks);
    800028f4:	8526                	mv	a0,s1
    800028f6:	fffff097          	auipc	ra,0xfffff
    800028fa:	7d6080e7          	jalr	2006(ra) # 800020cc <wakeup>
  release(&tickslock);
    800028fe:	854a                	mv	a0,s2
    80002900:	ffffe097          	auipc	ra,0xffffe
    80002904:	38a080e7          	jalr	906(ra) # 80000c8a <release>
}
    80002908:	60e2                	ld	ra,24(sp)
    8000290a:	6442                	ld	s0,16(sp)
    8000290c:	64a2                	ld	s1,8(sp)
    8000290e:	6902                	ld	s2,0(sp)
    80002910:	6105                	addi	sp,sp,32
    80002912:	8082                	ret

0000000080002914 <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    80002914:	1101                	addi	sp,sp,-32
    80002916:	ec06                	sd	ra,24(sp)
    80002918:	e822                	sd	s0,16(sp)
    8000291a:	e426                	sd	s1,8(sp)
    8000291c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000291e:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if ((scause & 0x8000000000000000L) &&
    80002922:	00074d63          	bltz	a4,8000293c <devintr+0x28>
    if (irq)
      plic_complete(irq);

    return 1;
  }
  else if (scause == 0x8000000000000001L)
    80002926:	57fd                	li	a5,-1
    80002928:	17fe                	slli	a5,a5,0x3f
    8000292a:	0785                	addi	a5,a5,1

    return 2;
  }
  else
  {
    return 0;
    8000292c:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    8000292e:	06f70363          	beq	a4,a5,80002994 <devintr+0x80>
  }
}
    80002932:	60e2                	ld	ra,24(sp)
    80002934:	6442                	ld	s0,16(sp)
    80002936:	64a2                	ld	s1,8(sp)
    80002938:	6105                	addi	sp,sp,32
    8000293a:	8082                	ret
      (scause & 0xff) == 9)
    8000293c:	0ff77793          	andi	a5,a4,255
  if ((scause & 0x8000000000000000L) &&
    80002940:	46a5                	li	a3,9
    80002942:	fed792e3          	bne	a5,a3,80002926 <devintr+0x12>
    int irq = plic_claim();
    80002946:	00003097          	auipc	ra,0x3
    8000294a:	622080e7          	jalr	1570(ra) # 80005f68 <plic_claim>
    8000294e:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    80002950:	47a9                	li	a5,10
    80002952:	02f50763          	beq	a0,a5,80002980 <devintr+0x6c>
    else if (irq == VIRTIO0_IRQ)
    80002956:	4785                	li	a5,1
    80002958:	02f50963          	beq	a0,a5,8000298a <devintr+0x76>
    return 1;
    8000295c:	4505                	li	a0,1
    else if (irq)
    8000295e:	d8f1                	beqz	s1,80002932 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002960:	85a6                	mv	a1,s1
    80002962:	00006517          	auipc	a0,0x6
    80002966:	99e50513          	addi	a0,a0,-1634 # 80008300 <states.0+0x38>
    8000296a:	ffffe097          	auipc	ra,0xffffe
    8000296e:	c1e080e7          	jalr	-994(ra) # 80000588 <printf>
      plic_complete(irq);
    80002972:	8526                	mv	a0,s1
    80002974:	00003097          	auipc	ra,0x3
    80002978:	618080e7          	jalr	1560(ra) # 80005f8c <plic_complete>
    return 1;
    8000297c:	4505                	li	a0,1
    8000297e:	bf55                	j	80002932 <devintr+0x1e>
      uartintr();
    80002980:	ffffe097          	auipc	ra,0xffffe
    80002984:	01a080e7          	jalr	26(ra) # 8000099a <uartintr>
    80002988:	b7ed                	j	80002972 <devintr+0x5e>
      virtio_disk_intr();
    8000298a:	00004097          	auipc	ra,0x4
    8000298e:	ace080e7          	jalr	-1330(ra) # 80006458 <virtio_disk_intr>
    80002992:	b7c5                	j	80002972 <devintr+0x5e>
    if (cpuid() == 0)
    80002994:	fffff097          	auipc	ra,0xfffff
    80002998:	fec080e7          	jalr	-20(ra) # 80001980 <cpuid>
    8000299c:	c901                	beqz	a0,800029ac <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    8000299e:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800029a2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800029a4:	14479073          	csrw	sip,a5
    return 2;
    800029a8:	4509                	li	a0,2
    800029aa:	b761                	j	80002932 <devintr+0x1e>
      clockintr();
    800029ac:	00000097          	auipc	ra,0x0
    800029b0:	f14080e7          	jalr	-236(ra) # 800028c0 <clockintr>
    800029b4:	b7ed                	j	8000299e <devintr+0x8a>

00000000800029b6 <usertrap>:
{
    800029b6:	1101                	addi	sp,sp,-32
    800029b8:	ec06                	sd	ra,24(sp)
    800029ba:	e822                	sd	s0,16(sp)
    800029bc:	e426                	sd	s1,8(sp)
    800029be:	e04a                	sd	s2,0(sp)
    800029c0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029c2:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    800029c6:	1007f793          	andi	a5,a5,256
    800029ca:	e3b1                	bnez	a5,80002a0e <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029cc:	00003797          	auipc	a5,0x3
    800029d0:	49478793          	addi	a5,a5,1172 # 80005e60 <kernelvec>
    800029d4:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800029d8:	fffff097          	auipc	ra,0xfffff
    800029dc:	fd4080e7          	jalr	-44(ra) # 800019ac <myproc>
    800029e0:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800029e2:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029e4:	14102773          	csrr	a4,sepc
    800029e8:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029ea:	14202773          	csrr	a4,scause
  if (r_scause() == 8)
    800029ee:	47a1                	li	a5,8
    800029f0:	02f70763          	beq	a4,a5,80002a1e <usertrap+0x68>
  else if ((which_dev = devintr()) != 0)
    800029f4:	00000097          	auipc	ra,0x0
    800029f8:	f20080e7          	jalr	-224(ra) # 80002914 <devintr>
    800029fc:	892a                	mv	s2,a0
    800029fe:	c151                	beqz	a0,80002a82 <usertrap+0xcc>
  if (killed(p))
    80002a00:	8526                	mv	a0,s1
    80002a02:	00000097          	auipc	ra,0x0
    80002a06:	91a080e7          	jalr	-1766(ra) # 8000231c <killed>
    80002a0a:	c929                	beqz	a0,80002a5c <usertrap+0xa6>
    80002a0c:	a099                	j	80002a52 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002a0e:	00006517          	auipc	a0,0x6
    80002a12:	91250513          	addi	a0,a0,-1774 # 80008320 <states.0+0x58>
    80002a16:	ffffe097          	auipc	ra,0xffffe
    80002a1a:	b28080e7          	jalr	-1240(ra) # 8000053e <panic>
    if (killed(p))
    80002a1e:	00000097          	auipc	ra,0x0
    80002a22:	8fe080e7          	jalr	-1794(ra) # 8000231c <killed>
    80002a26:	e921                	bnez	a0,80002a76 <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002a28:	6cb8                	ld	a4,88(s1)
    80002a2a:	6f1c                	ld	a5,24(a4)
    80002a2c:	0791                	addi	a5,a5,4
    80002a2e:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a30:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002a34:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a38:	10079073          	csrw	sstatus,a5
    syscall();
    80002a3c:	00000097          	auipc	ra,0x0
    80002a40:	2d4080e7          	jalr	724(ra) # 80002d10 <syscall>
  if (killed(p))
    80002a44:	8526                	mv	a0,s1
    80002a46:	00000097          	auipc	ra,0x0
    80002a4a:	8d6080e7          	jalr	-1834(ra) # 8000231c <killed>
    80002a4e:	c911                	beqz	a0,80002a62 <usertrap+0xac>
    80002a50:	4901                	li	s2,0
    exit(-1);
    80002a52:	557d                	li	a0,-1
    80002a54:	fffff097          	auipc	ra,0xfffff
    80002a58:	748080e7          	jalr	1864(ra) # 8000219c <exit>
  if (which_dev == 2)
    80002a5c:	4789                	li	a5,2
    80002a5e:	04f90f63          	beq	s2,a5,80002abc <usertrap+0x106>
  usertrapret();
    80002a62:	00000097          	auipc	ra,0x0
    80002a66:	dc8080e7          	jalr	-568(ra) # 8000282a <usertrapret>
}
    80002a6a:	60e2                	ld	ra,24(sp)
    80002a6c:	6442                	ld	s0,16(sp)
    80002a6e:	64a2                	ld	s1,8(sp)
    80002a70:	6902                	ld	s2,0(sp)
    80002a72:	6105                	addi	sp,sp,32
    80002a74:	8082                	ret
      exit(-1);
    80002a76:	557d                	li	a0,-1
    80002a78:	fffff097          	auipc	ra,0xfffff
    80002a7c:	724080e7          	jalr	1828(ra) # 8000219c <exit>
    80002a80:	b765                	j	80002a28 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a82:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002a86:	5890                	lw	a2,48(s1)
    80002a88:	00006517          	auipc	a0,0x6
    80002a8c:	8b850513          	addi	a0,a0,-1864 # 80008340 <states.0+0x78>
    80002a90:	ffffe097          	auipc	ra,0xffffe
    80002a94:	af8080e7          	jalr	-1288(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a98:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a9c:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002aa0:	00006517          	auipc	a0,0x6
    80002aa4:	8d050513          	addi	a0,a0,-1840 # 80008370 <states.0+0xa8>
    80002aa8:	ffffe097          	auipc	ra,0xffffe
    80002aac:	ae0080e7          	jalr	-1312(ra) # 80000588 <printf>
    setkilled(p);
    80002ab0:	8526                	mv	a0,s1
    80002ab2:	00000097          	auipc	ra,0x0
    80002ab6:	83e080e7          	jalr	-1986(ra) # 800022f0 <setkilled>
    80002aba:	b769                	j	80002a44 <usertrap+0x8e>
    yield();
    80002abc:	fffff097          	auipc	ra,0xfffff
    80002ac0:	570080e7          	jalr	1392(ra) # 8000202c <yield>
    80002ac4:	bf79                	j	80002a62 <usertrap+0xac>

0000000080002ac6 <kerneltrap>:
{
    80002ac6:	7179                	addi	sp,sp,-48
    80002ac8:	f406                	sd	ra,40(sp)
    80002aca:	f022                	sd	s0,32(sp)
    80002acc:	ec26                	sd	s1,24(sp)
    80002ace:	e84a                	sd	s2,16(sp)
    80002ad0:	e44e                	sd	s3,8(sp)
    80002ad2:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ad4:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ad8:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002adc:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80002ae0:	1004f793          	andi	a5,s1,256
    80002ae4:	cb85                	beqz	a5,80002b14 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ae6:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002aea:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80002aec:	ef85                	bnez	a5,80002b24 <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    80002aee:	00000097          	auipc	ra,0x0
    80002af2:	e26080e7          	jalr	-474(ra) # 80002914 <devintr>
    80002af6:	cd1d                	beqz	a0,80002b34 <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002af8:	4789                	li	a5,2
    80002afa:	06f50a63          	beq	a0,a5,80002b6e <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002afe:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b02:	10049073          	csrw	sstatus,s1
}
    80002b06:	70a2                	ld	ra,40(sp)
    80002b08:	7402                	ld	s0,32(sp)
    80002b0a:	64e2                	ld	s1,24(sp)
    80002b0c:	6942                	ld	s2,16(sp)
    80002b0e:	69a2                	ld	s3,8(sp)
    80002b10:	6145                	addi	sp,sp,48
    80002b12:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002b14:	00006517          	auipc	a0,0x6
    80002b18:	87c50513          	addi	a0,a0,-1924 # 80008390 <states.0+0xc8>
    80002b1c:	ffffe097          	auipc	ra,0xffffe
    80002b20:	a22080e7          	jalr	-1502(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    80002b24:	00006517          	auipc	a0,0x6
    80002b28:	89450513          	addi	a0,a0,-1900 # 800083b8 <states.0+0xf0>
    80002b2c:	ffffe097          	auipc	ra,0xffffe
    80002b30:	a12080e7          	jalr	-1518(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    80002b34:	85ce                	mv	a1,s3
    80002b36:	00006517          	auipc	a0,0x6
    80002b3a:	8a250513          	addi	a0,a0,-1886 # 800083d8 <states.0+0x110>
    80002b3e:	ffffe097          	auipc	ra,0xffffe
    80002b42:	a4a080e7          	jalr	-1462(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b46:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b4a:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b4e:	00006517          	auipc	a0,0x6
    80002b52:	89a50513          	addi	a0,a0,-1894 # 800083e8 <states.0+0x120>
    80002b56:	ffffe097          	auipc	ra,0xffffe
    80002b5a:	a32080e7          	jalr	-1486(ra) # 80000588 <printf>
    panic("kerneltrap");
    80002b5e:	00006517          	auipc	a0,0x6
    80002b62:	8a250513          	addi	a0,a0,-1886 # 80008400 <states.0+0x138>
    80002b66:	ffffe097          	auipc	ra,0xffffe
    80002b6a:	9d8080e7          	jalr	-1576(ra) # 8000053e <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002b6e:	fffff097          	auipc	ra,0xfffff
    80002b72:	e3e080e7          	jalr	-450(ra) # 800019ac <myproc>
    80002b76:	d541                	beqz	a0,80002afe <kerneltrap+0x38>
    80002b78:	fffff097          	auipc	ra,0xfffff
    80002b7c:	e34080e7          	jalr	-460(ra) # 800019ac <myproc>
    80002b80:	4d18                	lw	a4,24(a0)
    80002b82:	4791                	li	a5,4
    80002b84:	f6f71de3          	bne	a4,a5,80002afe <kerneltrap+0x38>
    yield();
    80002b88:	fffff097          	auipc	ra,0xfffff
    80002b8c:	4a4080e7          	jalr	1188(ra) # 8000202c <yield>
    80002b90:	b7bd                	j	80002afe <kerneltrap+0x38>

0000000080002b92 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002b92:	1101                	addi	sp,sp,-32
    80002b94:	ec06                	sd	ra,24(sp)
    80002b96:	e822                	sd	s0,16(sp)
    80002b98:	e426                	sd	s1,8(sp)
    80002b9a:	1000                	addi	s0,sp,32
    80002b9c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002b9e:	fffff097          	auipc	ra,0xfffff
    80002ba2:	e0e080e7          	jalr	-498(ra) # 800019ac <myproc>
  switch (n)
    80002ba6:	4795                	li	a5,5
    80002ba8:	0497e163          	bltu	a5,s1,80002bea <argraw+0x58>
    80002bac:	048a                	slli	s1,s1,0x2
    80002bae:	00006717          	auipc	a4,0x6
    80002bb2:	88a70713          	addi	a4,a4,-1910 # 80008438 <states.0+0x170>
    80002bb6:	94ba                	add	s1,s1,a4
    80002bb8:	409c                	lw	a5,0(s1)
    80002bba:	97ba                	add	a5,a5,a4
    80002bbc:	8782                	jr	a5
  {
  case 0:
    return p->trapframe->a0;
    80002bbe:	6d3c                	ld	a5,88(a0)
    80002bc0:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002bc2:	60e2                	ld	ra,24(sp)
    80002bc4:	6442                	ld	s0,16(sp)
    80002bc6:	64a2                	ld	s1,8(sp)
    80002bc8:	6105                	addi	sp,sp,32
    80002bca:	8082                	ret
    return p->trapframe->a1;
    80002bcc:	6d3c                	ld	a5,88(a0)
    80002bce:	7fa8                	ld	a0,120(a5)
    80002bd0:	bfcd                	j	80002bc2 <argraw+0x30>
    return p->trapframe->a2;
    80002bd2:	6d3c                	ld	a5,88(a0)
    80002bd4:	63c8                	ld	a0,128(a5)
    80002bd6:	b7f5                	j	80002bc2 <argraw+0x30>
    return p->trapframe->a3;
    80002bd8:	6d3c                	ld	a5,88(a0)
    80002bda:	67c8                	ld	a0,136(a5)
    80002bdc:	b7dd                	j	80002bc2 <argraw+0x30>
    return p->trapframe->a4;
    80002bde:	6d3c                	ld	a5,88(a0)
    80002be0:	6bc8                	ld	a0,144(a5)
    80002be2:	b7c5                	j	80002bc2 <argraw+0x30>
    return p->trapframe->a5;
    80002be4:	6d3c                	ld	a5,88(a0)
    80002be6:	6fc8                	ld	a0,152(a5)
    80002be8:	bfe9                	j	80002bc2 <argraw+0x30>
  panic("argraw");
    80002bea:	00006517          	auipc	a0,0x6
    80002bee:	82650513          	addi	a0,a0,-2010 # 80008410 <states.0+0x148>
    80002bf2:	ffffe097          	auipc	ra,0xffffe
    80002bf6:	94c080e7          	jalr	-1716(ra) # 8000053e <panic>

0000000080002bfa <fetchaddr>:
{
    80002bfa:	1101                	addi	sp,sp,-32
    80002bfc:	ec06                	sd	ra,24(sp)
    80002bfe:	e822                	sd	s0,16(sp)
    80002c00:	e426                	sd	s1,8(sp)
    80002c02:	e04a                	sd	s2,0(sp)
    80002c04:	1000                	addi	s0,sp,32
    80002c06:	84aa                	mv	s1,a0
    80002c08:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002c0a:	fffff097          	auipc	ra,0xfffff
    80002c0e:	da2080e7          	jalr	-606(ra) # 800019ac <myproc>
  if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002c12:	653c                	ld	a5,72(a0)
    80002c14:	02f4f863          	bgeu	s1,a5,80002c44 <fetchaddr+0x4a>
    80002c18:	00848713          	addi	a4,s1,8
    80002c1c:	02e7e663          	bltu	a5,a4,80002c48 <fetchaddr+0x4e>
  if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002c20:	46a1                	li	a3,8
    80002c22:	8626                	mv	a2,s1
    80002c24:	85ca                	mv	a1,s2
    80002c26:	6928                	ld	a0,80(a0)
    80002c28:	fffff097          	auipc	ra,0xfffff
    80002c2c:	acc080e7          	jalr	-1332(ra) # 800016f4 <copyin>
    80002c30:	00a03533          	snez	a0,a0
    80002c34:	40a00533          	neg	a0,a0
}
    80002c38:	60e2                	ld	ra,24(sp)
    80002c3a:	6442                	ld	s0,16(sp)
    80002c3c:	64a2                	ld	s1,8(sp)
    80002c3e:	6902                	ld	s2,0(sp)
    80002c40:	6105                	addi	sp,sp,32
    80002c42:	8082                	ret
    return -1;
    80002c44:	557d                	li	a0,-1
    80002c46:	bfcd                	j	80002c38 <fetchaddr+0x3e>
    80002c48:	557d                	li	a0,-1
    80002c4a:	b7fd                	j	80002c38 <fetchaddr+0x3e>

0000000080002c4c <fetchstr>:
{
    80002c4c:	7179                	addi	sp,sp,-48
    80002c4e:	f406                	sd	ra,40(sp)
    80002c50:	f022                	sd	s0,32(sp)
    80002c52:	ec26                	sd	s1,24(sp)
    80002c54:	e84a                	sd	s2,16(sp)
    80002c56:	e44e                	sd	s3,8(sp)
    80002c58:	1800                	addi	s0,sp,48
    80002c5a:	892a                	mv	s2,a0
    80002c5c:	84ae                	mv	s1,a1
    80002c5e:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002c60:	fffff097          	auipc	ra,0xfffff
    80002c64:	d4c080e7          	jalr	-692(ra) # 800019ac <myproc>
  if (copyinstr(p->pagetable, buf, addr, max) < 0)
    80002c68:	86ce                	mv	a3,s3
    80002c6a:	864a                	mv	a2,s2
    80002c6c:	85a6                	mv	a1,s1
    80002c6e:	6928                	ld	a0,80(a0)
    80002c70:	fffff097          	auipc	ra,0xfffff
    80002c74:	b12080e7          	jalr	-1262(ra) # 80001782 <copyinstr>
    80002c78:	00054e63          	bltz	a0,80002c94 <fetchstr+0x48>
  return strlen(buf);
    80002c7c:	8526                	mv	a0,s1
    80002c7e:	ffffe097          	auipc	ra,0xffffe
    80002c82:	1d0080e7          	jalr	464(ra) # 80000e4e <strlen>
}
    80002c86:	70a2                	ld	ra,40(sp)
    80002c88:	7402                	ld	s0,32(sp)
    80002c8a:	64e2                	ld	s1,24(sp)
    80002c8c:	6942                	ld	s2,16(sp)
    80002c8e:	69a2                	ld	s3,8(sp)
    80002c90:	6145                	addi	sp,sp,48
    80002c92:	8082                	ret
    return -1;
    80002c94:	557d                	li	a0,-1
    80002c96:	bfc5                	j	80002c86 <fetchstr+0x3a>

0000000080002c98 <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    80002c98:	1101                	addi	sp,sp,-32
    80002c9a:	ec06                	sd	ra,24(sp)
    80002c9c:	e822                	sd	s0,16(sp)
    80002c9e:	e426                	sd	s1,8(sp)
    80002ca0:	1000                	addi	s0,sp,32
    80002ca2:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002ca4:	00000097          	auipc	ra,0x0
    80002ca8:	eee080e7          	jalr	-274(ra) # 80002b92 <argraw>
    80002cac:	c088                	sw	a0,0(s1)
}
    80002cae:	60e2                	ld	ra,24(sp)
    80002cb0:	6442                	ld	s0,16(sp)
    80002cb2:	64a2                	ld	s1,8(sp)
    80002cb4:	6105                	addi	sp,sp,32
    80002cb6:	8082                	ret

0000000080002cb8 <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    80002cb8:	1101                	addi	sp,sp,-32
    80002cba:	ec06                	sd	ra,24(sp)
    80002cbc:	e822                	sd	s0,16(sp)
    80002cbe:	e426                	sd	s1,8(sp)
    80002cc0:	1000                	addi	s0,sp,32
    80002cc2:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002cc4:	00000097          	auipc	ra,0x0
    80002cc8:	ece080e7          	jalr	-306(ra) # 80002b92 <argraw>
    80002ccc:	e088                	sd	a0,0(s1)
}
    80002cce:	60e2                	ld	ra,24(sp)
    80002cd0:	6442                	ld	s0,16(sp)
    80002cd2:	64a2                	ld	s1,8(sp)
    80002cd4:	6105                	addi	sp,sp,32
    80002cd6:	8082                	ret

0000000080002cd8 <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    80002cd8:	7179                	addi	sp,sp,-48
    80002cda:	f406                	sd	ra,40(sp)
    80002cdc:	f022                	sd	s0,32(sp)
    80002cde:	ec26                	sd	s1,24(sp)
    80002ce0:	e84a                	sd	s2,16(sp)
    80002ce2:	1800                	addi	s0,sp,48
    80002ce4:	84ae                	mv	s1,a1
    80002ce6:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002ce8:	fd840593          	addi	a1,s0,-40
    80002cec:	00000097          	auipc	ra,0x0
    80002cf0:	fcc080e7          	jalr	-52(ra) # 80002cb8 <argaddr>
  return fetchstr(addr, buf, max);
    80002cf4:	864a                	mv	a2,s2
    80002cf6:	85a6                	mv	a1,s1
    80002cf8:	fd843503          	ld	a0,-40(s0)
    80002cfc:	00000097          	auipc	ra,0x0
    80002d00:	f50080e7          	jalr	-176(ra) # 80002c4c <fetchstr>
}
    80002d04:	70a2                	ld	ra,40(sp)
    80002d06:	7402                	ld	s0,32(sp)
    80002d08:	64e2                	ld	s1,24(sp)
    80002d0a:	6942                	ld	s2,16(sp)
    80002d0c:	6145                	addi	sp,sp,48
    80002d0e:	8082                	ret

0000000080002d10 <syscall>:
    [SYS_waitx] sys_waitx,
    [SYS_getSysCount] sys_getSysCount,
};

void syscall(void)
{
    80002d10:	1101                	addi	sp,sp,-32
    80002d12:	ec06                	sd	ra,24(sp)
    80002d14:	e822                	sd	s0,16(sp)
    80002d16:	e426                	sd	s1,8(sp)
    80002d18:	e04a                	sd	s2,0(sp)
    80002d1a:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002d1c:	fffff097          	auipc	ra,0xfffff
    80002d20:	c90080e7          	jalr	-880(ra) # 800019ac <myproc>
    80002d24:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002d26:	05853903          	ld	s2,88(a0)
    80002d2a:	0a893783          	ld	a5,168(s2)
    80002d2e:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    80002d32:	37fd                	addiw	a5,a5,-1
    80002d34:	4759                	li	a4,22
    80002d36:	02f76763          	bltu	a4,a5,80002d64 <syscall+0x54>
    80002d3a:	00369713          	slli	a4,a3,0x3
    80002d3e:	00005797          	auipc	a5,0x5
    80002d42:	71278793          	addi	a5,a5,1810 # 80008450 <syscalls>
    80002d46:	97ba                	add	a5,a5,a4
    80002d48:	6398                	ld	a4,0(a5)
    80002d4a:	cf09                	beqz	a4,80002d64 <syscall+0x54>
  {
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->syscall_count[num]++;
    80002d4c:	068a                	slli	a3,a3,0x2
    80002d4e:	00d504b3          	add	s1,a0,a3
    80002d52:	1744a783          	lw	a5,372(s1)
    80002d56:	2785                	addiw	a5,a5,1
    80002d58:	16f4aa23          	sw	a5,372(s1)
    p->trapframe->a0 = syscalls[num]();
    80002d5c:	9702                	jalr	a4
    80002d5e:	06a93823          	sd	a0,112(s2)
    80002d62:	a839                	j	80002d80 <syscall+0x70>
  }
  else
  {
    printf("%d %s: unknown sys call %d\n",
    80002d64:	15848613          	addi	a2,s1,344
    80002d68:	588c                	lw	a1,48(s1)
    80002d6a:	00005517          	auipc	a0,0x5
    80002d6e:	6ae50513          	addi	a0,a0,1710 # 80008418 <states.0+0x150>
    80002d72:	ffffe097          	auipc	ra,0xffffe
    80002d76:	816080e7          	jalr	-2026(ra) # 80000588 <printf>
           p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002d7a:	6cbc                	ld	a5,88(s1)
    80002d7c:	577d                	li	a4,-1
    80002d7e:	fbb8                	sd	a4,112(a5)
  }
}
    80002d80:	60e2                	ld	ra,24(sp)
    80002d82:	6442                	ld	s0,16(sp)
    80002d84:	64a2                	ld	s1,8(sp)
    80002d86:	6902                	ld	s2,0(sp)
    80002d88:	6105                	addi	sp,sp,32
    80002d8a:	8082                	ret

0000000080002d8c <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002d8c:	1101                	addi	sp,sp,-32
    80002d8e:	ec06                	sd	ra,24(sp)
    80002d90:	e822                	sd	s0,16(sp)
    80002d92:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002d94:	fec40593          	addi	a1,s0,-20
    80002d98:	4501                	li	a0,0
    80002d9a:	00000097          	auipc	ra,0x0
    80002d9e:	efe080e7          	jalr	-258(ra) # 80002c98 <argint>
  exit(n);
    80002da2:	fec42503          	lw	a0,-20(s0)
    80002da6:	fffff097          	auipc	ra,0xfffff
    80002daa:	3f6080e7          	jalr	1014(ra) # 8000219c <exit>
  return 0; // not reached
}
    80002dae:	4501                	li	a0,0
    80002db0:	60e2                	ld	ra,24(sp)
    80002db2:	6442                	ld	s0,16(sp)
    80002db4:	6105                	addi	sp,sp,32
    80002db6:	8082                	ret

0000000080002db8 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002db8:	1141                	addi	sp,sp,-16
    80002dba:	e406                	sd	ra,8(sp)
    80002dbc:	e022                	sd	s0,0(sp)
    80002dbe:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002dc0:	fffff097          	auipc	ra,0xfffff
    80002dc4:	bec080e7          	jalr	-1044(ra) # 800019ac <myproc>
}
    80002dc8:	5908                	lw	a0,48(a0)
    80002dca:	60a2                	ld	ra,8(sp)
    80002dcc:	6402                	ld	s0,0(sp)
    80002dce:	0141                	addi	sp,sp,16
    80002dd0:	8082                	ret

0000000080002dd2 <sys_fork>:

uint64
sys_fork(void)
{
    80002dd2:	1141                	addi	sp,sp,-16
    80002dd4:	e406                	sd	ra,8(sp)
    80002dd6:	e022                	sd	s0,0(sp)
    80002dd8:	0800                	addi	s0,sp,16
  return fork();
    80002dda:	fffff097          	auipc	ra,0xfffff
    80002dde:	f9c080e7          	jalr	-100(ra) # 80001d76 <fork>
}
    80002de2:	60a2                	ld	ra,8(sp)
    80002de4:	6402                	ld	s0,0(sp)
    80002de6:	0141                	addi	sp,sp,16
    80002de8:	8082                	ret

0000000080002dea <sys_wait>:

uint64
sys_wait(void)
{
    80002dea:	1101                	addi	sp,sp,-32
    80002dec:	ec06                	sd	ra,24(sp)
    80002dee:	e822                	sd	s0,16(sp)
    80002df0:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002df2:	fe840593          	addi	a1,s0,-24
    80002df6:	4501                	li	a0,0
    80002df8:	00000097          	auipc	ra,0x0
    80002dfc:	ec0080e7          	jalr	-320(ra) # 80002cb8 <argaddr>
  return wait(p);
    80002e00:	fe843503          	ld	a0,-24(s0)
    80002e04:	fffff097          	auipc	ra,0xfffff
    80002e08:	54a080e7          	jalr	1354(ra) # 8000234e <wait>
}
    80002e0c:	60e2                	ld	ra,24(sp)
    80002e0e:	6442                	ld	s0,16(sp)
    80002e10:	6105                	addi	sp,sp,32
    80002e12:	8082                	ret

0000000080002e14 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002e14:	7179                	addi	sp,sp,-48
    80002e16:	f406                	sd	ra,40(sp)
    80002e18:	f022                	sd	s0,32(sp)
    80002e1a:	ec26                	sd	s1,24(sp)
    80002e1c:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002e1e:	fdc40593          	addi	a1,s0,-36
    80002e22:	4501                	li	a0,0
    80002e24:	00000097          	auipc	ra,0x0
    80002e28:	e74080e7          	jalr	-396(ra) # 80002c98 <argint>
  addr = myproc()->sz;
    80002e2c:	fffff097          	auipc	ra,0xfffff
    80002e30:	b80080e7          	jalr	-1152(ra) # 800019ac <myproc>
    80002e34:	6524                	ld	s1,72(a0)
  if (growproc(n) < 0)
    80002e36:	fdc42503          	lw	a0,-36(s0)
    80002e3a:	fffff097          	auipc	ra,0xfffff
    80002e3e:	ee0080e7          	jalr	-288(ra) # 80001d1a <growproc>
    80002e42:	00054863          	bltz	a0,80002e52 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002e46:	8526                	mv	a0,s1
    80002e48:	70a2                	ld	ra,40(sp)
    80002e4a:	7402                	ld	s0,32(sp)
    80002e4c:	64e2                	ld	s1,24(sp)
    80002e4e:	6145                	addi	sp,sp,48
    80002e50:	8082                	ret
    return -1;
    80002e52:	54fd                	li	s1,-1
    80002e54:	bfcd                	j	80002e46 <sys_sbrk+0x32>

0000000080002e56 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002e56:	7139                	addi	sp,sp,-64
    80002e58:	fc06                	sd	ra,56(sp)
    80002e5a:	f822                	sd	s0,48(sp)
    80002e5c:	f426                	sd	s1,40(sp)
    80002e5e:	f04a                	sd	s2,32(sp)
    80002e60:	ec4e                	sd	s3,24(sp)
    80002e62:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002e64:	fcc40593          	addi	a1,s0,-52
    80002e68:	4501                	li	a0,0
    80002e6a:	00000097          	auipc	ra,0x0
    80002e6e:	e2e080e7          	jalr	-466(ra) # 80002c98 <argint>
  acquire(&tickslock);
    80002e72:	00016517          	auipc	a0,0x16
    80002e76:	cfe50513          	addi	a0,a0,-770 # 80018b70 <tickslock>
    80002e7a:	ffffe097          	auipc	ra,0xffffe
    80002e7e:	d5c080e7          	jalr	-676(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80002e82:	00006917          	auipc	s2,0x6
    80002e86:	a4e92903          	lw	s2,-1458(s2) # 800088d0 <ticks>
  while (ticks - ticks0 < n)
    80002e8a:	fcc42783          	lw	a5,-52(s0)
    80002e8e:	cf9d                	beqz	a5,80002ecc <sys_sleep+0x76>
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002e90:	00016997          	auipc	s3,0x16
    80002e94:	ce098993          	addi	s3,s3,-800 # 80018b70 <tickslock>
    80002e98:	00006497          	auipc	s1,0x6
    80002e9c:	a3848493          	addi	s1,s1,-1480 # 800088d0 <ticks>
    if (killed(myproc()))
    80002ea0:	fffff097          	auipc	ra,0xfffff
    80002ea4:	b0c080e7          	jalr	-1268(ra) # 800019ac <myproc>
    80002ea8:	fffff097          	auipc	ra,0xfffff
    80002eac:	474080e7          	jalr	1140(ra) # 8000231c <killed>
    80002eb0:	ed15                	bnez	a0,80002eec <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002eb2:	85ce                	mv	a1,s3
    80002eb4:	8526                	mv	a0,s1
    80002eb6:	fffff097          	auipc	ra,0xfffff
    80002eba:	1b2080e7          	jalr	434(ra) # 80002068 <sleep>
  while (ticks - ticks0 < n)
    80002ebe:	409c                	lw	a5,0(s1)
    80002ec0:	412787bb          	subw	a5,a5,s2
    80002ec4:	fcc42703          	lw	a4,-52(s0)
    80002ec8:	fce7ece3          	bltu	a5,a4,80002ea0 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002ecc:	00016517          	auipc	a0,0x16
    80002ed0:	ca450513          	addi	a0,a0,-860 # 80018b70 <tickslock>
    80002ed4:	ffffe097          	auipc	ra,0xffffe
    80002ed8:	db6080e7          	jalr	-586(ra) # 80000c8a <release>
  return 0;
    80002edc:	4501                	li	a0,0
}
    80002ede:	70e2                	ld	ra,56(sp)
    80002ee0:	7442                	ld	s0,48(sp)
    80002ee2:	74a2                	ld	s1,40(sp)
    80002ee4:	7902                	ld	s2,32(sp)
    80002ee6:	69e2                	ld	s3,24(sp)
    80002ee8:	6121                	addi	sp,sp,64
    80002eea:	8082                	ret
      release(&tickslock);
    80002eec:	00016517          	auipc	a0,0x16
    80002ef0:	c8450513          	addi	a0,a0,-892 # 80018b70 <tickslock>
    80002ef4:	ffffe097          	auipc	ra,0xffffe
    80002ef8:	d96080e7          	jalr	-618(ra) # 80000c8a <release>
      return -1;
    80002efc:	557d                	li	a0,-1
    80002efe:	b7c5                	j	80002ede <sys_sleep+0x88>

0000000080002f00 <sys_kill>:

uint64
sys_kill(void)
{
    80002f00:	1101                	addi	sp,sp,-32
    80002f02:	ec06                	sd	ra,24(sp)
    80002f04:	e822                	sd	s0,16(sp)
    80002f06:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002f08:	fec40593          	addi	a1,s0,-20
    80002f0c:	4501                	li	a0,0
    80002f0e:	00000097          	auipc	ra,0x0
    80002f12:	d8a080e7          	jalr	-630(ra) # 80002c98 <argint>
  return kill(pid);
    80002f16:	fec42503          	lw	a0,-20(s0)
    80002f1a:	fffff097          	auipc	ra,0xfffff
    80002f1e:	364080e7          	jalr	868(ra) # 8000227e <kill>
}
    80002f22:	60e2                	ld	ra,24(sp)
    80002f24:	6442                	ld	s0,16(sp)
    80002f26:	6105                	addi	sp,sp,32
    80002f28:	8082                	ret

0000000080002f2a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002f2a:	1101                	addi	sp,sp,-32
    80002f2c:	ec06                	sd	ra,24(sp)
    80002f2e:	e822                	sd	s0,16(sp)
    80002f30:	e426                	sd	s1,8(sp)
    80002f32:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002f34:	00016517          	auipc	a0,0x16
    80002f38:	c3c50513          	addi	a0,a0,-964 # 80018b70 <tickslock>
    80002f3c:	ffffe097          	auipc	ra,0xffffe
    80002f40:	c9a080e7          	jalr	-870(ra) # 80000bd6 <acquire>
  xticks = ticks;
    80002f44:	00006497          	auipc	s1,0x6
    80002f48:	98c4a483          	lw	s1,-1652(s1) # 800088d0 <ticks>
  release(&tickslock);
    80002f4c:	00016517          	auipc	a0,0x16
    80002f50:	c2450513          	addi	a0,a0,-988 # 80018b70 <tickslock>
    80002f54:	ffffe097          	auipc	ra,0xffffe
    80002f58:	d36080e7          	jalr	-714(ra) # 80000c8a <release>
  return xticks;
}
    80002f5c:	02049513          	slli	a0,s1,0x20
    80002f60:	9101                	srli	a0,a0,0x20
    80002f62:	60e2                	ld	ra,24(sp)
    80002f64:	6442                	ld	s0,16(sp)
    80002f66:	64a2                	ld	s1,8(sp)
    80002f68:	6105                	addi	sp,sp,32
    80002f6a:	8082                	ret

0000000080002f6c <sys_waitx>:

uint64
sys_waitx(void)
{
    80002f6c:	7139                	addi	sp,sp,-64
    80002f6e:	fc06                	sd	ra,56(sp)
    80002f70:	f822                	sd	s0,48(sp)
    80002f72:	f426                	sd	s1,40(sp)
    80002f74:	f04a                	sd	s2,32(sp)
    80002f76:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    80002f78:	fd840593          	addi	a1,s0,-40
    80002f7c:	4501                	li	a0,0
    80002f7e:	00000097          	auipc	ra,0x0
    80002f82:	d3a080e7          	jalr	-710(ra) # 80002cb8 <argaddr>
  argaddr(1, &addr1); // user virtual memory
    80002f86:	fd040593          	addi	a1,s0,-48
    80002f8a:	4505                	li	a0,1
    80002f8c:	00000097          	auipc	ra,0x0
    80002f90:	d2c080e7          	jalr	-724(ra) # 80002cb8 <argaddr>
  argaddr(2, &addr2);
    80002f94:	fc840593          	addi	a1,s0,-56
    80002f98:	4509                	li	a0,2
    80002f9a:	00000097          	auipc	ra,0x0
    80002f9e:	d1e080e7          	jalr	-738(ra) # 80002cb8 <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    80002fa2:	fc040613          	addi	a2,s0,-64
    80002fa6:	fc440593          	addi	a1,s0,-60
    80002faa:	fd843503          	ld	a0,-40(s0)
    80002fae:	fffff097          	auipc	ra,0xfffff
    80002fb2:	628080e7          	jalr	1576(ra) # 800025d6 <waitx>
    80002fb6:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80002fb8:	fffff097          	auipc	ra,0xfffff
    80002fbc:	9f4080e7          	jalr	-1548(ra) # 800019ac <myproc>
    80002fc0:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    80002fc2:	4691                	li	a3,4
    80002fc4:	fc440613          	addi	a2,s0,-60
    80002fc8:	fd043583          	ld	a1,-48(s0)
    80002fcc:	6928                	ld	a0,80(a0)
    80002fce:	ffffe097          	auipc	ra,0xffffe
    80002fd2:	69a080e7          	jalr	1690(ra) # 80001668 <copyout>
    return -1;
    80002fd6:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    80002fd8:	00054f63          	bltz	a0,80002ff6 <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    80002fdc:	4691                	li	a3,4
    80002fde:	fc040613          	addi	a2,s0,-64
    80002fe2:	fc843583          	ld	a1,-56(s0)
    80002fe6:	68a8                	ld	a0,80(s1)
    80002fe8:	ffffe097          	auipc	ra,0xffffe
    80002fec:	680080e7          	jalr	1664(ra) # 80001668 <copyout>
    80002ff0:	00054a63          	bltz	a0,80003004 <sys_waitx+0x98>
    return -1;
  return ret;
    80002ff4:	87ca                	mv	a5,s2
}
    80002ff6:	853e                	mv	a0,a5
    80002ff8:	70e2                	ld	ra,56(sp)
    80002ffa:	7442                	ld	s0,48(sp)
    80002ffc:	74a2                	ld	s1,40(sp)
    80002ffe:	7902                	ld	s2,32(sp)
    80003000:	6121                	addi	sp,sp,64
    80003002:	8082                	ret
    return -1;
    80003004:	57fd                	li	a5,-1
    80003006:	bfc5                	j	80002ff6 <sys_waitx+0x8a>

0000000080003008 <count_syscalls_from_children>:

  return count;
}

int count_syscalls_from_children(struct proc *p, int syscall_index)
{
    80003008:	7139                	addi	sp,sp,-64
    8000300a:	fc06                	sd	ra,56(sp)
    8000300c:	f822                	sd	s0,48(sp)
    8000300e:	f426                	sd	s1,40(sp)
    80003010:	f04a                	sd	s2,32(sp)
    80003012:	ec4e                	sd	s3,24(sp)
    80003014:	e852                	sd	s4,16(sp)
    80003016:	e456                	sd	s5,8(sp)
    80003018:	e05a                	sd	s6,0(sp)
    8000301a:	0080                	addi	s0,sp,64
    8000301c:	892a                	mv	s2,a0
    8000301e:	8aae                	mv	s5,a1
  int total = 0;
  struct proc *child;
  for (child = proc; child < &proc[NPROC]; child++)
    80003020:	00259b13          	slli	s6,a1,0x2
    80003024:	0000e497          	auipc	s1,0xe
    80003028:	f4c48493          	addi	s1,s1,-180 # 80010f70 <proc>
  int total = 0;
    8000302c:	4501                	li	a0,0
  for (child = proc; child < &proc[NPROC]; child++)
    8000302e:	00016997          	auipc	s3,0x16
    80003032:	b4298993          	addi	s3,s3,-1214 # 80018b70 <tickslock>
    80003036:	a029                	j	80003040 <count_syscalls_from_children+0x38>
    80003038:	1f048493          	addi	s1,s1,496
    8000303c:	03348463          	beq	s1,s3,80003064 <count_syscalls_from_children+0x5c>
  {
    if (child->parent == p)
    80003040:	7c9c                	ld	a5,56(s1)
    80003042:	ff279be3          	bne	a5,s2,80003038 <count_syscalls_from_children+0x30>
    {
      total += child->syscall_count[syscall_index];
    80003046:	016487b3          	add	a5,s1,s6
    8000304a:	1747aa03          	lw	s4,372(a5)
    8000304e:	00aa0a3b          	addw	s4,s4,a0
      total += count_syscalls_from_children(child, syscall_index); // Recursively check the child's children
    80003052:	85d6                	mv	a1,s5
    80003054:	8526                	mv	a0,s1
    80003056:	00000097          	auipc	ra,0x0
    8000305a:	fb2080e7          	jalr	-78(ra) # 80003008 <count_syscalls_from_children>
    8000305e:	00aa053b          	addw	a0,s4,a0
    80003062:	bfd9                	j	80003038 <count_syscalls_from_children+0x30>
    }
  }
  return total;
    80003064:	70e2                	ld	ra,56(sp)
    80003066:	7442                	ld	s0,48(sp)
    80003068:	74a2                	ld	s1,40(sp)
    8000306a:	7902                	ld	s2,32(sp)
    8000306c:	69e2                	ld	s3,24(sp)
    8000306e:	6a42                	ld	s4,16(sp)
    80003070:	6aa2                	ld	s5,8(sp)
    80003072:	6b02                	ld	s6,0(sp)
    80003074:	6121                	addi	sp,sp,64
    80003076:	8082                	ret

0000000080003078 <sys_getSysCount>:
{
    80003078:	7179                	addi	sp,sp,-48
    8000307a:	f406                	sd	ra,40(sp)
    8000307c:	f022                	sd	s0,32(sp)
    8000307e:	ec26                	sd	s1,24(sp)
    80003080:	1800                	addi	s0,sp,48
  argint(0, &mask);
    80003082:	fdc40593          	addi	a1,s0,-36
    80003086:	4501                	li	a0,0
    80003088:	00000097          	auipc	ra,0x0
    8000308c:	c10080e7          	jalr	-1008(ra) # 80002c98 <argint>
  struct proc *p = myproc();
    80003090:	fffff097          	auipc	ra,0xfffff
    80003094:	91c080e7          	jalr	-1764(ra) # 800019ac <myproc>
    80003098:	86aa                	mv	a3,a0
    if (mask & (1 << i))
    8000309a:	fdc42783          	lw	a5,-36(s0)
    8000309e:	0017f713          	andi	a4,a5,1
    800030a2:	eb19                	bnez	a4,800030b8 <sys_getSysCount+0x40>
  for (int i = 0; i < 31; i++)
    800030a4:	4585                	li	a1,1
    800030a6:	477d                	li	a4,31
    if (mask & (1 << i))
    800030a8:	40b7d53b          	sraw	a0,a5,a1
    800030ac:	8905                	andi	a0,a0,1
    800030ae:	e511                	bnez	a0,800030ba <sys_getSysCount+0x42>
  for (int i = 0; i < 31; i++)
    800030b0:	2585                	addiw	a1,a1,1
    800030b2:	fee59be3          	bne	a1,a4,800030a8 <sys_getSysCount+0x30>
    800030b6:	a829                	j	800030d0 <sys_getSysCount+0x58>
    800030b8:	4581                	li	a1,0
      count += p->syscall_count[i]; // Add counts from the current process
    800030ba:	05c58793          	addi	a5,a1,92 # 105c <_entry-0x7fffefa4>
    800030be:	078a                	slli	a5,a5,0x2
    800030c0:	97b6                	add	a5,a5,a3
    800030c2:	43c4                	lw	s1,4(a5)
      count += count_syscalls_from_children(p, i);
    800030c4:	8536                	mv	a0,a3
    800030c6:	00000097          	auipc	ra,0x0
    800030ca:	f42080e7          	jalr	-190(ra) # 80003008 <count_syscalls_from_children>
    800030ce:	9d25                	addw	a0,a0,s1
}
    800030d0:	70a2                	ld	ra,40(sp)
    800030d2:	7402                	ld	s0,32(sp)
    800030d4:	64e2                	ld	s1,24(sp)
    800030d6:	6145                	addi	sp,sp,48
    800030d8:	8082                	ret

00000000800030da <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800030da:	7179                	addi	sp,sp,-48
    800030dc:	f406                	sd	ra,40(sp)
    800030de:	f022                	sd	s0,32(sp)
    800030e0:	ec26                	sd	s1,24(sp)
    800030e2:	e84a                	sd	s2,16(sp)
    800030e4:	e44e                	sd	s3,8(sp)
    800030e6:	e052                	sd	s4,0(sp)
    800030e8:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800030ea:	00005597          	auipc	a1,0x5
    800030ee:	42658593          	addi	a1,a1,1062 # 80008510 <syscalls+0xc0>
    800030f2:	00016517          	auipc	a0,0x16
    800030f6:	a9650513          	addi	a0,a0,-1386 # 80018b88 <bcache>
    800030fa:	ffffe097          	auipc	ra,0xffffe
    800030fe:	a4c080e7          	jalr	-1460(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003102:	0001e797          	auipc	a5,0x1e
    80003106:	a8678793          	addi	a5,a5,-1402 # 80020b88 <bcache+0x8000>
    8000310a:	0001e717          	auipc	a4,0x1e
    8000310e:	ce670713          	addi	a4,a4,-794 # 80020df0 <bcache+0x8268>
    80003112:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003116:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000311a:	00016497          	auipc	s1,0x16
    8000311e:	a8648493          	addi	s1,s1,-1402 # 80018ba0 <bcache+0x18>
    b->next = bcache.head.next;
    80003122:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003124:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003126:	00005a17          	auipc	s4,0x5
    8000312a:	3f2a0a13          	addi	s4,s4,1010 # 80008518 <syscalls+0xc8>
    b->next = bcache.head.next;
    8000312e:	2b893783          	ld	a5,696(s2)
    80003132:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003134:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003138:	85d2                	mv	a1,s4
    8000313a:	01048513          	addi	a0,s1,16
    8000313e:	00001097          	auipc	ra,0x1
    80003142:	4c4080e7          	jalr	1220(ra) # 80004602 <initsleeplock>
    bcache.head.next->prev = b;
    80003146:	2b893783          	ld	a5,696(s2)
    8000314a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000314c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003150:	45848493          	addi	s1,s1,1112
    80003154:	fd349de3          	bne	s1,s3,8000312e <binit+0x54>
  }
}
    80003158:	70a2                	ld	ra,40(sp)
    8000315a:	7402                	ld	s0,32(sp)
    8000315c:	64e2                	ld	s1,24(sp)
    8000315e:	6942                	ld	s2,16(sp)
    80003160:	69a2                	ld	s3,8(sp)
    80003162:	6a02                	ld	s4,0(sp)
    80003164:	6145                	addi	sp,sp,48
    80003166:	8082                	ret

0000000080003168 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003168:	7179                	addi	sp,sp,-48
    8000316a:	f406                	sd	ra,40(sp)
    8000316c:	f022                	sd	s0,32(sp)
    8000316e:	ec26                	sd	s1,24(sp)
    80003170:	e84a                	sd	s2,16(sp)
    80003172:	e44e                	sd	s3,8(sp)
    80003174:	1800                	addi	s0,sp,48
    80003176:	892a                	mv	s2,a0
    80003178:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000317a:	00016517          	auipc	a0,0x16
    8000317e:	a0e50513          	addi	a0,a0,-1522 # 80018b88 <bcache>
    80003182:	ffffe097          	auipc	ra,0xffffe
    80003186:	a54080e7          	jalr	-1452(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000318a:	0001e497          	auipc	s1,0x1e
    8000318e:	cb64b483          	ld	s1,-842(s1) # 80020e40 <bcache+0x82b8>
    80003192:	0001e797          	auipc	a5,0x1e
    80003196:	c5e78793          	addi	a5,a5,-930 # 80020df0 <bcache+0x8268>
    8000319a:	02f48f63          	beq	s1,a5,800031d8 <bread+0x70>
    8000319e:	873e                	mv	a4,a5
    800031a0:	a021                	j	800031a8 <bread+0x40>
    800031a2:	68a4                	ld	s1,80(s1)
    800031a4:	02e48a63          	beq	s1,a4,800031d8 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800031a8:	449c                	lw	a5,8(s1)
    800031aa:	ff279ce3          	bne	a5,s2,800031a2 <bread+0x3a>
    800031ae:	44dc                	lw	a5,12(s1)
    800031b0:	ff3799e3          	bne	a5,s3,800031a2 <bread+0x3a>
      b->refcnt++;
    800031b4:	40bc                	lw	a5,64(s1)
    800031b6:	2785                	addiw	a5,a5,1
    800031b8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800031ba:	00016517          	auipc	a0,0x16
    800031be:	9ce50513          	addi	a0,a0,-1586 # 80018b88 <bcache>
    800031c2:	ffffe097          	auipc	ra,0xffffe
    800031c6:	ac8080e7          	jalr	-1336(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    800031ca:	01048513          	addi	a0,s1,16
    800031ce:	00001097          	auipc	ra,0x1
    800031d2:	46e080e7          	jalr	1134(ra) # 8000463c <acquiresleep>
      return b;
    800031d6:	a8b9                	j	80003234 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800031d8:	0001e497          	auipc	s1,0x1e
    800031dc:	c604b483          	ld	s1,-928(s1) # 80020e38 <bcache+0x82b0>
    800031e0:	0001e797          	auipc	a5,0x1e
    800031e4:	c1078793          	addi	a5,a5,-1008 # 80020df0 <bcache+0x8268>
    800031e8:	00f48863          	beq	s1,a5,800031f8 <bread+0x90>
    800031ec:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800031ee:	40bc                	lw	a5,64(s1)
    800031f0:	cf81                	beqz	a5,80003208 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800031f2:	64a4                	ld	s1,72(s1)
    800031f4:	fee49de3          	bne	s1,a4,800031ee <bread+0x86>
  panic("bget: no buffers");
    800031f8:	00005517          	auipc	a0,0x5
    800031fc:	32850513          	addi	a0,a0,808 # 80008520 <syscalls+0xd0>
    80003200:	ffffd097          	auipc	ra,0xffffd
    80003204:	33e080e7          	jalr	830(ra) # 8000053e <panic>
      b->dev = dev;
    80003208:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000320c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003210:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003214:	4785                	li	a5,1
    80003216:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003218:	00016517          	auipc	a0,0x16
    8000321c:	97050513          	addi	a0,a0,-1680 # 80018b88 <bcache>
    80003220:	ffffe097          	auipc	ra,0xffffe
    80003224:	a6a080e7          	jalr	-1430(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80003228:	01048513          	addi	a0,s1,16
    8000322c:	00001097          	auipc	ra,0x1
    80003230:	410080e7          	jalr	1040(ra) # 8000463c <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003234:	409c                	lw	a5,0(s1)
    80003236:	cb89                	beqz	a5,80003248 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003238:	8526                	mv	a0,s1
    8000323a:	70a2                	ld	ra,40(sp)
    8000323c:	7402                	ld	s0,32(sp)
    8000323e:	64e2                	ld	s1,24(sp)
    80003240:	6942                	ld	s2,16(sp)
    80003242:	69a2                	ld	s3,8(sp)
    80003244:	6145                	addi	sp,sp,48
    80003246:	8082                	ret
    virtio_disk_rw(b, 0);
    80003248:	4581                	li	a1,0
    8000324a:	8526                	mv	a0,s1
    8000324c:	00003097          	auipc	ra,0x3
    80003250:	fd8080e7          	jalr	-40(ra) # 80006224 <virtio_disk_rw>
    b->valid = 1;
    80003254:	4785                	li	a5,1
    80003256:	c09c                	sw	a5,0(s1)
  return b;
    80003258:	b7c5                	j	80003238 <bread+0xd0>

000000008000325a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000325a:	1101                	addi	sp,sp,-32
    8000325c:	ec06                	sd	ra,24(sp)
    8000325e:	e822                	sd	s0,16(sp)
    80003260:	e426                	sd	s1,8(sp)
    80003262:	1000                	addi	s0,sp,32
    80003264:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003266:	0541                	addi	a0,a0,16
    80003268:	00001097          	auipc	ra,0x1
    8000326c:	46e080e7          	jalr	1134(ra) # 800046d6 <holdingsleep>
    80003270:	cd01                	beqz	a0,80003288 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003272:	4585                	li	a1,1
    80003274:	8526                	mv	a0,s1
    80003276:	00003097          	auipc	ra,0x3
    8000327a:	fae080e7          	jalr	-82(ra) # 80006224 <virtio_disk_rw>
}
    8000327e:	60e2                	ld	ra,24(sp)
    80003280:	6442                	ld	s0,16(sp)
    80003282:	64a2                	ld	s1,8(sp)
    80003284:	6105                	addi	sp,sp,32
    80003286:	8082                	ret
    panic("bwrite");
    80003288:	00005517          	auipc	a0,0x5
    8000328c:	2b050513          	addi	a0,a0,688 # 80008538 <syscalls+0xe8>
    80003290:	ffffd097          	auipc	ra,0xffffd
    80003294:	2ae080e7          	jalr	686(ra) # 8000053e <panic>

0000000080003298 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003298:	1101                	addi	sp,sp,-32
    8000329a:	ec06                	sd	ra,24(sp)
    8000329c:	e822                	sd	s0,16(sp)
    8000329e:	e426                	sd	s1,8(sp)
    800032a0:	e04a                	sd	s2,0(sp)
    800032a2:	1000                	addi	s0,sp,32
    800032a4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800032a6:	01050913          	addi	s2,a0,16
    800032aa:	854a                	mv	a0,s2
    800032ac:	00001097          	auipc	ra,0x1
    800032b0:	42a080e7          	jalr	1066(ra) # 800046d6 <holdingsleep>
    800032b4:	c92d                	beqz	a0,80003326 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800032b6:	854a                	mv	a0,s2
    800032b8:	00001097          	auipc	ra,0x1
    800032bc:	3da080e7          	jalr	986(ra) # 80004692 <releasesleep>

  acquire(&bcache.lock);
    800032c0:	00016517          	auipc	a0,0x16
    800032c4:	8c850513          	addi	a0,a0,-1848 # 80018b88 <bcache>
    800032c8:	ffffe097          	auipc	ra,0xffffe
    800032cc:	90e080e7          	jalr	-1778(ra) # 80000bd6 <acquire>
  b->refcnt--;
    800032d0:	40bc                	lw	a5,64(s1)
    800032d2:	37fd                	addiw	a5,a5,-1
    800032d4:	0007871b          	sext.w	a4,a5
    800032d8:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800032da:	eb05                	bnez	a4,8000330a <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800032dc:	68bc                	ld	a5,80(s1)
    800032de:	64b8                	ld	a4,72(s1)
    800032e0:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800032e2:	64bc                	ld	a5,72(s1)
    800032e4:	68b8                	ld	a4,80(s1)
    800032e6:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800032e8:	0001e797          	auipc	a5,0x1e
    800032ec:	8a078793          	addi	a5,a5,-1888 # 80020b88 <bcache+0x8000>
    800032f0:	2b87b703          	ld	a4,696(a5)
    800032f4:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800032f6:	0001e717          	auipc	a4,0x1e
    800032fa:	afa70713          	addi	a4,a4,-1286 # 80020df0 <bcache+0x8268>
    800032fe:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003300:	2b87b703          	ld	a4,696(a5)
    80003304:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003306:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000330a:	00016517          	auipc	a0,0x16
    8000330e:	87e50513          	addi	a0,a0,-1922 # 80018b88 <bcache>
    80003312:	ffffe097          	auipc	ra,0xffffe
    80003316:	978080e7          	jalr	-1672(ra) # 80000c8a <release>
}
    8000331a:	60e2                	ld	ra,24(sp)
    8000331c:	6442                	ld	s0,16(sp)
    8000331e:	64a2                	ld	s1,8(sp)
    80003320:	6902                	ld	s2,0(sp)
    80003322:	6105                	addi	sp,sp,32
    80003324:	8082                	ret
    panic("brelse");
    80003326:	00005517          	auipc	a0,0x5
    8000332a:	21a50513          	addi	a0,a0,538 # 80008540 <syscalls+0xf0>
    8000332e:	ffffd097          	auipc	ra,0xffffd
    80003332:	210080e7          	jalr	528(ra) # 8000053e <panic>

0000000080003336 <bpin>:

void
bpin(struct buf *b) {
    80003336:	1101                	addi	sp,sp,-32
    80003338:	ec06                	sd	ra,24(sp)
    8000333a:	e822                	sd	s0,16(sp)
    8000333c:	e426                	sd	s1,8(sp)
    8000333e:	1000                	addi	s0,sp,32
    80003340:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003342:	00016517          	auipc	a0,0x16
    80003346:	84650513          	addi	a0,a0,-1978 # 80018b88 <bcache>
    8000334a:	ffffe097          	auipc	ra,0xffffe
    8000334e:	88c080e7          	jalr	-1908(ra) # 80000bd6 <acquire>
  b->refcnt++;
    80003352:	40bc                	lw	a5,64(s1)
    80003354:	2785                	addiw	a5,a5,1
    80003356:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003358:	00016517          	auipc	a0,0x16
    8000335c:	83050513          	addi	a0,a0,-2000 # 80018b88 <bcache>
    80003360:	ffffe097          	auipc	ra,0xffffe
    80003364:	92a080e7          	jalr	-1750(ra) # 80000c8a <release>
}
    80003368:	60e2                	ld	ra,24(sp)
    8000336a:	6442                	ld	s0,16(sp)
    8000336c:	64a2                	ld	s1,8(sp)
    8000336e:	6105                	addi	sp,sp,32
    80003370:	8082                	ret

0000000080003372 <bunpin>:

void
bunpin(struct buf *b) {
    80003372:	1101                	addi	sp,sp,-32
    80003374:	ec06                	sd	ra,24(sp)
    80003376:	e822                	sd	s0,16(sp)
    80003378:	e426                	sd	s1,8(sp)
    8000337a:	1000                	addi	s0,sp,32
    8000337c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000337e:	00016517          	auipc	a0,0x16
    80003382:	80a50513          	addi	a0,a0,-2038 # 80018b88 <bcache>
    80003386:	ffffe097          	auipc	ra,0xffffe
    8000338a:	850080e7          	jalr	-1968(ra) # 80000bd6 <acquire>
  b->refcnt--;
    8000338e:	40bc                	lw	a5,64(s1)
    80003390:	37fd                	addiw	a5,a5,-1
    80003392:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003394:	00015517          	auipc	a0,0x15
    80003398:	7f450513          	addi	a0,a0,2036 # 80018b88 <bcache>
    8000339c:	ffffe097          	auipc	ra,0xffffe
    800033a0:	8ee080e7          	jalr	-1810(ra) # 80000c8a <release>
}
    800033a4:	60e2                	ld	ra,24(sp)
    800033a6:	6442                	ld	s0,16(sp)
    800033a8:	64a2                	ld	s1,8(sp)
    800033aa:	6105                	addi	sp,sp,32
    800033ac:	8082                	ret

00000000800033ae <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800033ae:	1101                	addi	sp,sp,-32
    800033b0:	ec06                	sd	ra,24(sp)
    800033b2:	e822                	sd	s0,16(sp)
    800033b4:	e426                	sd	s1,8(sp)
    800033b6:	e04a                	sd	s2,0(sp)
    800033b8:	1000                	addi	s0,sp,32
    800033ba:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800033bc:	00d5d59b          	srliw	a1,a1,0xd
    800033c0:	0001e797          	auipc	a5,0x1e
    800033c4:	ea47a783          	lw	a5,-348(a5) # 80021264 <sb+0x1c>
    800033c8:	9dbd                	addw	a1,a1,a5
    800033ca:	00000097          	auipc	ra,0x0
    800033ce:	d9e080e7          	jalr	-610(ra) # 80003168 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800033d2:	0074f713          	andi	a4,s1,7
    800033d6:	4785                	li	a5,1
    800033d8:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800033dc:	14ce                	slli	s1,s1,0x33
    800033de:	90d9                	srli	s1,s1,0x36
    800033e0:	00950733          	add	a4,a0,s1
    800033e4:	05874703          	lbu	a4,88(a4)
    800033e8:	00e7f6b3          	and	a3,a5,a4
    800033ec:	c69d                	beqz	a3,8000341a <bfree+0x6c>
    800033ee:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800033f0:	94aa                	add	s1,s1,a0
    800033f2:	fff7c793          	not	a5,a5
    800033f6:	8ff9                	and	a5,a5,a4
    800033f8:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800033fc:	00001097          	auipc	ra,0x1
    80003400:	120080e7          	jalr	288(ra) # 8000451c <log_write>
  brelse(bp);
    80003404:	854a                	mv	a0,s2
    80003406:	00000097          	auipc	ra,0x0
    8000340a:	e92080e7          	jalr	-366(ra) # 80003298 <brelse>
}
    8000340e:	60e2                	ld	ra,24(sp)
    80003410:	6442                	ld	s0,16(sp)
    80003412:	64a2                	ld	s1,8(sp)
    80003414:	6902                	ld	s2,0(sp)
    80003416:	6105                	addi	sp,sp,32
    80003418:	8082                	ret
    panic("freeing free block");
    8000341a:	00005517          	auipc	a0,0x5
    8000341e:	12e50513          	addi	a0,a0,302 # 80008548 <syscalls+0xf8>
    80003422:	ffffd097          	auipc	ra,0xffffd
    80003426:	11c080e7          	jalr	284(ra) # 8000053e <panic>

000000008000342a <balloc>:
{
    8000342a:	711d                	addi	sp,sp,-96
    8000342c:	ec86                	sd	ra,88(sp)
    8000342e:	e8a2                	sd	s0,80(sp)
    80003430:	e4a6                	sd	s1,72(sp)
    80003432:	e0ca                	sd	s2,64(sp)
    80003434:	fc4e                	sd	s3,56(sp)
    80003436:	f852                	sd	s4,48(sp)
    80003438:	f456                	sd	s5,40(sp)
    8000343a:	f05a                	sd	s6,32(sp)
    8000343c:	ec5e                	sd	s7,24(sp)
    8000343e:	e862                	sd	s8,16(sp)
    80003440:	e466                	sd	s9,8(sp)
    80003442:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003444:	0001e797          	auipc	a5,0x1e
    80003448:	e087a783          	lw	a5,-504(a5) # 8002124c <sb+0x4>
    8000344c:	10078163          	beqz	a5,8000354e <balloc+0x124>
    80003450:	8baa                	mv	s7,a0
    80003452:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003454:	0001eb17          	auipc	s6,0x1e
    80003458:	df4b0b13          	addi	s6,s6,-524 # 80021248 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000345c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000345e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003460:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003462:	6c89                	lui	s9,0x2
    80003464:	a061                	j	800034ec <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003466:	974a                	add	a4,a4,s2
    80003468:	8fd5                	or	a5,a5,a3
    8000346a:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    8000346e:	854a                	mv	a0,s2
    80003470:	00001097          	auipc	ra,0x1
    80003474:	0ac080e7          	jalr	172(ra) # 8000451c <log_write>
        brelse(bp);
    80003478:	854a                	mv	a0,s2
    8000347a:	00000097          	auipc	ra,0x0
    8000347e:	e1e080e7          	jalr	-482(ra) # 80003298 <brelse>
  bp = bread(dev, bno);
    80003482:	85a6                	mv	a1,s1
    80003484:	855e                	mv	a0,s7
    80003486:	00000097          	auipc	ra,0x0
    8000348a:	ce2080e7          	jalr	-798(ra) # 80003168 <bread>
    8000348e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003490:	40000613          	li	a2,1024
    80003494:	4581                	li	a1,0
    80003496:	05850513          	addi	a0,a0,88
    8000349a:	ffffe097          	auipc	ra,0xffffe
    8000349e:	838080e7          	jalr	-1992(ra) # 80000cd2 <memset>
  log_write(bp);
    800034a2:	854a                	mv	a0,s2
    800034a4:	00001097          	auipc	ra,0x1
    800034a8:	078080e7          	jalr	120(ra) # 8000451c <log_write>
  brelse(bp);
    800034ac:	854a                	mv	a0,s2
    800034ae:	00000097          	auipc	ra,0x0
    800034b2:	dea080e7          	jalr	-534(ra) # 80003298 <brelse>
}
    800034b6:	8526                	mv	a0,s1
    800034b8:	60e6                	ld	ra,88(sp)
    800034ba:	6446                	ld	s0,80(sp)
    800034bc:	64a6                	ld	s1,72(sp)
    800034be:	6906                	ld	s2,64(sp)
    800034c0:	79e2                	ld	s3,56(sp)
    800034c2:	7a42                	ld	s4,48(sp)
    800034c4:	7aa2                	ld	s5,40(sp)
    800034c6:	7b02                	ld	s6,32(sp)
    800034c8:	6be2                	ld	s7,24(sp)
    800034ca:	6c42                	ld	s8,16(sp)
    800034cc:	6ca2                	ld	s9,8(sp)
    800034ce:	6125                	addi	sp,sp,96
    800034d0:	8082                	ret
    brelse(bp);
    800034d2:	854a                	mv	a0,s2
    800034d4:	00000097          	auipc	ra,0x0
    800034d8:	dc4080e7          	jalr	-572(ra) # 80003298 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800034dc:	015c87bb          	addw	a5,s9,s5
    800034e0:	00078a9b          	sext.w	s5,a5
    800034e4:	004b2703          	lw	a4,4(s6)
    800034e8:	06eaf363          	bgeu	s5,a4,8000354e <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    800034ec:	41fad79b          	sraiw	a5,s5,0x1f
    800034f0:	0137d79b          	srliw	a5,a5,0x13
    800034f4:	015787bb          	addw	a5,a5,s5
    800034f8:	40d7d79b          	sraiw	a5,a5,0xd
    800034fc:	01cb2583          	lw	a1,28(s6)
    80003500:	9dbd                	addw	a1,a1,a5
    80003502:	855e                	mv	a0,s7
    80003504:	00000097          	auipc	ra,0x0
    80003508:	c64080e7          	jalr	-924(ra) # 80003168 <bread>
    8000350c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000350e:	004b2503          	lw	a0,4(s6)
    80003512:	000a849b          	sext.w	s1,s5
    80003516:	8662                	mv	a2,s8
    80003518:	faa4fde3          	bgeu	s1,a0,800034d2 <balloc+0xa8>
      m = 1 << (bi % 8);
    8000351c:	41f6579b          	sraiw	a5,a2,0x1f
    80003520:	01d7d69b          	srliw	a3,a5,0x1d
    80003524:	00c6873b          	addw	a4,a3,a2
    80003528:	00777793          	andi	a5,a4,7
    8000352c:	9f95                	subw	a5,a5,a3
    8000352e:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003532:	4037571b          	sraiw	a4,a4,0x3
    80003536:	00e906b3          	add	a3,s2,a4
    8000353a:	0586c683          	lbu	a3,88(a3)
    8000353e:	00d7f5b3          	and	a1,a5,a3
    80003542:	d195                	beqz	a1,80003466 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003544:	2605                	addiw	a2,a2,1
    80003546:	2485                	addiw	s1,s1,1
    80003548:	fd4618e3          	bne	a2,s4,80003518 <balloc+0xee>
    8000354c:	b759                	j	800034d2 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    8000354e:	00005517          	auipc	a0,0x5
    80003552:	01250513          	addi	a0,a0,18 # 80008560 <syscalls+0x110>
    80003556:	ffffd097          	auipc	ra,0xffffd
    8000355a:	032080e7          	jalr	50(ra) # 80000588 <printf>
  return 0;
    8000355e:	4481                	li	s1,0
    80003560:	bf99                	j	800034b6 <balloc+0x8c>

0000000080003562 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003562:	7179                	addi	sp,sp,-48
    80003564:	f406                	sd	ra,40(sp)
    80003566:	f022                	sd	s0,32(sp)
    80003568:	ec26                	sd	s1,24(sp)
    8000356a:	e84a                	sd	s2,16(sp)
    8000356c:	e44e                	sd	s3,8(sp)
    8000356e:	e052                	sd	s4,0(sp)
    80003570:	1800                	addi	s0,sp,48
    80003572:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003574:	47ad                	li	a5,11
    80003576:	02b7e763          	bltu	a5,a1,800035a4 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    8000357a:	02059493          	slli	s1,a1,0x20
    8000357e:	9081                	srli	s1,s1,0x20
    80003580:	048a                	slli	s1,s1,0x2
    80003582:	94aa                	add	s1,s1,a0
    80003584:	0504a903          	lw	s2,80(s1)
    80003588:	06091e63          	bnez	s2,80003604 <bmap+0xa2>
      addr = balloc(ip->dev);
    8000358c:	4108                	lw	a0,0(a0)
    8000358e:	00000097          	auipc	ra,0x0
    80003592:	e9c080e7          	jalr	-356(ra) # 8000342a <balloc>
    80003596:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000359a:	06090563          	beqz	s2,80003604 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    8000359e:	0524a823          	sw	s2,80(s1)
    800035a2:	a08d                	j	80003604 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    800035a4:	ff45849b          	addiw	s1,a1,-12
    800035a8:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800035ac:	0ff00793          	li	a5,255
    800035b0:	08e7e563          	bltu	a5,a4,8000363a <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800035b4:	08052903          	lw	s2,128(a0)
    800035b8:	00091d63          	bnez	s2,800035d2 <bmap+0x70>
      addr = balloc(ip->dev);
    800035bc:	4108                	lw	a0,0(a0)
    800035be:	00000097          	auipc	ra,0x0
    800035c2:	e6c080e7          	jalr	-404(ra) # 8000342a <balloc>
    800035c6:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800035ca:	02090d63          	beqz	s2,80003604 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800035ce:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800035d2:	85ca                	mv	a1,s2
    800035d4:	0009a503          	lw	a0,0(s3)
    800035d8:	00000097          	auipc	ra,0x0
    800035dc:	b90080e7          	jalr	-1136(ra) # 80003168 <bread>
    800035e0:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800035e2:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800035e6:	02049593          	slli	a1,s1,0x20
    800035ea:	9181                	srli	a1,a1,0x20
    800035ec:	058a                	slli	a1,a1,0x2
    800035ee:	00b784b3          	add	s1,a5,a1
    800035f2:	0004a903          	lw	s2,0(s1)
    800035f6:	02090063          	beqz	s2,80003616 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800035fa:	8552                	mv	a0,s4
    800035fc:	00000097          	auipc	ra,0x0
    80003600:	c9c080e7          	jalr	-868(ra) # 80003298 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003604:	854a                	mv	a0,s2
    80003606:	70a2                	ld	ra,40(sp)
    80003608:	7402                	ld	s0,32(sp)
    8000360a:	64e2                	ld	s1,24(sp)
    8000360c:	6942                	ld	s2,16(sp)
    8000360e:	69a2                	ld	s3,8(sp)
    80003610:	6a02                	ld	s4,0(sp)
    80003612:	6145                	addi	sp,sp,48
    80003614:	8082                	ret
      addr = balloc(ip->dev);
    80003616:	0009a503          	lw	a0,0(s3)
    8000361a:	00000097          	auipc	ra,0x0
    8000361e:	e10080e7          	jalr	-496(ra) # 8000342a <balloc>
    80003622:	0005091b          	sext.w	s2,a0
      if(addr){
    80003626:	fc090ae3          	beqz	s2,800035fa <bmap+0x98>
        a[bn] = addr;
    8000362a:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    8000362e:	8552                	mv	a0,s4
    80003630:	00001097          	auipc	ra,0x1
    80003634:	eec080e7          	jalr	-276(ra) # 8000451c <log_write>
    80003638:	b7c9                	j	800035fa <bmap+0x98>
  panic("bmap: out of range");
    8000363a:	00005517          	auipc	a0,0x5
    8000363e:	f3e50513          	addi	a0,a0,-194 # 80008578 <syscalls+0x128>
    80003642:	ffffd097          	auipc	ra,0xffffd
    80003646:	efc080e7          	jalr	-260(ra) # 8000053e <panic>

000000008000364a <iget>:
{
    8000364a:	7179                	addi	sp,sp,-48
    8000364c:	f406                	sd	ra,40(sp)
    8000364e:	f022                	sd	s0,32(sp)
    80003650:	ec26                	sd	s1,24(sp)
    80003652:	e84a                	sd	s2,16(sp)
    80003654:	e44e                	sd	s3,8(sp)
    80003656:	e052                	sd	s4,0(sp)
    80003658:	1800                	addi	s0,sp,48
    8000365a:	89aa                	mv	s3,a0
    8000365c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000365e:	0001e517          	auipc	a0,0x1e
    80003662:	c0a50513          	addi	a0,a0,-1014 # 80021268 <itable>
    80003666:	ffffd097          	auipc	ra,0xffffd
    8000366a:	570080e7          	jalr	1392(ra) # 80000bd6 <acquire>
  empty = 0;
    8000366e:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003670:	0001e497          	auipc	s1,0x1e
    80003674:	c1048493          	addi	s1,s1,-1008 # 80021280 <itable+0x18>
    80003678:	0001f697          	auipc	a3,0x1f
    8000367c:	69868693          	addi	a3,a3,1688 # 80022d10 <log>
    80003680:	a039                	j	8000368e <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003682:	02090b63          	beqz	s2,800036b8 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003686:	08848493          	addi	s1,s1,136
    8000368a:	02d48a63          	beq	s1,a3,800036be <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000368e:	449c                	lw	a5,8(s1)
    80003690:	fef059e3          	blez	a5,80003682 <iget+0x38>
    80003694:	4098                	lw	a4,0(s1)
    80003696:	ff3716e3          	bne	a4,s3,80003682 <iget+0x38>
    8000369a:	40d8                	lw	a4,4(s1)
    8000369c:	ff4713e3          	bne	a4,s4,80003682 <iget+0x38>
      ip->ref++;
    800036a0:	2785                	addiw	a5,a5,1
    800036a2:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800036a4:	0001e517          	auipc	a0,0x1e
    800036a8:	bc450513          	addi	a0,a0,-1084 # 80021268 <itable>
    800036ac:	ffffd097          	auipc	ra,0xffffd
    800036b0:	5de080e7          	jalr	1502(ra) # 80000c8a <release>
      return ip;
    800036b4:	8926                	mv	s2,s1
    800036b6:	a03d                	j	800036e4 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800036b8:	f7f9                	bnez	a5,80003686 <iget+0x3c>
    800036ba:	8926                	mv	s2,s1
    800036bc:	b7e9                	j	80003686 <iget+0x3c>
  if(empty == 0)
    800036be:	02090c63          	beqz	s2,800036f6 <iget+0xac>
  ip->dev = dev;
    800036c2:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800036c6:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800036ca:	4785                	li	a5,1
    800036cc:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800036d0:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800036d4:	0001e517          	auipc	a0,0x1e
    800036d8:	b9450513          	addi	a0,a0,-1132 # 80021268 <itable>
    800036dc:	ffffd097          	auipc	ra,0xffffd
    800036e0:	5ae080e7          	jalr	1454(ra) # 80000c8a <release>
}
    800036e4:	854a                	mv	a0,s2
    800036e6:	70a2                	ld	ra,40(sp)
    800036e8:	7402                	ld	s0,32(sp)
    800036ea:	64e2                	ld	s1,24(sp)
    800036ec:	6942                	ld	s2,16(sp)
    800036ee:	69a2                	ld	s3,8(sp)
    800036f0:	6a02                	ld	s4,0(sp)
    800036f2:	6145                	addi	sp,sp,48
    800036f4:	8082                	ret
    panic("iget: no inodes");
    800036f6:	00005517          	auipc	a0,0x5
    800036fa:	e9a50513          	addi	a0,a0,-358 # 80008590 <syscalls+0x140>
    800036fe:	ffffd097          	auipc	ra,0xffffd
    80003702:	e40080e7          	jalr	-448(ra) # 8000053e <panic>

0000000080003706 <fsinit>:
fsinit(int dev) {
    80003706:	7179                	addi	sp,sp,-48
    80003708:	f406                	sd	ra,40(sp)
    8000370a:	f022                	sd	s0,32(sp)
    8000370c:	ec26                	sd	s1,24(sp)
    8000370e:	e84a                	sd	s2,16(sp)
    80003710:	e44e                	sd	s3,8(sp)
    80003712:	1800                	addi	s0,sp,48
    80003714:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003716:	4585                	li	a1,1
    80003718:	00000097          	auipc	ra,0x0
    8000371c:	a50080e7          	jalr	-1456(ra) # 80003168 <bread>
    80003720:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003722:	0001e997          	auipc	s3,0x1e
    80003726:	b2698993          	addi	s3,s3,-1242 # 80021248 <sb>
    8000372a:	02000613          	li	a2,32
    8000372e:	05850593          	addi	a1,a0,88
    80003732:	854e                	mv	a0,s3
    80003734:	ffffd097          	auipc	ra,0xffffd
    80003738:	5fa080e7          	jalr	1530(ra) # 80000d2e <memmove>
  brelse(bp);
    8000373c:	8526                	mv	a0,s1
    8000373e:	00000097          	auipc	ra,0x0
    80003742:	b5a080e7          	jalr	-1190(ra) # 80003298 <brelse>
  if(sb.magic != FSMAGIC)
    80003746:	0009a703          	lw	a4,0(s3)
    8000374a:	102037b7          	lui	a5,0x10203
    8000374e:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003752:	02f71263          	bne	a4,a5,80003776 <fsinit+0x70>
  initlog(dev, &sb);
    80003756:	0001e597          	auipc	a1,0x1e
    8000375a:	af258593          	addi	a1,a1,-1294 # 80021248 <sb>
    8000375e:	854a                	mv	a0,s2
    80003760:	00001097          	auipc	ra,0x1
    80003764:	b40080e7          	jalr	-1216(ra) # 800042a0 <initlog>
}
    80003768:	70a2                	ld	ra,40(sp)
    8000376a:	7402                	ld	s0,32(sp)
    8000376c:	64e2                	ld	s1,24(sp)
    8000376e:	6942                	ld	s2,16(sp)
    80003770:	69a2                	ld	s3,8(sp)
    80003772:	6145                	addi	sp,sp,48
    80003774:	8082                	ret
    panic("invalid file system");
    80003776:	00005517          	auipc	a0,0x5
    8000377a:	e2a50513          	addi	a0,a0,-470 # 800085a0 <syscalls+0x150>
    8000377e:	ffffd097          	auipc	ra,0xffffd
    80003782:	dc0080e7          	jalr	-576(ra) # 8000053e <panic>

0000000080003786 <iinit>:
{
    80003786:	7179                	addi	sp,sp,-48
    80003788:	f406                	sd	ra,40(sp)
    8000378a:	f022                	sd	s0,32(sp)
    8000378c:	ec26                	sd	s1,24(sp)
    8000378e:	e84a                	sd	s2,16(sp)
    80003790:	e44e                	sd	s3,8(sp)
    80003792:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003794:	00005597          	auipc	a1,0x5
    80003798:	e2458593          	addi	a1,a1,-476 # 800085b8 <syscalls+0x168>
    8000379c:	0001e517          	auipc	a0,0x1e
    800037a0:	acc50513          	addi	a0,a0,-1332 # 80021268 <itable>
    800037a4:	ffffd097          	auipc	ra,0xffffd
    800037a8:	3a2080e7          	jalr	930(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    800037ac:	0001e497          	auipc	s1,0x1e
    800037b0:	ae448493          	addi	s1,s1,-1308 # 80021290 <itable+0x28>
    800037b4:	0001f997          	auipc	s3,0x1f
    800037b8:	56c98993          	addi	s3,s3,1388 # 80022d20 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800037bc:	00005917          	auipc	s2,0x5
    800037c0:	e0490913          	addi	s2,s2,-508 # 800085c0 <syscalls+0x170>
    800037c4:	85ca                	mv	a1,s2
    800037c6:	8526                	mv	a0,s1
    800037c8:	00001097          	auipc	ra,0x1
    800037cc:	e3a080e7          	jalr	-454(ra) # 80004602 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800037d0:	08848493          	addi	s1,s1,136
    800037d4:	ff3498e3          	bne	s1,s3,800037c4 <iinit+0x3e>
}
    800037d8:	70a2                	ld	ra,40(sp)
    800037da:	7402                	ld	s0,32(sp)
    800037dc:	64e2                	ld	s1,24(sp)
    800037de:	6942                	ld	s2,16(sp)
    800037e0:	69a2                	ld	s3,8(sp)
    800037e2:	6145                	addi	sp,sp,48
    800037e4:	8082                	ret

00000000800037e6 <ialloc>:
{
    800037e6:	715d                	addi	sp,sp,-80
    800037e8:	e486                	sd	ra,72(sp)
    800037ea:	e0a2                	sd	s0,64(sp)
    800037ec:	fc26                	sd	s1,56(sp)
    800037ee:	f84a                	sd	s2,48(sp)
    800037f0:	f44e                	sd	s3,40(sp)
    800037f2:	f052                	sd	s4,32(sp)
    800037f4:	ec56                	sd	s5,24(sp)
    800037f6:	e85a                	sd	s6,16(sp)
    800037f8:	e45e                	sd	s7,8(sp)
    800037fa:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800037fc:	0001e717          	auipc	a4,0x1e
    80003800:	a5872703          	lw	a4,-1448(a4) # 80021254 <sb+0xc>
    80003804:	4785                	li	a5,1
    80003806:	04e7fa63          	bgeu	a5,a4,8000385a <ialloc+0x74>
    8000380a:	8aaa                	mv	s5,a0
    8000380c:	8bae                	mv	s7,a1
    8000380e:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003810:	0001ea17          	auipc	s4,0x1e
    80003814:	a38a0a13          	addi	s4,s4,-1480 # 80021248 <sb>
    80003818:	00048b1b          	sext.w	s6,s1
    8000381c:	0044d793          	srli	a5,s1,0x4
    80003820:	018a2583          	lw	a1,24(s4)
    80003824:	9dbd                	addw	a1,a1,a5
    80003826:	8556                	mv	a0,s5
    80003828:	00000097          	auipc	ra,0x0
    8000382c:	940080e7          	jalr	-1728(ra) # 80003168 <bread>
    80003830:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003832:	05850993          	addi	s3,a0,88
    80003836:	00f4f793          	andi	a5,s1,15
    8000383a:	079a                	slli	a5,a5,0x6
    8000383c:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000383e:	00099783          	lh	a5,0(s3)
    80003842:	c3a1                	beqz	a5,80003882 <ialloc+0x9c>
    brelse(bp);
    80003844:	00000097          	auipc	ra,0x0
    80003848:	a54080e7          	jalr	-1452(ra) # 80003298 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000384c:	0485                	addi	s1,s1,1
    8000384e:	00ca2703          	lw	a4,12(s4)
    80003852:	0004879b          	sext.w	a5,s1
    80003856:	fce7e1e3          	bltu	a5,a4,80003818 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    8000385a:	00005517          	auipc	a0,0x5
    8000385e:	d6e50513          	addi	a0,a0,-658 # 800085c8 <syscalls+0x178>
    80003862:	ffffd097          	auipc	ra,0xffffd
    80003866:	d26080e7          	jalr	-730(ra) # 80000588 <printf>
  return 0;
    8000386a:	4501                	li	a0,0
}
    8000386c:	60a6                	ld	ra,72(sp)
    8000386e:	6406                	ld	s0,64(sp)
    80003870:	74e2                	ld	s1,56(sp)
    80003872:	7942                	ld	s2,48(sp)
    80003874:	79a2                	ld	s3,40(sp)
    80003876:	7a02                	ld	s4,32(sp)
    80003878:	6ae2                	ld	s5,24(sp)
    8000387a:	6b42                	ld	s6,16(sp)
    8000387c:	6ba2                	ld	s7,8(sp)
    8000387e:	6161                	addi	sp,sp,80
    80003880:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003882:	04000613          	li	a2,64
    80003886:	4581                	li	a1,0
    80003888:	854e                	mv	a0,s3
    8000388a:	ffffd097          	auipc	ra,0xffffd
    8000388e:	448080e7          	jalr	1096(ra) # 80000cd2 <memset>
      dip->type = type;
    80003892:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003896:	854a                	mv	a0,s2
    80003898:	00001097          	auipc	ra,0x1
    8000389c:	c84080e7          	jalr	-892(ra) # 8000451c <log_write>
      brelse(bp);
    800038a0:	854a                	mv	a0,s2
    800038a2:	00000097          	auipc	ra,0x0
    800038a6:	9f6080e7          	jalr	-1546(ra) # 80003298 <brelse>
      return iget(dev, inum);
    800038aa:	85da                	mv	a1,s6
    800038ac:	8556                	mv	a0,s5
    800038ae:	00000097          	auipc	ra,0x0
    800038b2:	d9c080e7          	jalr	-612(ra) # 8000364a <iget>
    800038b6:	bf5d                	j	8000386c <ialloc+0x86>

00000000800038b8 <iupdate>:
{
    800038b8:	1101                	addi	sp,sp,-32
    800038ba:	ec06                	sd	ra,24(sp)
    800038bc:	e822                	sd	s0,16(sp)
    800038be:	e426                	sd	s1,8(sp)
    800038c0:	e04a                	sd	s2,0(sp)
    800038c2:	1000                	addi	s0,sp,32
    800038c4:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800038c6:	415c                	lw	a5,4(a0)
    800038c8:	0047d79b          	srliw	a5,a5,0x4
    800038cc:	0001e597          	auipc	a1,0x1e
    800038d0:	9945a583          	lw	a1,-1644(a1) # 80021260 <sb+0x18>
    800038d4:	9dbd                	addw	a1,a1,a5
    800038d6:	4108                	lw	a0,0(a0)
    800038d8:	00000097          	auipc	ra,0x0
    800038dc:	890080e7          	jalr	-1904(ra) # 80003168 <bread>
    800038e0:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800038e2:	05850793          	addi	a5,a0,88
    800038e6:	40c8                	lw	a0,4(s1)
    800038e8:	893d                	andi	a0,a0,15
    800038ea:	051a                	slli	a0,a0,0x6
    800038ec:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800038ee:	04449703          	lh	a4,68(s1)
    800038f2:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    800038f6:	04649703          	lh	a4,70(s1)
    800038fa:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    800038fe:	04849703          	lh	a4,72(s1)
    80003902:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003906:	04a49703          	lh	a4,74(s1)
    8000390a:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    8000390e:	44f8                	lw	a4,76(s1)
    80003910:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003912:	03400613          	li	a2,52
    80003916:	05048593          	addi	a1,s1,80
    8000391a:	0531                	addi	a0,a0,12
    8000391c:	ffffd097          	auipc	ra,0xffffd
    80003920:	412080e7          	jalr	1042(ra) # 80000d2e <memmove>
  log_write(bp);
    80003924:	854a                	mv	a0,s2
    80003926:	00001097          	auipc	ra,0x1
    8000392a:	bf6080e7          	jalr	-1034(ra) # 8000451c <log_write>
  brelse(bp);
    8000392e:	854a                	mv	a0,s2
    80003930:	00000097          	auipc	ra,0x0
    80003934:	968080e7          	jalr	-1688(ra) # 80003298 <brelse>
}
    80003938:	60e2                	ld	ra,24(sp)
    8000393a:	6442                	ld	s0,16(sp)
    8000393c:	64a2                	ld	s1,8(sp)
    8000393e:	6902                	ld	s2,0(sp)
    80003940:	6105                	addi	sp,sp,32
    80003942:	8082                	ret

0000000080003944 <idup>:
{
    80003944:	1101                	addi	sp,sp,-32
    80003946:	ec06                	sd	ra,24(sp)
    80003948:	e822                	sd	s0,16(sp)
    8000394a:	e426                	sd	s1,8(sp)
    8000394c:	1000                	addi	s0,sp,32
    8000394e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003950:	0001e517          	auipc	a0,0x1e
    80003954:	91850513          	addi	a0,a0,-1768 # 80021268 <itable>
    80003958:	ffffd097          	auipc	ra,0xffffd
    8000395c:	27e080e7          	jalr	638(ra) # 80000bd6 <acquire>
  ip->ref++;
    80003960:	449c                	lw	a5,8(s1)
    80003962:	2785                	addiw	a5,a5,1
    80003964:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003966:	0001e517          	auipc	a0,0x1e
    8000396a:	90250513          	addi	a0,a0,-1790 # 80021268 <itable>
    8000396e:	ffffd097          	auipc	ra,0xffffd
    80003972:	31c080e7          	jalr	796(ra) # 80000c8a <release>
}
    80003976:	8526                	mv	a0,s1
    80003978:	60e2                	ld	ra,24(sp)
    8000397a:	6442                	ld	s0,16(sp)
    8000397c:	64a2                	ld	s1,8(sp)
    8000397e:	6105                	addi	sp,sp,32
    80003980:	8082                	ret

0000000080003982 <ilock>:
{
    80003982:	1101                	addi	sp,sp,-32
    80003984:	ec06                	sd	ra,24(sp)
    80003986:	e822                	sd	s0,16(sp)
    80003988:	e426                	sd	s1,8(sp)
    8000398a:	e04a                	sd	s2,0(sp)
    8000398c:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000398e:	c115                	beqz	a0,800039b2 <ilock+0x30>
    80003990:	84aa                	mv	s1,a0
    80003992:	451c                	lw	a5,8(a0)
    80003994:	00f05f63          	blez	a5,800039b2 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003998:	0541                	addi	a0,a0,16
    8000399a:	00001097          	auipc	ra,0x1
    8000399e:	ca2080e7          	jalr	-862(ra) # 8000463c <acquiresleep>
  if(ip->valid == 0){
    800039a2:	40bc                	lw	a5,64(s1)
    800039a4:	cf99                	beqz	a5,800039c2 <ilock+0x40>
}
    800039a6:	60e2                	ld	ra,24(sp)
    800039a8:	6442                	ld	s0,16(sp)
    800039aa:	64a2                	ld	s1,8(sp)
    800039ac:	6902                	ld	s2,0(sp)
    800039ae:	6105                	addi	sp,sp,32
    800039b0:	8082                	ret
    panic("ilock");
    800039b2:	00005517          	auipc	a0,0x5
    800039b6:	c2e50513          	addi	a0,a0,-978 # 800085e0 <syscalls+0x190>
    800039ba:	ffffd097          	auipc	ra,0xffffd
    800039be:	b84080e7          	jalr	-1148(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800039c2:	40dc                	lw	a5,4(s1)
    800039c4:	0047d79b          	srliw	a5,a5,0x4
    800039c8:	0001e597          	auipc	a1,0x1e
    800039cc:	8985a583          	lw	a1,-1896(a1) # 80021260 <sb+0x18>
    800039d0:	9dbd                	addw	a1,a1,a5
    800039d2:	4088                	lw	a0,0(s1)
    800039d4:	fffff097          	auipc	ra,0xfffff
    800039d8:	794080e7          	jalr	1940(ra) # 80003168 <bread>
    800039dc:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800039de:	05850593          	addi	a1,a0,88
    800039e2:	40dc                	lw	a5,4(s1)
    800039e4:	8bbd                	andi	a5,a5,15
    800039e6:	079a                	slli	a5,a5,0x6
    800039e8:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800039ea:	00059783          	lh	a5,0(a1)
    800039ee:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800039f2:	00259783          	lh	a5,2(a1)
    800039f6:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800039fa:	00459783          	lh	a5,4(a1)
    800039fe:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003a02:	00659783          	lh	a5,6(a1)
    80003a06:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003a0a:	459c                	lw	a5,8(a1)
    80003a0c:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003a0e:	03400613          	li	a2,52
    80003a12:	05b1                	addi	a1,a1,12
    80003a14:	05048513          	addi	a0,s1,80
    80003a18:	ffffd097          	auipc	ra,0xffffd
    80003a1c:	316080e7          	jalr	790(ra) # 80000d2e <memmove>
    brelse(bp);
    80003a20:	854a                	mv	a0,s2
    80003a22:	00000097          	auipc	ra,0x0
    80003a26:	876080e7          	jalr	-1930(ra) # 80003298 <brelse>
    ip->valid = 1;
    80003a2a:	4785                	li	a5,1
    80003a2c:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003a2e:	04449783          	lh	a5,68(s1)
    80003a32:	fbb5                	bnez	a5,800039a6 <ilock+0x24>
      panic("ilock: no type");
    80003a34:	00005517          	auipc	a0,0x5
    80003a38:	bb450513          	addi	a0,a0,-1100 # 800085e8 <syscalls+0x198>
    80003a3c:	ffffd097          	auipc	ra,0xffffd
    80003a40:	b02080e7          	jalr	-1278(ra) # 8000053e <panic>

0000000080003a44 <iunlock>:
{
    80003a44:	1101                	addi	sp,sp,-32
    80003a46:	ec06                	sd	ra,24(sp)
    80003a48:	e822                	sd	s0,16(sp)
    80003a4a:	e426                	sd	s1,8(sp)
    80003a4c:	e04a                	sd	s2,0(sp)
    80003a4e:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003a50:	c905                	beqz	a0,80003a80 <iunlock+0x3c>
    80003a52:	84aa                	mv	s1,a0
    80003a54:	01050913          	addi	s2,a0,16
    80003a58:	854a                	mv	a0,s2
    80003a5a:	00001097          	auipc	ra,0x1
    80003a5e:	c7c080e7          	jalr	-900(ra) # 800046d6 <holdingsleep>
    80003a62:	cd19                	beqz	a0,80003a80 <iunlock+0x3c>
    80003a64:	449c                	lw	a5,8(s1)
    80003a66:	00f05d63          	blez	a5,80003a80 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003a6a:	854a                	mv	a0,s2
    80003a6c:	00001097          	auipc	ra,0x1
    80003a70:	c26080e7          	jalr	-986(ra) # 80004692 <releasesleep>
}
    80003a74:	60e2                	ld	ra,24(sp)
    80003a76:	6442                	ld	s0,16(sp)
    80003a78:	64a2                	ld	s1,8(sp)
    80003a7a:	6902                	ld	s2,0(sp)
    80003a7c:	6105                	addi	sp,sp,32
    80003a7e:	8082                	ret
    panic("iunlock");
    80003a80:	00005517          	auipc	a0,0x5
    80003a84:	b7850513          	addi	a0,a0,-1160 # 800085f8 <syscalls+0x1a8>
    80003a88:	ffffd097          	auipc	ra,0xffffd
    80003a8c:	ab6080e7          	jalr	-1354(ra) # 8000053e <panic>

0000000080003a90 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003a90:	7179                	addi	sp,sp,-48
    80003a92:	f406                	sd	ra,40(sp)
    80003a94:	f022                	sd	s0,32(sp)
    80003a96:	ec26                	sd	s1,24(sp)
    80003a98:	e84a                	sd	s2,16(sp)
    80003a9a:	e44e                	sd	s3,8(sp)
    80003a9c:	e052                	sd	s4,0(sp)
    80003a9e:	1800                	addi	s0,sp,48
    80003aa0:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003aa2:	05050493          	addi	s1,a0,80
    80003aa6:	08050913          	addi	s2,a0,128
    80003aaa:	a021                	j	80003ab2 <itrunc+0x22>
    80003aac:	0491                	addi	s1,s1,4
    80003aae:	01248d63          	beq	s1,s2,80003ac8 <itrunc+0x38>
    if(ip->addrs[i]){
    80003ab2:	408c                	lw	a1,0(s1)
    80003ab4:	dde5                	beqz	a1,80003aac <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003ab6:	0009a503          	lw	a0,0(s3)
    80003aba:	00000097          	auipc	ra,0x0
    80003abe:	8f4080e7          	jalr	-1804(ra) # 800033ae <bfree>
      ip->addrs[i] = 0;
    80003ac2:	0004a023          	sw	zero,0(s1)
    80003ac6:	b7dd                	j	80003aac <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003ac8:	0809a583          	lw	a1,128(s3)
    80003acc:	e185                	bnez	a1,80003aec <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003ace:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003ad2:	854e                	mv	a0,s3
    80003ad4:	00000097          	auipc	ra,0x0
    80003ad8:	de4080e7          	jalr	-540(ra) # 800038b8 <iupdate>
}
    80003adc:	70a2                	ld	ra,40(sp)
    80003ade:	7402                	ld	s0,32(sp)
    80003ae0:	64e2                	ld	s1,24(sp)
    80003ae2:	6942                	ld	s2,16(sp)
    80003ae4:	69a2                	ld	s3,8(sp)
    80003ae6:	6a02                	ld	s4,0(sp)
    80003ae8:	6145                	addi	sp,sp,48
    80003aea:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003aec:	0009a503          	lw	a0,0(s3)
    80003af0:	fffff097          	auipc	ra,0xfffff
    80003af4:	678080e7          	jalr	1656(ra) # 80003168 <bread>
    80003af8:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003afa:	05850493          	addi	s1,a0,88
    80003afe:	45850913          	addi	s2,a0,1112
    80003b02:	a021                	j	80003b0a <itrunc+0x7a>
    80003b04:	0491                	addi	s1,s1,4
    80003b06:	01248b63          	beq	s1,s2,80003b1c <itrunc+0x8c>
      if(a[j])
    80003b0a:	408c                	lw	a1,0(s1)
    80003b0c:	dde5                	beqz	a1,80003b04 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003b0e:	0009a503          	lw	a0,0(s3)
    80003b12:	00000097          	auipc	ra,0x0
    80003b16:	89c080e7          	jalr	-1892(ra) # 800033ae <bfree>
    80003b1a:	b7ed                	j	80003b04 <itrunc+0x74>
    brelse(bp);
    80003b1c:	8552                	mv	a0,s4
    80003b1e:	fffff097          	auipc	ra,0xfffff
    80003b22:	77a080e7          	jalr	1914(ra) # 80003298 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003b26:	0809a583          	lw	a1,128(s3)
    80003b2a:	0009a503          	lw	a0,0(s3)
    80003b2e:	00000097          	auipc	ra,0x0
    80003b32:	880080e7          	jalr	-1920(ra) # 800033ae <bfree>
    ip->addrs[NDIRECT] = 0;
    80003b36:	0809a023          	sw	zero,128(s3)
    80003b3a:	bf51                	j	80003ace <itrunc+0x3e>

0000000080003b3c <iput>:
{
    80003b3c:	1101                	addi	sp,sp,-32
    80003b3e:	ec06                	sd	ra,24(sp)
    80003b40:	e822                	sd	s0,16(sp)
    80003b42:	e426                	sd	s1,8(sp)
    80003b44:	e04a                	sd	s2,0(sp)
    80003b46:	1000                	addi	s0,sp,32
    80003b48:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003b4a:	0001d517          	auipc	a0,0x1d
    80003b4e:	71e50513          	addi	a0,a0,1822 # 80021268 <itable>
    80003b52:	ffffd097          	auipc	ra,0xffffd
    80003b56:	084080e7          	jalr	132(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b5a:	4498                	lw	a4,8(s1)
    80003b5c:	4785                	li	a5,1
    80003b5e:	02f70363          	beq	a4,a5,80003b84 <iput+0x48>
  ip->ref--;
    80003b62:	449c                	lw	a5,8(s1)
    80003b64:	37fd                	addiw	a5,a5,-1
    80003b66:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003b68:	0001d517          	auipc	a0,0x1d
    80003b6c:	70050513          	addi	a0,a0,1792 # 80021268 <itable>
    80003b70:	ffffd097          	auipc	ra,0xffffd
    80003b74:	11a080e7          	jalr	282(ra) # 80000c8a <release>
}
    80003b78:	60e2                	ld	ra,24(sp)
    80003b7a:	6442                	ld	s0,16(sp)
    80003b7c:	64a2                	ld	s1,8(sp)
    80003b7e:	6902                	ld	s2,0(sp)
    80003b80:	6105                	addi	sp,sp,32
    80003b82:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b84:	40bc                	lw	a5,64(s1)
    80003b86:	dff1                	beqz	a5,80003b62 <iput+0x26>
    80003b88:	04a49783          	lh	a5,74(s1)
    80003b8c:	fbf9                	bnez	a5,80003b62 <iput+0x26>
    acquiresleep(&ip->lock);
    80003b8e:	01048913          	addi	s2,s1,16
    80003b92:	854a                	mv	a0,s2
    80003b94:	00001097          	auipc	ra,0x1
    80003b98:	aa8080e7          	jalr	-1368(ra) # 8000463c <acquiresleep>
    release(&itable.lock);
    80003b9c:	0001d517          	auipc	a0,0x1d
    80003ba0:	6cc50513          	addi	a0,a0,1740 # 80021268 <itable>
    80003ba4:	ffffd097          	auipc	ra,0xffffd
    80003ba8:	0e6080e7          	jalr	230(ra) # 80000c8a <release>
    itrunc(ip);
    80003bac:	8526                	mv	a0,s1
    80003bae:	00000097          	auipc	ra,0x0
    80003bb2:	ee2080e7          	jalr	-286(ra) # 80003a90 <itrunc>
    ip->type = 0;
    80003bb6:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003bba:	8526                	mv	a0,s1
    80003bbc:	00000097          	auipc	ra,0x0
    80003bc0:	cfc080e7          	jalr	-772(ra) # 800038b8 <iupdate>
    ip->valid = 0;
    80003bc4:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003bc8:	854a                	mv	a0,s2
    80003bca:	00001097          	auipc	ra,0x1
    80003bce:	ac8080e7          	jalr	-1336(ra) # 80004692 <releasesleep>
    acquire(&itable.lock);
    80003bd2:	0001d517          	auipc	a0,0x1d
    80003bd6:	69650513          	addi	a0,a0,1686 # 80021268 <itable>
    80003bda:	ffffd097          	auipc	ra,0xffffd
    80003bde:	ffc080e7          	jalr	-4(ra) # 80000bd6 <acquire>
    80003be2:	b741                	j	80003b62 <iput+0x26>

0000000080003be4 <iunlockput>:
{
    80003be4:	1101                	addi	sp,sp,-32
    80003be6:	ec06                	sd	ra,24(sp)
    80003be8:	e822                	sd	s0,16(sp)
    80003bea:	e426                	sd	s1,8(sp)
    80003bec:	1000                	addi	s0,sp,32
    80003bee:	84aa                	mv	s1,a0
  iunlock(ip);
    80003bf0:	00000097          	auipc	ra,0x0
    80003bf4:	e54080e7          	jalr	-428(ra) # 80003a44 <iunlock>
  iput(ip);
    80003bf8:	8526                	mv	a0,s1
    80003bfa:	00000097          	auipc	ra,0x0
    80003bfe:	f42080e7          	jalr	-190(ra) # 80003b3c <iput>
}
    80003c02:	60e2                	ld	ra,24(sp)
    80003c04:	6442                	ld	s0,16(sp)
    80003c06:	64a2                	ld	s1,8(sp)
    80003c08:	6105                	addi	sp,sp,32
    80003c0a:	8082                	ret

0000000080003c0c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003c0c:	1141                	addi	sp,sp,-16
    80003c0e:	e422                	sd	s0,8(sp)
    80003c10:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003c12:	411c                	lw	a5,0(a0)
    80003c14:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003c16:	415c                	lw	a5,4(a0)
    80003c18:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003c1a:	04451783          	lh	a5,68(a0)
    80003c1e:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003c22:	04a51783          	lh	a5,74(a0)
    80003c26:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003c2a:	04c56783          	lwu	a5,76(a0)
    80003c2e:	e99c                	sd	a5,16(a1)
}
    80003c30:	6422                	ld	s0,8(sp)
    80003c32:	0141                	addi	sp,sp,16
    80003c34:	8082                	ret

0000000080003c36 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c36:	457c                	lw	a5,76(a0)
    80003c38:	0ed7e963          	bltu	a5,a3,80003d2a <readi+0xf4>
{
    80003c3c:	7159                	addi	sp,sp,-112
    80003c3e:	f486                	sd	ra,104(sp)
    80003c40:	f0a2                	sd	s0,96(sp)
    80003c42:	eca6                	sd	s1,88(sp)
    80003c44:	e8ca                	sd	s2,80(sp)
    80003c46:	e4ce                	sd	s3,72(sp)
    80003c48:	e0d2                	sd	s4,64(sp)
    80003c4a:	fc56                	sd	s5,56(sp)
    80003c4c:	f85a                	sd	s6,48(sp)
    80003c4e:	f45e                	sd	s7,40(sp)
    80003c50:	f062                	sd	s8,32(sp)
    80003c52:	ec66                	sd	s9,24(sp)
    80003c54:	e86a                	sd	s10,16(sp)
    80003c56:	e46e                	sd	s11,8(sp)
    80003c58:	1880                	addi	s0,sp,112
    80003c5a:	8b2a                	mv	s6,a0
    80003c5c:	8bae                	mv	s7,a1
    80003c5e:	8a32                	mv	s4,a2
    80003c60:	84b6                	mv	s1,a3
    80003c62:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003c64:	9f35                	addw	a4,a4,a3
    return 0;
    80003c66:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003c68:	0ad76063          	bltu	a4,a3,80003d08 <readi+0xd2>
  if(off + n > ip->size)
    80003c6c:	00e7f463          	bgeu	a5,a4,80003c74 <readi+0x3e>
    n = ip->size - off;
    80003c70:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c74:	0a0a8963          	beqz	s5,80003d26 <readi+0xf0>
    80003c78:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c7a:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003c7e:	5c7d                	li	s8,-1
    80003c80:	a82d                	j	80003cba <readi+0x84>
    80003c82:	020d1d93          	slli	s11,s10,0x20
    80003c86:	020ddd93          	srli	s11,s11,0x20
    80003c8a:	05890793          	addi	a5,s2,88
    80003c8e:	86ee                	mv	a3,s11
    80003c90:	963e                	add	a2,a2,a5
    80003c92:	85d2                	mv	a1,s4
    80003c94:	855e                	mv	a0,s7
    80003c96:	ffffe097          	auipc	ra,0xffffe
    80003c9a:	7e6080e7          	jalr	2022(ra) # 8000247c <either_copyout>
    80003c9e:	05850d63          	beq	a0,s8,80003cf8 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003ca2:	854a                	mv	a0,s2
    80003ca4:	fffff097          	auipc	ra,0xfffff
    80003ca8:	5f4080e7          	jalr	1524(ra) # 80003298 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003cac:	013d09bb          	addw	s3,s10,s3
    80003cb0:	009d04bb          	addw	s1,s10,s1
    80003cb4:	9a6e                	add	s4,s4,s11
    80003cb6:	0559f763          	bgeu	s3,s5,80003d04 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003cba:	00a4d59b          	srliw	a1,s1,0xa
    80003cbe:	855a                	mv	a0,s6
    80003cc0:	00000097          	auipc	ra,0x0
    80003cc4:	8a2080e7          	jalr	-1886(ra) # 80003562 <bmap>
    80003cc8:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003ccc:	cd85                	beqz	a1,80003d04 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003cce:	000b2503          	lw	a0,0(s6)
    80003cd2:	fffff097          	auipc	ra,0xfffff
    80003cd6:	496080e7          	jalr	1174(ra) # 80003168 <bread>
    80003cda:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cdc:	3ff4f613          	andi	a2,s1,1023
    80003ce0:	40cc87bb          	subw	a5,s9,a2
    80003ce4:	413a873b          	subw	a4,s5,s3
    80003ce8:	8d3e                	mv	s10,a5
    80003cea:	2781                	sext.w	a5,a5
    80003cec:	0007069b          	sext.w	a3,a4
    80003cf0:	f8f6f9e3          	bgeu	a3,a5,80003c82 <readi+0x4c>
    80003cf4:	8d3a                	mv	s10,a4
    80003cf6:	b771                	j	80003c82 <readi+0x4c>
      brelse(bp);
    80003cf8:	854a                	mv	a0,s2
    80003cfa:	fffff097          	auipc	ra,0xfffff
    80003cfe:	59e080e7          	jalr	1438(ra) # 80003298 <brelse>
      tot = -1;
    80003d02:	59fd                	li	s3,-1
  }
  return tot;
    80003d04:	0009851b          	sext.w	a0,s3
}
    80003d08:	70a6                	ld	ra,104(sp)
    80003d0a:	7406                	ld	s0,96(sp)
    80003d0c:	64e6                	ld	s1,88(sp)
    80003d0e:	6946                	ld	s2,80(sp)
    80003d10:	69a6                	ld	s3,72(sp)
    80003d12:	6a06                	ld	s4,64(sp)
    80003d14:	7ae2                	ld	s5,56(sp)
    80003d16:	7b42                	ld	s6,48(sp)
    80003d18:	7ba2                	ld	s7,40(sp)
    80003d1a:	7c02                	ld	s8,32(sp)
    80003d1c:	6ce2                	ld	s9,24(sp)
    80003d1e:	6d42                	ld	s10,16(sp)
    80003d20:	6da2                	ld	s11,8(sp)
    80003d22:	6165                	addi	sp,sp,112
    80003d24:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d26:	89d6                	mv	s3,s5
    80003d28:	bff1                	j	80003d04 <readi+0xce>
    return 0;
    80003d2a:	4501                	li	a0,0
}
    80003d2c:	8082                	ret

0000000080003d2e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003d2e:	457c                	lw	a5,76(a0)
    80003d30:	10d7e863          	bltu	a5,a3,80003e40 <writei+0x112>
{
    80003d34:	7159                	addi	sp,sp,-112
    80003d36:	f486                	sd	ra,104(sp)
    80003d38:	f0a2                	sd	s0,96(sp)
    80003d3a:	eca6                	sd	s1,88(sp)
    80003d3c:	e8ca                	sd	s2,80(sp)
    80003d3e:	e4ce                	sd	s3,72(sp)
    80003d40:	e0d2                	sd	s4,64(sp)
    80003d42:	fc56                	sd	s5,56(sp)
    80003d44:	f85a                	sd	s6,48(sp)
    80003d46:	f45e                	sd	s7,40(sp)
    80003d48:	f062                	sd	s8,32(sp)
    80003d4a:	ec66                	sd	s9,24(sp)
    80003d4c:	e86a                	sd	s10,16(sp)
    80003d4e:	e46e                	sd	s11,8(sp)
    80003d50:	1880                	addi	s0,sp,112
    80003d52:	8aaa                	mv	s5,a0
    80003d54:	8bae                	mv	s7,a1
    80003d56:	8a32                	mv	s4,a2
    80003d58:	8936                	mv	s2,a3
    80003d5a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003d5c:	00e687bb          	addw	a5,a3,a4
    80003d60:	0ed7e263          	bltu	a5,a3,80003e44 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003d64:	00043737          	lui	a4,0x43
    80003d68:	0ef76063          	bltu	a4,a5,80003e48 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d6c:	0c0b0863          	beqz	s6,80003e3c <writei+0x10e>
    80003d70:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d72:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003d76:	5c7d                	li	s8,-1
    80003d78:	a091                	j	80003dbc <writei+0x8e>
    80003d7a:	020d1d93          	slli	s11,s10,0x20
    80003d7e:	020ddd93          	srli	s11,s11,0x20
    80003d82:	05848793          	addi	a5,s1,88
    80003d86:	86ee                	mv	a3,s11
    80003d88:	8652                	mv	a2,s4
    80003d8a:	85de                	mv	a1,s7
    80003d8c:	953e                	add	a0,a0,a5
    80003d8e:	ffffe097          	auipc	ra,0xffffe
    80003d92:	744080e7          	jalr	1860(ra) # 800024d2 <either_copyin>
    80003d96:	07850263          	beq	a0,s8,80003dfa <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003d9a:	8526                	mv	a0,s1
    80003d9c:	00000097          	auipc	ra,0x0
    80003da0:	780080e7          	jalr	1920(ra) # 8000451c <log_write>
    brelse(bp);
    80003da4:	8526                	mv	a0,s1
    80003da6:	fffff097          	auipc	ra,0xfffff
    80003daa:	4f2080e7          	jalr	1266(ra) # 80003298 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003dae:	013d09bb          	addw	s3,s10,s3
    80003db2:	012d093b          	addw	s2,s10,s2
    80003db6:	9a6e                	add	s4,s4,s11
    80003db8:	0569f663          	bgeu	s3,s6,80003e04 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003dbc:	00a9559b          	srliw	a1,s2,0xa
    80003dc0:	8556                	mv	a0,s5
    80003dc2:	fffff097          	auipc	ra,0xfffff
    80003dc6:	7a0080e7          	jalr	1952(ra) # 80003562 <bmap>
    80003dca:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003dce:	c99d                	beqz	a1,80003e04 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003dd0:	000aa503          	lw	a0,0(s5)
    80003dd4:	fffff097          	auipc	ra,0xfffff
    80003dd8:	394080e7          	jalr	916(ra) # 80003168 <bread>
    80003ddc:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003dde:	3ff97513          	andi	a0,s2,1023
    80003de2:	40ac87bb          	subw	a5,s9,a0
    80003de6:	413b073b          	subw	a4,s6,s3
    80003dea:	8d3e                	mv	s10,a5
    80003dec:	2781                	sext.w	a5,a5
    80003dee:	0007069b          	sext.w	a3,a4
    80003df2:	f8f6f4e3          	bgeu	a3,a5,80003d7a <writei+0x4c>
    80003df6:	8d3a                	mv	s10,a4
    80003df8:	b749                	j	80003d7a <writei+0x4c>
      brelse(bp);
    80003dfa:	8526                	mv	a0,s1
    80003dfc:	fffff097          	auipc	ra,0xfffff
    80003e00:	49c080e7          	jalr	1180(ra) # 80003298 <brelse>
  }

  if(off > ip->size)
    80003e04:	04caa783          	lw	a5,76(s5)
    80003e08:	0127f463          	bgeu	a5,s2,80003e10 <writei+0xe2>
    ip->size = off;
    80003e0c:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003e10:	8556                	mv	a0,s5
    80003e12:	00000097          	auipc	ra,0x0
    80003e16:	aa6080e7          	jalr	-1370(ra) # 800038b8 <iupdate>

  return tot;
    80003e1a:	0009851b          	sext.w	a0,s3
}
    80003e1e:	70a6                	ld	ra,104(sp)
    80003e20:	7406                	ld	s0,96(sp)
    80003e22:	64e6                	ld	s1,88(sp)
    80003e24:	6946                	ld	s2,80(sp)
    80003e26:	69a6                	ld	s3,72(sp)
    80003e28:	6a06                	ld	s4,64(sp)
    80003e2a:	7ae2                	ld	s5,56(sp)
    80003e2c:	7b42                	ld	s6,48(sp)
    80003e2e:	7ba2                	ld	s7,40(sp)
    80003e30:	7c02                	ld	s8,32(sp)
    80003e32:	6ce2                	ld	s9,24(sp)
    80003e34:	6d42                	ld	s10,16(sp)
    80003e36:	6da2                	ld	s11,8(sp)
    80003e38:	6165                	addi	sp,sp,112
    80003e3a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e3c:	89da                	mv	s3,s6
    80003e3e:	bfc9                	j	80003e10 <writei+0xe2>
    return -1;
    80003e40:	557d                	li	a0,-1
}
    80003e42:	8082                	ret
    return -1;
    80003e44:	557d                	li	a0,-1
    80003e46:	bfe1                	j	80003e1e <writei+0xf0>
    return -1;
    80003e48:	557d                	li	a0,-1
    80003e4a:	bfd1                	j	80003e1e <writei+0xf0>

0000000080003e4c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003e4c:	1141                	addi	sp,sp,-16
    80003e4e:	e406                	sd	ra,8(sp)
    80003e50:	e022                	sd	s0,0(sp)
    80003e52:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003e54:	4639                	li	a2,14
    80003e56:	ffffd097          	auipc	ra,0xffffd
    80003e5a:	f4c080e7          	jalr	-180(ra) # 80000da2 <strncmp>
}
    80003e5e:	60a2                	ld	ra,8(sp)
    80003e60:	6402                	ld	s0,0(sp)
    80003e62:	0141                	addi	sp,sp,16
    80003e64:	8082                	ret

0000000080003e66 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003e66:	7139                	addi	sp,sp,-64
    80003e68:	fc06                	sd	ra,56(sp)
    80003e6a:	f822                	sd	s0,48(sp)
    80003e6c:	f426                	sd	s1,40(sp)
    80003e6e:	f04a                	sd	s2,32(sp)
    80003e70:	ec4e                	sd	s3,24(sp)
    80003e72:	e852                	sd	s4,16(sp)
    80003e74:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003e76:	04451703          	lh	a4,68(a0)
    80003e7a:	4785                	li	a5,1
    80003e7c:	00f71a63          	bne	a4,a5,80003e90 <dirlookup+0x2a>
    80003e80:	892a                	mv	s2,a0
    80003e82:	89ae                	mv	s3,a1
    80003e84:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e86:	457c                	lw	a5,76(a0)
    80003e88:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003e8a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e8c:	e79d                	bnez	a5,80003eba <dirlookup+0x54>
    80003e8e:	a8a5                	j	80003f06 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003e90:	00004517          	auipc	a0,0x4
    80003e94:	77050513          	addi	a0,a0,1904 # 80008600 <syscalls+0x1b0>
    80003e98:	ffffc097          	auipc	ra,0xffffc
    80003e9c:	6a6080e7          	jalr	1702(ra) # 8000053e <panic>
      panic("dirlookup read");
    80003ea0:	00004517          	auipc	a0,0x4
    80003ea4:	77850513          	addi	a0,a0,1912 # 80008618 <syscalls+0x1c8>
    80003ea8:	ffffc097          	auipc	ra,0xffffc
    80003eac:	696080e7          	jalr	1686(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003eb0:	24c1                	addiw	s1,s1,16
    80003eb2:	04c92783          	lw	a5,76(s2)
    80003eb6:	04f4f763          	bgeu	s1,a5,80003f04 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003eba:	4741                	li	a4,16
    80003ebc:	86a6                	mv	a3,s1
    80003ebe:	fc040613          	addi	a2,s0,-64
    80003ec2:	4581                	li	a1,0
    80003ec4:	854a                	mv	a0,s2
    80003ec6:	00000097          	auipc	ra,0x0
    80003eca:	d70080e7          	jalr	-656(ra) # 80003c36 <readi>
    80003ece:	47c1                	li	a5,16
    80003ed0:	fcf518e3          	bne	a0,a5,80003ea0 <dirlookup+0x3a>
    if(de.inum == 0)
    80003ed4:	fc045783          	lhu	a5,-64(s0)
    80003ed8:	dfe1                	beqz	a5,80003eb0 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003eda:	fc240593          	addi	a1,s0,-62
    80003ede:	854e                	mv	a0,s3
    80003ee0:	00000097          	auipc	ra,0x0
    80003ee4:	f6c080e7          	jalr	-148(ra) # 80003e4c <namecmp>
    80003ee8:	f561                	bnez	a0,80003eb0 <dirlookup+0x4a>
      if(poff)
    80003eea:	000a0463          	beqz	s4,80003ef2 <dirlookup+0x8c>
        *poff = off;
    80003eee:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003ef2:	fc045583          	lhu	a1,-64(s0)
    80003ef6:	00092503          	lw	a0,0(s2)
    80003efa:	fffff097          	auipc	ra,0xfffff
    80003efe:	750080e7          	jalr	1872(ra) # 8000364a <iget>
    80003f02:	a011                	j	80003f06 <dirlookup+0xa0>
  return 0;
    80003f04:	4501                	li	a0,0
}
    80003f06:	70e2                	ld	ra,56(sp)
    80003f08:	7442                	ld	s0,48(sp)
    80003f0a:	74a2                	ld	s1,40(sp)
    80003f0c:	7902                	ld	s2,32(sp)
    80003f0e:	69e2                	ld	s3,24(sp)
    80003f10:	6a42                	ld	s4,16(sp)
    80003f12:	6121                	addi	sp,sp,64
    80003f14:	8082                	ret

0000000080003f16 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003f16:	711d                	addi	sp,sp,-96
    80003f18:	ec86                	sd	ra,88(sp)
    80003f1a:	e8a2                	sd	s0,80(sp)
    80003f1c:	e4a6                	sd	s1,72(sp)
    80003f1e:	e0ca                	sd	s2,64(sp)
    80003f20:	fc4e                	sd	s3,56(sp)
    80003f22:	f852                	sd	s4,48(sp)
    80003f24:	f456                	sd	s5,40(sp)
    80003f26:	f05a                	sd	s6,32(sp)
    80003f28:	ec5e                	sd	s7,24(sp)
    80003f2a:	e862                	sd	s8,16(sp)
    80003f2c:	e466                	sd	s9,8(sp)
    80003f2e:	1080                	addi	s0,sp,96
    80003f30:	84aa                	mv	s1,a0
    80003f32:	8aae                	mv	s5,a1
    80003f34:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003f36:	00054703          	lbu	a4,0(a0)
    80003f3a:	02f00793          	li	a5,47
    80003f3e:	02f70363          	beq	a4,a5,80003f64 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003f42:	ffffe097          	auipc	ra,0xffffe
    80003f46:	a6a080e7          	jalr	-1430(ra) # 800019ac <myproc>
    80003f4a:	15053503          	ld	a0,336(a0)
    80003f4e:	00000097          	auipc	ra,0x0
    80003f52:	9f6080e7          	jalr	-1546(ra) # 80003944 <idup>
    80003f56:	89aa                	mv	s3,a0
  while(*path == '/')
    80003f58:	02f00913          	li	s2,47
  len = path - s;
    80003f5c:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003f5e:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003f60:	4b85                	li	s7,1
    80003f62:	a865                	j	8000401a <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003f64:	4585                	li	a1,1
    80003f66:	4505                	li	a0,1
    80003f68:	fffff097          	auipc	ra,0xfffff
    80003f6c:	6e2080e7          	jalr	1762(ra) # 8000364a <iget>
    80003f70:	89aa                	mv	s3,a0
    80003f72:	b7dd                	j	80003f58 <namex+0x42>
      iunlockput(ip);
    80003f74:	854e                	mv	a0,s3
    80003f76:	00000097          	auipc	ra,0x0
    80003f7a:	c6e080e7          	jalr	-914(ra) # 80003be4 <iunlockput>
      return 0;
    80003f7e:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003f80:	854e                	mv	a0,s3
    80003f82:	60e6                	ld	ra,88(sp)
    80003f84:	6446                	ld	s0,80(sp)
    80003f86:	64a6                	ld	s1,72(sp)
    80003f88:	6906                	ld	s2,64(sp)
    80003f8a:	79e2                	ld	s3,56(sp)
    80003f8c:	7a42                	ld	s4,48(sp)
    80003f8e:	7aa2                	ld	s5,40(sp)
    80003f90:	7b02                	ld	s6,32(sp)
    80003f92:	6be2                	ld	s7,24(sp)
    80003f94:	6c42                	ld	s8,16(sp)
    80003f96:	6ca2                	ld	s9,8(sp)
    80003f98:	6125                	addi	sp,sp,96
    80003f9a:	8082                	ret
      iunlock(ip);
    80003f9c:	854e                	mv	a0,s3
    80003f9e:	00000097          	auipc	ra,0x0
    80003fa2:	aa6080e7          	jalr	-1370(ra) # 80003a44 <iunlock>
      return ip;
    80003fa6:	bfe9                	j	80003f80 <namex+0x6a>
      iunlockput(ip);
    80003fa8:	854e                	mv	a0,s3
    80003faa:	00000097          	auipc	ra,0x0
    80003fae:	c3a080e7          	jalr	-966(ra) # 80003be4 <iunlockput>
      return 0;
    80003fb2:	89e6                	mv	s3,s9
    80003fb4:	b7f1                	j	80003f80 <namex+0x6a>
  len = path - s;
    80003fb6:	40b48633          	sub	a2,s1,a1
    80003fba:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003fbe:	099c5463          	bge	s8,s9,80004046 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003fc2:	4639                	li	a2,14
    80003fc4:	8552                	mv	a0,s4
    80003fc6:	ffffd097          	auipc	ra,0xffffd
    80003fca:	d68080e7          	jalr	-664(ra) # 80000d2e <memmove>
  while(*path == '/')
    80003fce:	0004c783          	lbu	a5,0(s1)
    80003fd2:	01279763          	bne	a5,s2,80003fe0 <namex+0xca>
    path++;
    80003fd6:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003fd8:	0004c783          	lbu	a5,0(s1)
    80003fdc:	ff278de3          	beq	a5,s2,80003fd6 <namex+0xc0>
    ilock(ip);
    80003fe0:	854e                	mv	a0,s3
    80003fe2:	00000097          	auipc	ra,0x0
    80003fe6:	9a0080e7          	jalr	-1632(ra) # 80003982 <ilock>
    if(ip->type != T_DIR){
    80003fea:	04499783          	lh	a5,68(s3)
    80003fee:	f97793e3          	bne	a5,s7,80003f74 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003ff2:	000a8563          	beqz	s5,80003ffc <namex+0xe6>
    80003ff6:	0004c783          	lbu	a5,0(s1)
    80003ffa:	d3cd                	beqz	a5,80003f9c <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003ffc:	865a                	mv	a2,s6
    80003ffe:	85d2                	mv	a1,s4
    80004000:	854e                	mv	a0,s3
    80004002:	00000097          	auipc	ra,0x0
    80004006:	e64080e7          	jalr	-412(ra) # 80003e66 <dirlookup>
    8000400a:	8caa                	mv	s9,a0
    8000400c:	dd51                	beqz	a0,80003fa8 <namex+0x92>
    iunlockput(ip);
    8000400e:	854e                	mv	a0,s3
    80004010:	00000097          	auipc	ra,0x0
    80004014:	bd4080e7          	jalr	-1068(ra) # 80003be4 <iunlockput>
    ip = next;
    80004018:	89e6                	mv	s3,s9
  while(*path == '/')
    8000401a:	0004c783          	lbu	a5,0(s1)
    8000401e:	05279763          	bne	a5,s2,8000406c <namex+0x156>
    path++;
    80004022:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004024:	0004c783          	lbu	a5,0(s1)
    80004028:	ff278de3          	beq	a5,s2,80004022 <namex+0x10c>
  if(*path == 0)
    8000402c:	c79d                	beqz	a5,8000405a <namex+0x144>
    path++;
    8000402e:	85a6                	mv	a1,s1
  len = path - s;
    80004030:	8cda                	mv	s9,s6
    80004032:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004034:	01278963          	beq	a5,s2,80004046 <namex+0x130>
    80004038:	dfbd                	beqz	a5,80003fb6 <namex+0xa0>
    path++;
    8000403a:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    8000403c:	0004c783          	lbu	a5,0(s1)
    80004040:	ff279ce3          	bne	a5,s2,80004038 <namex+0x122>
    80004044:	bf8d                	j	80003fb6 <namex+0xa0>
    memmove(name, s, len);
    80004046:	2601                	sext.w	a2,a2
    80004048:	8552                	mv	a0,s4
    8000404a:	ffffd097          	auipc	ra,0xffffd
    8000404e:	ce4080e7          	jalr	-796(ra) # 80000d2e <memmove>
    name[len] = 0;
    80004052:	9cd2                	add	s9,s9,s4
    80004054:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004058:	bf9d                	j	80003fce <namex+0xb8>
  if(nameiparent){
    8000405a:	f20a83e3          	beqz	s5,80003f80 <namex+0x6a>
    iput(ip);
    8000405e:	854e                	mv	a0,s3
    80004060:	00000097          	auipc	ra,0x0
    80004064:	adc080e7          	jalr	-1316(ra) # 80003b3c <iput>
    return 0;
    80004068:	4981                	li	s3,0
    8000406a:	bf19                	j	80003f80 <namex+0x6a>
  if(*path == 0)
    8000406c:	d7fd                	beqz	a5,8000405a <namex+0x144>
  while(*path != '/' && *path != 0)
    8000406e:	0004c783          	lbu	a5,0(s1)
    80004072:	85a6                	mv	a1,s1
    80004074:	b7d1                	j	80004038 <namex+0x122>

0000000080004076 <dirlink>:
{
    80004076:	7139                	addi	sp,sp,-64
    80004078:	fc06                	sd	ra,56(sp)
    8000407a:	f822                	sd	s0,48(sp)
    8000407c:	f426                	sd	s1,40(sp)
    8000407e:	f04a                	sd	s2,32(sp)
    80004080:	ec4e                	sd	s3,24(sp)
    80004082:	e852                	sd	s4,16(sp)
    80004084:	0080                	addi	s0,sp,64
    80004086:	892a                	mv	s2,a0
    80004088:	8a2e                	mv	s4,a1
    8000408a:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000408c:	4601                	li	a2,0
    8000408e:	00000097          	auipc	ra,0x0
    80004092:	dd8080e7          	jalr	-552(ra) # 80003e66 <dirlookup>
    80004096:	e93d                	bnez	a0,8000410c <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004098:	04c92483          	lw	s1,76(s2)
    8000409c:	c49d                	beqz	s1,800040ca <dirlink+0x54>
    8000409e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040a0:	4741                	li	a4,16
    800040a2:	86a6                	mv	a3,s1
    800040a4:	fc040613          	addi	a2,s0,-64
    800040a8:	4581                	li	a1,0
    800040aa:	854a                	mv	a0,s2
    800040ac:	00000097          	auipc	ra,0x0
    800040b0:	b8a080e7          	jalr	-1142(ra) # 80003c36 <readi>
    800040b4:	47c1                	li	a5,16
    800040b6:	06f51163          	bne	a0,a5,80004118 <dirlink+0xa2>
    if(de.inum == 0)
    800040ba:	fc045783          	lhu	a5,-64(s0)
    800040be:	c791                	beqz	a5,800040ca <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040c0:	24c1                	addiw	s1,s1,16
    800040c2:	04c92783          	lw	a5,76(s2)
    800040c6:	fcf4ede3          	bltu	s1,a5,800040a0 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800040ca:	4639                	li	a2,14
    800040cc:	85d2                	mv	a1,s4
    800040ce:	fc240513          	addi	a0,s0,-62
    800040d2:	ffffd097          	auipc	ra,0xffffd
    800040d6:	d0c080e7          	jalr	-756(ra) # 80000dde <strncpy>
  de.inum = inum;
    800040da:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040de:	4741                	li	a4,16
    800040e0:	86a6                	mv	a3,s1
    800040e2:	fc040613          	addi	a2,s0,-64
    800040e6:	4581                	li	a1,0
    800040e8:	854a                	mv	a0,s2
    800040ea:	00000097          	auipc	ra,0x0
    800040ee:	c44080e7          	jalr	-956(ra) # 80003d2e <writei>
    800040f2:	1541                	addi	a0,a0,-16
    800040f4:	00a03533          	snez	a0,a0
    800040f8:	40a00533          	neg	a0,a0
}
    800040fc:	70e2                	ld	ra,56(sp)
    800040fe:	7442                	ld	s0,48(sp)
    80004100:	74a2                	ld	s1,40(sp)
    80004102:	7902                	ld	s2,32(sp)
    80004104:	69e2                	ld	s3,24(sp)
    80004106:	6a42                	ld	s4,16(sp)
    80004108:	6121                	addi	sp,sp,64
    8000410a:	8082                	ret
    iput(ip);
    8000410c:	00000097          	auipc	ra,0x0
    80004110:	a30080e7          	jalr	-1488(ra) # 80003b3c <iput>
    return -1;
    80004114:	557d                	li	a0,-1
    80004116:	b7dd                	j	800040fc <dirlink+0x86>
      panic("dirlink read");
    80004118:	00004517          	auipc	a0,0x4
    8000411c:	51050513          	addi	a0,a0,1296 # 80008628 <syscalls+0x1d8>
    80004120:	ffffc097          	auipc	ra,0xffffc
    80004124:	41e080e7          	jalr	1054(ra) # 8000053e <panic>

0000000080004128 <namei>:

struct inode*
namei(char *path)
{
    80004128:	1101                	addi	sp,sp,-32
    8000412a:	ec06                	sd	ra,24(sp)
    8000412c:	e822                	sd	s0,16(sp)
    8000412e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004130:	fe040613          	addi	a2,s0,-32
    80004134:	4581                	li	a1,0
    80004136:	00000097          	auipc	ra,0x0
    8000413a:	de0080e7          	jalr	-544(ra) # 80003f16 <namex>
}
    8000413e:	60e2                	ld	ra,24(sp)
    80004140:	6442                	ld	s0,16(sp)
    80004142:	6105                	addi	sp,sp,32
    80004144:	8082                	ret

0000000080004146 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004146:	1141                	addi	sp,sp,-16
    80004148:	e406                	sd	ra,8(sp)
    8000414a:	e022                	sd	s0,0(sp)
    8000414c:	0800                	addi	s0,sp,16
    8000414e:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004150:	4585                	li	a1,1
    80004152:	00000097          	auipc	ra,0x0
    80004156:	dc4080e7          	jalr	-572(ra) # 80003f16 <namex>
}
    8000415a:	60a2                	ld	ra,8(sp)
    8000415c:	6402                	ld	s0,0(sp)
    8000415e:	0141                	addi	sp,sp,16
    80004160:	8082                	ret

0000000080004162 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004162:	1101                	addi	sp,sp,-32
    80004164:	ec06                	sd	ra,24(sp)
    80004166:	e822                	sd	s0,16(sp)
    80004168:	e426                	sd	s1,8(sp)
    8000416a:	e04a                	sd	s2,0(sp)
    8000416c:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000416e:	0001f917          	auipc	s2,0x1f
    80004172:	ba290913          	addi	s2,s2,-1118 # 80022d10 <log>
    80004176:	01892583          	lw	a1,24(s2)
    8000417a:	02892503          	lw	a0,40(s2)
    8000417e:	fffff097          	auipc	ra,0xfffff
    80004182:	fea080e7          	jalr	-22(ra) # 80003168 <bread>
    80004186:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004188:	02c92683          	lw	a3,44(s2)
    8000418c:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000418e:	02d05763          	blez	a3,800041bc <write_head+0x5a>
    80004192:	0001f797          	auipc	a5,0x1f
    80004196:	bae78793          	addi	a5,a5,-1106 # 80022d40 <log+0x30>
    8000419a:	05c50713          	addi	a4,a0,92
    8000419e:	36fd                	addiw	a3,a3,-1
    800041a0:	1682                	slli	a3,a3,0x20
    800041a2:	9281                	srli	a3,a3,0x20
    800041a4:	068a                	slli	a3,a3,0x2
    800041a6:	0001f617          	auipc	a2,0x1f
    800041aa:	b9e60613          	addi	a2,a2,-1122 # 80022d44 <log+0x34>
    800041ae:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800041b0:	4390                	lw	a2,0(a5)
    800041b2:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800041b4:	0791                	addi	a5,a5,4
    800041b6:	0711                	addi	a4,a4,4
    800041b8:	fed79ce3          	bne	a5,a3,800041b0 <write_head+0x4e>
  }
  bwrite(buf);
    800041bc:	8526                	mv	a0,s1
    800041be:	fffff097          	auipc	ra,0xfffff
    800041c2:	09c080e7          	jalr	156(ra) # 8000325a <bwrite>
  brelse(buf);
    800041c6:	8526                	mv	a0,s1
    800041c8:	fffff097          	auipc	ra,0xfffff
    800041cc:	0d0080e7          	jalr	208(ra) # 80003298 <brelse>
}
    800041d0:	60e2                	ld	ra,24(sp)
    800041d2:	6442                	ld	s0,16(sp)
    800041d4:	64a2                	ld	s1,8(sp)
    800041d6:	6902                	ld	s2,0(sp)
    800041d8:	6105                	addi	sp,sp,32
    800041da:	8082                	ret

00000000800041dc <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800041dc:	0001f797          	auipc	a5,0x1f
    800041e0:	b607a783          	lw	a5,-1184(a5) # 80022d3c <log+0x2c>
    800041e4:	0af05d63          	blez	a5,8000429e <install_trans+0xc2>
{
    800041e8:	7139                	addi	sp,sp,-64
    800041ea:	fc06                	sd	ra,56(sp)
    800041ec:	f822                	sd	s0,48(sp)
    800041ee:	f426                	sd	s1,40(sp)
    800041f0:	f04a                	sd	s2,32(sp)
    800041f2:	ec4e                	sd	s3,24(sp)
    800041f4:	e852                	sd	s4,16(sp)
    800041f6:	e456                	sd	s5,8(sp)
    800041f8:	e05a                	sd	s6,0(sp)
    800041fa:	0080                	addi	s0,sp,64
    800041fc:	8b2a                	mv	s6,a0
    800041fe:	0001fa97          	auipc	s5,0x1f
    80004202:	b42a8a93          	addi	s5,s5,-1214 # 80022d40 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004206:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004208:	0001f997          	auipc	s3,0x1f
    8000420c:	b0898993          	addi	s3,s3,-1272 # 80022d10 <log>
    80004210:	a00d                	j	80004232 <install_trans+0x56>
    brelse(lbuf);
    80004212:	854a                	mv	a0,s2
    80004214:	fffff097          	auipc	ra,0xfffff
    80004218:	084080e7          	jalr	132(ra) # 80003298 <brelse>
    brelse(dbuf);
    8000421c:	8526                	mv	a0,s1
    8000421e:	fffff097          	auipc	ra,0xfffff
    80004222:	07a080e7          	jalr	122(ra) # 80003298 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004226:	2a05                	addiw	s4,s4,1
    80004228:	0a91                	addi	s5,s5,4
    8000422a:	02c9a783          	lw	a5,44(s3)
    8000422e:	04fa5e63          	bge	s4,a5,8000428a <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004232:	0189a583          	lw	a1,24(s3)
    80004236:	014585bb          	addw	a1,a1,s4
    8000423a:	2585                	addiw	a1,a1,1
    8000423c:	0289a503          	lw	a0,40(s3)
    80004240:	fffff097          	auipc	ra,0xfffff
    80004244:	f28080e7          	jalr	-216(ra) # 80003168 <bread>
    80004248:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000424a:	000aa583          	lw	a1,0(s5)
    8000424e:	0289a503          	lw	a0,40(s3)
    80004252:	fffff097          	auipc	ra,0xfffff
    80004256:	f16080e7          	jalr	-234(ra) # 80003168 <bread>
    8000425a:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000425c:	40000613          	li	a2,1024
    80004260:	05890593          	addi	a1,s2,88
    80004264:	05850513          	addi	a0,a0,88
    80004268:	ffffd097          	auipc	ra,0xffffd
    8000426c:	ac6080e7          	jalr	-1338(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    80004270:	8526                	mv	a0,s1
    80004272:	fffff097          	auipc	ra,0xfffff
    80004276:	fe8080e7          	jalr	-24(ra) # 8000325a <bwrite>
    if(recovering == 0)
    8000427a:	f80b1ce3          	bnez	s6,80004212 <install_trans+0x36>
      bunpin(dbuf);
    8000427e:	8526                	mv	a0,s1
    80004280:	fffff097          	auipc	ra,0xfffff
    80004284:	0f2080e7          	jalr	242(ra) # 80003372 <bunpin>
    80004288:	b769                	j	80004212 <install_trans+0x36>
}
    8000428a:	70e2                	ld	ra,56(sp)
    8000428c:	7442                	ld	s0,48(sp)
    8000428e:	74a2                	ld	s1,40(sp)
    80004290:	7902                	ld	s2,32(sp)
    80004292:	69e2                	ld	s3,24(sp)
    80004294:	6a42                	ld	s4,16(sp)
    80004296:	6aa2                	ld	s5,8(sp)
    80004298:	6b02                	ld	s6,0(sp)
    8000429a:	6121                	addi	sp,sp,64
    8000429c:	8082                	ret
    8000429e:	8082                	ret

00000000800042a0 <initlog>:
{
    800042a0:	7179                	addi	sp,sp,-48
    800042a2:	f406                	sd	ra,40(sp)
    800042a4:	f022                	sd	s0,32(sp)
    800042a6:	ec26                	sd	s1,24(sp)
    800042a8:	e84a                	sd	s2,16(sp)
    800042aa:	e44e                	sd	s3,8(sp)
    800042ac:	1800                	addi	s0,sp,48
    800042ae:	892a                	mv	s2,a0
    800042b0:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800042b2:	0001f497          	auipc	s1,0x1f
    800042b6:	a5e48493          	addi	s1,s1,-1442 # 80022d10 <log>
    800042ba:	00004597          	auipc	a1,0x4
    800042be:	37e58593          	addi	a1,a1,894 # 80008638 <syscalls+0x1e8>
    800042c2:	8526                	mv	a0,s1
    800042c4:	ffffd097          	auipc	ra,0xffffd
    800042c8:	882080e7          	jalr	-1918(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    800042cc:	0149a583          	lw	a1,20(s3)
    800042d0:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800042d2:	0109a783          	lw	a5,16(s3)
    800042d6:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800042d8:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800042dc:	854a                	mv	a0,s2
    800042de:	fffff097          	auipc	ra,0xfffff
    800042e2:	e8a080e7          	jalr	-374(ra) # 80003168 <bread>
  log.lh.n = lh->n;
    800042e6:	4d34                	lw	a3,88(a0)
    800042e8:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800042ea:	02d05563          	blez	a3,80004314 <initlog+0x74>
    800042ee:	05c50793          	addi	a5,a0,92
    800042f2:	0001f717          	auipc	a4,0x1f
    800042f6:	a4e70713          	addi	a4,a4,-1458 # 80022d40 <log+0x30>
    800042fa:	36fd                	addiw	a3,a3,-1
    800042fc:	1682                	slli	a3,a3,0x20
    800042fe:	9281                	srli	a3,a3,0x20
    80004300:	068a                	slli	a3,a3,0x2
    80004302:	06050613          	addi	a2,a0,96
    80004306:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004308:	4390                	lw	a2,0(a5)
    8000430a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000430c:	0791                	addi	a5,a5,4
    8000430e:	0711                	addi	a4,a4,4
    80004310:	fed79ce3          	bne	a5,a3,80004308 <initlog+0x68>
  brelse(buf);
    80004314:	fffff097          	auipc	ra,0xfffff
    80004318:	f84080e7          	jalr	-124(ra) # 80003298 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000431c:	4505                	li	a0,1
    8000431e:	00000097          	auipc	ra,0x0
    80004322:	ebe080e7          	jalr	-322(ra) # 800041dc <install_trans>
  log.lh.n = 0;
    80004326:	0001f797          	auipc	a5,0x1f
    8000432a:	a007ab23          	sw	zero,-1514(a5) # 80022d3c <log+0x2c>
  write_head(); // clear the log
    8000432e:	00000097          	auipc	ra,0x0
    80004332:	e34080e7          	jalr	-460(ra) # 80004162 <write_head>
}
    80004336:	70a2                	ld	ra,40(sp)
    80004338:	7402                	ld	s0,32(sp)
    8000433a:	64e2                	ld	s1,24(sp)
    8000433c:	6942                	ld	s2,16(sp)
    8000433e:	69a2                	ld	s3,8(sp)
    80004340:	6145                	addi	sp,sp,48
    80004342:	8082                	ret

0000000080004344 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004344:	1101                	addi	sp,sp,-32
    80004346:	ec06                	sd	ra,24(sp)
    80004348:	e822                	sd	s0,16(sp)
    8000434a:	e426                	sd	s1,8(sp)
    8000434c:	e04a                	sd	s2,0(sp)
    8000434e:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004350:	0001f517          	auipc	a0,0x1f
    80004354:	9c050513          	addi	a0,a0,-1600 # 80022d10 <log>
    80004358:	ffffd097          	auipc	ra,0xffffd
    8000435c:	87e080e7          	jalr	-1922(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    80004360:	0001f497          	auipc	s1,0x1f
    80004364:	9b048493          	addi	s1,s1,-1616 # 80022d10 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004368:	4979                	li	s2,30
    8000436a:	a039                	j	80004378 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000436c:	85a6                	mv	a1,s1
    8000436e:	8526                	mv	a0,s1
    80004370:	ffffe097          	auipc	ra,0xffffe
    80004374:	cf8080e7          	jalr	-776(ra) # 80002068 <sleep>
    if(log.committing){
    80004378:	50dc                	lw	a5,36(s1)
    8000437a:	fbed                	bnez	a5,8000436c <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000437c:	509c                	lw	a5,32(s1)
    8000437e:	0017871b          	addiw	a4,a5,1
    80004382:	0007069b          	sext.w	a3,a4
    80004386:	0027179b          	slliw	a5,a4,0x2
    8000438a:	9fb9                	addw	a5,a5,a4
    8000438c:	0017979b          	slliw	a5,a5,0x1
    80004390:	54d8                	lw	a4,44(s1)
    80004392:	9fb9                	addw	a5,a5,a4
    80004394:	00f95963          	bge	s2,a5,800043a6 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004398:	85a6                	mv	a1,s1
    8000439a:	8526                	mv	a0,s1
    8000439c:	ffffe097          	auipc	ra,0xffffe
    800043a0:	ccc080e7          	jalr	-820(ra) # 80002068 <sleep>
    800043a4:	bfd1                	j	80004378 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800043a6:	0001f517          	auipc	a0,0x1f
    800043aa:	96a50513          	addi	a0,a0,-1686 # 80022d10 <log>
    800043ae:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800043b0:	ffffd097          	auipc	ra,0xffffd
    800043b4:	8da080e7          	jalr	-1830(ra) # 80000c8a <release>
      break;
    }
  }
}
    800043b8:	60e2                	ld	ra,24(sp)
    800043ba:	6442                	ld	s0,16(sp)
    800043bc:	64a2                	ld	s1,8(sp)
    800043be:	6902                	ld	s2,0(sp)
    800043c0:	6105                	addi	sp,sp,32
    800043c2:	8082                	ret

00000000800043c4 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800043c4:	7139                	addi	sp,sp,-64
    800043c6:	fc06                	sd	ra,56(sp)
    800043c8:	f822                	sd	s0,48(sp)
    800043ca:	f426                	sd	s1,40(sp)
    800043cc:	f04a                	sd	s2,32(sp)
    800043ce:	ec4e                	sd	s3,24(sp)
    800043d0:	e852                	sd	s4,16(sp)
    800043d2:	e456                	sd	s5,8(sp)
    800043d4:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800043d6:	0001f497          	auipc	s1,0x1f
    800043da:	93a48493          	addi	s1,s1,-1734 # 80022d10 <log>
    800043de:	8526                	mv	a0,s1
    800043e0:	ffffc097          	auipc	ra,0xffffc
    800043e4:	7f6080e7          	jalr	2038(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    800043e8:	509c                	lw	a5,32(s1)
    800043ea:	37fd                	addiw	a5,a5,-1
    800043ec:	0007891b          	sext.w	s2,a5
    800043f0:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800043f2:	50dc                	lw	a5,36(s1)
    800043f4:	e7b9                	bnez	a5,80004442 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800043f6:	04091e63          	bnez	s2,80004452 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800043fa:	0001f497          	auipc	s1,0x1f
    800043fe:	91648493          	addi	s1,s1,-1770 # 80022d10 <log>
    80004402:	4785                	li	a5,1
    80004404:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004406:	8526                	mv	a0,s1
    80004408:	ffffd097          	auipc	ra,0xffffd
    8000440c:	882080e7          	jalr	-1918(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004410:	54dc                	lw	a5,44(s1)
    80004412:	06f04763          	bgtz	a5,80004480 <end_op+0xbc>
    acquire(&log.lock);
    80004416:	0001f497          	auipc	s1,0x1f
    8000441a:	8fa48493          	addi	s1,s1,-1798 # 80022d10 <log>
    8000441e:	8526                	mv	a0,s1
    80004420:	ffffc097          	auipc	ra,0xffffc
    80004424:	7b6080e7          	jalr	1974(ra) # 80000bd6 <acquire>
    log.committing = 0;
    80004428:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000442c:	8526                	mv	a0,s1
    8000442e:	ffffe097          	auipc	ra,0xffffe
    80004432:	c9e080e7          	jalr	-866(ra) # 800020cc <wakeup>
    release(&log.lock);
    80004436:	8526                	mv	a0,s1
    80004438:	ffffd097          	auipc	ra,0xffffd
    8000443c:	852080e7          	jalr	-1966(ra) # 80000c8a <release>
}
    80004440:	a03d                	j	8000446e <end_op+0xaa>
    panic("log.committing");
    80004442:	00004517          	auipc	a0,0x4
    80004446:	1fe50513          	addi	a0,a0,510 # 80008640 <syscalls+0x1f0>
    8000444a:	ffffc097          	auipc	ra,0xffffc
    8000444e:	0f4080e7          	jalr	244(ra) # 8000053e <panic>
    wakeup(&log);
    80004452:	0001f497          	auipc	s1,0x1f
    80004456:	8be48493          	addi	s1,s1,-1858 # 80022d10 <log>
    8000445a:	8526                	mv	a0,s1
    8000445c:	ffffe097          	auipc	ra,0xffffe
    80004460:	c70080e7          	jalr	-912(ra) # 800020cc <wakeup>
  release(&log.lock);
    80004464:	8526                	mv	a0,s1
    80004466:	ffffd097          	auipc	ra,0xffffd
    8000446a:	824080e7          	jalr	-2012(ra) # 80000c8a <release>
}
    8000446e:	70e2                	ld	ra,56(sp)
    80004470:	7442                	ld	s0,48(sp)
    80004472:	74a2                	ld	s1,40(sp)
    80004474:	7902                	ld	s2,32(sp)
    80004476:	69e2                	ld	s3,24(sp)
    80004478:	6a42                	ld	s4,16(sp)
    8000447a:	6aa2                	ld	s5,8(sp)
    8000447c:	6121                	addi	sp,sp,64
    8000447e:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004480:	0001fa97          	auipc	s5,0x1f
    80004484:	8c0a8a93          	addi	s5,s5,-1856 # 80022d40 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004488:	0001fa17          	auipc	s4,0x1f
    8000448c:	888a0a13          	addi	s4,s4,-1912 # 80022d10 <log>
    80004490:	018a2583          	lw	a1,24(s4)
    80004494:	012585bb          	addw	a1,a1,s2
    80004498:	2585                	addiw	a1,a1,1
    8000449a:	028a2503          	lw	a0,40(s4)
    8000449e:	fffff097          	auipc	ra,0xfffff
    800044a2:	cca080e7          	jalr	-822(ra) # 80003168 <bread>
    800044a6:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800044a8:	000aa583          	lw	a1,0(s5)
    800044ac:	028a2503          	lw	a0,40(s4)
    800044b0:	fffff097          	auipc	ra,0xfffff
    800044b4:	cb8080e7          	jalr	-840(ra) # 80003168 <bread>
    800044b8:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800044ba:	40000613          	li	a2,1024
    800044be:	05850593          	addi	a1,a0,88
    800044c2:	05848513          	addi	a0,s1,88
    800044c6:	ffffd097          	auipc	ra,0xffffd
    800044ca:	868080e7          	jalr	-1944(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    800044ce:	8526                	mv	a0,s1
    800044d0:	fffff097          	auipc	ra,0xfffff
    800044d4:	d8a080e7          	jalr	-630(ra) # 8000325a <bwrite>
    brelse(from);
    800044d8:	854e                	mv	a0,s3
    800044da:	fffff097          	auipc	ra,0xfffff
    800044de:	dbe080e7          	jalr	-578(ra) # 80003298 <brelse>
    brelse(to);
    800044e2:	8526                	mv	a0,s1
    800044e4:	fffff097          	auipc	ra,0xfffff
    800044e8:	db4080e7          	jalr	-588(ra) # 80003298 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800044ec:	2905                	addiw	s2,s2,1
    800044ee:	0a91                	addi	s5,s5,4
    800044f0:	02ca2783          	lw	a5,44(s4)
    800044f4:	f8f94ee3          	blt	s2,a5,80004490 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800044f8:	00000097          	auipc	ra,0x0
    800044fc:	c6a080e7          	jalr	-918(ra) # 80004162 <write_head>
    install_trans(0); // Now install writes to home locations
    80004500:	4501                	li	a0,0
    80004502:	00000097          	auipc	ra,0x0
    80004506:	cda080e7          	jalr	-806(ra) # 800041dc <install_trans>
    log.lh.n = 0;
    8000450a:	0001f797          	auipc	a5,0x1f
    8000450e:	8207a923          	sw	zero,-1998(a5) # 80022d3c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004512:	00000097          	auipc	ra,0x0
    80004516:	c50080e7          	jalr	-944(ra) # 80004162 <write_head>
    8000451a:	bdf5                	j	80004416 <end_op+0x52>

000000008000451c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000451c:	1101                	addi	sp,sp,-32
    8000451e:	ec06                	sd	ra,24(sp)
    80004520:	e822                	sd	s0,16(sp)
    80004522:	e426                	sd	s1,8(sp)
    80004524:	e04a                	sd	s2,0(sp)
    80004526:	1000                	addi	s0,sp,32
    80004528:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000452a:	0001e917          	auipc	s2,0x1e
    8000452e:	7e690913          	addi	s2,s2,2022 # 80022d10 <log>
    80004532:	854a                	mv	a0,s2
    80004534:	ffffc097          	auipc	ra,0xffffc
    80004538:	6a2080e7          	jalr	1698(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000453c:	02c92603          	lw	a2,44(s2)
    80004540:	47f5                	li	a5,29
    80004542:	06c7c563          	blt	a5,a2,800045ac <log_write+0x90>
    80004546:	0001e797          	auipc	a5,0x1e
    8000454a:	7e67a783          	lw	a5,2022(a5) # 80022d2c <log+0x1c>
    8000454e:	37fd                	addiw	a5,a5,-1
    80004550:	04f65e63          	bge	a2,a5,800045ac <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004554:	0001e797          	auipc	a5,0x1e
    80004558:	7dc7a783          	lw	a5,2012(a5) # 80022d30 <log+0x20>
    8000455c:	06f05063          	blez	a5,800045bc <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004560:	4781                	li	a5,0
    80004562:	06c05563          	blez	a2,800045cc <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004566:	44cc                	lw	a1,12(s1)
    80004568:	0001e717          	auipc	a4,0x1e
    8000456c:	7d870713          	addi	a4,a4,2008 # 80022d40 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004570:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004572:	4314                	lw	a3,0(a4)
    80004574:	04b68c63          	beq	a3,a1,800045cc <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004578:	2785                	addiw	a5,a5,1
    8000457a:	0711                	addi	a4,a4,4
    8000457c:	fef61be3          	bne	a2,a5,80004572 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004580:	0621                	addi	a2,a2,8
    80004582:	060a                	slli	a2,a2,0x2
    80004584:	0001e797          	auipc	a5,0x1e
    80004588:	78c78793          	addi	a5,a5,1932 # 80022d10 <log>
    8000458c:	963e                	add	a2,a2,a5
    8000458e:	44dc                	lw	a5,12(s1)
    80004590:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004592:	8526                	mv	a0,s1
    80004594:	fffff097          	auipc	ra,0xfffff
    80004598:	da2080e7          	jalr	-606(ra) # 80003336 <bpin>
    log.lh.n++;
    8000459c:	0001e717          	auipc	a4,0x1e
    800045a0:	77470713          	addi	a4,a4,1908 # 80022d10 <log>
    800045a4:	575c                	lw	a5,44(a4)
    800045a6:	2785                	addiw	a5,a5,1
    800045a8:	d75c                	sw	a5,44(a4)
    800045aa:	a835                	j	800045e6 <log_write+0xca>
    panic("too big a transaction");
    800045ac:	00004517          	auipc	a0,0x4
    800045b0:	0a450513          	addi	a0,a0,164 # 80008650 <syscalls+0x200>
    800045b4:	ffffc097          	auipc	ra,0xffffc
    800045b8:	f8a080e7          	jalr	-118(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    800045bc:	00004517          	auipc	a0,0x4
    800045c0:	0ac50513          	addi	a0,a0,172 # 80008668 <syscalls+0x218>
    800045c4:	ffffc097          	auipc	ra,0xffffc
    800045c8:	f7a080e7          	jalr	-134(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    800045cc:	00878713          	addi	a4,a5,8
    800045d0:	00271693          	slli	a3,a4,0x2
    800045d4:	0001e717          	auipc	a4,0x1e
    800045d8:	73c70713          	addi	a4,a4,1852 # 80022d10 <log>
    800045dc:	9736                	add	a4,a4,a3
    800045de:	44d4                	lw	a3,12(s1)
    800045e0:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800045e2:	faf608e3          	beq	a2,a5,80004592 <log_write+0x76>
  }
  release(&log.lock);
    800045e6:	0001e517          	auipc	a0,0x1e
    800045ea:	72a50513          	addi	a0,a0,1834 # 80022d10 <log>
    800045ee:	ffffc097          	auipc	ra,0xffffc
    800045f2:	69c080e7          	jalr	1692(ra) # 80000c8a <release>
}
    800045f6:	60e2                	ld	ra,24(sp)
    800045f8:	6442                	ld	s0,16(sp)
    800045fa:	64a2                	ld	s1,8(sp)
    800045fc:	6902                	ld	s2,0(sp)
    800045fe:	6105                	addi	sp,sp,32
    80004600:	8082                	ret

0000000080004602 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004602:	1101                	addi	sp,sp,-32
    80004604:	ec06                	sd	ra,24(sp)
    80004606:	e822                	sd	s0,16(sp)
    80004608:	e426                	sd	s1,8(sp)
    8000460a:	e04a                	sd	s2,0(sp)
    8000460c:	1000                	addi	s0,sp,32
    8000460e:	84aa                	mv	s1,a0
    80004610:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004612:	00004597          	auipc	a1,0x4
    80004616:	07658593          	addi	a1,a1,118 # 80008688 <syscalls+0x238>
    8000461a:	0521                	addi	a0,a0,8
    8000461c:	ffffc097          	auipc	ra,0xffffc
    80004620:	52a080e7          	jalr	1322(ra) # 80000b46 <initlock>
  lk->name = name;
    80004624:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004628:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000462c:	0204a423          	sw	zero,40(s1)
}
    80004630:	60e2                	ld	ra,24(sp)
    80004632:	6442                	ld	s0,16(sp)
    80004634:	64a2                	ld	s1,8(sp)
    80004636:	6902                	ld	s2,0(sp)
    80004638:	6105                	addi	sp,sp,32
    8000463a:	8082                	ret

000000008000463c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000463c:	1101                	addi	sp,sp,-32
    8000463e:	ec06                	sd	ra,24(sp)
    80004640:	e822                	sd	s0,16(sp)
    80004642:	e426                	sd	s1,8(sp)
    80004644:	e04a                	sd	s2,0(sp)
    80004646:	1000                	addi	s0,sp,32
    80004648:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000464a:	00850913          	addi	s2,a0,8
    8000464e:	854a                	mv	a0,s2
    80004650:	ffffc097          	auipc	ra,0xffffc
    80004654:	586080e7          	jalr	1414(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    80004658:	409c                	lw	a5,0(s1)
    8000465a:	cb89                	beqz	a5,8000466c <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000465c:	85ca                	mv	a1,s2
    8000465e:	8526                	mv	a0,s1
    80004660:	ffffe097          	auipc	ra,0xffffe
    80004664:	a08080e7          	jalr	-1528(ra) # 80002068 <sleep>
  while (lk->locked) {
    80004668:	409c                	lw	a5,0(s1)
    8000466a:	fbed                	bnez	a5,8000465c <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000466c:	4785                	li	a5,1
    8000466e:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004670:	ffffd097          	auipc	ra,0xffffd
    80004674:	33c080e7          	jalr	828(ra) # 800019ac <myproc>
    80004678:	591c                	lw	a5,48(a0)
    8000467a:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000467c:	854a                	mv	a0,s2
    8000467e:	ffffc097          	auipc	ra,0xffffc
    80004682:	60c080e7          	jalr	1548(ra) # 80000c8a <release>
}
    80004686:	60e2                	ld	ra,24(sp)
    80004688:	6442                	ld	s0,16(sp)
    8000468a:	64a2                	ld	s1,8(sp)
    8000468c:	6902                	ld	s2,0(sp)
    8000468e:	6105                	addi	sp,sp,32
    80004690:	8082                	ret

0000000080004692 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004692:	1101                	addi	sp,sp,-32
    80004694:	ec06                	sd	ra,24(sp)
    80004696:	e822                	sd	s0,16(sp)
    80004698:	e426                	sd	s1,8(sp)
    8000469a:	e04a                	sd	s2,0(sp)
    8000469c:	1000                	addi	s0,sp,32
    8000469e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800046a0:	00850913          	addi	s2,a0,8
    800046a4:	854a                	mv	a0,s2
    800046a6:	ffffc097          	auipc	ra,0xffffc
    800046aa:	530080e7          	jalr	1328(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    800046ae:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800046b2:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800046b6:	8526                	mv	a0,s1
    800046b8:	ffffe097          	auipc	ra,0xffffe
    800046bc:	a14080e7          	jalr	-1516(ra) # 800020cc <wakeup>
  release(&lk->lk);
    800046c0:	854a                	mv	a0,s2
    800046c2:	ffffc097          	auipc	ra,0xffffc
    800046c6:	5c8080e7          	jalr	1480(ra) # 80000c8a <release>
}
    800046ca:	60e2                	ld	ra,24(sp)
    800046cc:	6442                	ld	s0,16(sp)
    800046ce:	64a2                	ld	s1,8(sp)
    800046d0:	6902                	ld	s2,0(sp)
    800046d2:	6105                	addi	sp,sp,32
    800046d4:	8082                	ret

00000000800046d6 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800046d6:	7179                	addi	sp,sp,-48
    800046d8:	f406                	sd	ra,40(sp)
    800046da:	f022                	sd	s0,32(sp)
    800046dc:	ec26                	sd	s1,24(sp)
    800046de:	e84a                	sd	s2,16(sp)
    800046e0:	e44e                	sd	s3,8(sp)
    800046e2:	1800                	addi	s0,sp,48
    800046e4:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800046e6:	00850913          	addi	s2,a0,8
    800046ea:	854a                	mv	a0,s2
    800046ec:	ffffc097          	auipc	ra,0xffffc
    800046f0:	4ea080e7          	jalr	1258(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800046f4:	409c                	lw	a5,0(s1)
    800046f6:	ef99                	bnez	a5,80004714 <holdingsleep+0x3e>
    800046f8:	4481                	li	s1,0
  release(&lk->lk);
    800046fa:	854a                	mv	a0,s2
    800046fc:	ffffc097          	auipc	ra,0xffffc
    80004700:	58e080e7          	jalr	1422(ra) # 80000c8a <release>
  return r;
}
    80004704:	8526                	mv	a0,s1
    80004706:	70a2                	ld	ra,40(sp)
    80004708:	7402                	ld	s0,32(sp)
    8000470a:	64e2                	ld	s1,24(sp)
    8000470c:	6942                	ld	s2,16(sp)
    8000470e:	69a2                	ld	s3,8(sp)
    80004710:	6145                	addi	sp,sp,48
    80004712:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004714:	0284a983          	lw	s3,40(s1)
    80004718:	ffffd097          	auipc	ra,0xffffd
    8000471c:	294080e7          	jalr	660(ra) # 800019ac <myproc>
    80004720:	5904                	lw	s1,48(a0)
    80004722:	413484b3          	sub	s1,s1,s3
    80004726:	0014b493          	seqz	s1,s1
    8000472a:	bfc1                	j	800046fa <holdingsleep+0x24>

000000008000472c <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000472c:	1141                	addi	sp,sp,-16
    8000472e:	e406                	sd	ra,8(sp)
    80004730:	e022                	sd	s0,0(sp)
    80004732:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004734:	00004597          	auipc	a1,0x4
    80004738:	f6458593          	addi	a1,a1,-156 # 80008698 <syscalls+0x248>
    8000473c:	0001e517          	auipc	a0,0x1e
    80004740:	71c50513          	addi	a0,a0,1820 # 80022e58 <ftable>
    80004744:	ffffc097          	auipc	ra,0xffffc
    80004748:	402080e7          	jalr	1026(ra) # 80000b46 <initlock>
}
    8000474c:	60a2                	ld	ra,8(sp)
    8000474e:	6402                	ld	s0,0(sp)
    80004750:	0141                	addi	sp,sp,16
    80004752:	8082                	ret

0000000080004754 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004754:	1101                	addi	sp,sp,-32
    80004756:	ec06                	sd	ra,24(sp)
    80004758:	e822                	sd	s0,16(sp)
    8000475a:	e426                	sd	s1,8(sp)
    8000475c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000475e:	0001e517          	auipc	a0,0x1e
    80004762:	6fa50513          	addi	a0,a0,1786 # 80022e58 <ftable>
    80004766:	ffffc097          	auipc	ra,0xffffc
    8000476a:	470080e7          	jalr	1136(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000476e:	0001e497          	auipc	s1,0x1e
    80004772:	70248493          	addi	s1,s1,1794 # 80022e70 <ftable+0x18>
    80004776:	0001f717          	auipc	a4,0x1f
    8000477a:	69a70713          	addi	a4,a4,1690 # 80023e10 <disk>
    if(f->ref == 0){
    8000477e:	40dc                	lw	a5,4(s1)
    80004780:	cf99                	beqz	a5,8000479e <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004782:	02848493          	addi	s1,s1,40
    80004786:	fee49ce3          	bne	s1,a4,8000477e <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000478a:	0001e517          	auipc	a0,0x1e
    8000478e:	6ce50513          	addi	a0,a0,1742 # 80022e58 <ftable>
    80004792:	ffffc097          	auipc	ra,0xffffc
    80004796:	4f8080e7          	jalr	1272(ra) # 80000c8a <release>
  return 0;
    8000479a:	4481                	li	s1,0
    8000479c:	a819                	j	800047b2 <filealloc+0x5e>
      f->ref = 1;
    8000479e:	4785                	li	a5,1
    800047a0:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800047a2:	0001e517          	auipc	a0,0x1e
    800047a6:	6b650513          	addi	a0,a0,1718 # 80022e58 <ftable>
    800047aa:	ffffc097          	auipc	ra,0xffffc
    800047ae:	4e0080e7          	jalr	1248(ra) # 80000c8a <release>
}
    800047b2:	8526                	mv	a0,s1
    800047b4:	60e2                	ld	ra,24(sp)
    800047b6:	6442                	ld	s0,16(sp)
    800047b8:	64a2                	ld	s1,8(sp)
    800047ba:	6105                	addi	sp,sp,32
    800047bc:	8082                	ret

00000000800047be <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800047be:	1101                	addi	sp,sp,-32
    800047c0:	ec06                	sd	ra,24(sp)
    800047c2:	e822                	sd	s0,16(sp)
    800047c4:	e426                	sd	s1,8(sp)
    800047c6:	1000                	addi	s0,sp,32
    800047c8:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800047ca:	0001e517          	auipc	a0,0x1e
    800047ce:	68e50513          	addi	a0,a0,1678 # 80022e58 <ftable>
    800047d2:	ffffc097          	auipc	ra,0xffffc
    800047d6:	404080e7          	jalr	1028(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    800047da:	40dc                	lw	a5,4(s1)
    800047dc:	02f05263          	blez	a5,80004800 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800047e0:	2785                	addiw	a5,a5,1
    800047e2:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800047e4:	0001e517          	auipc	a0,0x1e
    800047e8:	67450513          	addi	a0,a0,1652 # 80022e58 <ftable>
    800047ec:	ffffc097          	auipc	ra,0xffffc
    800047f0:	49e080e7          	jalr	1182(ra) # 80000c8a <release>
  return f;
}
    800047f4:	8526                	mv	a0,s1
    800047f6:	60e2                	ld	ra,24(sp)
    800047f8:	6442                	ld	s0,16(sp)
    800047fa:	64a2                	ld	s1,8(sp)
    800047fc:	6105                	addi	sp,sp,32
    800047fe:	8082                	ret
    panic("filedup");
    80004800:	00004517          	auipc	a0,0x4
    80004804:	ea050513          	addi	a0,a0,-352 # 800086a0 <syscalls+0x250>
    80004808:	ffffc097          	auipc	ra,0xffffc
    8000480c:	d36080e7          	jalr	-714(ra) # 8000053e <panic>

0000000080004810 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004810:	7139                	addi	sp,sp,-64
    80004812:	fc06                	sd	ra,56(sp)
    80004814:	f822                	sd	s0,48(sp)
    80004816:	f426                	sd	s1,40(sp)
    80004818:	f04a                	sd	s2,32(sp)
    8000481a:	ec4e                	sd	s3,24(sp)
    8000481c:	e852                	sd	s4,16(sp)
    8000481e:	e456                	sd	s5,8(sp)
    80004820:	0080                	addi	s0,sp,64
    80004822:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004824:	0001e517          	auipc	a0,0x1e
    80004828:	63450513          	addi	a0,a0,1588 # 80022e58 <ftable>
    8000482c:	ffffc097          	auipc	ra,0xffffc
    80004830:	3aa080e7          	jalr	938(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004834:	40dc                	lw	a5,4(s1)
    80004836:	06f05163          	blez	a5,80004898 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    8000483a:	37fd                	addiw	a5,a5,-1
    8000483c:	0007871b          	sext.w	a4,a5
    80004840:	c0dc                	sw	a5,4(s1)
    80004842:	06e04363          	bgtz	a4,800048a8 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004846:	0004a903          	lw	s2,0(s1)
    8000484a:	0094ca83          	lbu	s5,9(s1)
    8000484e:	0104ba03          	ld	s4,16(s1)
    80004852:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004856:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000485a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000485e:	0001e517          	auipc	a0,0x1e
    80004862:	5fa50513          	addi	a0,a0,1530 # 80022e58 <ftable>
    80004866:	ffffc097          	auipc	ra,0xffffc
    8000486a:	424080e7          	jalr	1060(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    8000486e:	4785                	li	a5,1
    80004870:	04f90d63          	beq	s2,a5,800048ca <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004874:	3979                	addiw	s2,s2,-2
    80004876:	4785                	li	a5,1
    80004878:	0527e063          	bltu	a5,s2,800048b8 <fileclose+0xa8>
    begin_op();
    8000487c:	00000097          	auipc	ra,0x0
    80004880:	ac8080e7          	jalr	-1336(ra) # 80004344 <begin_op>
    iput(ff.ip);
    80004884:	854e                	mv	a0,s3
    80004886:	fffff097          	auipc	ra,0xfffff
    8000488a:	2b6080e7          	jalr	694(ra) # 80003b3c <iput>
    end_op();
    8000488e:	00000097          	auipc	ra,0x0
    80004892:	b36080e7          	jalr	-1226(ra) # 800043c4 <end_op>
    80004896:	a00d                	j	800048b8 <fileclose+0xa8>
    panic("fileclose");
    80004898:	00004517          	auipc	a0,0x4
    8000489c:	e1050513          	addi	a0,a0,-496 # 800086a8 <syscalls+0x258>
    800048a0:	ffffc097          	auipc	ra,0xffffc
    800048a4:	c9e080e7          	jalr	-866(ra) # 8000053e <panic>
    release(&ftable.lock);
    800048a8:	0001e517          	auipc	a0,0x1e
    800048ac:	5b050513          	addi	a0,a0,1456 # 80022e58 <ftable>
    800048b0:	ffffc097          	auipc	ra,0xffffc
    800048b4:	3da080e7          	jalr	986(ra) # 80000c8a <release>
  }
}
    800048b8:	70e2                	ld	ra,56(sp)
    800048ba:	7442                	ld	s0,48(sp)
    800048bc:	74a2                	ld	s1,40(sp)
    800048be:	7902                	ld	s2,32(sp)
    800048c0:	69e2                	ld	s3,24(sp)
    800048c2:	6a42                	ld	s4,16(sp)
    800048c4:	6aa2                	ld	s5,8(sp)
    800048c6:	6121                	addi	sp,sp,64
    800048c8:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800048ca:	85d6                	mv	a1,s5
    800048cc:	8552                	mv	a0,s4
    800048ce:	00000097          	auipc	ra,0x0
    800048d2:	34c080e7          	jalr	844(ra) # 80004c1a <pipeclose>
    800048d6:	b7cd                	j	800048b8 <fileclose+0xa8>

00000000800048d8 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800048d8:	715d                	addi	sp,sp,-80
    800048da:	e486                	sd	ra,72(sp)
    800048dc:	e0a2                	sd	s0,64(sp)
    800048de:	fc26                	sd	s1,56(sp)
    800048e0:	f84a                	sd	s2,48(sp)
    800048e2:	f44e                	sd	s3,40(sp)
    800048e4:	0880                	addi	s0,sp,80
    800048e6:	84aa                	mv	s1,a0
    800048e8:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800048ea:	ffffd097          	auipc	ra,0xffffd
    800048ee:	0c2080e7          	jalr	194(ra) # 800019ac <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800048f2:	409c                	lw	a5,0(s1)
    800048f4:	37f9                	addiw	a5,a5,-2
    800048f6:	4705                	li	a4,1
    800048f8:	04f76763          	bltu	a4,a5,80004946 <filestat+0x6e>
    800048fc:	892a                	mv	s2,a0
    ilock(f->ip);
    800048fe:	6c88                	ld	a0,24(s1)
    80004900:	fffff097          	auipc	ra,0xfffff
    80004904:	082080e7          	jalr	130(ra) # 80003982 <ilock>
    stati(f->ip, &st);
    80004908:	fb840593          	addi	a1,s0,-72
    8000490c:	6c88                	ld	a0,24(s1)
    8000490e:	fffff097          	auipc	ra,0xfffff
    80004912:	2fe080e7          	jalr	766(ra) # 80003c0c <stati>
    iunlock(f->ip);
    80004916:	6c88                	ld	a0,24(s1)
    80004918:	fffff097          	auipc	ra,0xfffff
    8000491c:	12c080e7          	jalr	300(ra) # 80003a44 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004920:	46e1                	li	a3,24
    80004922:	fb840613          	addi	a2,s0,-72
    80004926:	85ce                	mv	a1,s3
    80004928:	05093503          	ld	a0,80(s2)
    8000492c:	ffffd097          	auipc	ra,0xffffd
    80004930:	d3c080e7          	jalr	-708(ra) # 80001668 <copyout>
    80004934:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004938:	60a6                	ld	ra,72(sp)
    8000493a:	6406                	ld	s0,64(sp)
    8000493c:	74e2                	ld	s1,56(sp)
    8000493e:	7942                	ld	s2,48(sp)
    80004940:	79a2                	ld	s3,40(sp)
    80004942:	6161                	addi	sp,sp,80
    80004944:	8082                	ret
  return -1;
    80004946:	557d                	li	a0,-1
    80004948:	bfc5                	j	80004938 <filestat+0x60>

000000008000494a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000494a:	7179                	addi	sp,sp,-48
    8000494c:	f406                	sd	ra,40(sp)
    8000494e:	f022                	sd	s0,32(sp)
    80004950:	ec26                	sd	s1,24(sp)
    80004952:	e84a                	sd	s2,16(sp)
    80004954:	e44e                	sd	s3,8(sp)
    80004956:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004958:	00854783          	lbu	a5,8(a0)
    8000495c:	c3d5                	beqz	a5,80004a00 <fileread+0xb6>
    8000495e:	84aa                	mv	s1,a0
    80004960:	89ae                	mv	s3,a1
    80004962:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004964:	411c                	lw	a5,0(a0)
    80004966:	4705                	li	a4,1
    80004968:	04e78963          	beq	a5,a4,800049ba <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000496c:	470d                	li	a4,3
    8000496e:	04e78d63          	beq	a5,a4,800049c8 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004972:	4709                	li	a4,2
    80004974:	06e79e63          	bne	a5,a4,800049f0 <fileread+0xa6>
    ilock(f->ip);
    80004978:	6d08                	ld	a0,24(a0)
    8000497a:	fffff097          	auipc	ra,0xfffff
    8000497e:	008080e7          	jalr	8(ra) # 80003982 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004982:	874a                	mv	a4,s2
    80004984:	5094                	lw	a3,32(s1)
    80004986:	864e                	mv	a2,s3
    80004988:	4585                	li	a1,1
    8000498a:	6c88                	ld	a0,24(s1)
    8000498c:	fffff097          	auipc	ra,0xfffff
    80004990:	2aa080e7          	jalr	682(ra) # 80003c36 <readi>
    80004994:	892a                	mv	s2,a0
    80004996:	00a05563          	blez	a0,800049a0 <fileread+0x56>
      f->off += r;
    8000499a:	509c                	lw	a5,32(s1)
    8000499c:	9fa9                	addw	a5,a5,a0
    8000499e:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800049a0:	6c88                	ld	a0,24(s1)
    800049a2:	fffff097          	auipc	ra,0xfffff
    800049a6:	0a2080e7          	jalr	162(ra) # 80003a44 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800049aa:	854a                	mv	a0,s2
    800049ac:	70a2                	ld	ra,40(sp)
    800049ae:	7402                	ld	s0,32(sp)
    800049b0:	64e2                	ld	s1,24(sp)
    800049b2:	6942                	ld	s2,16(sp)
    800049b4:	69a2                	ld	s3,8(sp)
    800049b6:	6145                	addi	sp,sp,48
    800049b8:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800049ba:	6908                	ld	a0,16(a0)
    800049bc:	00000097          	auipc	ra,0x0
    800049c0:	3c6080e7          	jalr	966(ra) # 80004d82 <piperead>
    800049c4:	892a                	mv	s2,a0
    800049c6:	b7d5                	j	800049aa <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800049c8:	02451783          	lh	a5,36(a0)
    800049cc:	03079693          	slli	a3,a5,0x30
    800049d0:	92c1                	srli	a3,a3,0x30
    800049d2:	4725                	li	a4,9
    800049d4:	02d76863          	bltu	a4,a3,80004a04 <fileread+0xba>
    800049d8:	0792                	slli	a5,a5,0x4
    800049da:	0001e717          	auipc	a4,0x1e
    800049de:	3de70713          	addi	a4,a4,990 # 80022db8 <devsw>
    800049e2:	97ba                	add	a5,a5,a4
    800049e4:	639c                	ld	a5,0(a5)
    800049e6:	c38d                	beqz	a5,80004a08 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800049e8:	4505                	li	a0,1
    800049ea:	9782                	jalr	a5
    800049ec:	892a                	mv	s2,a0
    800049ee:	bf75                	j	800049aa <fileread+0x60>
    panic("fileread");
    800049f0:	00004517          	auipc	a0,0x4
    800049f4:	cc850513          	addi	a0,a0,-824 # 800086b8 <syscalls+0x268>
    800049f8:	ffffc097          	auipc	ra,0xffffc
    800049fc:	b46080e7          	jalr	-1210(ra) # 8000053e <panic>
    return -1;
    80004a00:	597d                	li	s2,-1
    80004a02:	b765                	j	800049aa <fileread+0x60>
      return -1;
    80004a04:	597d                	li	s2,-1
    80004a06:	b755                	j	800049aa <fileread+0x60>
    80004a08:	597d                	li	s2,-1
    80004a0a:	b745                	j	800049aa <fileread+0x60>

0000000080004a0c <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004a0c:	715d                	addi	sp,sp,-80
    80004a0e:	e486                	sd	ra,72(sp)
    80004a10:	e0a2                	sd	s0,64(sp)
    80004a12:	fc26                	sd	s1,56(sp)
    80004a14:	f84a                	sd	s2,48(sp)
    80004a16:	f44e                	sd	s3,40(sp)
    80004a18:	f052                	sd	s4,32(sp)
    80004a1a:	ec56                	sd	s5,24(sp)
    80004a1c:	e85a                	sd	s6,16(sp)
    80004a1e:	e45e                	sd	s7,8(sp)
    80004a20:	e062                	sd	s8,0(sp)
    80004a22:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004a24:	00954783          	lbu	a5,9(a0)
    80004a28:	10078663          	beqz	a5,80004b34 <filewrite+0x128>
    80004a2c:	892a                	mv	s2,a0
    80004a2e:	8aae                	mv	s5,a1
    80004a30:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004a32:	411c                	lw	a5,0(a0)
    80004a34:	4705                	li	a4,1
    80004a36:	02e78263          	beq	a5,a4,80004a5a <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004a3a:	470d                	li	a4,3
    80004a3c:	02e78663          	beq	a5,a4,80004a68 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004a40:	4709                	li	a4,2
    80004a42:	0ee79163          	bne	a5,a4,80004b24 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004a46:	0ac05d63          	blez	a2,80004b00 <filewrite+0xf4>
    int i = 0;
    80004a4a:	4981                	li	s3,0
    80004a4c:	6b05                	lui	s6,0x1
    80004a4e:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004a52:	6b85                	lui	s7,0x1
    80004a54:	c00b8b9b          	addiw	s7,s7,-1024
    80004a58:	a861                	j	80004af0 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004a5a:	6908                	ld	a0,16(a0)
    80004a5c:	00000097          	auipc	ra,0x0
    80004a60:	22e080e7          	jalr	558(ra) # 80004c8a <pipewrite>
    80004a64:	8a2a                	mv	s4,a0
    80004a66:	a045                	j	80004b06 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004a68:	02451783          	lh	a5,36(a0)
    80004a6c:	03079693          	slli	a3,a5,0x30
    80004a70:	92c1                	srli	a3,a3,0x30
    80004a72:	4725                	li	a4,9
    80004a74:	0cd76263          	bltu	a4,a3,80004b38 <filewrite+0x12c>
    80004a78:	0792                	slli	a5,a5,0x4
    80004a7a:	0001e717          	auipc	a4,0x1e
    80004a7e:	33e70713          	addi	a4,a4,830 # 80022db8 <devsw>
    80004a82:	97ba                	add	a5,a5,a4
    80004a84:	679c                	ld	a5,8(a5)
    80004a86:	cbdd                	beqz	a5,80004b3c <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004a88:	4505                	li	a0,1
    80004a8a:	9782                	jalr	a5
    80004a8c:	8a2a                	mv	s4,a0
    80004a8e:	a8a5                	j	80004b06 <filewrite+0xfa>
    80004a90:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004a94:	00000097          	auipc	ra,0x0
    80004a98:	8b0080e7          	jalr	-1872(ra) # 80004344 <begin_op>
      ilock(f->ip);
    80004a9c:	01893503          	ld	a0,24(s2)
    80004aa0:	fffff097          	auipc	ra,0xfffff
    80004aa4:	ee2080e7          	jalr	-286(ra) # 80003982 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004aa8:	8762                	mv	a4,s8
    80004aaa:	02092683          	lw	a3,32(s2)
    80004aae:	01598633          	add	a2,s3,s5
    80004ab2:	4585                	li	a1,1
    80004ab4:	01893503          	ld	a0,24(s2)
    80004ab8:	fffff097          	auipc	ra,0xfffff
    80004abc:	276080e7          	jalr	630(ra) # 80003d2e <writei>
    80004ac0:	84aa                	mv	s1,a0
    80004ac2:	00a05763          	blez	a0,80004ad0 <filewrite+0xc4>
        f->off += r;
    80004ac6:	02092783          	lw	a5,32(s2)
    80004aca:	9fa9                	addw	a5,a5,a0
    80004acc:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004ad0:	01893503          	ld	a0,24(s2)
    80004ad4:	fffff097          	auipc	ra,0xfffff
    80004ad8:	f70080e7          	jalr	-144(ra) # 80003a44 <iunlock>
      end_op();
    80004adc:	00000097          	auipc	ra,0x0
    80004ae0:	8e8080e7          	jalr	-1816(ra) # 800043c4 <end_op>

      if(r != n1){
    80004ae4:	009c1f63          	bne	s8,s1,80004b02 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004ae8:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004aec:	0149db63          	bge	s3,s4,80004b02 <filewrite+0xf6>
      int n1 = n - i;
    80004af0:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004af4:	84be                	mv	s1,a5
    80004af6:	2781                	sext.w	a5,a5
    80004af8:	f8fb5ce3          	bge	s6,a5,80004a90 <filewrite+0x84>
    80004afc:	84de                	mv	s1,s7
    80004afe:	bf49                	j	80004a90 <filewrite+0x84>
    int i = 0;
    80004b00:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004b02:	013a1f63          	bne	s4,s3,80004b20 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004b06:	8552                	mv	a0,s4
    80004b08:	60a6                	ld	ra,72(sp)
    80004b0a:	6406                	ld	s0,64(sp)
    80004b0c:	74e2                	ld	s1,56(sp)
    80004b0e:	7942                	ld	s2,48(sp)
    80004b10:	79a2                	ld	s3,40(sp)
    80004b12:	7a02                	ld	s4,32(sp)
    80004b14:	6ae2                	ld	s5,24(sp)
    80004b16:	6b42                	ld	s6,16(sp)
    80004b18:	6ba2                	ld	s7,8(sp)
    80004b1a:	6c02                	ld	s8,0(sp)
    80004b1c:	6161                	addi	sp,sp,80
    80004b1e:	8082                	ret
    ret = (i == n ? n : -1);
    80004b20:	5a7d                	li	s4,-1
    80004b22:	b7d5                	j	80004b06 <filewrite+0xfa>
    panic("filewrite");
    80004b24:	00004517          	auipc	a0,0x4
    80004b28:	ba450513          	addi	a0,a0,-1116 # 800086c8 <syscalls+0x278>
    80004b2c:	ffffc097          	auipc	ra,0xffffc
    80004b30:	a12080e7          	jalr	-1518(ra) # 8000053e <panic>
    return -1;
    80004b34:	5a7d                	li	s4,-1
    80004b36:	bfc1                	j	80004b06 <filewrite+0xfa>
      return -1;
    80004b38:	5a7d                	li	s4,-1
    80004b3a:	b7f1                	j	80004b06 <filewrite+0xfa>
    80004b3c:	5a7d                	li	s4,-1
    80004b3e:	b7e1                	j	80004b06 <filewrite+0xfa>

0000000080004b40 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004b40:	7179                	addi	sp,sp,-48
    80004b42:	f406                	sd	ra,40(sp)
    80004b44:	f022                	sd	s0,32(sp)
    80004b46:	ec26                	sd	s1,24(sp)
    80004b48:	e84a                	sd	s2,16(sp)
    80004b4a:	e44e                	sd	s3,8(sp)
    80004b4c:	e052                	sd	s4,0(sp)
    80004b4e:	1800                	addi	s0,sp,48
    80004b50:	84aa                	mv	s1,a0
    80004b52:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004b54:	0005b023          	sd	zero,0(a1)
    80004b58:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004b5c:	00000097          	auipc	ra,0x0
    80004b60:	bf8080e7          	jalr	-1032(ra) # 80004754 <filealloc>
    80004b64:	e088                	sd	a0,0(s1)
    80004b66:	c551                	beqz	a0,80004bf2 <pipealloc+0xb2>
    80004b68:	00000097          	auipc	ra,0x0
    80004b6c:	bec080e7          	jalr	-1044(ra) # 80004754 <filealloc>
    80004b70:	00aa3023          	sd	a0,0(s4)
    80004b74:	c92d                	beqz	a0,80004be6 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004b76:	ffffc097          	auipc	ra,0xffffc
    80004b7a:	f70080e7          	jalr	-144(ra) # 80000ae6 <kalloc>
    80004b7e:	892a                	mv	s2,a0
    80004b80:	c125                	beqz	a0,80004be0 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004b82:	4985                	li	s3,1
    80004b84:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004b88:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004b8c:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004b90:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004b94:	00004597          	auipc	a1,0x4
    80004b98:	b4458593          	addi	a1,a1,-1212 # 800086d8 <syscalls+0x288>
    80004b9c:	ffffc097          	auipc	ra,0xffffc
    80004ba0:	faa080e7          	jalr	-86(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004ba4:	609c                	ld	a5,0(s1)
    80004ba6:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004baa:	609c                	ld	a5,0(s1)
    80004bac:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004bb0:	609c                	ld	a5,0(s1)
    80004bb2:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004bb6:	609c                	ld	a5,0(s1)
    80004bb8:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004bbc:	000a3783          	ld	a5,0(s4)
    80004bc0:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004bc4:	000a3783          	ld	a5,0(s4)
    80004bc8:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004bcc:	000a3783          	ld	a5,0(s4)
    80004bd0:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004bd4:	000a3783          	ld	a5,0(s4)
    80004bd8:	0127b823          	sd	s2,16(a5)
  return 0;
    80004bdc:	4501                	li	a0,0
    80004bde:	a025                	j	80004c06 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004be0:	6088                	ld	a0,0(s1)
    80004be2:	e501                	bnez	a0,80004bea <pipealloc+0xaa>
    80004be4:	a039                	j	80004bf2 <pipealloc+0xb2>
    80004be6:	6088                	ld	a0,0(s1)
    80004be8:	c51d                	beqz	a0,80004c16 <pipealloc+0xd6>
    fileclose(*f0);
    80004bea:	00000097          	auipc	ra,0x0
    80004bee:	c26080e7          	jalr	-986(ra) # 80004810 <fileclose>
  if(*f1)
    80004bf2:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004bf6:	557d                	li	a0,-1
  if(*f1)
    80004bf8:	c799                	beqz	a5,80004c06 <pipealloc+0xc6>
    fileclose(*f1);
    80004bfa:	853e                	mv	a0,a5
    80004bfc:	00000097          	auipc	ra,0x0
    80004c00:	c14080e7          	jalr	-1004(ra) # 80004810 <fileclose>
  return -1;
    80004c04:	557d                	li	a0,-1
}
    80004c06:	70a2                	ld	ra,40(sp)
    80004c08:	7402                	ld	s0,32(sp)
    80004c0a:	64e2                	ld	s1,24(sp)
    80004c0c:	6942                	ld	s2,16(sp)
    80004c0e:	69a2                	ld	s3,8(sp)
    80004c10:	6a02                	ld	s4,0(sp)
    80004c12:	6145                	addi	sp,sp,48
    80004c14:	8082                	ret
  return -1;
    80004c16:	557d                	li	a0,-1
    80004c18:	b7fd                	j	80004c06 <pipealloc+0xc6>

0000000080004c1a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004c1a:	1101                	addi	sp,sp,-32
    80004c1c:	ec06                	sd	ra,24(sp)
    80004c1e:	e822                	sd	s0,16(sp)
    80004c20:	e426                	sd	s1,8(sp)
    80004c22:	e04a                	sd	s2,0(sp)
    80004c24:	1000                	addi	s0,sp,32
    80004c26:	84aa                	mv	s1,a0
    80004c28:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004c2a:	ffffc097          	auipc	ra,0xffffc
    80004c2e:	fac080e7          	jalr	-84(ra) # 80000bd6 <acquire>
  if(writable){
    80004c32:	02090d63          	beqz	s2,80004c6c <pipeclose+0x52>
    pi->writeopen = 0;
    80004c36:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004c3a:	21848513          	addi	a0,s1,536
    80004c3e:	ffffd097          	auipc	ra,0xffffd
    80004c42:	48e080e7          	jalr	1166(ra) # 800020cc <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004c46:	2204b783          	ld	a5,544(s1)
    80004c4a:	eb95                	bnez	a5,80004c7e <pipeclose+0x64>
    release(&pi->lock);
    80004c4c:	8526                	mv	a0,s1
    80004c4e:	ffffc097          	auipc	ra,0xffffc
    80004c52:	03c080e7          	jalr	60(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004c56:	8526                	mv	a0,s1
    80004c58:	ffffc097          	auipc	ra,0xffffc
    80004c5c:	d92080e7          	jalr	-622(ra) # 800009ea <kfree>
  } else
    release(&pi->lock);
}
    80004c60:	60e2                	ld	ra,24(sp)
    80004c62:	6442                	ld	s0,16(sp)
    80004c64:	64a2                	ld	s1,8(sp)
    80004c66:	6902                	ld	s2,0(sp)
    80004c68:	6105                	addi	sp,sp,32
    80004c6a:	8082                	ret
    pi->readopen = 0;
    80004c6c:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004c70:	21c48513          	addi	a0,s1,540
    80004c74:	ffffd097          	auipc	ra,0xffffd
    80004c78:	458080e7          	jalr	1112(ra) # 800020cc <wakeup>
    80004c7c:	b7e9                	j	80004c46 <pipeclose+0x2c>
    release(&pi->lock);
    80004c7e:	8526                	mv	a0,s1
    80004c80:	ffffc097          	auipc	ra,0xffffc
    80004c84:	00a080e7          	jalr	10(ra) # 80000c8a <release>
}
    80004c88:	bfe1                	j	80004c60 <pipeclose+0x46>

0000000080004c8a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004c8a:	711d                	addi	sp,sp,-96
    80004c8c:	ec86                	sd	ra,88(sp)
    80004c8e:	e8a2                	sd	s0,80(sp)
    80004c90:	e4a6                	sd	s1,72(sp)
    80004c92:	e0ca                	sd	s2,64(sp)
    80004c94:	fc4e                	sd	s3,56(sp)
    80004c96:	f852                	sd	s4,48(sp)
    80004c98:	f456                	sd	s5,40(sp)
    80004c9a:	f05a                	sd	s6,32(sp)
    80004c9c:	ec5e                	sd	s7,24(sp)
    80004c9e:	e862                	sd	s8,16(sp)
    80004ca0:	1080                	addi	s0,sp,96
    80004ca2:	84aa                	mv	s1,a0
    80004ca4:	8aae                	mv	s5,a1
    80004ca6:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004ca8:	ffffd097          	auipc	ra,0xffffd
    80004cac:	d04080e7          	jalr	-764(ra) # 800019ac <myproc>
    80004cb0:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004cb2:	8526                	mv	a0,s1
    80004cb4:	ffffc097          	auipc	ra,0xffffc
    80004cb8:	f22080e7          	jalr	-222(ra) # 80000bd6 <acquire>
  while(i < n){
    80004cbc:	0b405663          	blez	s4,80004d68 <pipewrite+0xde>
  int i = 0;
    80004cc0:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004cc2:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004cc4:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004cc8:	21c48b93          	addi	s7,s1,540
    80004ccc:	a089                	j	80004d0e <pipewrite+0x84>
      release(&pi->lock);
    80004cce:	8526                	mv	a0,s1
    80004cd0:	ffffc097          	auipc	ra,0xffffc
    80004cd4:	fba080e7          	jalr	-70(ra) # 80000c8a <release>
      return -1;
    80004cd8:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004cda:	854a                	mv	a0,s2
    80004cdc:	60e6                	ld	ra,88(sp)
    80004cde:	6446                	ld	s0,80(sp)
    80004ce0:	64a6                	ld	s1,72(sp)
    80004ce2:	6906                	ld	s2,64(sp)
    80004ce4:	79e2                	ld	s3,56(sp)
    80004ce6:	7a42                	ld	s4,48(sp)
    80004ce8:	7aa2                	ld	s5,40(sp)
    80004cea:	7b02                	ld	s6,32(sp)
    80004cec:	6be2                	ld	s7,24(sp)
    80004cee:	6c42                	ld	s8,16(sp)
    80004cf0:	6125                	addi	sp,sp,96
    80004cf2:	8082                	ret
      wakeup(&pi->nread);
    80004cf4:	8562                	mv	a0,s8
    80004cf6:	ffffd097          	auipc	ra,0xffffd
    80004cfa:	3d6080e7          	jalr	982(ra) # 800020cc <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004cfe:	85a6                	mv	a1,s1
    80004d00:	855e                	mv	a0,s7
    80004d02:	ffffd097          	auipc	ra,0xffffd
    80004d06:	366080e7          	jalr	870(ra) # 80002068 <sleep>
  while(i < n){
    80004d0a:	07495063          	bge	s2,s4,80004d6a <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004d0e:	2204a783          	lw	a5,544(s1)
    80004d12:	dfd5                	beqz	a5,80004cce <pipewrite+0x44>
    80004d14:	854e                	mv	a0,s3
    80004d16:	ffffd097          	auipc	ra,0xffffd
    80004d1a:	606080e7          	jalr	1542(ra) # 8000231c <killed>
    80004d1e:	f945                	bnez	a0,80004cce <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004d20:	2184a783          	lw	a5,536(s1)
    80004d24:	21c4a703          	lw	a4,540(s1)
    80004d28:	2007879b          	addiw	a5,a5,512
    80004d2c:	fcf704e3          	beq	a4,a5,80004cf4 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d30:	4685                	li	a3,1
    80004d32:	01590633          	add	a2,s2,s5
    80004d36:	faf40593          	addi	a1,s0,-81
    80004d3a:	0509b503          	ld	a0,80(s3)
    80004d3e:	ffffd097          	auipc	ra,0xffffd
    80004d42:	9b6080e7          	jalr	-1610(ra) # 800016f4 <copyin>
    80004d46:	03650263          	beq	a0,s6,80004d6a <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004d4a:	21c4a783          	lw	a5,540(s1)
    80004d4e:	0017871b          	addiw	a4,a5,1
    80004d52:	20e4ae23          	sw	a4,540(s1)
    80004d56:	1ff7f793          	andi	a5,a5,511
    80004d5a:	97a6                	add	a5,a5,s1
    80004d5c:	faf44703          	lbu	a4,-81(s0)
    80004d60:	00e78c23          	sb	a4,24(a5)
      i++;
    80004d64:	2905                	addiw	s2,s2,1
    80004d66:	b755                	j	80004d0a <pipewrite+0x80>
  int i = 0;
    80004d68:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004d6a:	21848513          	addi	a0,s1,536
    80004d6e:	ffffd097          	auipc	ra,0xffffd
    80004d72:	35e080e7          	jalr	862(ra) # 800020cc <wakeup>
  release(&pi->lock);
    80004d76:	8526                	mv	a0,s1
    80004d78:	ffffc097          	auipc	ra,0xffffc
    80004d7c:	f12080e7          	jalr	-238(ra) # 80000c8a <release>
  return i;
    80004d80:	bfa9                	j	80004cda <pipewrite+0x50>

0000000080004d82 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004d82:	715d                	addi	sp,sp,-80
    80004d84:	e486                	sd	ra,72(sp)
    80004d86:	e0a2                	sd	s0,64(sp)
    80004d88:	fc26                	sd	s1,56(sp)
    80004d8a:	f84a                	sd	s2,48(sp)
    80004d8c:	f44e                	sd	s3,40(sp)
    80004d8e:	f052                	sd	s4,32(sp)
    80004d90:	ec56                	sd	s5,24(sp)
    80004d92:	e85a                	sd	s6,16(sp)
    80004d94:	0880                	addi	s0,sp,80
    80004d96:	84aa                	mv	s1,a0
    80004d98:	892e                	mv	s2,a1
    80004d9a:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004d9c:	ffffd097          	auipc	ra,0xffffd
    80004da0:	c10080e7          	jalr	-1008(ra) # 800019ac <myproc>
    80004da4:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004da6:	8526                	mv	a0,s1
    80004da8:	ffffc097          	auipc	ra,0xffffc
    80004dac:	e2e080e7          	jalr	-466(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004db0:	2184a703          	lw	a4,536(s1)
    80004db4:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004db8:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004dbc:	02f71763          	bne	a4,a5,80004dea <piperead+0x68>
    80004dc0:	2244a783          	lw	a5,548(s1)
    80004dc4:	c39d                	beqz	a5,80004dea <piperead+0x68>
    if(killed(pr)){
    80004dc6:	8552                	mv	a0,s4
    80004dc8:	ffffd097          	auipc	ra,0xffffd
    80004dcc:	554080e7          	jalr	1364(ra) # 8000231c <killed>
    80004dd0:	e941                	bnez	a0,80004e60 <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004dd2:	85a6                	mv	a1,s1
    80004dd4:	854e                	mv	a0,s3
    80004dd6:	ffffd097          	auipc	ra,0xffffd
    80004dda:	292080e7          	jalr	658(ra) # 80002068 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004dde:	2184a703          	lw	a4,536(s1)
    80004de2:	21c4a783          	lw	a5,540(s1)
    80004de6:	fcf70de3          	beq	a4,a5,80004dc0 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004dea:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004dec:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004dee:	05505363          	blez	s5,80004e34 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004df2:	2184a783          	lw	a5,536(s1)
    80004df6:	21c4a703          	lw	a4,540(s1)
    80004dfa:	02f70d63          	beq	a4,a5,80004e34 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004dfe:	0017871b          	addiw	a4,a5,1
    80004e02:	20e4ac23          	sw	a4,536(s1)
    80004e06:	1ff7f793          	andi	a5,a5,511
    80004e0a:	97a6                	add	a5,a5,s1
    80004e0c:	0187c783          	lbu	a5,24(a5)
    80004e10:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e14:	4685                	li	a3,1
    80004e16:	fbf40613          	addi	a2,s0,-65
    80004e1a:	85ca                	mv	a1,s2
    80004e1c:	050a3503          	ld	a0,80(s4)
    80004e20:	ffffd097          	auipc	ra,0xffffd
    80004e24:	848080e7          	jalr	-1976(ra) # 80001668 <copyout>
    80004e28:	01650663          	beq	a0,s6,80004e34 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e2c:	2985                	addiw	s3,s3,1
    80004e2e:	0905                	addi	s2,s2,1
    80004e30:	fd3a91e3          	bne	s5,s3,80004df2 <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004e34:	21c48513          	addi	a0,s1,540
    80004e38:	ffffd097          	auipc	ra,0xffffd
    80004e3c:	294080e7          	jalr	660(ra) # 800020cc <wakeup>
  release(&pi->lock);
    80004e40:	8526                	mv	a0,s1
    80004e42:	ffffc097          	auipc	ra,0xffffc
    80004e46:	e48080e7          	jalr	-440(ra) # 80000c8a <release>
  return i;
}
    80004e4a:	854e                	mv	a0,s3
    80004e4c:	60a6                	ld	ra,72(sp)
    80004e4e:	6406                	ld	s0,64(sp)
    80004e50:	74e2                	ld	s1,56(sp)
    80004e52:	7942                	ld	s2,48(sp)
    80004e54:	79a2                	ld	s3,40(sp)
    80004e56:	7a02                	ld	s4,32(sp)
    80004e58:	6ae2                	ld	s5,24(sp)
    80004e5a:	6b42                	ld	s6,16(sp)
    80004e5c:	6161                	addi	sp,sp,80
    80004e5e:	8082                	ret
      release(&pi->lock);
    80004e60:	8526                	mv	a0,s1
    80004e62:	ffffc097          	auipc	ra,0xffffc
    80004e66:	e28080e7          	jalr	-472(ra) # 80000c8a <release>
      return -1;
    80004e6a:	59fd                	li	s3,-1
    80004e6c:	bff9                	j	80004e4a <piperead+0xc8>

0000000080004e6e <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004e6e:	1141                	addi	sp,sp,-16
    80004e70:	e422                	sd	s0,8(sp)
    80004e72:	0800                	addi	s0,sp,16
    80004e74:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004e76:	8905                	andi	a0,a0,1
    80004e78:	c111                	beqz	a0,80004e7c <flags2perm+0xe>
      perm = PTE_X;
    80004e7a:	4521                	li	a0,8
    if(flags & 0x2)
    80004e7c:	8b89                	andi	a5,a5,2
    80004e7e:	c399                	beqz	a5,80004e84 <flags2perm+0x16>
      perm |= PTE_W;
    80004e80:	00456513          	ori	a0,a0,4
    return perm;
}
    80004e84:	6422                	ld	s0,8(sp)
    80004e86:	0141                	addi	sp,sp,16
    80004e88:	8082                	ret

0000000080004e8a <exec>:

int
exec(char *path, char **argv)
{
    80004e8a:	de010113          	addi	sp,sp,-544
    80004e8e:	20113c23          	sd	ra,536(sp)
    80004e92:	20813823          	sd	s0,528(sp)
    80004e96:	20913423          	sd	s1,520(sp)
    80004e9a:	21213023          	sd	s2,512(sp)
    80004e9e:	ffce                	sd	s3,504(sp)
    80004ea0:	fbd2                	sd	s4,496(sp)
    80004ea2:	f7d6                	sd	s5,488(sp)
    80004ea4:	f3da                	sd	s6,480(sp)
    80004ea6:	efde                	sd	s7,472(sp)
    80004ea8:	ebe2                	sd	s8,464(sp)
    80004eaa:	e7e6                	sd	s9,456(sp)
    80004eac:	e3ea                	sd	s10,448(sp)
    80004eae:	ff6e                	sd	s11,440(sp)
    80004eb0:	1400                	addi	s0,sp,544
    80004eb2:	892a                	mv	s2,a0
    80004eb4:	dea43423          	sd	a0,-536(s0)
    80004eb8:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004ebc:	ffffd097          	auipc	ra,0xffffd
    80004ec0:	af0080e7          	jalr	-1296(ra) # 800019ac <myproc>
    80004ec4:	84aa                	mv	s1,a0

  begin_op();
    80004ec6:	fffff097          	auipc	ra,0xfffff
    80004eca:	47e080e7          	jalr	1150(ra) # 80004344 <begin_op>

  if((ip = namei(path)) == 0){
    80004ece:	854a                	mv	a0,s2
    80004ed0:	fffff097          	auipc	ra,0xfffff
    80004ed4:	258080e7          	jalr	600(ra) # 80004128 <namei>
    80004ed8:	c93d                	beqz	a0,80004f4e <exec+0xc4>
    80004eda:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004edc:	fffff097          	auipc	ra,0xfffff
    80004ee0:	aa6080e7          	jalr	-1370(ra) # 80003982 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004ee4:	04000713          	li	a4,64
    80004ee8:	4681                	li	a3,0
    80004eea:	e5040613          	addi	a2,s0,-432
    80004eee:	4581                	li	a1,0
    80004ef0:	8556                	mv	a0,s5
    80004ef2:	fffff097          	auipc	ra,0xfffff
    80004ef6:	d44080e7          	jalr	-700(ra) # 80003c36 <readi>
    80004efa:	04000793          	li	a5,64
    80004efe:	00f51a63          	bne	a0,a5,80004f12 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004f02:	e5042703          	lw	a4,-432(s0)
    80004f06:	464c47b7          	lui	a5,0x464c4
    80004f0a:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004f0e:	04f70663          	beq	a4,a5,80004f5a <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004f12:	8556                	mv	a0,s5
    80004f14:	fffff097          	auipc	ra,0xfffff
    80004f18:	cd0080e7          	jalr	-816(ra) # 80003be4 <iunlockput>
    end_op();
    80004f1c:	fffff097          	auipc	ra,0xfffff
    80004f20:	4a8080e7          	jalr	1192(ra) # 800043c4 <end_op>
  }
  return -1;
    80004f24:	557d                	li	a0,-1
}
    80004f26:	21813083          	ld	ra,536(sp)
    80004f2a:	21013403          	ld	s0,528(sp)
    80004f2e:	20813483          	ld	s1,520(sp)
    80004f32:	20013903          	ld	s2,512(sp)
    80004f36:	79fe                	ld	s3,504(sp)
    80004f38:	7a5e                	ld	s4,496(sp)
    80004f3a:	7abe                	ld	s5,488(sp)
    80004f3c:	7b1e                	ld	s6,480(sp)
    80004f3e:	6bfe                	ld	s7,472(sp)
    80004f40:	6c5e                	ld	s8,464(sp)
    80004f42:	6cbe                	ld	s9,456(sp)
    80004f44:	6d1e                	ld	s10,448(sp)
    80004f46:	7dfa                	ld	s11,440(sp)
    80004f48:	22010113          	addi	sp,sp,544
    80004f4c:	8082                	ret
    end_op();
    80004f4e:	fffff097          	auipc	ra,0xfffff
    80004f52:	476080e7          	jalr	1142(ra) # 800043c4 <end_op>
    return -1;
    80004f56:	557d                	li	a0,-1
    80004f58:	b7f9                	j	80004f26 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004f5a:	8526                	mv	a0,s1
    80004f5c:	ffffd097          	auipc	ra,0xffffd
    80004f60:	b14080e7          	jalr	-1260(ra) # 80001a70 <proc_pagetable>
    80004f64:	8b2a                	mv	s6,a0
    80004f66:	d555                	beqz	a0,80004f12 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f68:	e7042783          	lw	a5,-400(s0)
    80004f6c:	e8845703          	lhu	a4,-376(s0)
    80004f70:	c735                	beqz	a4,80004fdc <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f72:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f74:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004f78:	6a05                	lui	s4,0x1
    80004f7a:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004f7e:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004f82:	6d85                	lui	s11,0x1
    80004f84:	7d7d                	lui	s10,0xfffff
    80004f86:	a481                	j	800051c6 <exec+0x33c>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004f88:	00003517          	auipc	a0,0x3
    80004f8c:	75850513          	addi	a0,a0,1880 # 800086e0 <syscalls+0x290>
    80004f90:	ffffb097          	auipc	ra,0xffffb
    80004f94:	5ae080e7          	jalr	1454(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004f98:	874a                	mv	a4,s2
    80004f9a:	009c86bb          	addw	a3,s9,s1
    80004f9e:	4581                	li	a1,0
    80004fa0:	8556                	mv	a0,s5
    80004fa2:	fffff097          	auipc	ra,0xfffff
    80004fa6:	c94080e7          	jalr	-876(ra) # 80003c36 <readi>
    80004faa:	2501                	sext.w	a0,a0
    80004fac:	1aa91a63          	bne	s2,a0,80005160 <exec+0x2d6>
  for(i = 0; i < sz; i += PGSIZE){
    80004fb0:	009d84bb          	addw	s1,s11,s1
    80004fb4:	013d09bb          	addw	s3,s10,s3
    80004fb8:	1f74f763          	bgeu	s1,s7,800051a6 <exec+0x31c>
    pa = walkaddr(pagetable, va + i);
    80004fbc:	02049593          	slli	a1,s1,0x20
    80004fc0:	9181                	srli	a1,a1,0x20
    80004fc2:	95e2                	add	a1,a1,s8
    80004fc4:	855a                	mv	a0,s6
    80004fc6:	ffffc097          	auipc	ra,0xffffc
    80004fca:	096080e7          	jalr	150(ra) # 8000105c <walkaddr>
    80004fce:	862a                	mv	a2,a0
    if(pa == 0)
    80004fd0:	dd45                	beqz	a0,80004f88 <exec+0xfe>
      n = PGSIZE;
    80004fd2:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004fd4:	fd49f2e3          	bgeu	s3,s4,80004f98 <exec+0x10e>
      n = sz - i;
    80004fd8:	894e                	mv	s2,s3
    80004fda:	bf7d                	j	80004f98 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004fdc:	4901                	li	s2,0
  iunlockput(ip);
    80004fde:	8556                	mv	a0,s5
    80004fe0:	fffff097          	auipc	ra,0xfffff
    80004fe4:	c04080e7          	jalr	-1020(ra) # 80003be4 <iunlockput>
  end_op();
    80004fe8:	fffff097          	auipc	ra,0xfffff
    80004fec:	3dc080e7          	jalr	988(ra) # 800043c4 <end_op>
  p = myproc();
    80004ff0:	ffffd097          	auipc	ra,0xffffd
    80004ff4:	9bc080e7          	jalr	-1604(ra) # 800019ac <myproc>
    80004ff8:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004ffa:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004ffe:	6785                	lui	a5,0x1
    80005000:	17fd                	addi	a5,a5,-1
    80005002:	993e                	add	s2,s2,a5
    80005004:	77fd                	lui	a5,0xfffff
    80005006:	00f977b3          	and	a5,s2,a5
    8000500a:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    8000500e:	4691                	li	a3,4
    80005010:	6609                	lui	a2,0x2
    80005012:	963e                	add	a2,a2,a5
    80005014:	85be                	mv	a1,a5
    80005016:	855a                	mv	a0,s6
    80005018:	ffffc097          	auipc	ra,0xffffc
    8000501c:	3f8080e7          	jalr	1016(ra) # 80001410 <uvmalloc>
    80005020:	8c2a                	mv	s8,a0
  ip = 0;
    80005022:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005024:	12050e63          	beqz	a0,80005160 <exec+0x2d6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005028:	75f9                	lui	a1,0xffffe
    8000502a:	95aa                	add	a1,a1,a0
    8000502c:	855a                	mv	a0,s6
    8000502e:	ffffc097          	auipc	ra,0xffffc
    80005032:	608080e7          	jalr	1544(ra) # 80001636 <uvmclear>
  stackbase = sp - PGSIZE;
    80005036:	7afd                	lui	s5,0xfffff
    80005038:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    8000503a:	df043783          	ld	a5,-528(s0)
    8000503e:	6388                	ld	a0,0(a5)
    80005040:	c925                	beqz	a0,800050b0 <exec+0x226>
    80005042:	e9040993          	addi	s3,s0,-368
    80005046:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    8000504a:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000504c:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000504e:	ffffc097          	auipc	ra,0xffffc
    80005052:	e00080e7          	jalr	-512(ra) # 80000e4e <strlen>
    80005056:	0015079b          	addiw	a5,a0,1
    8000505a:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000505e:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005062:	13596663          	bltu	s2,s5,8000518e <exec+0x304>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005066:	df043d83          	ld	s11,-528(s0)
    8000506a:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    8000506e:	8552                	mv	a0,s4
    80005070:	ffffc097          	auipc	ra,0xffffc
    80005074:	dde080e7          	jalr	-546(ra) # 80000e4e <strlen>
    80005078:	0015069b          	addiw	a3,a0,1
    8000507c:	8652                	mv	a2,s4
    8000507e:	85ca                	mv	a1,s2
    80005080:	855a                	mv	a0,s6
    80005082:	ffffc097          	auipc	ra,0xffffc
    80005086:	5e6080e7          	jalr	1510(ra) # 80001668 <copyout>
    8000508a:	10054663          	bltz	a0,80005196 <exec+0x30c>
    ustack[argc] = sp;
    8000508e:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005092:	0485                	addi	s1,s1,1
    80005094:	008d8793          	addi	a5,s11,8
    80005098:	def43823          	sd	a5,-528(s0)
    8000509c:	008db503          	ld	a0,8(s11)
    800050a0:	c911                	beqz	a0,800050b4 <exec+0x22a>
    if(argc >= MAXARG)
    800050a2:	09a1                	addi	s3,s3,8
    800050a4:	fb3c95e3          	bne	s9,s3,8000504e <exec+0x1c4>
  sz = sz1;
    800050a8:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800050ac:	4a81                	li	s5,0
    800050ae:	a84d                	j	80005160 <exec+0x2d6>
  sp = sz;
    800050b0:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800050b2:	4481                	li	s1,0
  ustack[argc] = 0;
    800050b4:	00349793          	slli	a5,s1,0x3
    800050b8:	f9040713          	addi	a4,s0,-112
    800050bc:	97ba                	add	a5,a5,a4
    800050be:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7ffdafb0>
  sp -= (argc+1) * sizeof(uint64);
    800050c2:	00148693          	addi	a3,s1,1
    800050c6:	068e                	slli	a3,a3,0x3
    800050c8:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800050cc:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800050d0:	01597663          	bgeu	s2,s5,800050dc <exec+0x252>
  sz = sz1;
    800050d4:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800050d8:	4a81                	li	s5,0
    800050da:	a059                	j	80005160 <exec+0x2d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800050dc:	e9040613          	addi	a2,s0,-368
    800050e0:	85ca                	mv	a1,s2
    800050e2:	855a                	mv	a0,s6
    800050e4:	ffffc097          	auipc	ra,0xffffc
    800050e8:	584080e7          	jalr	1412(ra) # 80001668 <copyout>
    800050ec:	0a054963          	bltz	a0,8000519e <exec+0x314>
  p->trapframe->a1 = sp;
    800050f0:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    800050f4:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800050f8:	de843783          	ld	a5,-536(s0)
    800050fc:	0007c703          	lbu	a4,0(a5)
    80005100:	cf11                	beqz	a4,8000511c <exec+0x292>
    80005102:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005104:	02f00693          	li	a3,47
    80005108:	a039                	j	80005116 <exec+0x28c>
      last = s+1;
    8000510a:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    8000510e:	0785                	addi	a5,a5,1
    80005110:	fff7c703          	lbu	a4,-1(a5)
    80005114:	c701                	beqz	a4,8000511c <exec+0x292>
    if(*s == '/')
    80005116:	fed71ce3          	bne	a4,a3,8000510e <exec+0x284>
    8000511a:	bfc5                	j	8000510a <exec+0x280>
  safestrcpy(p->name, last, sizeof(p->name));
    8000511c:	4641                	li	a2,16
    8000511e:	de843583          	ld	a1,-536(s0)
    80005122:	158b8513          	addi	a0,s7,344
    80005126:	ffffc097          	auipc	ra,0xffffc
    8000512a:	cf6080e7          	jalr	-778(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    8000512e:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80005132:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80005136:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000513a:	058bb783          	ld	a5,88(s7)
    8000513e:	e6843703          	ld	a4,-408(s0)
    80005142:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005144:	058bb783          	ld	a5,88(s7)
    80005148:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000514c:	85ea                	mv	a1,s10
    8000514e:	ffffd097          	auipc	ra,0xffffd
    80005152:	9be080e7          	jalr	-1602(ra) # 80001b0c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005156:	0004851b          	sext.w	a0,s1
    8000515a:	b3f1                	j	80004f26 <exec+0x9c>
    8000515c:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005160:	df843583          	ld	a1,-520(s0)
    80005164:	855a                	mv	a0,s6
    80005166:	ffffd097          	auipc	ra,0xffffd
    8000516a:	9a6080e7          	jalr	-1626(ra) # 80001b0c <proc_freepagetable>
  if(ip){
    8000516e:	da0a92e3          	bnez	s5,80004f12 <exec+0x88>
  return -1;
    80005172:	557d                	li	a0,-1
    80005174:	bb4d                	j	80004f26 <exec+0x9c>
    80005176:	df243c23          	sd	s2,-520(s0)
    8000517a:	b7dd                	j	80005160 <exec+0x2d6>
    8000517c:	df243c23          	sd	s2,-520(s0)
    80005180:	b7c5                	j	80005160 <exec+0x2d6>
    80005182:	df243c23          	sd	s2,-520(s0)
    80005186:	bfe9                	j	80005160 <exec+0x2d6>
    80005188:	df243c23          	sd	s2,-520(s0)
    8000518c:	bfd1                	j	80005160 <exec+0x2d6>
  sz = sz1;
    8000518e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005192:	4a81                	li	s5,0
    80005194:	b7f1                	j	80005160 <exec+0x2d6>
  sz = sz1;
    80005196:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000519a:	4a81                	li	s5,0
    8000519c:	b7d1                	j	80005160 <exec+0x2d6>
  sz = sz1;
    8000519e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800051a2:	4a81                	li	s5,0
    800051a4:	bf75                	j	80005160 <exec+0x2d6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800051a6:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800051aa:	e0843783          	ld	a5,-504(s0)
    800051ae:	0017869b          	addiw	a3,a5,1
    800051b2:	e0d43423          	sd	a3,-504(s0)
    800051b6:	e0043783          	ld	a5,-512(s0)
    800051ba:	0387879b          	addiw	a5,a5,56
    800051be:	e8845703          	lhu	a4,-376(s0)
    800051c2:	e0e6dee3          	bge	a3,a4,80004fde <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800051c6:	2781                	sext.w	a5,a5
    800051c8:	e0f43023          	sd	a5,-512(s0)
    800051cc:	03800713          	li	a4,56
    800051d0:	86be                	mv	a3,a5
    800051d2:	e1840613          	addi	a2,s0,-488
    800051d6:	4581                	li	a1,0
    800051d8:	8556                	mv	a0,s5
    800051da:	fffff097          	auipc	ra,0xfffff
    800051de:	a5c080e7          	jalr	-1444(ra) # 80003c36 <readi>
    800051e2:	03800793          	li	a5,56
    800051e6:	f6f51be3          	bne	a0,a5,8000515c <exec+0x2d2>
    if(ph.type != ELF_PROG_LOAD)
    800051ea:	e1842783          	lw	a5,-488(s0)
    800051ee:	4705                	li	a4,1
    800051f0:	fae79de3          	bne	a5,a4,800051aa <exec+0x320>
    if(ph.memsz < ph.filesz)
    800051f4:	e4043483          	ld	s1,-448(s0)
    800051f8:	e3843783          	ld	a5,-456(s0)
    800051fc:	f6f4ede3          	bltu	s1,a5,80005176 <exec+0x2ec>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005200:	e2843783          	ld	a5,-472(s0)
    80005204:	94be                	add	s1,s1,a5
    80005206:	f6f4ebe3          	bltu	s1,a5,8000517c <exec+0x2f2>
    if(ph.vaddr % PGSIZE != 0)
    8000520a:	de043703          	ld	a4,-544(s0)
    8000520e:	8ff9                	and	a5,a5,a4
    80005210:	fbad                	bnez	a5,80005182 <exec+0x2f8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005212:	e1c42503          	lw	a0,-484(s0)
    80005216:	00000097          	auipc	ra,0x0
    8000521a:	c58080e7          	jalr	-936(ra) # 80004e6e <flags2perm>
    8000521e:	86aa                	mv	a3,a0
    80005220:	8626                	mv	a2,s1
    80005222:	85ca                	mv	a1,s2
    80005224:	855a                	mv	a0,s6
    80005226:	ffffc097          	auipc	ra,0xffffc
    8000522a:	1ea080e7          	jalr	490(ra) # 80001410 <uvmalloc>
    8000522e:	dea43c23          	sd	a0,-520(s0)
    80005232:	d939                	beqz	a0,80005188 <exec+0x2fe>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005234:	e2843c03          	ld	s8,-472(s0)
    80005238:	e2042c83          	lw	s9,-480(s0)
    8000523c:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005240:	f60b83e3          	beqz	s7,800051a6 <exec+0x31c>
    80005244:	89de                	mv	s3,s7
    80005246:	4481                	li	s1,0
    80005248:	bb95                	j	80004fbc <exec+0x132>

000000008000524a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000524a:	7179                	addi	sp,sp,-48
    8000524c:	f406                	sd	ra,40(sp)
    8000524e:	f022                	sd	s0,32(sp)
    80005250:	ec26                	sd	s1,24(sp)
    80005252:	e84a                	sd	s2,16(sp)
    80005254:	1800                	addi	s0,sp,48
    80005256:	892e                	mv	s2,a1
    80005258:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000525a:	fdc40593          	addi	a1,s0,-36
    8000525e:	ffffe097          	auipc	ra,0xffffe
    80005262:	a3a080e7          	jalr	-1478(ra) # 80002c98 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005266:	fdc42703          	lw	a4,-36(s0)
    8000526a:	47bd                	li	a5,15
    8000526c:	02e7eb63          	bltu	a5,a4,800052a2 <argfd+0x58>
    80005270:	ffffc097          	auipc	ra,0xffffc
    80005274:	73c080e7          	jalr	1852(ra) # 800019ac <myproc>
    80005278:	fdc42703          	lw	a4,-36(s0)
    8000527c:	01a70793          	addi	a5,a4,26
    80005280:	078e                	slli	a5,a5,0x3
    80005282:	953e                	add	a0,a0,a5
    80005284:	611c                	ld	a5,0(a0)
    80005286:	c385                	beqz	a5,800052a6 <argfd+0x5c>
    return -1;
  if(pfd)
    80005288:	00090463          	beqz	s2,80005290 <argfd+0x46>
    *pfd = fd;
    8000528c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005290:	4501                	li	a0,0
  if(pf)
    80005292:	c091                	beqz	s1,80005296 <argfd+0x4c>
    *pf = f;
    80005294:	e09c                	sd	a5,0(s1)
}
    80005296:	70a2                	ld	ra,40(sp)
    80005298:	7402                	ld	s0,32(sp)
    8000529a:	64e2                	ld	s1,24(sp)
    8000529c:	6942                	ld	s2,16(sp)
    8000529e:	6145                	addi	sp,sp,48
    800052a0:	8082                	ret
    return -1;
    800052a2:	557d                	li	a0,-1
    800052a4:	bfcd                	j	80005296 <argfd+0x4c>
    800052a6:	557d                	li	a0,-1
    800052a8:	b7fd                	j	80005296 <argfd+0x4c>

00000000800052aa <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800052aa:	1101                	addi	sp,sp,-32
    800052ac:	ec06                	sd	ra,24(sp)
    800052ae:	e822                	sd	s0,16(sp)
    800052b0:	e426                	sd	s1,8(sp)
    800052b2:	1000                	addi	s0,sp,32
    800052b4:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800052b6:	ffffc097          	auipc	ra,0xffffc
    800052ba:	6f6080e7          	jalr	1782(ra) # 800019ac <myproc>
    800052be:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800052c0:	0d050793          	addi	a5,a0,208
    800052c4:	4501                	li	a0,0
    800052c6:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800052c8:	6398                	ld	a4,0(a5)
    800052ca:	cb19                	beqz	a4,800052e0 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800052cc:	2505                	addiw	a0,a0,1
    800052ce:	07a1                	addi	a5,a5,8
    800052d0:	fed51ce3          	bne	a0,a3,800052c8 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800052d4:	557d                	li	a0,-1
}
    800052d6:	60e2                	ld	ra,24(sp)
    800052d8:	6442                	ld	s0,16(sp)
    800052da:	64a2                	ld	s1,8(sp)
    800052dc:	6105                	addi	sp,sp,32
    800052de:	8082                	ret
      p->ofile[fd] = f;
    800052e0:	01a50793          	addi	a5,a0,26
    800052e4:	078e                	slli	a5,a5,0x3
    800052e6:	963e                	add	a2,a2,a5
    800052e8:	e204                	sd	s1,0(a2)
      return fd;
    800052ea:	b7f5                	j	800052d6 <fdalloc+0x2c>

00000000800052ec <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800052ec:	715d                	addi	sp,sp,-80
    800052ee:	e486                	sd	ra,72(sp)
    800052f0:	e0a2                	sd	s0,64(sp)
    800052f2:	fc26                	sd	s1,56(sp)
    800052f4:	f84a                	sd	s2,48(sp)
    800052f6:	f44e                	sd	s3,40(sp)
    800052f8:	f052                	sd	s4,32(sp)
    800052fa:	ec56                	sd	s5,24(sp)
    800052fc:	e85a                	sd	s6,16(sp)
    800052fe:	0880                	addi	s0,sp,80
    80005300:	8b2e                	mv	s6,a1
    80005302:	89b2                	mv	s3,a2
    80005304:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005306:	fb040593          	addi	a1,s0,-80
    8000530a:	fffff097          	auipc	ra,0xfffff
    8000530e:	e3c080e7          	jalr	-452(ra) # 80004146 <nameiparent>
    80005312:	84aa                	mv	s1,a0
    80005314:	14050f63          	beqz	a0,80005472 <create+0x186>
    return 0;

  ilock(dp);
    80005318:	ffffe097          	auipc	ra,0xffffe
    8000531c:	66a080e7          	jalr	1642(ra) # 80003982 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005320:	4601                	li	a2,0
    80005322:	fb040593          	addi	a1,s0,-80
    80005326:	8526                	mv	a0,s1
    80005328:	fffff097          	auipc	ra,0xfffff
    8000532c:	b3e080e7          	jalr	-1218(ra) # 80003e66 <dirlookup>
    80005330:	8aaa                	mv	s5,a0
    80005332:	c931                	beqz	a0,80005386 <create+0x9a>
    iunlockput(dp);
    80005334:	8526                	mv	a0,s1
    80005336:	fffff097          	auipc	ra,0xfffff
    8000533a:	8ae080e7          	jalr	-1874(ra) # 80003be4 <iunlockput>
    ilock(ip);
    8000533e:	8556                	mv	a0,s5
    80005340:	ffffe097          	auipc	ra,0xffffe
    80005344:	642080e7          	jalr	1602(ra) # 80003982 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005348:	000b059b          	sext.w	a1,s6
    8000534c:	4789                	li	a5,2
    8000534e:	02f59563          	bne	a1,a5,80005378 <create+0x8c>
    80005352:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdb0f4>
    80005356:	37f9                	addiw	a5,a5,-2
    80005358:	17c2                	slli	a5,a5,0x30
    8000535a:	93c1                	srli	a5,a5,0x30
    8000535c:	4705                	li	a4,1
    8000535e:	00f76d63          	bltu	a4,a5,80005378 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005362:	8556                	mv	a0,s5
    80005364:	60a6                	ld	ra,72(sp)
    80005366:	6406                	ld	s0,64(sp)
    80005368:	74e2                	ld	s1,56(sp)
    8000536a:	7942                	ld	s2,48(sp)
    8000536c:	79a2                	ld	s3,40(sp)
    8000536e:	7a02                	ld	s4,32(sp)
    80005370:	6ae2                	ld	s5,24(sp)
    80005372:	6b42                	ld	s6,16(sp)
    80005374:	6161                	addi	sp,sp,80
    80005376:	8082                	ret
    iunlockput(ip);
    80005378:	8556                	mv	a0,s5
    8000537a:	fffff097          	auipc	ra,0xfffff
    8000537e:	86a080e7          	jalr	-1942(ra) # 80003be4 <iunlockput>
    return 0;
    80005382:	4a81                	li	s5,0
    80005384:	bff9                	j	80005362 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005386:	85da                	mv	a1,s6
    80005388:	4088                	lw	a0,0(s1)
    8000538a:	ffffe097          	auipc	ra,0xffffe
    8000538e:	45c080e7          	jalr	1116(ra) # 800037e6 <ialloc>
    80005392:	8a2a                	mv	s4,a0
    80005394:	c539                	beqz	a0,800053e2 <create+0xf6>
  ilock(ip);
    80005396:	ffffe097          	auipc	ra,0xffffe
    8000539a:	5ec080e7          	jalr	1516(ra) # 80003982 <ilock>
  ip->major = major;
    8000539e:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800053a2:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800053a6:	4905                	li	s2,1
    800053a8:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800053ac:	8552                	mv	a0,s4
    800053ae:	ffffe097          	auipc	ra,0xffffe
    800053b2:	50a080e7          	jalr	1290(ra) # 800038b8 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800053b6:	000b059b          	sext.w	a1,s6
    800053ba:	03258b63          	beq	a1,s2,800053f0 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    800053be:	004a2603          	lw	a2,4(s4)
    800053c2:	fb040593          	addi	a1,s0,-80
    800053c6:	8526                	mv	a0,s1
    800053c8:	fffff097          	auipc	ra,0xfffff
    800053cc:	cae080e7          	jalr	-850(ra) # 80004076 <dirlink>
    800053d0:	06054f63          	bltz	a0,8000544e <create+0x162>
  iunlockput(dp);
    800053d4:	8526                	mv	a0,s1
    800053d6:	fffff097          	auipc	ra,0xfffff
    800053da:	80e080e7          	jalr	-2034(ra) # 80003be4 <iunlockput>
  return ip;
    800053de:	8ad2                	mv	s5,s4
    800053e0:	b749                	j	80005362 <create+0x76>
    iunlockput(dp);
    800053e2:	8526                	mv	a0,s1
    800053e4:	fffff097          	auipc	ra,0xfffff
    800053e8:	800080e7          	jalr	-2048(ra) # 80003be4 <iunlockput>
    return 0;
    800053ec:	8ad2                	mv	s5,s4
    800053ee:	bf95                	j	80005362 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800053f0:	004a2603          	lw	a2,4(s4)
    800053f4:	00003597          	auipc	a1,0x3
    800053f8:	30c58593          	addi	a1,a1,780 # 80008700 <syscalls+0x2b0>
    800053fc:	8552                	mv	a0,s4
    800053fe:	fffff097          	auipc	ra,0xfffff
    80005402:	c78080e7          	jalr	-904(ra) # 80004076 <dirlink>
    80005406:	04054463          	bltz	a0,8000544e <create+0x162>
    8000540a:	40d0                	lw	a2,4(s1)
    8000540c:	00003597          	auipc	a1,0x3
    80005410:	2fc58593          	addi	a1,a1,764 # 80008708 <syscalls+0x2b8>
    80005414:	8552                	mv	a0,s4
    80005416:	fffff097          	auipc	ra,0xfffff
    8000541a:	c60080e7          	jalr	-928(ra) # 80004076 <dirlink>
    8000541e:	02054863          	bltz	a0,8000544e <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    80005422:	004a2603          	lw	a2,4(s4)
    80005426:	fb040593          	addi	a1,s0,-80
    8000542a:	8526                	mv	a0,s1
    8000542c:	fffff097          	auipc	ra,0xfffff
    80005430:	c4a080e7          	jalr	-950(ra) # 80004076 <dirlink>
    80005434:	00054d63          	bltz	a0,8000544e <create+0x162>
    dp->nlink++;  // for ".."
    80005438:	04a4d783          	lhu	a5,74(s1)
    8000543c:	2785                	addiw	a5,a5,1
    8000543e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005442:	8526                	mv	a0,s1
    80005444:	ffffe097          	auipc	ra,0xffffe
    80005448:	474080e7          	jalr	1140(ra) # 800038b8 <iupdate>
    8000544c:	b761                	j	800053d4 <create+0xe8>
  ip->nlink = 0;
    8000544e:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005452:	8552                	mv	a0,s4
    80005454:	ffffe097          	auipc	ra,0xffffe
    80005458:	464080e7          	jalr	1124(ra) # 800038b8 <iupdate>
  iunlockput(ip);
    8000545c:	8552                	mv	a0,s4
    8000545e:	ffffe097          	auipc	ra,0xffffe
    80005462:	786080e7          	jalr	1926(ra) # 80003be4 <iunlockput>
  iunlockput(dp);
    80005466:	8526                	mv	a0,s1
    80005468:	ffffe097          	auipc	ra,0xffffe
    8000546c:	77c080e7          	jalr	1916(ra) # 80003be4 <iunlockput>
  return 0;
    80005470:	bdcd                	j	80005362 <create+0x76>
    return 0;
    80005472:	8aaa                	mv	s5,a0
    80005474:	b5fd                	j	80005362 <create+0x76>

0000000080005476 <sys_dup>:
{
    80005476:	7179                	addi	sp,sp,-48
    80005478:	f406                	sd	ra,40(sp)
    8000547a:	f022                	sd	s0,32(sp)
    8000547c:	ec26                	sd	s1,24(sp)
    8000547e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005480:	fd840613          	addi	a2,s0,-40
    80005484:	4581                	li	a1,0
    80005486:	4501                	li	a0,0
    80005488:	00000097          	auipc	ra,0x0
    8000548c:	dc2080e7          	jalr	-574(ra) # 8000524a <argfd>
    return -1;
    80005490:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005492:	02054363          	bltz	a0,800054b8 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005496:	fd843503          	ld	a0,-40(s0)
    8000549a:	00000097          	auipc	ra,0x0
    8000549e:	e10080e7          	jalr	-496(ra) # 800052aa <fdalloc>
    800054a2:	84aa                	mv	s1,a0
    return -1;
    800054a4:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800054a6:	00054963          	bltz	a0,800054b8 <sys_dup+0x42>
  filedup(f);
    800054aa:	fd843503          	ld	a0,-40(s0)
    800054ae:	fffff097          	auipc	ra,0xfffff
    800054b2:	310080e7          	jalr	784(ra) # 800047be <filedup>
  return fd;
    800054b6:	87a6                	mv	a5,s1
}
    800054b8:	853e                	mv	a0,a5
    800054ba:	70a2                	ld	ra,40(sp)
    800054bc:	7402                	ld	s0,32(sp)
    800054be:	64e2                	ld	s1,24(sp)
    800054c0:	6145                	addi	sp,sp,48
    800054c2:	8082                	ret

00000000800054c4 <sys_read>:
{
    800054c4:	7179                	addi	sp,sp,-48
    800054c6:	f406                	sd	ra,40(sp)
    800054c8:	f022                	sd	s0,32(sp)
    800054ca:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800054cc:	fd840593          	addi	a1,s0,-40
    800054d0:	4505                	li	a0,1
    800054d2:	ffffd097          	auipc	ra,0xffffd
    800054d6:	7e6080e7          	jalr	2022(ra) # 80002cb8 <argaddr>
  argint(2, &n);
    800054da:	fe440593          	addi	a1,s0,-28
    800054de:	4509                	li	a0,2
    800054e0:	ffffd097          	auipc	ra,0xffffd
    800054e4:	7b8080e7          	jalr	1976(ra) # 80002c98 <argint>
  if(argfd(0, 0, &f) < 0)
    800054e8:	fe840613          	addi	a2,s0,-24
    800054ec:	4581                	li	a1,0
    800054ee:	4501                	li	a0,0
    800054f0:	00000097          	auipc	ra,0x0
    800054f4:	d5a080e7          	jalr	-678(ra) # 8000524a <argfd>
    800054f8:	87aa                	mv	a5,a0
    return -1;
    800054fa:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800054fc:	0007cc63          	bltz	a5,80005514 <sys_read+0x50>
  return fileread(f, p, n);
    80005500:	fe442603          	lw	a2,-28(s0)
    80005504:	fd843583          	ld	a1,-40(s0)
    80005508:	fe843503          	ld	a0,-24(s0)
    8000550c:	fffff097          	auipc	ra,0xfffff
    80005510:	43e080e7          	jalr	1086(ra) # 8000494a <fileread>
}
    80005514:	70a2                	ld	ra,40(sp)
    80005516:	7402                	ld	s0,32(sp)
    80005518:	6145                	addi	sp,sp,48
    8000551a:	8082                	ret

000000008000551c <sys_write>:
{
    8000551c:	7179                	addi	sp,sp,-48
    8000551e:	f406                	sd	ra,40(sp)
    80005520:	f022                	sd	s0,32(sp)
    80005522:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005524:	fd840593          	addi	a1,s0,-40
    80005528:	4505                	li	a0,1
    8000552a:	ffffd097          	auipc	ra,0xffffd
    8000552e:	78e080e7          	jalr	1934(ra) # 80002cb8 <argaddr>
  argint(2, &n);
    80005532:	fe440593          	addi	a1,s0,-28
    80005536:	4509                	li	a0,2
    80005538:	ffffd097          	auipc	ra,0xffffd
    8000553c:	760080e7          	jalr	1888(ra) # 80002c98 <argint>
  if(argfd(0, 0, &f) < 0)
    80005540:	fe840613          	addi	a2,s0,-24
    80005544:	4581                	li	a1,0
    80005546:	4501                	li	a0,0
    80005548:	00000097          	auipc	ra,0x0
    8000554c:	d02080e7          	jalr	-766(ra) # 8000524a <argfd>
    80005550:	87aa                	mv	a5,a0
    return -1;
    80005552:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005554:	0007cc63          	bltz	a5,8000556c <sys_write+0x50>
  return filewrite(f, p, n);
    80005558:	fe442603          	lw	a2,-28(s0)
    8000555c:	fd843583          	ld	a1,-40(s0)
    80005560:	fe843503          	ld	a0,-24(s0)
    80005564:	fffff097          	auipc	ra,0xfffff
    80005568:	4a8080e7          	jalr	1192(ra) # 80004a0c <filewrite>
}
    8000556c:	70a2                	ld	ra,40(sp)
    8000556e:	7402                	ld	s0,32(sp)
    80005570:	6145                	addi	sp,sp,48
    80005572:	8082                	ret

0000000080005574 <sys_close>:
{
    80005574:	1101                	addi	sp,sp,-32
    80005576:	ec06                	sd	ra,24(sp)
    80005578:	e822                	sd	s0,16(sp)
    8000557a:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000557c:	fe040613          	addi	a2,s0,-32
    80005580:	fec40593          	addi	a1,s0,-20
    80005584:	4501                	li	a0,0
    80005586:	00000097          	auipc	ra,0x0
    8000558a:	cc4080e7          	jalr	-828(ra) # 8000524a <argfd>
    return -1;
    8000558e:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005590:	02054463          	bltz	a0,800055b8 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005594:	ffffc097          	auipc	ra,0xffffc
    80005598:	418080e7          	jalr	1048(ra) # 800019ac <myproc>
    8000559c:	fec42783          	lw	a5,-20(s0)
    800055a0:	07e9                	addi	a5,a5,26
    800055a2:	078e                	slli	a5,a5,0x3
    800055a4:	97aa                	add	a5,a5,a0
    800055a6:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800055aa:	fe043503          	ld	a0,-32(s0)
    800055ae:	fffff097          	auipc	ra,0xfffff
    800055b2:	262080e7          	jalr	610(ra) # 80004810 <fileclose>
  return 0;
    800055b6:	4781                	li	a5,0
}
    800055b8:	853e                	mv	a0,a5
    800055ba:	60e2                	ld	ra,24(sp)
    800055bc:	6442                	ld	s0,16(sp)
    800055be:	6105                	addi	sp,sp,32
    800055c0:	8082                	ret

00000000800055c2 <sys_fstat>:
{
    800055c2:	1101                	addi	sp,sp,-32
    800055c4:	ec06                	sd	ra,24(sp)
    800055c6:	e822                	sd	s0,16(sp)
    800055c8:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800055ca:	fe040593          	addi	a1,s0,-32
    800055ce:	4505                	li	a0,1
    800055d0:	ffffd097          	auipc	ra,0xffffd
    800055d4:	6e8080e7          	jalr	1768(ra) # 80002cb8 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800055d8:	fe840613          	addi	a2,s0,-24
    800055dc:	4581                	li	a1,0
    800055de:	4501                	li	a0,0
    800055e0:	00000097          	auipc	ra,0x0
    800055e4:	c6a080e7          	jalr	-918(ra) # 8000524a <argfd>
    800055e8:	87aa                	mv	a5,a0
    return -1;
    800055ea:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800055ec:	0007ca63          	bltz	a5,80005600 <sys_fstat+0x3e>
  return filestat(f, st);
    800055f0:	fe043583          	ld	a1,-32(s0)
    800055f4:	fe843503          	ld	a0,-24(s0)
    800055f8:	fffff097          	auipc	ra,0xfffff
    800055fc:	2e0080e7          	jalr	736(ra) # 800048d8 <filestat>
}
    80005600:	60e2                	ld	ra,24(sp)
    80005602:	6442                	ld	s0,16(sp)
    80005604:	6105                	addi	sp,sp,32
    80005606:	8082                	ret

0000000080005608 <sys_link>:
{
    80005608:	7169                	addi	sp,sp,-304
    8000560a:	f606                	sd	ra,296(sp)
    8000560c:	f222                	sd	s0,288(sp)
    8000560e:	ee26                	sd	s1,280(sp)
    80005610:	ea4a                	sd	s2,272(sp)
    80005612:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005614:	08000613          	li	a2,128
    80005618:	ed040593          	addi	a1,s0,-304
    8000561c:	4501                	li	a0,0
    8000561e:	ffffd097          	auipc	ra,0xffffd
    80005622:	6ba080e7          	jalr	1722(ra) # 80002cd8 <argstr>
    return -1;
    80005626:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005628:	10054e63          	bltz	a0,80005744 <sys_link+0x13c>
    8000562c:	08000613          	li	a2,128
    80005630:	f5040593          	addi	a1,s0,-176
    80005634:	4505                	li	a0,1
    80005636:	ffffd097          	auipc	ra,0xffffd
    8000563a:	6a2080e7          	jalr	1698(ra) # 80002cd8 <argstr>
    return -1;
    8000563e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005640:	10054263          	bltz	a0,80005744 <sys_link+0x13c>
  begin_op();
    80005644:	fffff097          	auipc	ra,0xfffff
    80005648:	d00080e7          	jalr	-768(ra) # 80004344 <begin_op>
  if((ip = namei(old)) == 0){
    8000564c:	ed040513          	addi	a0,s0,-304
    80005650:	fffff097          	auipc	ra,0xfffff
    80005654:	ad8080e7          	jalr	-1320(ra) # 80004128 <namei>
    80005658:	84aa                	mv	s1,a0
    8000565a:	c551                	beqz	a0,800056e6 <sys_link+0xde>
  ilock(ip);
    8000565c:	ffffe097          	auipc	ra,0xffffe
    80005660:	326080e7          	jalr	806(ra) # 80003982 <ilock>
  if(ip->type == T_DIR){
    80005664:	04449703          	lh	a4,68(s1)
    80005668:	4785                	li	a5,1
    8000566a:	08f70463          	beq	a4,a5,800056f2 <sys_link+0xea>
  ip->nlink++;
    8000566e:	04a4d783          	lhu	a5,74(s1)
    80005672:	2785                	addiw	a5,a5,1
    80005674:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005678:	8526                	mv	a0,s1
    8000567a:	ffffe097          	auipc	ra,0xffffe
    8000567e:	23e080e7          	jalr	574(ra) # 800038b8 <iupdate>
  iunlock(ip);
    80005682:	8526                	mv	a0,s1
    80005684:	ffffe097          	auipc	ra,0xffffe
    80005688:	3c0080e7          	jalr	960(ra) # 80003a44 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000568c:	fd040593          	addi	a1,s0,-48
    80005690:	f5040513          	addi	a0,s0,-176
    80005694:	fffff097          	auipc	ra,0xfffff
    80005698:	ab2080e7          	jalr	-1358(ra) # 80004146 <nameiparent>
    8000569c:	892a                	mv	s2,a0
    8000569e:	c935                	beqz	a0,80005712 <sys_link+0x10a>
  ilock(dp);
    800056a0:	ffffe097          	auipc	ra,0xffffe
    800056a4:	2e2080e7          	jalr	738(ra) # 80003982 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800056a8:	00092703          	lw	a4,0(s2)
    800056ac:	409c                	lw	a5,0(s1)
    800056ae:	04f71d63          	bne	a4,a5,80005708 <sys_link+0x100>
    800056b2:	40d0                	lw	a2,4(s1)
    800056b4:	fd040593          	addi	a1,s0,-48
    800056b8:	854a                	mv	a0,s2
    800056ba:	fffff097          	auipc	ra,0xfffff
    800056be:	9bc080e7          	jalr	-1604(ra) # 80004076 <dirlink>
    800056c2:	04054363          	bltz	a0,80005708 <sys_link+0x100>
  iunlockput(dp);
    800056c6:	854a                	mv	a0,s2
    800056c8:	ffffe097          	auipc	ra,0xffffe
    800056cc:	51c080e7          	jalr	1308(ra) # 80003be4 <iunlockput>
  iput(ip);
    800056d0:	8526                	mv	a0,s1
    800056d2:	ffffe097          	auipc	ra,0xffffe
    800056d6:	46a080e7          	jalr	1130(ra) # 80003b3c <iput>
  end_op();
    800056da:	fffff097          	auipc	ra,0xfffff
    800056de:	cea080e7          	jalr	-790(ra) # 800043c4 <end_op>
  return 0;
    800056e2:	4781                	li	a5,0
    800056e4:	a085                	j	80005744 <sys_link+0x13c>
    end_op();
    800056e6:	fffff097          	auipc	ra,0xfffff
    800056ea:	cde080e7          	jalr	-802(ra) # 800043c4 <end_op>
    return -1;
    800056ee:	57fd                	li	a5,-1
    800056f0:	a891                	j	80005744 <sys_link+0x13c>
    iunlockput(ip);
    800056f2:	8526                	mv	a0,s1
    800056f4:	ffffe097          	auipc	ra,0xffffe
    800056f8:	4f0080e7          	jalr	1264(ra) # 80003be4 <iunlockput>
    end_op();
    800056fc:	fffff097          	auipc	ra,0xfffff
    80005700:	cc8080e7          	jalr	-824(ra) # 800043c4 <end_op>
    return -1;
    80005704:	57fd                	li	a5,-1
    80005706:	a83d                	j	80005744 <sys_link+0x13c>
    iunlockput(dp);
    80005708:	854a                	mv	a0,s2
    8000570a:	ffffe097          	auipc	ra,0xffffe
    8000570e:	4da080e7          	jalr	1242(ra) # 80003be4 <iunlockput>
  ilock(ip);
    80005712:	8526                	mv	a0,s1
    80005714:	ffffe097          	auipc	ra,0xffffe
    80005718:	26e080e7          	jalr	622(ra) # 80003982 <ilock>
  ip->nlink--;
    8000571c:	04a4d783          	lhu	a5,74(s1)
    80005720:	37fd                	addiw	a5,a5,-1
    80005722:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005726:	8526                	mv	a0,s1
    80005728:	ffffe097          	auipc	ra,0xffffe
    8000572c:	190080e7          	jalr	400(ra) # 800038b8 <iupdate>
  iunlockput(ip);
    80005730:	8526                	mv	a0,s1
    80005732:	ffffe097          	auipc	ra,0xffffe
    80005736:	4b2080e7          	jalr	1202(ra) # 80003be4 <iunlockput>
  end_op();
    8000573a:	fffff097          	auipc	ra,0xfffff
    8000573e:	c8a080e7          	jalr	-886(ra) # 800043c4 <end_op>
  return -1;
    80005742:	57fd                	li	a5,-1
}
    80005744:	853e                	mv	a0,a5
    80005746:	70b2                	ld	ra,296(sp)
    80005748:	7412                	ld	s0,288(sp)
    8000574a:	64f2                	ld	s1,280(sp)
    8000574c:	6952                	ld	s2,272(sp)
    8000574e:	6155                	addi	sp,sp,304
    80005750:	8082                	ret

0000000080005752 <sys_unlink>:
{
    80005752:	7151                	addi	sp,sp,-240
    80005754:	f586                	sd	ra,232(sp)
    80005756:	f1a2                	sd	s0,224(sp)
    80005758:	eda6                	sd	s1,216(sp)
    8000575a:	e9ca                	sd	s2,208(sp)
    8000575c:	e5ce                	sd	s3,200(sp)
    8000575e:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005760:	08000613          	li	a2,128
    80005764:	f3040593          	addi	a1,s0,-208
    80005768:	4501                	li	a0,0
    8000576a:	ffffd097          	auipc	ra,0xffffd
    8000576e:	56e080e7          	jalr	1390(ra) # 80002cd8 <argstr>
    80005772:	18054163          	bltz	a0,800058f4 <sys_unlink+0x1a2>
  begin_op();
    80005776:	fffff097          	auipc	ra,0xfffff
    8000577a:	bce080e7          	jalr	-1074(ra) # 80004344 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000577e:	fb040593          	addi	a1,s0,-80
    80005782:	f3040513          	addi	a0,s0,-208
    80005786:	fffff097          	auipc	ra,0xfffff
    8000578a:	9c0080e7          	jalr	-1600(ra) # 80004146 <nameiparent>
    8000578e:	84aa                	mv	s1,a0
    80005790:	c979                	beqz	a0,80005866 <sys_unlink+0x114>
  ilock(dp);
    80005792:	ffffe097          	auipc	ra,0xffffe
    80005796:	1f0080e7          	jalr	496(ra) # 80003982 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000579a:	00003597          	auipc	a1,0x3
    8000579e:	f6658593          	addi	a1,a1,-154 # 80008700 <syscalls+0x2b0>
    800057a2:	fb040513          	addi	a0,s0,-80
    800057a6:	ffffe097          	auipc	ra,0xffffe
    800057aa:	6a6080e7          	jalr	1702(ra) # 80003e4c <namecmp>
    800057ae:	14050a63          	beqz	a0,80005902 <sys_unlink+0x1b0>
    800057b2:	00003597          	auipc	a1,0x3
    800057b6:	f5658593          	addi	a1,a1,-170 # 80008708 <syscalls+0x2b8>
    800057ba:	fb040513          	addi	a0,s0,-80
    800057be:	ffffe097          	auipc	ra,0xffffe
    800057c2:	68e080e7          	jalr	1678(ra) # 80003e4c <namecmp>
    800057c6:	12050e63          	beqz	a0,80005902 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800057ca:	f2c40613          	addi	a2,s0,-212
    800057ce:	fb040593          	addi	a1,s0,-80
    800057d2:	8526                	mv	a0,s1
    800057d4:	ffffe097          	auipc	ra,0xffffe
    800057d8:	692080e7          	jalr	1682(ra) # 80003e66 <dirlookup>
    800057dc:	892a                	mv	s2,a0
    800057de:	12050263          	beqz	a0,80005902 <sys_unlink+0x1b0>
  ilock(ip);
    800057e2:	ffffe097          	auipc	ra,0xffffe
    800057e6:	1a0080e7          	jalr	416(ra) # 80003982 <ilock>
  if(ip->nlink < 1)
    800057ea:	04a91783          	lh	a5,74(s2)
    800057ee:	08f05263          	blez	a5,80005872 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800057f2:	04491703          	lh	a4,68(s2)
    800057f6:	4785                	li	a5,1
    800057f8:	08f70563          	beq	a4,a5,80005882 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800057fc:	4641                	li	a2,16
    800057fe:	4581                	li	a1,0
    80005800:	fc040513          	addi	a0,s0,-64
    80005804:	ffffb097          	auipc	ra,0xffffb
    80005808:	4ce080e7          	jalr	1230(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000580c:	4741                	li	a4,16
    8000580e:	f2c42683          	lw	a3,-212(s0)
    80005812:	fc040613          	addi	a2,s0,-64
    80005816:	4581                	li	a1,0
    80005818:	8526                	mv	a0,s1
    8000581a:	ffffe097          	auipc	ra,0xffffe
    8000581e:	514080e7          	jalr	1300(ra) # 80003d2e <writei>
    80005822:	47c1                	li	a5,16
    80005824:	0af51563          	bne	a0,a5,800058ce <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005828:	04491703          	lh	a4,68(s2)
    8000582c:	4785                	li	a5,1
    8000582e:	0af70863          	beq	a4,a5,800058de <sys_unlink+0x18c>
  iunlockput(dp);
    80005832:	8526                	mv	a0,s1
    80005834:	ffffe097          	auipc	ra,0xffffe
    80005838:	3b0080e7          	jalr	944(ra) # 80003be4 <iunlockput>
  ip->nlink--;
    8000583c:	04a95783          	lhu	a5,74(s2)
    80005840:	37fd                	addiw	a5,a5,-1
    80005842:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005846:	854a                	mv	a0,s2
    80005848:	ffffe097          	auipc	ra,0xffffe
    8000584c:	070080e7          	jalr	112(ra) # 800038b8 <iupdate>
  iunlockput(ip);
    80005850:	854a                	mv	a0,s2
    80005852:	ffffe097          	auipc	ra,0xffffe
    80005856:	392080e7          	jalr	914(ra) # 80003be4 <iunlockput>
  end_op();
    8000585a:	fffff097          	auipc	ra,0xfffff
    8000585e:	b6a080e7          	jalr	-1174(ra) # 800043c4 <end_op>
  return 0;
    80005862:	4501                	li	a0,0
    80005864:	a84d                	j	80005916 <sys_unlink+0x1c4>
    end_op();
    80005866:	fffff097          	auipc	ra,0xfffff
    8000586a:	b5e080e7          	jalr	-1186(ra) # 800043c4 <end_op>
    return -1;
    8000586e:	557d                	li	a0,-1
    80005870:	a05d                	j	80005916 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005872:	00003517          	auipc	a0,0x3
    80005876:	e9e50513          	addi	a0,a0,-354 # 80008710 <syscalls+0x2c0>
    8000587a:	ffffb097          	auipc	ra,0xffffb
    8000587e:	cc4080e7          	jalr	-828(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005882:	04c92703          	lw	a4,76(s2)
    80005886:	02000793          	li	a5,32
    8000588a:	f6e7f9e3          	bgeu	a5,a4,800057fc <sys_unlink+0xaa>
    8000588e:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005892:	4741                	li	a4,16
    80005894:	86ce                	mv	a3,s3
    80005896:	f1840613          	addi	a2,s0,-232
    8000589a:	4581                	li	a1,0
    8000589c:	854a                	mv	a0,s2
    8000589e:	ffffe097          	auipc	ra,0xffffe
    800058a2:	398080e7          	jalr	920(ra) # 80003c36 <readi>
    800058a6:	47c1                	li	a5,16
    800058a8:	00f51b63          	bne	a0,a5,800058be <sys_unlink+0x16c>
    if(de.inum != 0)
    800058ac:	f1845783          	lhu	a5,-232(s0)
    800058b0:	e7a1                	bnez	a5,800058f8 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800058b2:	29c1                	addiw	s3,s3,16
    800058b4:	04c92783          	lw	a5,76(s2)
    800058b8:	fcf9ede3          	bltu	s3,a5,80005892 <sys_unlink+0x140>
    800058bc:	b781                	j	800057fc <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800058be:	00003517          	auipc	a0,0x3
    800058c2:	e6a50513          	addi	a0,a0,-406 # 80008728 <syscalls+0x2d8>
    800058c6:	ffffb097          	auipc	ra,0xffffb
    800058ca:	c78080e7          	jalr	-904(ra) # 8000053e <panic>
    panic("unlink: writei");
    800058ce:	00003517          	auipc	a0,0x3
    800058d2:	e7250513          	addi	a0,a0,-398 # 80008740 <syscalls+0x2f0>
    800058d6:	ffffb097          	auipc	ra,0xffffb
    800058da:	c68080e7          	jalr	-920(ra) # 8000053e <panic>
    dp->nlink--;
    800058de:	04a4d783          	lhu	a5,74(s1)
    800058e2:	37fd                	addiw	a5,a5,-1
    800058e4:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800058e8:	8526                	mv	a0,s1
    800058ea:	ffffe097          	auipc	ra,0xffffe
    800058ee:	fce080e7          	jalr	-50(ra) # 800038b8 <iupdate>
    800058f2:	b781                	j	80005832 <sys_unlink+0xe0>
    return -1;
    800058f4:	557d                	li	a0,-1
    800058f6:	a005                	j	80005916 <sys_unlink+0x1c4>
    iunlockput(ip);
    800058f8:	854a                	mv	a0,s2
    800058fa:	ffffe097          	auipc	ra,0xffffe
    800058fe:	2ea080e7          	jalr	746(ra) # 80003be4 <iunlockput>
  iunlockput(dp);
    80005902:	8526                	mv	a0,s1
    80005904:	ffffe097          	auipc	ra,0xffffe
    80005908:	2e0080e7          	jalr	736(ra) # 80003be4 <iunlockput>
  end_op();
    8000590c:	fffff097          	auipc	ra,0xfffff
    80005910:	ab8080e7          	jalr	-1352(ra) # 800043c4 <end_op>
  return -1;
    80005914:	557d                	li	a0,-1
}
    80005916:	70ae                	ld	ra,232(sp)
    80005918:	740e                	ld	s0,224(sp)
    8000591a:	64ee                	ld	s1,216(sp)
    8000591c:	694e                	ld	s2,208(sp)
    8000591e:	69ae                	ld	s3,200(sp)
    80005920:	616d                	addi	sp,sp,240
    80005922:	8082                	ret

0000000080005924 <sys_open>:

uint64
sys_open(void)
{
    80005924:	7131                	addi	sp,sp,-192
    80005926:	fd06                	sd	ra,184(sp)
    80005928:	f922                	sd	s0,176(sp)
    8000592a:	f526                	sd	s1,168(sp)
    8000592c:	f14a                	sd	s2,160(sp)
    8000592e:	ed4e                	sd	s3,152(sp)
    80005930:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005932:	f4c40593          	addi	a1,s0,-180
    80005936:	4505                	li	a0,1
    80005938:	ffffd097          	auipc	ra,0xffffd
    8000593c:	360080e7          	jalr	864(ra) # 80002c98 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005940:	08000613          	li	a2,128
    80005944:	f5040593          	addi	a1,s0,-176
    80005948:	4501                	li	a0,0
    8000594a:	ffffd097          	auipc	ra,0xffffd
    8000594e:	38e080e7          	jalr	910(ra) # 80002cd8 <argstr>
    80005952:	87aa                	mv	a5,a0
    return -1;
    80005954:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005956:	0a07c963          	bltz	a5,80005a08 <sys_open+0xe4>

  begin_op();
    8000595a:	fffff097          	auipc	ra,0xfffff
    8000595e:	9ea080e7          	jalr	-1558(ra) # 80004344 <begin_op>

  if(omode & O_CREATE){
    80005962:	f4c42783          	lw	a5,-180(s0)
    80005966:	2007f793          	andi	a5,a5,512
    8000596a:	cfc5                	beqz	a5,80005a22 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    8000596c:	4681                	li	a3,0
    8000596e:	4601                	li	a2,0
    80005970:	4589                	li	a1,2
    80005972:	f5040513          	addi	a0,s0,-176
    80005976:	00000097          	auipc	ra,0x0
    8000597a:	976080e7          	jalr	-1674(ra) # 800052ec <create>
    8000597e:	84aa                	mv	s1,a0
    if(ip == 0){
    80005980:	c959                	beqz	a0,80005a16 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005982:	04449703          	lh	a4,68(s1)
    80005986:	478d                	li	a5,3
    80005988:	00f71763          	bne	a4,a5,80005996 <sys_open+0x72>
    8000598c:	0464d703          	lhu	a4,70(s1)
    80005990:	47a5                	li	a5,9
    80005992:	0ce7ed63          	bltu	a5,a4,80005a6c <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005996:	fffff097          	auipc	ra,0xfffff
    8000599a:	dbe080e7          	jalr	-578(ra) # 80004754 <filealloc>
    8000599e:	89aa                	mv	s3,a0
    800059a0:	10050363          	beqz	a0,80005aa6 <sys_open+0x182>
    800059a4:	00000097          	auipc	ra,0x0
    800059a8:	906080e7          	jalr	-1786(ra) # 800052aa <fdalloc>
    800059ac:	892a                	mv	s2,a0
    800059ae:	0e054763          	bltz	a0,80005a9c <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800059b2:	04449703          	lh	a4,68(s1)
    800059b6:	478d                	li	a5,3
    800059b8:	0cf70563          	beq	a4,a5,80005a82 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800059bc:	4789                	li	a5,2
    800059be:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800059c2:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800059c6:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    800059ca:	f4c42783          	lw	a5,-180(s0)
    800059ce:	0017c713          	xori	a4,a5,1
    800059d2:	8b05                	andi	a4,a4,1
    800059d4:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800059d8:	0037f713          	andi	a4,a5,3
    800059dc:	00e03733          	snez	a4,a4
    800059e0:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800059e4:	4007f793          	andi	a5,a5,1024
    800059e8:	c791                	beqz	a5,800059f4 <sys_open+0xd0>
    800059ea:	04449703          	lh	a4,68(s1)
    800059ee:	4789                	li	a5,2
    800059f0:	0af70063          	beq	a4,a5,80005a90 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    800059f4:	8526                	mv	a0,s1
    800059f6:	ffffe097          	auipc	ra,0xffffe
    800059fa:	04e080e7          	jalr	78(ra) # 80003a44 <iunlock>
  end_op();
    800059fe:	fffff097          	auipc	ra,0xfffff
    80005a02:	9c6080e7          	jalr	-1594(ra) # 800043c4 <end_op>

  return fd;
    80005a06:	854a                	mv	a0,s2
}
    80005a08:	70ea                	ld	ra,184(sp)
    80005a0a:	744a                	ld	s0,176(sp)
    80005a0c:	74aa                	ld	s1,168(sp)
    80005a0e:	790a                	ld	s2,160(sp)
    80005a10:	69ea                	ld	s3,152(sp)
    80005a12:	6129                	addi	sp,sp,192
    80005a14:	8082                	ret
      end_op();
    80005a16:	fffff097          	auipc	ra,0xfffff
    80005a1a:	9ae080e7          	jalr	-1618(ra) # 800043c4 <end_op>
      return -1;
    80005a1e:	557d                	li	a0,-1
    80005a20:	b7e5                	j	80005a08 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005a22:	f5040513          	addi	a0,s0,-176
    80005a26:	ffffe097          	auipc	ra,0xffffe
    80005a2a:	702080e7          	jalr	1794(ra) # 80004128 <namei>
    80005a2e:	84aa                	mv	s1,a0
    80005a30:	c905                	beqz	a0,80005a60 <sys_open+0x13c>
    ilock(ip);
    80005a32:	ffffe097          	auipc	ra,0xffffe
    80005a36:	f50080e7          	jalr	-176(ra) # 80003982 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005a3a:	04449703          	lh	a4,68(s1)
    80005a3e:	4785                	li	a5,1
    80005a40:	f4f711e3          	bne	a4,a5,80005982 <sys_open+0x5e>
    80005a44:	f4c42783          	lw	a5,-180(s0)
    80005a48:	d7b9                	beqz	a5,80005996 <sys_open+0x72>
      iunlockput(ip);
    80005a4a:	8526                	mv	a0,s1
    80005a4c:	ffffe097          	auipc	ra,0xffffe
    80005a50:	198080e7          	jalr	408(ra) # 80003be4 <iunlockput>
      end_op();
    80005a54:	fffff097          	auipc	ra,0xfffff
    80005a58:	970080e7          	jalr	-1680(ra) # 800043c4 <end_op>
      return -1;
    80005a5c:	557d                	li	a0,-1
    80005a5e:	b76d                	j	80005a08 <sys_open+0xe4>
      end_op();
    80005a60:	fffff097          	auipc	ra,0xfffff
    80005a64:	964080e7          	jalr	-1692(ra) # 800043c4 <end_op>
      return -1;
    80005a68:	557d                	li	a0,-1
    80005a6a:	bf79                	j	80005a08 <sys_open+0xe4>
    iunlockput(ip);
    80005a6c:	8526                	mv	a0,s1
    80005a6e:	ffffe097          	auipc	ra,0xffffe
    80005a72:	176080e7          	jalr	374(ra) # 80003be4 <iunlockput>
    end_op();
    80005a76:	fffff097          	auipc	ra,0xfffff
    80005a7a:	94e080e7          	jalr	-1714(ra) # 800043c4 <end_op>
    return -1;
    80005a7e:	557d                	li	a0,-1
    80005a80:	b761                	j	80005a08 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005a82:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005a86:	04649783          	lh	a5,70(s1)
    80005a8a:	02f99223          	sh	a5,36(s3)
    80005a8e:	bf25                	j	800059c6 <sys_open+0xa2>
    itrunc(ip);
    80005a90:	8526                	mv	a0,s1
    80005a92:	ffffe097          	auipc	ra,0xffffe
    80005a96:	ffe080e7          	jalr	-2(ra) # 80003a90 <itrunc>
    80005a9a:	bfa9                	j	800059f4 <sys_open+0xd0>
      fileclose(f);
    80005a9c:	854e                	mv	a0,s3
    80005a9e:	fffff097          	auipc	ra,0xfffff
    80005aa2:	d72080e7          	jalr	-654(ra) # 80004810 <fileclose>
    iunlockput(ip);
    80005aa6:	8526                	mv	a0,s1
    80005aa8:	ffffe097          	auipc	ra,0xffffe
    80005aac:	13c080e7          	jalr	316(ra) # 80003be4 <iunlockput>
    end_op();
    80005ab0:	fffff097          	auipc	ra,0xfffff
    80005ab4:	914080e7          	jalr	-1772(ra) # 800043c4 <end_op>
    return -1;
    80005ab8:	557d                	li	a0,-1
    80005aba:	b7b9                	j	80005a08 <sys_open+0xe4>

0000000080005abc <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005abc:	7175                	addi	sp,sp,-144
    80005abe:	e506                	sd	ra,136(sp)
    80005ac0:	e122                	sd	s0,128(sp)
    80005ac2:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005ac4:	fffff097          	auipc	ra,0xfffff
    80005ac8:	880080e7          	jalr	-1920(ra) # 80004344 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005acc:	08000613          	li	a2,128
    80005ad0:	f7040593          	addi	a1,s0,-144
    80005ad4:	4501                	li	a0,0
    80005ad6:	ffffd097          	auipc	ra,0xffffd
    80005ada:	202080e7          	jalr	514(ra) # 80002cd8 <argstr>
    80005ade:	02054963          	bltz	a0,80005b10 <sys_mkdir+0x54>
    80005ae2:	4681                	li	a3,0
    80005ae4:	4601                	li	a2,0
    80005ae6:	4585                	li	a1,1
    80005ae8:	f7040513          	addi	a0,s0,-144
    80005aec:	00000097          	auipc	ra,0x0
    80005af0:	800080e7          	jalr	-2048(ra) # 800052ec <create>
    80005af4:	cd11                	beqz	a0,80005b10 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005af6:	ffffe097          	auipc	ra,0xffffe
    80005afa:	0ee080e7          	jalr	238(ra) # 80003be4 <iunlockput>
  end_op();
    80005afe:	fffff097          	auipc	ra,0xfffff
    80005b02:	8c6080e7          	jalr	-1850(ra) # 800043c4 <end_op>
  return 0;
    80005b06:	4501                	li	a0,0
}
    80005b08:	60aa                	ld	ra,136(sp)
    80005b0a:	640a                	ld	s0,128(sp)
    80005b0c:	6149                	addi	sp,sp,144
    80005b0e:	8082                	ret
    end_op();
    80005b10:	fffff097          	auipc	ra,0xfffff
    80005b14:	8b4080e7          	jalr	-1868(ra) # 800043c4 <end_op>
    return -1;
    80005b18:	557d                	li	a0,-1
    80005b1a:	b7fd                	j	80005b08 <sys_mkdir+0x4c>

0000000080005b1c <sys_mknod>:

uint64
sys_mknod(void)
{
    80005b1c:	7135                	addi	sp,sp,-160
    80005b1e:	ed06                	sd	ra,152(sp)
    80005b20:	e922                	sd	s0,144(sp)
    80005b22:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005b24:	fffff097          	auipc	ra,0xfffff
    80005b28:	820080e7          	jalr	-2016(ra) # 80004344 <begin_op>
  argint(1, &major);
    80005b2c:	f6c40593          	addi	a1,s0,-148
    80005b30:	4505                	li	a0,1
    80005b32:	ffffd097          	auipc	ra,0xffffd
    80005b36:	166080e7          	jalr	358(ra) # 80002c98 <argint>
  argint(2, &minor);
    80005b3a:	f6840593          	addi	a1,s0,-152
    80005b3e:	4509                	li	a0,2
    80005b40:	ffffd097          	auipc	ra,0xffffd
    80005b44:	158080e7          	jalr	344(ra) # 80002c98 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b48:	08000613          	li	a2,128
    80005b4c:	f7040593          	addi	a1,s0,-144
    80005b50:	4501                	li	a0,0
    80005b52:	ffffd097          	auipc	ra,0xffffd
    80005b56:	186080e7          	jalr	390(ra) # 80002cd8 <argstr>
    80005b5a:	02054b63          	bltz	a0,80005b90 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005b5e:	f6841683          	lh	a3,-152(s0)
    80005b62:	f6c41603          	lh	a2,-148(s0)
    80005b66:	458d                	li	a1,3
    80005b68:	f7040513          	addi	a0,s0,-144
    80005b6c:	fffff097          	auipc	ra,0xfffff
    80005b70:	780080e7          	jalr	1920(ra) # 800052ec <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b74:	cd11                	beqz	a0,80005b90 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b76:	ffffe097          	auipc	ra,0xffffe
    80005b7a:	06e080e7          	jalr	110(ra) # 80003be4 <iunlockput>
  end_op();
    80005b7e:	fffff097          	auipc	ra,0xfffff
    80005b82:	846080e7          	jalr	-1978(ra) # 800043c4 <end_op>
  return 0;
    80005b86:	4501                	li	a0,0
}
    80005b88:	60ea                	ld	ra,152(sp)
    80005b8a:	644a                	ld	s0,144(sp)
    80005b8c:	610d                	addi	sp,sp,160
    80005b8e:	8082                	ret
    end_op();
    80005b90:	fffff097          	auipc	ra,0xfffff
    80005b94:	834080e7          	jalr	-1996(ra) # 800043c4 <end_op>
    return -1;
    80005b98:	557d                	li	a0,-1
    80005b9a:	b7fd                	j	80005b88 <sys_mknod+0x6c>

0000000080005b9c <sys_chdir>:

uint64
sys_chdir(void)
{
    80005b9c:	7135                	addi	sp,sp,-160
    80005b9e:	ed06                	sd	ra,152(sp)
    80005ba0:	e922                	sd	s0,144(sp)
    80005ba2:	e526                	sd	s1,136(sp)
    80005ba4:	e14a                	sd	s2,128(sp)
    80005ba6:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005ba8:	ffffc097          	auipc	ra,0xffffc
    80005bac:	e04080e7          	jalr	-508(ra) # 800019ac <myproc>
    80005bb0:	892a                	mv	s2,a0
  
  begin_op();
    80005bb2:	ffffe097          	auipc	ra,0xffffe
    80005bb6:	792080e7          	jalr	1938(ra) # 80004344 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005bba:	08000613          	li	a2,128
    80005bbe:	f6040593          	addi	a1,s0,-160
    80005bc2:	4501                	li	a0,0
    80005bc4:	ffffd097          	auipc	ra,0xffffd
    80005bc8:	114080e7          	jalr	276(ra) # 80002cd8 <argstr>
    80005bcc:	04054b63          	bltz	a0,80005c22 <sys_chdir+0x86>
    80005bd0:	f6040513          	addi	a0,s0,-160
    80005bd4:	ffffe097          	auipc	ra,0xffffe
    80005bd8:	554080e7          	jalr	1364(ra) # 80004128 <namei>
    80005bdc:	84aa                	mv	s1,a0
    80005bde:	c131                	beqz	a0,80005c22 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005be0:	ffffe097          	auipc	ra,0xffffe
    80005be4:	da2080e7          	jalr	-606(ra) # 80003982 <ilock>
  if(ip->type != T_DIR){
    80005be8:	04449703          	lh	a4,68(s1)
    80005bec:	4785                	li	a5,1
    80005bee:	04f71063          	bne	a4,a5,80005c2e <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005bf2:	8526                	mv	a0,s1
    80005bf4:	ffffe097          	auipc	ra,0xffffe
    80005bf8:	e50080e7          	jalr	-432(ra) # 80003a44 <iunlock>
  iput(p->cwd);
    80005bfc:	15093503          	ld	a0,336(s2)
    80005c00:	ffffe097          	auipc	ra,0xffffe
    80005c04:	f3c080e7          	jalr	-196(ra) # 80003b3c <iput>
  end_op();
    80005c08:	ffffe097          	auipc	ra,0xffffe
    80005c0c:	7bc080e7          	jalr	1980(ra) # 800043c4 <end_op>
  p->cwd = ip;
    80005c10:	14993823          	sd	s1,336(s2)
  return 0;
    80005c14:	4501                	li	a0,0
}
    80005c16:	60ea                	ld	ra,152(sp)
    80005c18:	644a                	ld	s0,144(sp)
    80005c1a:	64aa                	ld	s1,136(sp)
    80005c1c:	690a                	ld	s2,128(sp)
    80005c1e:	610d                	addi	sp,sp,160
    80005c20:	8082                	ret
    end_op();
    80005c22:	ffffe097          	auipc	ra,0xffffe
    80005c26:	7a2080e7          	jalr	1954(ra) # 800043c4 <end_op>
    return -1;
    80005c2a:	557d                	li	a0,-1
    80005c2c:	b7ed                	j	80005c16 <sys_chdir+0x7a>
    iunlockput(ip);
    80005c2e:	8526                	mv	a0,s1
    80005c30:	ffffe097          	auipc	ra,0xffffe
    80005c34:	fb4080e7          	jalr	-76(ra) # 80003be4 <iunlockput>
    end_op();
    80005c38:	ffffe097          	auipc	ra,0xffffe
    80005c3c:	78c080e7          	jalr	1932(ra) # 800043c4 <end_op>
    return -1;
    80005c40:	557d                	li	a0,-1
    80005c42:	bfd1                	j	80005c16 <sys_chdir+0x7a>

0000000080005c44 <sys_exec>:

uint64
sys_exec(void)
{
    80005c44:	7145                	addi	sp,sp,-464
    80005c46:	e786                	sd	ra,456(sp)
    80005c48:	e3a2                	sd	s0,448(sp)
    80005c4a:	ff26                	sd	s1,440(sp)
    80005c4c:	fb4a                	sd	s2,432(sp)
    80005c4e:	f74e                	sd	s3,424(sp)
    80005c50:	f352                	sd	s4,416(sp)
    80005c52:	ef56                	sd	s5,408(sp)
    80005c54:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005c56:	e3840593          	addi	a1,s0,-456
    80005c5a:	4505                	li	a0,1
    80005c5c:	ffffd097          	auipc	ra,0xffffd
    80005c60:	05c080e7          	jalr	92(ra) # 80002cb8 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005c64:	08000613          	li	a2,128
    80005c68:	f4040593          	addi	a1,s0,-192
    80005c6c:	4501                	li	a0,0
    80005c6e:	ffffd097          	auipc	ra,0xffffd
    80005c72:	06a080e7          	jalr	106(ra) # 80002cd8 <argstr>
    80005c76:	87aa                	mv	a5,a0
    return -1;
    80005c78:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005c7a:	0c07c263          	bltz	a5,80005d3e <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005c7e:	10000613          	li	a2,256
    80005c82:	4581                	li	a1,0
    80005c84:	e4040513          	addi	a0,s0,-448
    80005c88:	ffffb097          	auipc	ra,0xffffb
    80005c8c:	04a080e7          	jalr	74(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005c90:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005c94:	89a6                	mv	s3,s1
    80005c96:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005c98:	02000a13          	li	s4,32
    80005c9c:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005ca0:	00391793          	slli	a5,s2,0x3
    80005ca4:	e3040593          	addi	a1,s0,-464
    80005ca8:	e3843503          	ld	a0,-456(s0)
    80005cac:	953e                	add	a0,a0,a5
    80005cae:	ffffd097          	auipc	ra,0xffffd
    80005cb2:	f4c080e7          	jalr	-180(ra) # 80002bfa <fetchaddr>
    80005cb6:	02054a63          	bltz	a0,80005cea <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005cba:	e3043783          	ld	a5,-464(s0)
    80005cbe:	c3b9                	beqz	a5,80005d04 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005cc0:	ffffb097          	auipc	ra,0xffffb
    80005cc4:	e26080e7          	jalr	-474(ra) # 80000ae6 <kalloc>
    80005cc8:	85aa                	mv	a1,a0
    80005cca:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005cce:	cd11                	beqz	a0,80005cea <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005cd0:	6605                	lui	a2,0x1
    80005cd2:	e3043503          	ld	a0,-464(s0)
    80005cd6:	ffffd097          	auipc	ra,0xffffd
    80005cda:	f76080e7          	jalr	-138(ra) # 80002c4c <fetchstr>
    80005cde:	00054663          	bltz	a0,80005cea <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005ce2:	0905                	addi	s2,s2,1
    80005ce4:	09a1                	addi	s3,s3,8
    80005ce6:	fb491be3          	bne	s2,s4,80005c9c <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cea:	10048913          	addi	s2,s1,256
    80005cee:	6088                	ld	a0,0(s1)
    80005cf0:	c531                	beqz	a0,80005d3c <sys_exec+0xf8>
    kfree(argv[i]);
    80005cf2:	ffffb097          	auipc	ra,0xffffb
    80005cf6:	cf8080e7          	jalr	-776(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cfa:	04a1                	addi	s1,s1,8
    80005cfc:	ff2499e3          	bne	s1,s2,80005cee <sys_exec+0xaa>
  return -1;
    80005d00:	557d                	li	a0,-1
    80005d02:	a835                	j	80005d3e <sys_exec+0xfa>
      argv[i] = 0;
    80005d04:	0a8e                	slli	s5,s5,0x3
    80005d06:	fc040793          	addi	a5,s0,-64
    80005d0a:	9abe                	add	s5,s5,a5
    80005d0c:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005d10:	e4040593          	addi	a1,s0,-448
    80005d14:	f4040513          	addi	a0,s0,-192
    80005d18:	fffff097          	auipc	ra,0xfffff
    80005d1c:	172080e7          	jalr	370(ra) # 80004e8a <exec>
    80005d20:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d22:	10048993          	addi	s3,s1,256
    80005d26:	6088                	ld	a0,0(s1)
    80005d28:	c901                	beqz	a0,80005d38 <sys_exec+0xf4>
    kfree(argv[i]);
    80005d2a:	ffffb097          	auipc	ra,0xffffb
    80005d2e:	cc0080e7          	jalr	-832(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d32:	04a1                	addi	s1,s1,8
    80005d34:	ff3499e3          	bne	s1,s3,80005d26 <sys_exec+0xe2>
  return ret;
    80005d38:	854a                	mv	a0,s2
    80005d3a:	a011                	j	80005d3e <sys_exec+0xfa>
  return -1;
    80005d3c:	557d                	li	a0,-1
}
    80005d3e:	60be                	ld	ra,456(sp)
    80005d40:	641e                	ld	s0,448(sp)
    80005d42:	74fa                	ld	s1,440(sp)
    80005d44:	795a                	ld	s2,432(sp)
    80005d46:	79ba                	ld	s3,424(sp)
    80005d48:	7a1a                	ld	s4,416(sp)
    80005d4a:	6afa                	ld	s5,408(sp)
    80005d4c:	6179                	addi	sp,sp,464
    80005d4e:	8082                	ret

0000000080005d50 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005d50:	7139                	addi	sp,sp,-64
    80005d52:	fc06                	sd	ra,56(sp)
    80005d54:	f822                	sd	s0,48(sp)
    80005d56:	f426                	sd	s1,40(sp)
    80005d58:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005d5a:	ffffc097          	auipc	ra,0xffffc
    80005d5e:	c52080e7          	jalr	-942(ra) # 800019ac <myproc>
    80005d62:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005d64:	fd840593          	addi	a1,s0,-40
    80005d68:	4501                	li	a0,0
    80005d6a:	ffffd097          	auipc	ra,0xffffd
    80005d6e:	f4e080e7          	jalr	-178(ra) # 80002cb8 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005d72:	fc840593          	addi	a1,s0,-56
    80005d76:	fd040513          	addi	a0,s0,-48
    80005d7a:	fffff097          	auipc	ra,0xfffff
    80005d7e:	dc6080e7          	jalr	-570(ra) # 80004b40 <pipealloc>
    return -1;
    80005d82:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005d84:	0c054463          	bltz	a0,80005e4c <sys_pipe+0xfc>
  fd0 = -1;
    80005d88:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005d8c:	fd043503          	ld	a0,-48(s0)
    80005d90:	fffff097          	auipc	ra,0xfffff
    80005d94:	51a080e7          	jalr	1306(ra) # 800052aa <fdalloc>
    80005d98:	fca42223          	sw	a0,-60(s0)
    80005d9c:	08054b63          	bltz	a0,80005e32 <sys_pipe+0xe2>
    80005da0:	fc843503          	ld	a0,-56(s0)
    80005da4:	fffff097          	auipc	ra,0xfffff
    80005da8:	506080e7          	jalr	1286(ra) # 800052aa <fdalloc>
    80005dac:	fca42023          	sw	a0,-64(s0)
    80005db0:	06054863          	bltz	a0,80005e20 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005db4:	4691                	li	a3,4
    80005db6:	fc440613          	addi	a2,s0,-60
    80005dba:	fd843583          	ld	a1,-40(s0)
    80005dbe:	68a8                	ld	a0,80(s1)
    80005dc0:	ffffc097          	auipc	ra,0xffffc
    80005dc4:	8a8080e7          	jalr	-1880(ra) # 80001668 <copyout>
    80005dc8:	02054063          	bltz	a0,80005de8 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005dcc:	4691                	li	a3,4
    80005dce:	fc040613          	addi	a2,s0,-64
    80005dd2:	fd843583          	ld	a1,-40(s0)
    80005dd6:	0591                	addi	a1,a1,4
    80005dd8:	68a8                	ld	a0,80(s1)
    80005dda:	ffffc097          	auipc	ra,0xffffc
    80005dde:	88e080e7          	jalr	-1906(ra) # 80001668 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005de2:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005de4:	06055463          	bgez	a0,80005e4c <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005de8:	fc442783          	lw	a5,-60(s0)
    80005dec:	07e9                	addi	a5,a5,26
    80005dee:	078e                	slli	a5,a5,0x3
    80005df0:	97a6                	add	a5,a5,s1
    80005df2:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005df6:	fc042503          	lw	a0,-64(s0)
    80005dfa:	0569                	addi	a0,a0,26
    80005dfc:	050e                	slli	a0,a0,0x3
    80005dfe:	94aa                	add	s1,s1,a0
    80005e00:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005e04:	fd043503          	ld	a0,-48(s0)
    80005e08:	fffff097          	auipc	ra,0xfffff
    80005e0c:	a08080e7          	jalr	-1528(ra) # 80004810 <fileclose>
    fileclose(wf);
    80005e10:	fc843503          	ld	a0,-56(s0)
    80005e14:	fffff097          	auipc	ra,0xfffff
    80005e18:	9fc080e7          	jalr	-1540(ra) # 80004810 <fileclose>
    return -1;
    80005e1c:	57fd                	li	a5,-1
    80005e1e:	a03d                	j	80005e4c <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005e20:	fc442783          	lw	a5,-60(s0)
    80005e24:	0007c763          	bltz	a5,80005e32 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005e28:	07e9                	addi	a5,a5,26
    80005e2a:	078e                	slli	a5,a5,0x3
    80005e2c:	94be                	add	s1,s1,a5
    80005e2e:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005e32:	fd043503          	ld	a0,-48(s0)
    80005e36:	fffff097          	auipc	ra,0xfffff
    80005e3a:	9da080e7          	jalr	-1574(ra) # 80004810 <fileclose>
    fileclose(wf);
    80005e3e:	fc843503          	ld	a0,-56(s0)
    80005e42:	fffff097          	auipc	ra,0xfffff
    80005e46:	9ce080e7          	jalr	-1586(ra) # 80004810 <fileclose>
    return -1;
    80005e4a:	57fd                	li	a5,-1
}
    80005e4c:	853e                	mv	a0,a5
    80005e4e:	70e2                	ld	ra,56(sp)
    80005e50:	7442                	ld	s0,48(sp)
    80005e52:	74a2                	ld	s1,40(sp)
    80005e54:	6121                	addi	sp,sp,64
    80005e56:	8082                	ret
	...

0000000080005e60 <kernelvec>:
    80005e60:	7111                	addi	sp,sp,-256
    80005e62:	e006                	sd	ra,0(sp)
    80005e64:	e40a                	sd	sp,8(sp)
    80005e66:	e80e                	sd	gp,16(sp)
    80005e68:	ec12                	sd	tp,24(sp)
    80005e6a:	f016                	sd	t0,32(sp)
    80005e6c:	f41a                	sd	t1,40(sp)
    80005e6e:	f81e                	sd	t2,48(sp)
    80005e70:	fc22                	sd	s0,56(sp)
    80005e72:	e0a6                	sd	s1,64(sp)
    80005e74:	e4aa                	sd	a0,72(sp)
    80005e76:	e8ae                	sd	a1,80(sp)
    80005e78:	ecb2                	sd	a2,88(sp)
    80005e7a:	f0b6                	sd	a3,96(sp)
    80005e7c:	f4ba                	sd	a4,104(sp)
    80005e7e:	f8be                	sd	a5,112(sp)
    80005e80:	fcc2                	sd	a6,120(sp)
    80005e82:	e146                	sd	a7,128(sp)
    80005e84:	e54a                	sd	s2,136(sp)
    80005e86:	e94e                	sd	s3,144(sp)
    80005e88:	ed52                	sd	s4,152(sp)
    80005e8a:	f156                	sd	s5,160(sp)
    80005e8c:	f55a                	sd	s6,168(sp)
    80005e8e:	f95e                	sd	s7,176(sp)
    80005e90:	fd62                	sd	s8,184(sp)
    80005e92:	e1e6                	sd	s9,192(sp)
    80005e94:	e5ea                	sd	s10,200(sp)
    80005e96:	e9ee                	sd	s11,208(sp)
    80005e98:	edf2                	sd	t3,216(sp)
    80005e9a:	f1f6                	sd	t4,224(sp)
    80005e9c:	f5fa                	sd	t5,232(sp)
    80005e9e:	f9fe                	sd	t6,240(sp)
    80005ea0:	c27fc0ef          	jal	ra,80002ac6 <kerneltrap>
    80005ea4:	6082                	ld	ra,0(sp)
    80005ea6:	6122                	ld	sp,8(sp)
    80005ea8:	61c2                	ld	gp,16(sp)
    80005eaa:	7282                	ld	t0,32(sp)
    80005eac:	7322                	ld	t1,40(sp)
    80005eae:	73c2                	ld	t2,48(sp)
    80005eb0:	7462                	ld	s0,56(sp)
    80005eb2:	6486                	ld	s1,64(sp)
    80005eb4:	6526                	ld	a0,72(sp)
    80005eb6:	65c6                	ld	a1,80(sp)
    80005eb8:	6666                	ld	a2,88(sp)
    80005eba:	7686                	ld	a3,96(sp)
    80005ebc:	7726                	ld	a4,104(sp)
    80005ebe:	77c6                	ld	a5,112(sp)
    80005ec0:	7866                	ld	a6,120(sp)
    80005ec2:	688a                	ld	a7,128(sp)
    80005ec4:	692a                	ld	s2,136(sp)
    80005ec6:	69ca                	ld	s3,144(sp)
    80005ec8:	6a6a                	ld	s4,152(sp)
    80005eca:	7a8a                	ld	s5,160(sp)
    80005ecc:	7b2a                	ld	s6,168(sp)
    80005ece:	7bca                	ld	s7,176(sp)
    80005ed0:	7c6a                	ld	s8,184(sp)
    80005ed2:	6c8e                	ld	s9,192(sp)
    80005ed4:	6d2e                	ld	s10,200(sp)
    80005ed6:	6dce                	ld	s11,208(sp)
    80005ed8:	6e6e                	ld	t3,216(sp)
    80005eda:	7e8e                	ld	t4,224(sp)
    80005edc:	7f2e                	ld	t5,232(sp)
    80005ede:	7fce                	ld	t6,240(sp)
    80005ee0:	6111                	addi	sp,sp,256
    80005ee2:	10200073          	sret
    80005ee6:	00000013          	nop
    80005eea:	00000013          	nop
    80005eee:	0001                	nop

0000000080005ef0 <timervec>:
    80005ef0:	34051573          	csrrw	a0,mscratch,a0
    80005ef4:	e10c                	sd	a1,0(a0)
    80005ef6:	e510                	sd	a2,8(a0)
    80005ef8:	e914                	sd	a3,16(a0)
    80005efa:	6d0c                	ld	a1,24(a0)
    80005efc:	7110                	ld	a2,32(a0)
    80005efe:	6194                	ld	a3,0(a1)
    80005f00:	96b2                	add	a3,a3,a2
    80005f02:	e194                	sd	a3,0(a1)
    80005f04:	4589                	li	a1,2
    80005f06:	14459073          	csrw	sip,a1
    80005f0a:	6914                	ld	a3,16(a0)
    80005f0c:	6510                	ld	a2,8(a0)
    80005f0e:	610c                	ld	a1,0(a0)
    80005f10:	34051573          	csrrw	a0,mscratch,a0
    80005f14:	30200073          	mret
	...

0000000080005f1a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005f1a:	1141                	addi	sp,sp,-16
    80005f1c:	e422                	sd	s0,8(sp)
    80005f1e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005f20:	0c0007b7          	lui	a5,0xc000
    80005f24:	4705                	li	a4,1
    80005f26:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005f28:	c3d8                	sw	a4,4(a5)
}
    80005f2a:	6422                	ld	s0,8(sp)
    80005f2c:	0141                	addi	sp,sp,16
    80005f2e:	8082                	ret

0000000080005f30 <plicinithart>:

void
plicinithart(void)
{
    80005f30:	1141                	addi	sp,sp,-16
    80005f32:	e406                	sd	ra,8(sp)
    80005f34:	e022                	sd	s0,0(sp)
    80005f36:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f38:	ffffc097          	auipc	ra,0xffffc
    80005f3c:	a48080e7          	jalr	-1464(ra) # 80001980 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005f40:	0085171b          	slliw	a4,a0,0x8
    80005f44:	0c0027b7          	lui	a5,0xc002
    80005f48:	97ba                	add	a5,a5,a4
    80005f4a:	40200713          	li	a4,1026
    80005f4e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005f52:	00d5151b          	slliw	a0,a0,0xd
    80005f56:	0c2017b7          	lui	a5,0xc201
    80005f5a:	953e                	add	a0,a0,a5
    80005f5c:	00052023          	sw	zero,0(a0)
}
    80005f60:	60a2                	ld	ra,8(sp)
    80005f62:	6402                	ld	s0,0(sp)
    80005f64:	0141                	addi	sp,sp,16
    80005f66:	8082                	ret

0000000080005f68 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005f68:	1141                	addi	sp,sp,-16
    80005f6a:	e406                	sd	ra,8(sp)
    80005f6c:	e022                	sd	s0,0(sp)
    80005f6e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f70:	ffffc097          	auipc	ra,0xffffc
    80005f74:	a10080e7          	jalr	-1520(ra) # 80001980 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005f78:	00d5179b          	slliw	a5,a0,0xd
    80005f7c:	0c201537          	lui	a0,0xc201
    80005f80:	953e                	add	a0,a0,a5
  return irq;
}
    80005f82:	4148                	lw	a0,4(a0)
    80005f84:	60a2                	ld	ra,8(sp)
    80005f86:	6402                	ld	s0,0(sp)
    80005f88:	0141                	addi	sp,sp,16
    80005f8a:	8082                	ret

0000000080005f8c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005f8c:	1101                	addi	sp,sp,-32
    80005f8e:	ec06                	sd	ra,24(sp)
    80005f90:	e822                	sd	s0,16(sp)
    80005f92:	e426                	sd	s1,8(sp)
    80005f94:	1000                	addi	s0,sp,32
    80005f96:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005f98:	ffffc097          	auipc	ra,0xffffc
    80005f9c:	9e8080e7          	jalr	-1560(ra) # 80001980 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005fa0:	00d5151b          	slliw	a0,a0,0xd
    80005fa4:	0c2017b7          	lui	a5,0xc201
    80005fa8:	97aa                	add	a5,a5,a0
    80005faa:	c3c4                	sw	s1,4(a5)
}
    80005fac:	60e2                	ld	ra,24(sp)
    80005fae:	6442                	ld	s0,16(sp)
    80005fb0:	64a2                	ld	s1,8(sp)
    80005fb2:	6105                	addi	sp,sp,32
    80005fb4:	8082                	ret

0000000080005fb6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005fb6:	1141                	addi	sp,sp,-16
    80005fb8:	e406                	sd	ra,8(sp)
    80005fba:	e022                	sd	s0,0(sp)
    80005fbc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005fbe:	479d                	li	a5,7
    80005fc0:	04a7cc63          	blt	a5,a0,80006018 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005fc4:	0001e797          	auipc	a5,0x1e
    80005fc8:	e4c78793          	addi	a5,a5,-436 # 80023e10 <disk>
    80005fcc:	97aa                	add	a5,a5,a0
    80005fce:	0187c783          	lbu	a5,24(a5)
    80005fd2:	ebb9                	bnez	a5,80006028 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005fd4:	00451613          	slli	a2,a0,0x4
    80005fd8:	0001e797          	auipc	a5,0x1e
    80005fdc:	e3878793          	addi	a5,a5,-456 # 80023e10 <disk>
    80005fe0:	6394                	ld	a3,0(a5)
    80005fe2:	96b2                	add	a3,a3,a2
    80005fe4:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005fe8:	6398                	ld	a4,0(a5)
    80005fea:	9732                	add	a4,a4,a2
    80005fec:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005ff0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005ff4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005ff8:	953e                	add	a0,a0,a5
    80005ffa:	4785                	li	a5,1
    80005ffc:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80006000:	0001e517          	auipc	a0,0x1e
    80006004:	e2850513          	addi	a0,a0,-472 # 80023e28 <disk+0x18>
    80006008:	ffffc097          	auipc	ra,0xffffc
    8000600c:	0c4080e7          	jalr	196(ra) # 800020cc <wakeup>
}
    80006010:	60a2                	ld	ra,8(sp)
    80006012:	6402                	ld	s0,0(sp)
    80006014:	0141                	addi	sp,sp,16
    80006016:	8082                	ret
    panic("free_desc 1");
    80006018:	00002517          	auipc	a0,0x2
    8000601c:	73850513          	addi	a0,a0,1848 # 80008750 <syscalls+0x300>
    80006020:	ffffa097          	auipc	ra,0xffffa
    80006024:	51e080e7          	jalr	1310(ra) # 8000053e <panic>
    panic("free_desc 2");
    80006028:	00002517          	auipc	a0,0x2
    8000602c:	73850513          	addi	a0,a0,1848 # 80008760 <syscalls+0x310>
    80006030:	ffffa097          	auipc	ra,0xffffa
    80006034:	50e080e7          	jalr	1294(ra) # 8000053e <panic>

0000000080006038 <virtio_disk_init>:
{
    80006038:	1101                	addi	sp,sp,-32
    8000603a:	ec06                	sd	ra,24(sp)
    8000603c:	e822                	sd	s0,16(sp)
    8000603e:	e426                	sd	s1,8(sp)
    80006040:	e04a                	sd	s2,0(sp)
    80006042:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006044:	00002597          	auipc	a1,0x2
    80006048:	72c58593          	addi	a1,a1,1836 # 80008770 <syscalls+0x320>
    8000604c:	0001e517          	auipc	a0,0x1e
    80006050:	eec50513          	addi	a0,a0,-276 # 80023f38 <disk+0x128>
    80006054:	ffffb097          	auipc	ra,0xffffb
    80006058:	af2080e7          	jalr	-1294(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000605c:	100017b7          	lui	a5,0x10001
    80006060:	4398                	lw	a4,0(a5)
    80006062:	2701                	sext.w	a4,a4
    80006064:	747277b7          	lui	a5,0x74727
    80006068:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000606c:	14f71c63          	bne	a4,a5,800061c4 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006070:	100017b7          	lui	a5,0x10001
    80006074:	43dc                	lw	a5,4(a5)
    80006076:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006078:	4709                	li	a4,2
    8000607a:	14e79563          	bne	a5,a4,800061c4 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000607e:	100017b7          	lui	a5,0x10001
    80006082:	479c                	lw	a5,8(a5)
    80006084:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006086:	12e79f63          	bne	a5,a4,800061c4 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000608a:	100017b7          	lui	a5,0x10001
    8000608e:	47d8                	lw	a4,12(a5)
    80006090:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006092:	554d47b7          	lui	a5,0x554d4
    80006096:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000609a:	12f71563          	bne	a4,a5,800061c4 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000609e:	100017b7          	lui	a5,0x10001
    800060a2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800060a6:	4705                	li	a4,1
    800060a8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800060aa:	470d                	li	a4,3
    800060ac:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800060ae:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800060b0:	c7ffe737          	lui	a4,0xc7ffe
    800060b4:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fda80f>
    800060b8:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800060ba:	2701                	sext.w	a4,a4
    800060bc:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800060be:	472d                	li	a4,11
    800060c0:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800060c2:	5bbc                	lw	a5,112(a5)
    800060c4:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800060c8:	8ba1                	andi	a5,a5,8
    800060ca:	10078563          	beqz	a5,800061d4 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800060ce:	100017b7          	lui	a5,0x10001
    800060d2:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800060d6:	43fc                	lw	a5,68(a5)
    800060d8:	2781                	sext.w	a5,a5
    800060da:	10079563          	bnez	a5,800061e4 <virtio_disk_init+0x1ac>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800060de:	100017b7          	lui	a5,0x10001
    800060e2:	5bdc                	lw	a5,52(a5)
    800060e4:	2781                	sext.w	a5,a5
  if(max == 0)
    800060e6:	10078763          	beqz	a5,800061f4 <virtio_disk_init+0x1bc>
  if(max < NUM)
    800060ea:	471d                	li	a4,7
    800060ec:	10f77c63          	bgeu	a4,a5,80006204 <virtio_disk_init+0x1cc>
  disk.desc = kalloc();
    800060f0:	ffffb097          	auipc	ra,0xffffb
    800060f4:	9f6080e7          	jalr	-1546(ra) # 80000ae6 <kalloc>
    800060f8:	0001e497          	auipc	s1,0x1e
    800060fc:	d1848493          	addi	s1,s1,-744 # 80023e10 <disk>
    80006100:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006102:	ffffb097          	auipc	ra,0xffffb
    80006106:	9e4080e7          	jalr	-1564(ra) # 80000ae6 <kalloc>
    8000610a:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000610c:	ffffb097          	auipc	ra,0xffffb
    80006110:	9da080e7          	jalr	-1574(ra) # 80000ae6 <kalloc>
    80006114:	87aa                	mv	a5,a0
    80006116:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006118:	6088                	ld	a0,0(s1)
    8000611a:	cd6d                	beqz	a0,80006214 <virtio_disk_init+0x1dc>
    8000611c:	0001e717          	auipc	a4,0x1e
    80006120:	cfc73703          	ld	a4,-772(a4) # 80023e18 <disk+0x8>
    80006124:	cb65                	beqz	a4,80006214 <virtio_disk_init+0x1dc>
    80006126:	c7fd                	beqz	a5,80006214 <virtio_disk_init+0x1dc>
  memset(disk.desc, 0, PGSIZE);
    80006128:	6605                	lui	a2,0x1
    8000612a:	4581                	li	a1,0
    8000612c:	ffffb097          	auipc	ra,0xffffb
    80006130:	ba6080e7          	jalr	-1114(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006134:	0001e497          	auipc	s1,0x1e
    80006138:	cdc48493          	addi	s1,s1,-804 # 80023e10 <disk>
    8000613c:	6605                	lui	a2,0x1
    8000613e:	4581                	li	a1,0
    80006140:	6488                	ld	a0,8(s1)
    80006142:	ffffb097          	auipc	ra,0xffffb
    80006146:	b90080e7          	jalr	-1136(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    8000614a:	6605                	lui	a2,0x1
    8000614c:	4581                	li	a1,0
    8000614e:	6888                	ld	a0,16(s1)
    80006150:	ffffb097          	auipc	ra,0xffffb
    80006154:	b82080e7          	jalr	-1150(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006158:	100017b7          	lui	a5,0x10001
    8000615c:	4721                	li	a4,8
    8000615e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006160:	4098                	lw	a4,0(s1)
    80006162:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006166:	40d8                	lw	a4,4(s1)
    80006168:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000616c:	6498                	ld	a4,8(s1)
    8000616e:	0007069b          	sext.w	a3,a4
    80006172:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006176:	9701                	srai	a4,a4,0x20
    80006178:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000617c:	6898                	ld	a4,16(s1)
    8000617e:	0007069b          	sext.w	a3,a4
    80006182:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006186:	9701                	srai	a4,a4,0x20
    80006188:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000618c:	4705                	li	a4,1
    8000618e:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80006190:	00e48c23          	sb	a4,24(s1)
    80006194:	00e48ca3          	sb	a4,25(s1)
    80006198:	00e48d23          	sb	a4,26(s1)
    8000619c:	00e48da3          	sb	a4,27(s1)
    800061a0:	00e48e23          	sb	a4,28(s1)
    800061a4:	00e48ea3          	sb	a4,29(s1)
    800061a8:	00e48f23          	sb	a4,30(s1)
    800061ac:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800061b0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800061b4:	0727a823          	sw	s2,112(a5)
}
    800061b8:	60e2                	ld	ra,24(sp)
    800061ba:	6442                	ld	s0,16(sp)
    800061bc:	64a2                	ld	s1,8(sp)
    800061be:	6902                	ld	s2,0(sp)
    800061c0:	6105                	addi	sp,sp,32
    800061c2:	8082                	ret
    panic("could not find virtio disk");
    800061c4:	00002517          	auipc	a0,0x2
    800061c8:	5bc50513          	addi	a0,a0,1468 # 80008780 <syscalls+0x330>
    800061cc:	ffffa097          	auipc	ra,0xffffa
    800061d0:	372080e7          	jalr	882(ra) # 8000053e <panic>
    panic("virtio disk FEATURES_OK unset");
    800061d4:	00002517          	auipc	a0,0x2
    800061d8:	5cc50513          	addi	a0,a0,1484 # 800087a0 <syscalls+0x350>
    800061dc:	ffffa097          	auipc	ra,0xffffa
    800061e0:	362080e7          	jalr	866(ra) # 8000053e <panic>
    panic("virtio disk should not be ready");
    800061e4:	00002517          	auipc	a0,0x2
    800061e8:	5dc50513          	addi	a0,a0,1500 # 800087c0 <syscalls+0x370>
    800061ec:	ffffa097          	auipc	ra,0xffffa
    800061f0:	352080e7          	jalr	850(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    800061f4:	00002517          	auipc	a0,0x2
    800061f8:	5ec50513          	addi	a0,a0,1516 # 800087e0 <syscalls+0x390>
    800061fc:	ffffa097          	auipc	ra,0xffffa
    80006200:	342080e7          	jalr	834(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    80006204:	00002517          	auipc	a0,0x2
    80006208:	5fc50513          	addi	a0,a0,1532 # 80008800 <syscalls+0x3b0>
    8000620c:	ffffa097          	auipc	ra,0xffffa
    80006210:	332080e7          	jalr	818(ra) # 8000053e <panic>
    panic("virtio disk kalloc");
    80006214:	00002517          	auipc	a0,0x2
    80006218:	60c50513          	addi	a0,a0,1548 # 80008820 <syscalls+0x3d0>
    8000621c:	ffffa097          	auipc	ra,0xffffa
    80006220:	322080e7          	jalr	802(ra) # 8000053e <panic>

0000000080006224 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006224:	7119                	addi	sp,sp,-128
    80006226:	fc86                	sd	ra,120(sp)
    80006228:	f8a2                	sd	s0,112(sp)
    8000622a:	f4a6                	sd	s1,104(sp)
    8000622c:	f0ca                	sd	s2,96(sp)
    8000622e:	ecce                	sd	s3,88(sp)
    80006230:	e8d2                	sd	s4,80(sp)
    80006232:	e4d6                	sd	s5,72(sp)
    80006234:	e0da                	sd	s6,64(sp)
    80006236:	fc5e                	sd	s7,56(sp)
    80006238:	f862                	sd	s8,48(sp)
    8000623a:	f466                	sd	s9,40(sp)
    8000623c:	f06a                	sd	s10,32(sp)
    8000623e:	ec6e                	sd	s11,24(sp)
    80006240:	0100                	addi	s0,sp,128
    80006242:	8aaa                	mv	s5,a0
    80006244:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006246:	00c52d03          	lw	s10,12(a0)
    8000624a:	001d1d1b          	slliw	s10,s10,0x1
    8000624e:	1d02                	slli	s10,s10,0x20
    80006250:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80006254:	0001e517          	auipc	a0,0x1e
    80006258:	ce450513          	addi	a0,a0,-796 # 80023f38 <disk+0x128>
    8000625c:	ffffb097          	auipc	ra,0xffffb
    80006260:	97a080e7          	jalr	-1670(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    80006264:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006266:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006268:	0001eb97          	auipc	s7,0x1e
    8000626c:	ba8b8b93          	addi	s7,s7,-1112 # 80023e10 <disk>
  for(int i = 0; i < 3; i++){
    80006270:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006272:	0001ec97          	auipc	s9,0x1e
    80006276:	cc6c8c93          	addi	s9,s9,-826 # 80023f38 <disk+0x128>
    8000627a:	a08d                	j	800062dc <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000627c:	00fb8733          	add	a4,s7,a5
    80006280:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006284:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006286:	0207c563          	bltz	a5,800062b0 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000628a:	2905                	addiw	s2,s2,1
    8000628c:	0611                	addi	a2,a2,4
    8000628e:	05690c63          	beq	s2,s6,800062e6 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006292:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006294:	0001e717          	auipc	a4,0x1e
    80006298:	b7c70713          	addi	a4,a4,-1156 # 80023e10 <disk>
    8000629c:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000629e:	01874683          	lbu	a3,24(a4)
    800062a2:	fee9                	bnez	a3,8000627c <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    800062a4:	2785                	addiw	a5,a5,1
    800062a6:	0705                	addi	a4,a4,1
    800062a8:	fe979be3          	bne	a5,s1,8000629e <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    800062ac:	57fd                	li	a5,-1
    800062ae:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800062b0:	01205d63          	blez	s2,800062ca <virtio_disk_rw+0xa6>
    800062b4:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800062b6:	000a2503          	lw	a0,0(s4)
    800062ba:	00000097          	auipc	ra,0x0
    800062be:	cfc080e7          	jalr	-772(ra) # 80005fb6 <free_desc>
      for(int j = 0; j < i; j++)
    800062c2:	2d85                	addiw	s11,s11,1
    800062c4:	0a11                	addi	s4,s4,4
    800062c6:	ffb918e3          	bne	s2,s11,800062b6 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800062ca:	85e6                	mv	a1,s9
    800062cc:	0001e517          	auipc	a0,0x1e
    800062d0:	b5c50513          	addi	a0,a0,-1188 # 80023e28 <disk+0x18>
    800062d4:	ffffc097          	auipc	ra,0xffffc
    800062d8:	d94080e7          	jalr	-620(ra) # 80002068 <sleep>
  for(int i = 0; i < 3; i++){
    800062dc:	f8040a13          	addi	s4,s0,-128
{
    800062e0:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800062e2:	894e                	mv	s2,s3
    800062e4:	b77d                	j	80006292 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800062e6:	f8042583          	lw	a1,-128(s0)
    800062ea:	00a58793          	addi	a5,a1,10
    800062ee:	0792                	slli	a5,a5,0x4

  if(write)
    800062f0:	0001e617          	auipc	a2,0x1e
    800062f4:	b2060613          	addi	a2,a2,-1248 # 80023e10 <disk>
    800062f8:	00f60733          	add	a4,a2,a5
    800062fc:	018036b3          	snez	a3,s8
    80006300:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006302:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006306:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000630a:	f6078693          	addi	a3,a5,-160
    8000630e:	6218                	ld	a4,0(a2)
    80006310:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006312:	00878513          	addi	a0,a5,8
    80006316:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006318:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000631a:	6208                	ld	a0,0(a2)
    8000631c:	96aa                	add	a3,a3,a0
    8000631e:	4741                	li	a4,16
    80006320:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006322:	4705                	li	a4,1
    80006324:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006328:	f8442703          	lw	a4,-124(s0)
    8000632c:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006330:	0712                	slli	a4,a4,0x4
    80006332:	953a                	add	a0,a0,a4
    80006334:	058a8693          	addi	a3,s5,88
    80006338:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000633a:	6208                	ld	a0,0(a2)
    8000633c:	972a                	add	a4,a4,a0
    8000633e:	40000693          	li	a3,1024
    80006342:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006344:	001c3c13          	seqz	s8,s8
    80006348:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000634a:	001c6c13          	ori	s8,s8,1
    8000634e:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006352:	f8842603          	lw	a2,-120(s0)
    80006356:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000635a:	0001e697          	auipc	a3,0x1e
    8000635e:	ab668693          	addi	a3,a3,-1354 # 80023e10 <disk>
    80006362:	00258713          	addi	a4,a1,2
    80006366:	0712                	slli	a4,a4,0x4
    80006368:	9736                	add	a4,a4,a3
    8000636a:	587d                	li	a6,-1
    8000636c:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006370:	0612                	slli	a2,a2,0x4
    80006372:	9532                	add	a0,a0,a2
    80006374:	f9078793          	addi	a5,a5,-112
    80006378:	97b6                	add	a5,a5,a3
    8000637a:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    8000637c:	629c                	ld	a5,0(a3)
    8000637e:	97b2                	add	a5,a5,a2
    80006380:	4605                	li	a2,1
    80006382:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006384:	4509                	li	a0,2
    80006386:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    8000638a:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000638e:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006392:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006396:	6698                	ld	a4,8(a3)
    80006398:	00275783          	lhu	a5,2(a4)
    8000639c:	8b9d                	andi	a5,a5,7
    8000639e:	0786                	slli	a5,a5,0x1
    800063a0:	97ba                	add	a5,a5,a4
    800063a2:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    800063a6:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800063aa:	6698                	ld	a4,8(a3)
    800063ac:	00275783          	lhu	a5,2(a4)
    800063b0:	2785                	addiw	a5,a5,1
    800063b2:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800063b6:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800063ba:	100017b7          	lui	a5,0x10001
    800063be:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800063c2:	004aa783          	lw	a5,4(s5)
    800063c6:	02c79163          	bne	a5,a2,800063e8 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    800063ca:	0001e917          	auipc	s2,0x1e
    800063ce:	b6e90913          	addi	s2,s2,-1170 # 80023f38 <disk+0x128>
  while(b->disk == 1) {
    800063d2:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800063d4:	85ca                	mv	a1,s2
    800063d6:	8556                	mv	a0,s5
    800063d8:	ffffc097          	auipc	ra,0xffffc
    800063dc:	c90080e7          	jalr	-880(ra) # 80002068 <sleep>
  while(b->disk == 1) {
    800063e0:	004aa783          	lw	a5,4(s5)
    800063e4:	fe9788e3          	beq	a5,s1,800063d4 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    800063e8:	f8042903          	lw	s2,-128(s0)
    800063ec:	00290793          	addi	a5,s2,2
    800063f0:	00479713          	slli	a4,a5,0x4
    800063f4:	0001e797          	auipc	a5,0x1e
    800063f8:	a1c78793          	addi	a5,a5,-1508 # 80023e10 <disk>
    800063fc:	97ba                	add	a5,a5,a4
    800063fe:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006402:	0001e997          	auipc	s3,0x1e
    80006406:	a0e98993          	addi	s3,s3,-1522 # 80023e10 <disk>
    8000640a:	00491713          	slli	a4,s2,0x4
    8000640e:	0009b783          	ld	a5,0(s3)
    80006412:	97ba                	add	a5,a5,a4
    80006414:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006418:	854a                	mv	a0,s2
    8000641a:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000641e:	00000097          	auipc	ra,0x0
    80006422:	b98080e7          	jalr	-1128(ra) # 80005fb6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006426:	8885                	andi	s1,s1,1
    80006428:	f0ed                	bnez	s1,8000640a <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000642a:	0001e517          	auipc	a0,0x1e
    8000642e:	b0e50513          	addi	a0,a0,-1266 # 80023f38 <disk+0x128>
    80006432:	ffffb097          	auipc	ra,0xffffb
    80006436:	858080e7          	jalr	-1960(ra) # 80000c8a <release>
}
    8000643a:	70e6                	ld	ra,120(sp)
    8000643c:	7446                	ld	s0,112(sp)
    8000643e:	74a6                	ld	s1,104(sp)
    80006440:	7906                	ld	s2,96(sp)
    80006442:	69e6                	ld	s3,88(sp)
    80006444:	6a46                	ld	s4,80(sp)
    80006446:	6aa6                	ld	s5,72(sp)
    80006448:	6b06                	ld	s6,64(sp)
    8000644a:	7be2                	ld	s7,56(sp)
    8000644c:	7c42                	ld	s8,48(sp)
    8000644e:	7ca2                	ld	s9,40(sp)
    80006450:	7d02                	ld	s10,32(sp)
    80006452:	6de2                	ld	s11,24(sp)
    80006454:	6109                	addi	sp,sp,128
    80006456:	8082                	ret

0000000080006458 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006458:	1101                	addi	sp,sp,-32
    8000645a:	ec06                	sd	ra,24(sp)
    8000645c:	e822                	sd	s0,16(sp)
    8000645e:	e426                	sd	s1,8(sp)
    80006460:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006462:	0001e497          	auipc	s1,0x1e
    80006466:	9ae48493          	addi	s1,s1,-1618 # 80023e10 <disk>
    8000646a:	0001e517          	auipc	a0,0x1e
    8000646e:	ace50513          	addi	a0,a0,-1330 # 80023f38 <disk+0x128>
    80006472:	ffffa097          	auipc	ra,0xffffa
    80006476:	764080e7          	jalr	1892(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000647a:	10001737          	lui	a4,0x10001
    8000647e:	533c                	lw	a5,96(a4)
    80006480:	8b8d                	andi	a5,a5,3
    80006482:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006484:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006488:	689c                	ld	a5,16(s1)
    8000648a:	0204d703          	lhu	a4,32(s1)
    8000648e:	0027d783          	lhu	a5,2(a5)
    80006492:	04f70863          	beq	a4,a5,800064e2 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006496:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000649a:	6898                	ld	a4,16(s1)
    8000649c:	0204d783          	lhu	a5,32(s1)
    800064a0:	8b9d                	andi	a5,a5,7
    800064a2:	078e                	slli	a5,a5,0x3
    800064a4:	97ba                	add	a5,a5,a4
    800064a6:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800064a8:	00278713          	addi	a4,a5,2
    800064ac:	0712                	slli	a4,a4,0x4
    800064ae:	9726                	add	a4,a4,s1
    800064b0:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800064b4:	e721                	bnez	a4,800064fc <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800064b6:	0789                	addi	a5,a5,2
    800064b8:	0792                	slli	a5,a5,0x4
    800064ba:	97a6                	add	a5,a5,s1
    800064bc:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800064be:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800064c2:	ffffc097          	auipc	ra,0xffffc
    800064c6:	c0a080e7          	jalr	-1014(ra) # 800020cc <wakeup>

    disk.used_idx += 1;
    800064ca:	0204d783          	lhu	a5,32(s1)
    800064ce:	2785                	addiw	a5,a5,1
    800064d0:	17c2                	slli	a5,a5,0x30
    800064d2:	93c1                	srli	a5,a5,0x30
    800064d4:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800064d8:	6898                	ld	a4,16(s1)
    800064da:	00275703          	lhu	a4,2(a4)
    800064de:	faf71ce3          	bne	a4,a5,80006496 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800064e2:	0001e517          	auipc	a0,0x1e
    800064e6:	a5650513          	addi	a0,a0,-1450 # 80023f38 <disk+0x128>
    800064ea:	ffffa097          	auipc	ra,0xffffa
    800064ee:	7a0080e7          	jalr	1952(ra) # 80000c8a <release>
}
    800064f2:	60e2                	ld	ra,24(sp)
    800064f4:	6442                	ld	s0,16(sp)
    800064f6:	64a2                	ld	s1,8(sp)
    800064f8:	6105                	addi	sp,sp,32
    800064fa:	8082                	ret
      panic("virtio_disk_intr status");
    800064fc:	00002517          	auipc	a0,0x2
    80006500:	33c50513          	addi	a0,a0,828 # 80008838 <syscalls+0x3e8>
    80006504:	ffffa097          	auipc	ra,0xffffa
    80006508:	03a080e7          	jalr	58(ra) # 8000053e <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
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
    800070ac:	357d                	addiw	a0,a0,-1
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
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
