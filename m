From: Nagendra Singh Tomar <nagendra_tomar@adaptec.com>
Date: Tue, 26 Aug 2003 21:32:15 +0000
Subject: Problems compiling kernel 2.4.18 patched with the latest patch
Message-Id: <marc-linux-ia64-106197620015702@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

The kernel is 2.4.18 taken from kernel.org
Patch applied is linux-2.4.18-ia64-020722.diff taken from
http://www.kernel.org/pub/linux/kernel/ports/ia64/v2.4/
I get the following error=20

/tmp/newhd/usr/src/linux-2.4.18-ia64/include/asm/machvec.h:82:12: pasting=20
"machvec_hpsim" and "." does not give a valid preprocessing token

The detailed compilation log can be found at the end of this mail. I have=20
made a cross compiler tool-chain on a IA32 system, running RedHat-8.0.
I searched in the archives. Looks like people have faced this problem, but =

it was fixed. Is it fixed for 2.4.18 or do I need a later kernel.

Thanx
tomar

Full compiler log:
----------------

. scripts/mkversion > .tmpversion
/usr/local/ia64-linux/bin/gcc -D__KERNEL__ -I/tmp/newhd/usr/src/linux-2.4.1=
8-ia64/include -Wall -Wstrict-prototypes -Wno-trigraphs -g -O2 -fomit-frame=
-pointer -fno-strict-aliasing -fno-common -pipe  -ffixed-r13 -mfixed-range=
=F10-f15,f32-f127 -falign-functions2 -frename-registers --param max-inline-=
insnsP00 -mconstant-gp -DUTS_MACHINE=3D'"ia64"' -DKBUILD_BASENAME=3Dversion=
 -c -o init/version.o init/version.c
make CFLAGS=3D"-D__KERNEL__ -I/tmp/newhd/usr/src/linux-2.4.18-ia64/include =
-Wall -Wstrict-prototypes -Wno-trigraphs -g -O2 -fomit-frame-pointer -fno-s=
trict-aliasing -fno-common -pipe  -ffixed-r13 -mfixed-range=F10-f15,f32-f12=
7 -falign-functions2 -frename-registers --param max-inline-insnsP00 -mconst=
ant-gp" -C  arch/ia64/tools
make[1]: Entering directory `/tmp/newhd/usr/src/linux-2.4.18-ia64/arch/ia64=
/tools'
make[1]: Nothing to be done for `all'.
make[1]: Leaving directory `/tmp/newhd/usr/src/linux-2.4.18-ia64/arch/ia64/=
tools'
make CFLAGS=3D"-D__KERNEL__ -I/tmp/newhd/usr/src/linux-2.4.18-ia64/include =
-Wall -Wstrict-prototypes -Wno-trigraphs -g -O2 -fomit-frame-pointer -fno-s=
trict-aliasing -fno-common -pipe  -ffixed-r13 -mfixed-range=F10-f15,f32-f12=
7 -falign-functions2 -frename-registers --param max-inline-insnsP00 -mconst=
ant-gp" -C  arch/ia64/kernel
make[1]: Entering directory `/tmp/newhd/usr/src/linux-2.4.18-ia64/arch/ia64=
/kernel'
make[1]: Nothing to be done for `all'.
make[1]: Leaving directory `/tmp/newhd/usr/src/linux-2.4.18-ia64/arch/ia64/=
kernel'
make CFLAGS=3D"-D__KERNEL__ -I/tmp/newhd/usr/src/linux-2.4.18-ia64/include =
-Wall -Wstrict-prototypes -Wno-trigraphs -g -O2 -fomit-frame-pointer -fno-s=
trict-aliasing -fno-common -pipe  -ffixed-r13 -mfixed-range=F10-f15,f32-f12=
7 -falign-functions2 -frename-registers --param max-inline-insnsP00 -mconst=
ant-gp" -C  arch/ia64/mm
make[1]: Entering directory `/tmp/newhd/usr/src/linux-2.4.18-ia64/arch/ia64=
/mm'
make all_targets
make[2]: Entering directory `/tmp/newhd/usr/src/linux-2.4.18-ia64/arch/ia64=
/mm'
make[2]: Nothing to be done for `all_targets'.
make[2]: Leaving directory `/tmp/newhd/usr/src/linux-2.4.18-ia64/arch/ia64/=
mm'
make[1]: Leaving directory `/tmp/newhd/usr/src/linux-2.4.18-ia64/arch/ia64/=
mm'
make CFLAGS=3D"-D__KERNEL__ -I/tmp/newhd/usr/src/linux-2.4.18-ia64/include =
-Wall -Wstrict-prototypes -Wno-trigraphs -g -O2 -fomit-frame-pointer -fno-s=
trict-aliasing -fno-common -pipe  -ffixed-r13 -mfixed-range=F10-f15,f32-f12=
7 -falign-functions2 -frename-registers --param max-inline-insnsP00 -mconst=
ant-gp" -C  arch/ia64/lib
make[1]: Entering directory `/tmp/newhd/usr/src/linux-2.4.18-ia64/arch/ia64=
/lib'
make[1]: `lib.a' is up to date.
make[1]: Leaving directory `/tmp/newhd/usr/src/linux-2.4.18-ia64/arch/ia64/=
lib'
make CFLAGS=3D"-D__KERNEL__ -I/tmp/newhd/usr/src/linux-2.4.18-ia64/include =
-Wall -Wstrict-prototypes -Wno-trigraphs -g -O2 -fomit-frame-pointer -fno-s=
trict-aliasing -fno-common -pipe  -ffixed-r13 -mfixed-range=F10-f15,f32-f12=
7 -falign-functions2 -frename-registers --param max-inline-insnsP00 -mconst=
ant-gp" -C  arch/ia64/hp
make[1]: Entering directory `/tmp/newhd/usr/src/linux-2.4.18-ia64/arch/ia64=
/hp'
make -C common
make[2]: Entering directory `/tmp/newhd/usr/src/linux-2.4.18-ia64/arch/ia64=
/hp/common'
make all_targets
make[3]: Entering directory `/tmp/newhd/usr/src/linux-2.4.18-ia64/arch/ia64=
/hp/common'
make[3]: Nothing to be done for `all_targets'.
make[3]: Leaving directory `/tmp/newhd/usr/src/linux-2.4.18-ia64/arch/ia64/=
hp/common'
make[2]: Leaving directory `/tmp/newhd/usr/src/linux-2.4.18-ia64/arch/ia64/=
hp/common'
make -C sim
make[2]: Entering directory `/tmp/newhd/usr/src/linux-2.4.18-ia64/arch/ia64=
/hp/sim'
make all_targets
make[3]: Entering directory `/tmp/newhd/usr/src/linux-2.4.18-ia64/arch/ia64=
/hp/sim'
/usr/local/ia64-linux/bin/gcc -D__KERNEL__ -I/tmp/newhd/usr/src/linux-2.4.1=
8-ia64/include -Wall -Wstrict-prototypes -Wno-trigraphs -g -O2 -fomit-frame=
-pointer -fno-strict-aliasing -fno-common -pipe  -ffixed-r13 -mfixed-range=
=F10-f15,f32-f127 -falign-functions2 -frename-registers --param max-inline-=
insnsP00 -mconstant-gp  -DKBUILD_BASENAME=3Dhpsim_machvec  -c -o hpsim_mach=
vec.o hpsim_machvec.c
In file included from /tmp/newhd/usr/src/linux-2.4.18-ia64/include/asm/mach=
vec_init.h:5,
                 from hpsim_machvec.c:2:
/tmp/newhd/usr/src/linux-2.4.18-ia64/include/asm/machvec.h:82:12: pasting "=
machvec_hpsim" and "." does not give a valid preprocessing token
make[3]: *** [hpsim_machvec.o] Error 1
make[3]: Leaving directory `/tmp/newhd/usr/src/linux-2.4.18-ia64/arch/ia64/=
hp/sim'
make[2]: *** [first_rule] Error 2
make[2]: Leaving directory `/tmp/newhd/usr/src/linux-2.4.18-ia64/arch/ia64/=
hp/sim'
make[1]: *** [_subdir_sim] Error 2
make[1]: Leaving directory `/tmp/newhd/usr/src/linux-2.4.18-ia64/arch/ia64/=
hp'
make: *** [_dir_arch/ia64/hp] Error 2



