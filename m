From: Piet/Pete Delaney <piet@sgi.com>
Date: Mon, 07 Jan 2002 22:20:22 +0000
Subject: [Linux-ia64] kdb - Entering Breakpoints
Message-Id: <marc-linux-ia64-105590698805767@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Is anyone familiar with this problem I'm experiencing of using breakpoints =
with kdb?

-piet

On Sat, Jan 05, 2002 at 01:23:04PM +1100, Keith Owens wrote:
> On Fri, 4 Jan 2002 17:53:26 -0800,=20
> Piet/Pete Delaney <piet@sgi.com> wrote:
> >On Sat, Jan 05, 2002 at 12:39:09PM +1100, Keith Owens wrote:
> >> On Fri, 4 Jan 2002 16:17:10 -0800,=20
> >>=20
> >> The address checking code in kdb is broken for ia64.  It is on my list
> >> of things to fix but I am swamped with other work at the moment.
> >> kdba_getword and kdba_setword need to do the same checks as mprotect.
> >
> >What's the problem exactly?=20
>=20
> The code for checking if an address is valid is a kludge that was
> inherited from i386 and does not fit the ia64 memory model.  The
> validation code used by mprotect should work for all architectures.

Looks like kdb is unhappy with the address in 2.4.13:
----------------------------------------------------------------------
[root@monica /root]#
Entering kdb (current=3D0xe000000000ee0000, pid 0) on processor 0 due to Ke=
yboard Entry
[0]kdb> bp sys_read
Instruction(i) BP #0 at 0xe00200000050d940 (sys_read)
    is enabled globally
[0]kdb> go
kdb: Bad kernel address 0xe00200000050d940
[0]kdb> id 0xe00200000050d940
0xe00200000050d940 sys_read [MII]           break.m 0x0
0xe00200000050d946 sys_read+0x6             break.i 0x0
0xe00200000050d94c sys_read+0xc             break.i 0x0
0xe00200000050d950 sys_read+0x10 [MII]      break.m 0x0
----------------------------------------------------------------------
Looks like the code at sys_read is also wrong. This appears to be a
very old verion of kdb, likely I should work on lcrash on a newer
release.




kdb appears to be trying harder in 2.4.16 (ie: kdb is in better shape):
----------------------------------------------------------------------
 258 monica 23:52 ~>
Entering kdb (current=3D0xe000000000998000, pid 0) on processor 0 due to Ke=
yboard Entry
[0]kdb> bp sys_read
Instruction(i) BP #0 at 0xe00200000050d140 (sys_read)
    is enabled globally
[0]kdb> go
Unable to handle kernel paging request at virtual address e00200000050d140
swapper[0]: Oops 11003706212352

Pid: 0, comm:              swapper
Registers: cpu 0, sapicid 0x0000, time 59593
psr : 0000121008022018 ifs : 8000000000000287 ip  : [<e0020000007f2291>]   =
 Not tainted
unat: 0000000000000000 pfs : 0000000000000287 rsc : 0000000000000003
rnat: 8000000000000013 bsps: 000000000001003e pr  : 000000000001d665
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70033f
b0  : e0020000007f20d0 b6  : e00200000061afe0 b7  : e00200000040acf0
f6  : 1003e000000000000000a f7  : 1003e0000000000000018
f8  : 1003e0000000000000004 f9  : 100038000000000000000
r1  : e002100000ba8000 r2  : 0000000000000000 r3  : e002000000856cb8
r8  : 0000000000000001 r9  : 0000000000000894 r10 : 0000000000000006
r11 : 000000000000040f r12 : e00000000099fc70 r13 : e000000000998000
r14 : 0000000000000000 r15 : e002100000b295f4 r16 : e002100000b295f4
r17 : fffffffffffffdff r18 : e000000000998060 r19 : e000000000998060
r20 : 0000000000000000 r21 : e002100000bcd8c4 r22 : 0000000000000002
r23 : 0000000000000003 r24 : 0000000000000000 r25 : 0000000000000001
r26 : c0000a0001f90010 r27 : c0000a0001830100 r28 : c0000a0001e08058
r29 : 0000000000000001 r30 : c0000a0001e08018 r31 : c0000a0001f90010
r32 : 0000000000000000 r33 : 0000000000000000 r34 : 0000000000000000
r35 : 0000000000000000 r36 : 0000000000000000 r37 : 0000000000000000
r38 : 0000000000000000

Call Trace: [<e0020000004101e0>] sp=3D0xe00000000099f860 bsp=3D0xe000000000=
999688
[<e002000000410a30>] sp=3D0xe00000000099fa20 bsp=3D0xe000000000999630	show_=
regs+0x7d0 [MMI]       		adds r17=16,r12;;
[<e002000000423710>] sp=3D0xe00000000099fa40 bsp=3D0xe000000000999608	die+0=
x190 [MIB]       			nop.m 0x0
[<e002000000442590>] sp=3D0xe00000000099fa40 bsp=3D0xe0000000009995a8	ia64_=
do_page_fault+0x810 [MIB]       	mov r43=3Dr0
[<e00200000040a740>] sp=3D0xe00000000099fad0 bsp=3D0xe0000000009995a8	ia64_=
leave_kernel [MLX]       		lfetch.fault [r12]
---------------------------------------------------------------------------=
--------------------------------------------------------------------
[<e0020000007f2290>] sp=3D0xe00000000099fc70 bsp=3D0xe000000000999570	kdba_=
putword+0x5d0 [MMI]       		cmp.eq p6,p7=3D8,r33;;	<--- pc
[<e0020000007ef7c0>] sp=3D0xe00000000099fc70 bsp=3D0xe000000000999530	kdba_=
installbp+0x280 [MMI]       	ld8 r14=3D[r35];;
[<e002000000613ff0>] sp=3D0xe00000000099fc70 bsp=3D0xe0000000009994f0	kdb_b=
p_install_global+0x110 [MII]       adds r34=3D1,r34
[<e0020000006197d0>] sp=3D0xe00000000099fc70 bsp=3D0xe000000000999498	kdb+0=
x1010 [MIB]       			nop.m 0x0
[<e0020000006765e0>] sp=3D0xe00000000099fc80 bsp=3D0xe0000000009993c0	recei=
ve_chars+0x140 [MIB]       	nop.m 0x0
[<e002000000676ed0>] sp=3D0xe00000000099fc80 bsp=3D0xe000000000999390	l1_co=
ns_interrupt+0xb0 [MMI]    	adds r15=16,r12;;
[<e00200000048f0c0>] sp=3D0xe00000000099fc90 bsp=3D0xe000000000999320	brl1_=
receive+0xbe0 [MII]        	ld8 r14=3D[r42]
[<e00200000048fad0>] sp=3D0xe00000000099fca0 bsp=3D0xe0000000009992f0	brl1_=
intrd+0x130 [MII]          	cmp4.eq p7,p6=3D0,r8
[<e00200000040d620>] sp=3D0xe00000000099fca0 bsp=3D0xe0000000009992b0	handl=
e_IRQ_event+0x100 [MII]    	ld8 r34=3D[r34]
[<e00200000040dd40>] sp=3D0xe00000000099fca0 bsp=3D0xe000000000999260	do_IR=
Q+0x2e0 [MII]       		mov.m ar.ccv=3Dr0
[<e00200000040fae0>] sp=3D0xe00000000099fca0 bsp=3D0xe000000000999238	ia64_=
handle_irq+0xa0 [MMI]      	rsm 0x4000;;
[<e00200000040a740>] sp=3D0xe00000000099fca0 bsp=3D0xe000000000999238	ia64_=
leave_kernel [MLX]       		lfetch.fault [r12]
[<e002000000410be0>] sp=3D0xe00000000099fe40 bsp=3D0xe000000000999188	cpu_i=
dle+0x180 [MMI]       		ld4 r14=3D[r35];;
[<e002000000409340>] sp=3D0xe00000000099fe40 bsp=3D0xe000000000999178	rest_=
init+0xc0 [MII]       		nop.m 0x0
[<e0020000008cd4d0>] sp=3D0xe00000000099fe40 bsp=3D0xe000000000999160	start=
_kernel+0x4f0 [MII]       		nop.m 0x0
[<e002000000408540>] sp=3D0xe00000000099fe60 bsp=3D0xe000000000999160	start=
_ap+0x320 [MMI]       		addl r3=111632,r1;;
 kdb: Debugger re-entered on cpu 0, new reason =3D 13
esponse from 001c28, system not responding
no response from 001c28, system not responding
no response from 001c28, system not responding
no response from 001c28, system not responding
no response from 001c28, system not responding
no response from 001c28, system not responding
no response from 001c28, system not responding
no response from 001c28, system not responding
no response from 001c28, system not responding
----------------------------------------------------------------------
The pc appreas to be in  kdba_putword:
...........................................................................=
...............................
[0]kdb> id e0020000007f2291
0xe0020000007f2290 kdba_putword+0x5d0 [MMI]       cmp.eq p6,p7=3D8,r33;;			=
			r33 appears to be NULL!
0xe0020000007f2296 kdba_putword+0x5d6       (p06) st8 [r32]=3Dr34
0xe0020000007f229c kdba_putword+0x5dc             nop.i 0x0

0xe0020000007f22a0 kdba_putword+0x5e0 [MIB] (p06) mov r8=3Dr0
0xe0020000007f22a6 kdba_putword+0x5e6             nop.i 0x0
0xe0020000007f22ac kdba_putword+0x5ec       (p06) br.cond.dpnt.few 0xe00200=
00007f22e0 kdba_putword+0x620 -----------------+
															  |
0xe0020000007f22b0 kdba_putword+0x5f0 [MMI]       addl r37=144560,r1;;
0xe0020000007f22b6 kdba_putword+0x5f6             ld8 r37=3D[r37]
0xe0020000007f22bc kdba_putword+0x5fc             nop.i 0x0

0xe0020000007f22c0 kdba_putword+0x600 [MIB]       nop.m 0x0
0xe0020000007f22c6 kdba_putword+0x606             nop.i 0x0
0xe0020000007f22cc kdba_putword+0x60c             br.call.sptk.many b0=3D0x=
e00200000061c5c0 kdb_printf ;;
0xe0020000007f22d0 kdba_putword+0x610 [MII]       mov r8=3Dr0
0xe0020000007f22d6 kdba_putword+0x616             nop.i 0x0
0xe0020000007f22dc kdba_putword+0x61c             nop.i 0x0
															 |
0xe0020000007f22e0 kdba_putword+0x620 [MII]       nop.m 0x0						<---------=
-------+
0xe0020000007f22e6 kdba_putword+0x626             mov.i ar.pfs=3Dr36
0xe0020000007f22ec kdba_putword+0x62c             mov b0=3Dr35

0xe0020000007f22f0 kdba_putword+0x630 [MIB]       nop.m 0x0
0xe0020000007f22f6 kdba_putword+0x636             nop.i 0x0
0xe0020000007f22fc kdba_putword+0x63c             br.ret.sptk.many b0;;
-------------------------------------
0xe0020000007f2300 kdba_init [MII]       alloc r33=3Dar.pfs,7,2,0
0xe0020000007f2306 kdba_init+0x6             mov r32=B0;;
0xe0020000007f230c kdba_init+0xc             nop.i 0x0
...........................................................................=
............................

---------------------------------------------------------------------------=
----------------------------
					karch/ia64/kdb/kdbasupport.c
---------------------------------------------------------------------------=
----------------------------

---------------------------------------------------------------------------=
----------------------------
   1374  *
   1375  *      Architecture specific function to access kernel virtual
   1376  *      address space.
   1377  *
   1378  * Parameters:
   1379  *      None.
   1380  * Returns:
   1381  *      None.
   1382  * Locking:
   1383  *      None.
   1384  * Remarks:
   1385  *      None.
   1386  */
   1387
   1388 unsigned long
   1389 kdba_putword(unsigned long addr, size_t size, unsigned long content=
s)
   1390 {
   1391         /*
   1392          * This function checks the address for validity.  Any addr=
ess
   1393          * in the range PAGE_OFFSET to high_memory is legal, any ad=
dress
   1394          * which maps to a vmalloc region is legal, and any address=
 which
   1395          * is a user address, we use get_user() to verify validity.
   1396          */
   1397
   1398         if (addr < PAGE_OFFSET) {
   1399                 /*
   1400                  * Usermode address.
   1401                  */
   1402                 unsigned long diag;
   1403
   1404                 switch (size) {
   1405                 case 8:
   1406                 {       unsigned long *lp;
   1407
   1408                         lp =3D (unsigned long *) addr;
   1409                         diag =3D put_user(contents, lp);
   1410                         break;
   1411                 }
		.
		.
		.
   1449         if (!kdb_is_direct_kernel_address(addr) && addr > (unsigned=
 long)high_memory) {
   1450                 extern int kdb_vmlist_check(unsigned long, unsigned=
 long);
   1451
   1452                 if (!kdb_vmlist_check(addr, addr+size)) {
   1453                         /*
   1454                          * Would appear to be an illegal kernel add=
ress;
   1455                          * Print a message once, and don't print ag=
ain until
   1456                          * a legal address is used.
   1457                          */
   1458                         if (!KDB_STATE(SUPPRESS)) {
   1459                                 kdb_printf("kdb: Bad kernel address=
 " kdb_machreg_fmt "\n", addr);
   1460                                 KDB_STATE_SET(SUPPRESS);
   1461                         }
   1462                         return 0L;
   1463                 }
   1464         }
   1465
   1466         /*
   1467          * A good address.  Reset error flag.
   1468          */
   1469         KDB_STATE_CLEAR(SUPPRESS);
   1470
   1471         switch (size) {
   1472         case 8:
   1473         {       unsigned long *lp;
   1474
   1475                 lp =3D (unsigned long *)(addr);
   1476                 *lp =3D contents;							<--- Should be here and lp =
was NULL
   1477                 return 0;
   1478         }
   1479         case 4:
   1480         {       unsigned int *ip;
   1481
   1482                 ip =3D (unsigned int *)(addr);
   1483                 *ip =3D contents;
   1484                 return 0;
   1485         }
   1486         case 2:
   1487         {       unsigned short *sp;
   1488
   1489                 sp =3D (unsigned short *)(addr);
   1490                 *sp =3D (unsigned short) contents;
   1491                 return 0;
   1492         }
   1493         case 1:
   1494         {       unsigned char *cp;
   1495
   1496                 cp =3D (unsigned char *)(addr);
   1497                 *cp =3D (unsigned char) contents;					<---- Appears=
 to be here and cp was NULL
   1498                 return 0;
   1499         }
   1500         }
   1501
   1502         kdb_printf("kdba_putword: Bad width\n");
   1503         return 0;
   1504 }
   1505
   1505
   1506 /*
   1507  * kdba_init
   1508  *
---------------------------------------------------------------------------=
------------------------------

---------------------------------------------------------------------------=
------------------------------
					arch/ia64/kdb/kdba_bp.c
---------------------------------------------------------------------------=
------------------------------
    714 kdba_installbp(kdb_eframe_t ef, kdb_bp_t *bp)
    715 {
    716         /*
    717          * Install the breakpoint, if it is not already installed.
    718          */
    719
    720         if (KDB_DEBUG(BP)) {
    721                 kdb_printf("kdba_installbp bp_installed %d\n", bp->=
bp_installed);
    722         }
    723         if (!bp->bp_installed) {
    724                 if (bp->bp_hardtype) {
    725                         kdba_installdbreg(bp);
    726                         bp->bp_installed =3D 1;
    727                         if (KDB_DEBUG(BP)) {
    728                                 kdb_printf("kdba_installbp hardware=
 reg %ld at " kdb_bfd_vma_fmt0 "\n",
    729                                            bp->bp_hard->bph_reg, bp=
->bp_addr);
    730                         }
    731                 } else if (bp->bp_delay) {
    732                         if (KDB_DEBUG(BP))
    733                                 kdb_printf("kdba_installbp delayed =
bp\n");
    734                         kdba_handle_bp(ef, bp);
    735                 } else {
    736                         /* Software breakpoints always use slot 0 i=
n the 128 bit
    737                          * bundle.  The template type does not matt=
er, slot 0
    738                          * can only be M or B and the encodings for=
 break.m and
    739                          * break.b are the same.
    740                          */
    741                         bp->bp_inst.inst[0] =3D kdba_getword(bp->bp=
_addr, 8);
    742                         bp->bp_inst.inst[1] =3D kdba_getword(bp->bp=
_addr+8, 8);
    743                         kdba_putword(bp->bp_addr, 8,							<---- Li=
kely Here
    744                                 (bp->bp_inst.inst[0] & ~INST_SLOT0_=
MASK) | BREAK_INSTR);
    745                         bp->bp_instvalid =3D 1;
    746                         if (KDB_DEBUG(BP))
    747                                 kdb_printf("kdba_installbp instruct=
ion 0x%lx at " kdb_bfd_vma_fmt0 "\n",
    748                                            BREAK_INSTR, bp->bp_addr=
);
    749                         bp->bp_installed =3D 1;
    750                         flush_icache_range(bp->bp_addr, bp->bp_addr=
+16);
    751                 }
    752         }
    753 }
    754
---------------------------------------------------------------------------=
------------------------------

Looks like addr (bp->bp_addr) was null. I don't know how to see the params.
Likely should enable KDB_DEBUG(BP):

include/linux/kdb.h

	#define KDB_DEBUG(flag)         (kdb_flags & (KDB_DEBUG_FLAG_##flag << KDB=
_DEBUG_FLAG_SHIFT))

This  KDB_DEBUG() macro should be better documented in include/linux/kdb.h.
It too me a while to see that the BP in the macro is sufixed to KDB_DEBUG_F=
LAG_
to make KDB_DEBUG_FLAG_BP (0x0002).

Since the newer kernel appears to be trying to install breakpoints I suspect
that I'm better off to help you and whoever else is working on this to get
it working to make it easier to debug the lcrash dump code. We could also
try to use lcrash on core files that created when kdb fails; like after
calling showregs from die(). I'm still rather new to ia64. It took a while
to learn sparc asm code also. Here I don't know even how to get to the
registers in the stackframes. In solaris kadb had a macro to dump the=20
stackframes with registers.=20

I believe solaris has die() transfer control back to panic and then kdb.
Why are we doing that?

I gave it another show and tried changing kdb_flags to  0xffff:

	[0]kdb> mm kdb_flags 0xffff
	0xe002100000b295f0 =3D 0xffff

and tried the breakpoint at sys_read again.=20
Seems it didn't help; looks about the same.=20
Does KDB debugging have to be configured?
...........................................................................=
...............................
[root@monica /root]#
Entering kdb (current=3D0xe000000000998000, pid 0) on processor 0 due to Ke=
yboard Entry
[0]kdb> bp sys_read
Instruction(i) BP #0 at 0xe00200000050d140 (sys_read)
    is enabled globally
[0]kdb> go
Unable to handle kernel paging request at virtual address e00200000050d140
swapper[0]: Oops 11003706212352

Pid: 0, comm:              swapper
Registers: cpu 0, sapicid 0x0000, time 5854028
psr : 0000121008022018 ifs : 8000000000000287 ip  : [<e0020000007f2291>]   =
 Not tainted
unat: 0000000000000000 pfs : 0000000000000287 rsc : 0000000000000003
rnat: 8000000000000013 bsps: 000000000001003e pr  : 000000000001d665
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70033f
b0  : e0020000007f20d0 b6  : e00200000061afe0 b7  : e00200000040acf0
f6  : 1003e000000000000000a f7  : 1003e0000000000000018
f8  : 1003e0000000000000004 f9  : 100038000000000000000
r1  : e002100000ba8000 r2  : 0000000000000000 r3  : e002000000856cb8
r8  : 0000000000000001 r9  : 0000000000000894 r10 : 0000000000000006
r11 : 000000000000040f r12 : e00000000099fc70 r13 : e000000000998000
r14 : 0000000000000000 r15 : e002100000b295f4 r16 : e002100000b295f4
r17 : fffffffffffffdff r18 : e000000000998060 r19 : e000000000998060
r20 : 0000000000000000 r21 : e002100000bcd8c4 r22 : 0000000000000002
r23 : 0000000000000003 r24 : 0000000000000000 r25 : 0000000000000001
r26 : c0000a0001f90010 r27 : c0000a0001830100 r28 : c0000a0001e08058
r29 : 0000000000000001 r30 : c0000a0001e08018 r31 : c0000a0001f90010
r32 : 0000000000000000 r33 : 0000000000000000 r34 : 0000000000000000
r35 : 0000000000000000 r36 : 0000000000000000 r37 : 0000000000000000
r38 : 0000000000000000

Call Trace: [<e0020000004101e0>] sp=3D0xe00000000099f860 bsp=3D0xe000000000=
999688
[<e002000000410a30>] sp=3D0xe00000000099fa20 bsp=3D0xe000000000999630
[<e002000000423710>] sp=3D0xe00000000099fa40 bsp=3D0xe000000000999608
[<e002000000442590>] sp=3D0xe00000000099fa40 bsp=3D0xe0000000009995a8
[<e00200000040a740>] sp=3D0xe00000000099fad0 bsp=3D0xe0000000009995a8
[<e0020000007f2290>] sp=3D0xe00000000099fc70 bsp=3D0xe000000000999570
[<e0020000007ef7c0>] sp=3D0xe00000000099fc70 bsp=3D0xe000000000999530
[<e002000000613ff0>] sp=3D0xe00000000099fc70 bsp=3D0xe0000000009994f0
[<e0020000006197d0>] sp=3D0xe00000000099fc70 bsp=3D0xe000000000999498
[<e0020000006765e0>] sp=3D0xe00000000099fc80 bsp=3D0xe0000000009993c0
[<e002000000676ed0>] sp=3D0xe00000000099fc80 bsp=3D0xe000000000999390
[<e00200000048f0c0>] sp=3D0xe00000000099fc90 bsp=3D0xe000000000999320
[<e00200000048fad0>] sp=3D0xe00000000099fca0 bsp=3D0xe0000000009992f0
[<e00200000040d620>] sp=3D0xe00000000099fca0 bsp=3D0xe0000000009992b0
[<e00200000040dd40>] sp=3D0xe00000000099fca0 bsp=3D0xe000000000999260
[<e00200000040fae0>] sp=3D0xe00000000099fca0 bsp=3D0xe000000000999238
[<e00200000040a740>] sp=3D0xe00000000099fca0 bsp=3D0xe000000000999238
[<e002000000410c50>] sp=3D0xe00000000099fe40 bsp=3D0xe000000000999188
[<e002000000409340>] sp=3D0xe00000000099fe40 bsp=3D0xe000000000999178
[<e0020000008cd4d0>] sp=3D0xe00000000099fe40 bsp=3D0xe000000000999160
[<e002000000408540>] sp=3D0xe00000000099fe60 bsp=3D0xe000000000999160
 kdb: Debugger re-entered on cpu 0, new reason =3D 13
...........................................................................=
...............................



> >Shouldn't breakpoints at least work? I thought I tried it before and it
> >worked. I was very surprised that breakpoints in read and idle did't wor=
k.
>=20
> I suspect it is because the SN2 memory model is different from standard
> IA64.
>=20
> >Looks like your patch only includes ia32 and common code. Is someone here
> >working on the ia64 part?
>=20
> There is a kdb-v1.9-2.4.16-ia64-011128 patch, I have not had time to
> convert ia64 to v2.0 format nor upgrade to 2.4.17.

Where is the patch downloaded from?=20

Shouldn't kdb have a version cmd to easily see the current version?


BTW, I was wondering if it would be helpfull to layer a gdb stub on top
of kdb. Sun did this with kadb and it was really hot; especially the
ethhernet based stub. I looked over the kdb man pages but didn't find
a overview design paper. My brief look at the code didn't lead me to
believe that it's currenlly layered (I might be wrong, I didn't see
the machine specific code yet).

An expanded ptrace interface with support to breakpoints and NUMA,
similar to what HP uses in their KWDB on ia64 was what I was thinking
about. I talked to the author of HP's debugger a bit this evening.
I thought you might like to chat about it.

-piet

----- End forwarded message -----

