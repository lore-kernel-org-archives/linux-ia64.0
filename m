From: Evan Felix <evan.felix@pnl.gov>
Date: Fri, 15 Aug 2003 22:37:39 +0000
Subject: ia64 2.6.0-test3 crashes on IOZone
Message-Id: <marc-linux-ia64-106098668517415@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Recently i've been trying to run linux 2.6.0-test3 on a HP zx2000,  I've
run IOZone twice on the system and both times it has crashed with:

pdflush[546]: General Exception: IA-64 Reserved Register/Field fault
(data acce]
                                                                           =
    =20
Pid: 546, CPU 0, comm:            =20
pdflush                                    =20
psr : 0000101008026018 ifs : 8000000000000002 ip  :
[<a0000001000d2e80>]    Notd
ip is at
kmem_cache_free+0xe0/0x180                                            =20
unat: a0000001003a0ef0 pfs : 000000000000040b rsc :
e00000000ffbc3c0           =20
rnat: 0000000000001000 bsps: 0000000000000000 pr  :
a0000001009d60b0           =20
ldrs: 0000000000000712 ccv : 0000028000000030 fpsr:
000000000000030a           =20
csd : c00000000ffbc3ea ssd :
0000000000000000                                  =20
b0  : a000000100301b60 b6  : 000000000000c000 b7  :
e00000000ffbc3c0           =20
f6  : 00003e000000025d70e60 f7  :
e000000017f3eb30e000000017f3ebb0             =20
f8  : 00005a000000100011ae0 f9  :
100068000000000000000                        =20
f10 : 1000397fffffff6800000 f11 :
1003e0000000000000013                        =20
r1  : e00000000ffbc3c0 r2  : a000000100113970 r3  :
0000000000000206           =20
r8  : e00000003ebf02a0 r9  : 0000000000054000 r10 :
0000000000000000           =20
r11 : 0000000000000000 r12 : a0000001009d60b0 r13 :
a000000100116820           =20
r14 : a0000001009d60b0 r15 : e00000000ffbc3c0 r16 :
a0000001000c5ae0           =20
r17 : a0000001009d60b0 r18 : a000000100115270 r19 :
0000000000000207           =20
r20 : a000000100115270 r21 : 0000000000000207 r22 :
e00000000481ea00           =20
r23 : e00000000ffbc3c0 r24 : 0000001008026018 r25 :
a0000001000c5980           =20
r26 : 0000000000000308 r27 : e00000000481ea10 r28 :
e00000000481edd0           =20
r29 : 000000000000000f r30 : e000000017f3ebb0 r31 :
0000000000000018           =20
                                                                           =
    =20
Call
Trace:                                                                     =

 [<a0000001000197a0>]
show_stack+0x80/0xa0                                     =20
                                sp=E000000017f3ed80
bsp=E000000017f3ed68       =20
 [<a00000010003eb20>]
die+0x200/0x300                                          =20
                                sp=E000000017f3ef50
bsp=E000000017f3ed40       =20
 [<a00000010003f970>]
ia64_fault+0x150/0xb20                                   =20
                                sp=E000000017f3ef50
bsp=E000000017f3ed00       =20
 [<a000000100011ae0>]
ia64_leave_kernel+0x0/0x280                              =20
                                sp=E000000017f3f050
bsp=E000000017f3ed00       =20
 <0>Kernel panic: Aiee, killing interrupt
handler!                             =20
In interrupt handler - not syncing  =20


I dont think the stack trace is complete, but here is the relavant code
from objdump for kmem_cache_free+0xe0/0x180:

mm/slab.c:2125
    3c70:       02 b0 00 00 25 04       [MII]       mov r22=3Dpsr
    3c76:       f0 00 00 00 49 a0                   mov r15=16384;;
    3c7c:       f2 10 31 80                         and r21=3Dr15,r34
    3c80:       03 00 00 00 01 00       [MII]       nop.m 0x0
    3c86:       00 00 00 02 00 e0                   nop.i 0x0;;
    3c8c:       50 01 18 e0                         cmp.eq
p7,p6=3Dr21,r0;;
    3c90:       d9 00 00 02 06 c0       [MMB] (p06) ssm 0x4000
    3c96:       01 00 04 0e 00 00             (p07) rsm 0x4000
    3c9c:       00 00 00 20                         nop.b 0x0;;
    3ca0:       c0 00 00 00 30 00       [MII] (p06) srlz.d
    3ca6:       80 01 00 60 00 80                   mov r24=3Dip
    3cac:       f2 b0 30 80                         and r20=3Dr15,r22
    3cb0:       02 78 00 02 00 24       [MII]       addl r15=3D0,r1
    3cb6:       90 00 54 10 72 40                   cmp.eq p9,p8=3D0,r21;;
    3cbc:       01 a0 2c e4                         cmp.eq p10,p11=3D0,r20
    3cc0:       56 01 08 00 c0 10       [BBB] (p10) br.cond.dpnt.few
3ce0 <kmem_cache_free+0x120>
    3cc6:       02 10 00 80 21 00             (p08) br.cond.dpnt.few
3ce0 <kmem_cache_free+0x120>
    3ccc:       00 00 00 20                         nop.b 0x0
    3cd0:       0a b8 00 1e 18 10       [MMI]       ld8 r23=3D[r15];;
mm/slab.c:2131


It did actually complete some of the IOZONE:

        Command line used: ./iozone -aze -M -i 0 -i 1 -n 1g -g 4g -R -b
j2.xls -f /tmp/iozone.tmp
        Output is in Kbytes/sec
        Time Resolution =3D 0.000001 seconds.
        Processor cache size set to 1024 Kbytes.
        Processor cache line size set to 32 bytes.
        File stride size set to 17 * record size.          =20
                                                            random=20
random    bkwd  record=20
stride                                               =20
              KB  reclen   write rewrite    read    reread    read =20
write    read rewrite    read   fwrite frewrite   fread  freread       =20
         1048576       4   43462   42361    86255    78589
         1048576       8   43811   42776    47928    48794
         1048576      16   43965   43113    48427    48885
         1048576      32   44198   43177    48516    48866
         1048576      64   44010   43113    48497    48834
         1048576     128   43900   43103    48534    48858
         1048576     256   43922   43103    48516    48812
         1048576     512   43967   43104    48471    48834
         1048576    1024   43869   43095    48441    46100
         1048576    2048   43880   43012    48501    48824
         1048576    4096   44096   43605    44953    48838
         1048576    8192   44138   43163    48442    48884
         1048576   16384   43879   42989    48444    48848
         2097152       4   43431   39915    48297    48321
         2097152       8   43534   38964    48306    48298
         2097152      16   43583   39956    47097    48025
         2097152      32   43561   40084    48316    48223
         2097152      64   43610   40130    48335    48313
         2097152     128   43626   40185    48332    48316
         2097152     256   43540   40052    48302    48266
         2097152     512   43703   39468    47964    48327
         2097152    1024   43541   39975    48238    48316
         2097152    2048   43715   40091    48283    48275
         2097152    4096   43587   40024    48330    48300
         2097152    8192   43624   39977    48298    48316
         2097152   16384   42779   39704    48335    48333
         4194304       4   42774   37505    47486    47484
         4194304       8Read from remote host j: Connection timed out

Evan
--=20
-------------------------
Evan Felix
Environmental Molecular Sciences Laboratory
Pacific Northwest National Laboratory
Operated for the U.S. DOE by Battelle

