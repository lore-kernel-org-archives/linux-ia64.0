From: Brent Clements <bclem@rice.edu>
Date: Fri, 28 Feb 2003 18:02:27 +0000
Subject: [Linux-ia64] Kernel compile errors.
Message-Id: <marc-linux-ia64-105590709805945@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

I am having the hardest time compiling kernel 2.4.20 with the latest
ia64 patches from kernel.org

I am using gcc-3.2.2 with binutils 2.13, I have set my path to point to
both of these directories direct. I have also specified in the kernel
Makefile to point to these paths directly.

When I do a compile of the kernel by doing make dep, make vmlinux

I get the following errors when it gets to the smp.c file

gcc3 -D__KERNEL__ -I/usr/src/linux-2.4.20/include -Wall
-Wstrict-prototypes -Wno-trigraphs -O2 -fno-strict-aliasing -fno-common
-g -fomit-frame-pointer -pipe  -ffixed-r13
-mfixed-range=F10-f15,f32-f127 -falign-functions2 -frename-registers
--param max-inline-insnsP00 -mconstant-gp  -nostdinc -iwithprefix
include -DKBUILD_BASENAME=3Dsmp  -c -o smp.o smp.c
{standard input}: Assembler messages:
{standard input}:864: Warning: Use of 'mov' may violate WAW dependency
'RR#' (impliedf)
{standard input}:864: Warning: Only the first path encountering the
conflict is reported
{standard input}:863: Warning: This is the location of the conflicting
usage
{standard input}:864: Warning: Use of 'mov' may violate WAW dependency
'RR#' (impliedf)
{standard input}:864: Warning: Only the first path encountering the
conflict is reported
{standard input}:863: Warning: This is the location of the conflicting
usage
{standard input}:864: Warning: Use of 'mov' may violate WAW dependency
'RR#' (impliedf)
{standard input}:864: Warning: Only the first path encountering the
conflict is reported
{standard input}:863: Warning: This is the location of the conflicting
usage

Then I get the following.
gcc3 -D__KERNEL__ -I/usr/src/linux-2.4.20/include -Wall
-Wstrict-prototypes -Wno-trigraphs -O2 -fno-strict-aliasing -fno-common
-g -fomit-frame-pointer -pipe  -ffixed-r13
-mfixed-range=F10-f15,f32-f127 -falign-functions2 -frename-registers
--param max-inline-insnsP00 -mconstant-gp  -nostdinc -iwithprefix
include -DKBUILD_BASENAME=3Dsmpboot  -c -o smpboot.o smpboot.c
smpboot.c:92: conflicting types for `smp_threads_ready'
/usr/src/linux-2.4.20/include/linux/smp.h:51: previous declaration of
`smp_threads_ready'
make[1]: *** [smpboot.o] Error 1
make[1]: Leaving directory `/usr/src/linux-2.4.20/arch/ia64/kernel'
make: *** [_dir_arch/ia64/kernel] Error 2


Any help would be appreciated.

I have noticed that when I compile using gcc-2.96 with binutil-2.13 it
works great.

Thanks for any help.

-Brent





