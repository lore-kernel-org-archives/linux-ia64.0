From: "Bahnsen, Bruce" <bruce.bahnsen@intel.com>
Date: Fri, 17 Jan 2003 00:42:20 +0000
Subject: [Linux-ia64] Error compiling 2.4.20 for i386
Message-Id: <marc-linux-ia64-105590709805709@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

I applied the ia64 patch to the 2.4.20 kernel (all from kernel.org). If I
try to compile i386 using the default config, I get the following compile
error:

gcc -D__KERNEL__ -I/home/bbahnsen/linux-2.4.20/include -Wall
-Wstrict-prototypes -Wno-trigraphs -O2 -fno-strict-aliasing -fno-common -g
-fomit-frame-pointer -pipe -mpreferred-stack-boundary=3D2 -march=3Di686
-nostdinc -iwithprefix include -DKBUILD_BASENAME=3Dsetup  -c -o setup.o
setup.c
setup.c: In function `parse_cmdline_early':
setup.c:792: `enable_acpi_smp_table' undeclared (first use in this function)
setup.c:792: (Each undeclared identifier is reported only once
setup.c:792: for each function it appears in.)
setup.c: In function `setup_arch':
setup.c:1139: `enable_acpi_smp_table' undeclared (first use in this
function)
make[1]: *** [setup.o] Error 1
make[1]: Leaving directory `/home/bbahnsen/linux-2.4.20/arch/i386/kernel'
make: *** [_dir_arch/i386/kernel] Error 2

Is there another patch I need (possibly acpi) or did I miss something?

I am getting errors compiling ia64 as well, such as:

gcc -D__KERNEL__ -I/home/bbahnsen/linux-2.4.20/include -Wall
-Wstrict-prototypes -Wno-trigraphs -O2 -fno-strict-aliasing -fno-common -g
-fomit-frame-pointer -pipe  -ffixed-r13 -mfixed-range=F10-f15,f32-f127
-falign-functions2 -frename-registers --param max-inline-insnsP00
-mconstant-gp  -nostdinc -iwithprefix include -DKBUILD_BASENAME=3Dsmpboot  =
-c
-o smpboot.o smpboot.c
smpboot.c:92: conflicting types for `smp_threads_ready'
/home/bbahnsen/linux-2.4.20/include/linux/smp.h:51: previous declaration of
`smp_threads_ready'
make[1]: *** [smpboot.o] Error 1
make[1]: Leaving directory `/home/bbahnsen/linux-2.4.20/arch/ia64/kernel'
make: *** [_dir_arch/ia64/kernel] Error 2

I did not have this trouble with 2.4.19.

Any advice you can give me would be appreciated. Thanks in advance.

Bruce Bahnsen


