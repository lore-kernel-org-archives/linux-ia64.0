From: Younggyun Koh <young@cc.gatech.edu>
Date: Thu, 27 May 2004 00:44:52 +0000
Subject: Re: Installing kernel 2.6.6 on hp zx6000 (fwd)
Message-Id: <Pine.GSO.4.58.0405262018450.15968@tokyo.cc.gatech.edu>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.GSO.4.58.0405251608490.28567@tokyo.cc.gatech.edu>
In-Reply-To: <Pine.GSO.4.58.0405251608490.28567@tokyo.cc.gatech.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

after upgrading binutils to 2.15.90.x, i got it built! the previous
version of ld i used was 2.12.x, which is supposed to meet the minimum
requirement for 2.6 kernels according to the Documentation/Changes, tho.

but i got another problem...:(

for 2.6 kernel, i installed modules-init-tools 0.9.14 like this,

./configure
make moveold
make
make install
./generate-modprobe.conf /etc/modprobe.conf
cp modprobe.devfs /etc

and in the kernel source directory,

make modules_install
depmod 2.6.6

after doing all this, i rebooted the machine, but i cannot boot with _2.4_
kernel that was running well before i installed modules-init-tools.
when Linux starts, it's stuck on "starting acpi daemon" and doesn't
proceed any more steps.

elilo.conf for kernel 2.6 was probably wrong, so, i cannot boot with
either of kernels (2.4 and 2.6)....

do you have any ideas? did the installation of modules-init-tools
possibly affect 2.4 settings? is there a way i can skip starting that
daemon?

thank you very much,

			-Younggyun Koh (young@cc.gatech.edu)

On Wed, 26 May 2004, H. J. Lu wrote:

> On Wed, May 26, 2004 at 08:46:19AM -0400, Younggyun Koh wrote:
> > > > 3. i got the link error when i build the kernel
> > > >
> > > > bash-2.05$ make CROSS_COMPILE=/opt/gcc-3.3.3/usr/local/bin/
> > >
> > > Can you add "V=1" parameter so we can see the commands?
> >
> >         /opt/gcc-3.3.3/usr/local/bin/ld  -static -T
> > arch/ia64/kernel/vmlinux.lds.s arch/ia64/kernel/head.o arch/ia64/kernel/init_task.o   init/built-in.o
> > --start-group  usr/built-in.o  arch/ia64/kernel/built-in.o  arch/ia64/mm/built-in.o
> > arch/ia64/ia32/built-in.o  arch/ia64/dig/built-in.o  kernel/built-in.o  mm/built-in.o
> > fs/built-in.o ipc/built-in.o  security/built-in.o  crypto/built-in.o  lib/lib.a
> > arch/ia64/lib/lib.a  lib/built-in.o  arch/ia64/lib/built-in.o  drivers/built-in.o
> > sound/built-in.o  arch/ia64/pci/built-in.o  arch/ia64/hp/common/built-in.o
> > arch/ia64/hp/zx1/built-in.o arch/ia64/hp/sim/built-in.o  arch/ia64/sn/built-in.o  net/built-in.o
> > --end-group  -o .tmp_vmlinux1
> > /opt/gcc-3.3.3/usr/local/bin/ld: final link failed: File truncated
> > make: *** [.tmp_vmlinux1] Error 1
> >
>
> Which linker are you using? I suggest get the current one from
>
> http://www.kernel.org/pub/linux/devel/binutils/
>
> It may fix your problem or tell you more about why it fails.
>
>
> H.J.
>
