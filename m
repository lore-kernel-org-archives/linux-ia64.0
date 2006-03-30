From: Jes Sorensen <jes@sgi.com>
Date: Thu, 30 Mar 2006 13:24:19 +0000
Subject: Re: [Fedora-ia64-list] kernel 2.6.16-1.2097_FC6 unbootable on Itanium
Message-Id: <yq07j6cuku4.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <442AB6DD.4020800@sgi.com>
In-Reply-To: <442AB6DD.4020800@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

>>>>> "Jes" =3D Jes Sorensen <jes@sgi.com> writes:

Jes> Tracked it down further. If I take the gate.o file from a working
Jes> kernel and copy it into the broken tree and run make again, the
Jes> resulting kernel boots.

Jes> I compared the code between a working and a broken gate.o with
Jes> objdump and it's identical. However the good file is 3552 bytes
Jes> whereas the broken one is 3648.

Looks like something goes wrong with some linking references due to
this. I ran objdump on the two kernels I get when replacing gate.o and
the diff is as attached below. Not sure if this is an ia64 specific
bug or we're just 'lucky'.

Cheers,
Jes

--- ../good/vmlinux.s	2006-03-30 15:13:11.000000000 +0200
+++ ../broken/vmlinux.s	2006-03-30 15:11:57.000000000 +0200
@@ -4981,8 +4981,8 @@
 a00000010000bd96:	30 01 44 44 08 40 	            mov.m r19=3Dar.bsp
 a00000010000bd9c:	01 00 40 00       	            mov f10=F0
 a00000010000bda0:	05 00 00 00 01 00 	[MLX]       nop.m 0x0
-a00000010000bda6:	00 00 00 00 20 c0 	            movl r14=3D0xa00000000001=
0640;;
-a00000010000bdac:	01 24 30 68=20
+a00000010000bda6:	00 00 00 00 00 c0 	            movl r14=3D0x10080;;
+a00000010000bdac:	01 20 04 60=20
 a00000010000bdb0:	08 00 00 32 2a 04 	[MMI]       mov.m ar25=3Dr0
 a00000010000bdb6:	00 00 80 54 08 e0 	            mov.m ar.ccv=3Dr0
 a00000010000bdbc:	e0 08 00 07       	            mov b7=3Dr14
@@ -8192,8 +8192,8 @@
 a00000010000fe06:	00 01 00 00 20 c0 	            movl r14=3D0xa00000010000=
bc60
 a00000010000fe0c:	01 06 e0 6d=20
 a00000010000fe10:	05 00 00 00 01 00 	[MLX]       nop.m 0x0
-a00000010000fe16:	00 00 00 00 20 80 	            movl r28=3D0xa00000000001=
0620;;
-a00000010000fe1c:	03 22 30 68=20
+a00000010000fe16:	00 00 00 00 00 80 	            movl r28=3D0x10060;;
+a00000010000fe1c:	03 26 00 60=20
 a00000010000fe20:	01 10 00 20 00 21 	[MII]       mov r2=3Dr16
 a00000010000fe26:	00 21 42 0c 42 e0 	            adds r16=836,r16
 a00000010000fe2c:	03 00 cc 00       	            mov r31=3Dpr;;
@@ -1563052,7 +1563052,7 @@
 a00000010091856c:	03 73 ff 00       	            data8 0x1fee607fe
 a000000100918570:	73 ec 02 f0 05 44 	[MBB] (p35) mov pmd[r120]=3Dr0
 a000000100918576:	ee 02 f0 06 46 e8 	            data8 0x1181bc00bb9
-a00000010091857c:	02 f0 03 4c       	            br.ctop.sptk.few.clr a000=
0000ff957570 <__kernel_sigtramp+0xff946e50>;;
+a00000010091857c:	02 f0 03 4c       	            br.ctop.sptk.few.clr a000=
0000ff957570 <__end_gate_brl_fsys_bubble_down_patchlist+0xff957064>;;
 a000000100918580:	e4 02 f0 01 36 e6 	[MLX] (p23) mov r0=3D-2090116
 a000000100918586:	02 f0 02 38 e1 02 	            data8 0x1be0edc605
 a00000010091858c:	e3 76 f0 0d=20
@@ -1563061,7 +1563061,7 @@
 a00000010091859c:	03 73 ff 00       	            data8 0x1fee607fe
 a0000001009185a0:	73 ec 00 f0 05 44 	[MBB] (p35) mov pmd[r120]=3Dr0
 a0000001009185a6:	ee 00 f0 06 46 e8 	            data8 0x1181bc003b9
-a0000001009185ac:	00 f0 03 4c       	            br.ctop.sptk.few.clr a000=
0000ff9575a0 <__kernel_sigtramp+0xff946e80>;;
+a0000001009185ac:	00 f0 03 4c       	            br.ctop.sptk.few.clr a000=
0000ff9575a0 <__end_gate_brl_fsys_bubble_down_patchlist+0xff957094>;;
 a0000001009185b0:	e4 00 f0 01 36 e6 	[MLX] (p07) mov r0=3D-2090116
 a0000001009185b6:	00 f0 02 38 e1 00 	            data8 0x1cdf2edc601
 a0000001009185bc:	e3 76 f9 e6=20
