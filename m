From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Thu, 25 Mar 2004 01:15:51 +0000
Subject: In-Kernel NaT consumption trap when debugging highly-parallel
Message-Id: <16482.12999.250663.921106@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

X-Mailer: VM 7.17 under 21.4 (patch 15) "Security Through Obscurity" XEmacs=
 Lucid
Comments: Hyperbole mail buttons accepted, v04.18.
X-Face: GgFg(Z>fx((4\32hvXq<)|jndSniCH~~$D)Ka:P@e@JR1P%Vr}EwUdfwf-4j\rUs#JR=
{'h#
 !]])6%Jh~b$VA|ALhnpPiHu[-x~@<"@Iv&|%R)Fq[[,(&Z'O)Q)xCqe1\M[F8#9l8~}#u$S$Rm=
`S9%
 \'T@`:&8>Sb*c5d'=EDYI&GF`+t[LfDH=3D"MP5rwOO]w>ALi7'=3DQJHz&y&C&TE_3j!
--text follows this line--

Hi,
	I'm trying to debug a highly-threaded user-space program, but
gdb is triggering NaT consumption faults in the middle of ptrace.

Does anyone have any good ideas on what could be going wrong, and how
to debug this?

stracing gdb gives this:
....
wait4(-1, 0x60000fffffffa570, WNOHANG|__WCLONE, NULL) =3D -1 ECHILD (No
child proc
esses)
wait4(-1, [WIFSTOPPED(s) && WSTOPSIG(s) =3D SIGTRAP], WNOHANG, NULL) 5015
ptrace(PTRACE_PEEKUSER, 5015, f32, NULL) =3D 2305843009213940640
open("/proc/5015/status", O_RDONLY)     =3D 15
fstat(15, {st_mode=3DS_IFREG|0444, st_size=3D0, ...}) =3D 0
mmap(NULL, 65536, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) =3D 0x20
000000005b0000
read(15, "Name:\tgigaecho.bin\nState:\tT (sto"..., 1024) =3D 495
read(15, "", 1024)                      =3D 0
close(15)                               =3D 0
munmap(0x20000000005b0000, 65536)       =3D 0
ptrace(0x4201 /* PTRACE_??? */, 5015, 0, 0x60000fffffffa4a0) =3D 0
wait4(5018, [WIFSTOPPED(s) && WSTOPSIG(s) =3D SIGSTOP], 0, NULL) =3D 5018
ptrace(PTRACE_PEEKUSER, 5015, r1, NULL) =3D 2305843009216381440
ptrace(PTRACE_PEEKUSER, 5015, r2, NULL) =3D 2305843009216661592
ptrace(PTRACE_PEEKUSER, 5015, r3, NULL) =3D 2305843009216656032
ptrace(PTRACE_PEEKUSER, 5015, r4,  <unfinished ...>
+++ killed by SIGSEGV +++



And in the log:
 gdb[5014]: NaT consumption 17179869216 [5]

Pid: 5014, CPU 0, comm:                  gdb
psr : 0000101008026018 ifs : 8000000000000005 ip  :
[<a00000010003d320>]    Not tainted
ip is at unw_access_gr+0x1a0/0x5a0
unat: 0000000000000000 pfs : 000000000000048e rsc : 0000000000000003
rnat: 0000000000000000 bsps: a000000100a49840 pr  : 10000004aa996555
ldrs: 0000000000000000 ccv : 0000000000000008 fpsr: 0009804c8a70033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a00000010002dbb0 b6  : a00000010002f1a0 b7  : a00000010000d2c0
f6  : 1003e9e3779b97f4a7c16 f7  : 000000000000000000000
f8  : 1003e0000000000000077 f9  : 1003e0000000000000341
f10 : 1003e6db6db6db6db6db7 f11 : 1003efffffffffffffff7
r1  : a000000100a49840 r2  : 0000000000000003 r3  : 0000000000000000
r8  : 0000000000000000 r9  : e000000034ab7cd0 r10 : 1ffffffff0c48240
r11 : 1ffffffff0c48242 r12 : e000000034ab7c00 r13 : e000000034ab0000
r14 : 0000000000000000 r15 : 0000000000000038 r16 : 0100000000000000
r17 : 0000000000000000 r18 : 00000000000000c0 r19 : a00000010077628c
r20 : 0000000000000000 r21 : a000000100776290 r22 : 0000000000000017
r23 : 0000000000000002 r24 : 0000000000000000 r25 : a000000100852ff8
r26 : 0000000000000000 r27 : a00000010077628c r28 : a000000100776270
r29 : a000000100042030 r30 : ffffffffff9c4218 r31 : a00000010067de08

Call Trace:
 [<a000000100014880>] show_stack+0x80/0xa0
                                sp=E000000034ab7760 bsp=E000000034ab1278
 [<a000000100037520>] die+0x140/0x1e0
                                sp=E000000034ab7930 bsp=E000000034ab1250
 [<a0000001000381f0>] ia64_fault+0x150/0xb60
                                sp=E000000034ab7930 bsp=E000000034ab1210
 [<a00000010000db00>] ia64_leave_kernel+0x0/0x260
                                sp=E000000034ab7a30 bsp=E000000034ab1210
 [<a00000010003d320>] unw_access_gr+0x1a0/0x5a0
                                sp=E000000034ab7c00 bsp=E000000034ab11e0
 [<a00000010002dbb0>] access_uarea+0xc10/0xfe0
                                sp=E000000034ab7c00 bsp=E000000034ab1198
 [<a00000010002f4b0>] sys_ptrace+0x310/0x800
                                sp=E000000034ab7e20 bsp=E000000034ab1110
 [<a00000010000d7f0>] ia64_trace_syscall+0xd0/0x110
                                sp=E000000034ab7e30 bsp=E000000034ab1110
