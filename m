From: Mark Buckaway <markb@platespin.com>
Date: Thu, 03 May 2001 18:37:57 +0000
Subject: [Linux-ia64] Kernel 2.4.4 compile problems...
Message-Id: <marc-linux-ia64-105590693005531@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Situation:

I've install Redhat Wolverine onto our IA64 system (BigSur). I've
downloaded and "installed" the 2.4.4 kernel source. I've attempting to
make vmlinux after make menuconfig, and it stops on main.c (errors
below). BTW, this is the same problem I had with the 2.4.3 plus the
Apr.5 patch on the previous redhat IA64 release...although I had better
luck with the SGIPro compiler, but it would not link the kernel. BTW,
I've wiped the /usr/include/asm and /usr/include/linux directories and
correctly linked them into the kernel source. Help.

So far, I've assumed the gcc (2.96) with Redhat is busted or I need more
caffine. In any respect, can someone offer some tips on compiling the
kernel on a IA64 system...or recommend something better then Redhat to
use.

Error:
[root@ia64 linux]# make vmlinux
gcc -D__KERNEL__ -I/usr/src/linux-2.4.4/include -Wall
-Wstrict-prototypes -O2 -fomit-frame-pointer -fno-strict-aliasing -pipe=20
-Wa,-x -ffixed-r13 -mfixed-range=F10-f15,f32-f127 -funwind-tables
-falign-functions2 -mconstant-gp  -c -o init/main.o init/main.c
In file included from /usr/src/linux-2.4.4/include/linux/irq.h:57,
                 from /usr/src/linux-2.4.4/include/asm/hardirq.h:12,
                 from /usr/src/linux-2.4.4/include/linux/interrupt.h:45,
                 from /usr/src/linux-2.4.4/include/asm/smplock.h:6,
                 from /usr/src/linux-2.4.4/include/linux/smp_lock.h:16,
                 from /usr/src/linux-2.4.4/include/linux/raid/md.h:32,
                 from init/main.c:24:
/usr/src/linux-2.4.4/include/asm/hw_irq.h: In function
`__ia64_irq_desc':
/usr/src/linux-2.4.4/include/asm/hw_irq.h:93: arithmetic on pointer to
an incomplete type
/usr/src/linux-2.4.4/include/asm/hw_irq.h: At top level:
/usr/src/linux-2.4.4/include/asm/hw_irq.h:121: `irq_desc' redeclared as
different kind of symbol
/usr/src/linux-2.4.4/include/linux/irq.h:55: previous declaration of
`irq_desc'
/usr/src/linux-2.4.4/include/asm/hw_irq.h:121: warning: `irq_desc' was
declared `extern' and later `static'
In file included from /usr/src/linux-2.4.4/include/linux/skbuff.h:27,
                 from
/usr/src/linux-2.4.4/include/linux/netdevice.h:146,
                 from /usr/src/linux-2.4.4/include/net/ip.h:29,
                 from /usr/src/linux-2.4.4/include/net/checksum.h:31,
                 from /usr/src/linux-2.4.4/include/linux/raid/md.h:34,
                 from init/main.c:24:
/usr/src/linux-2.4.4/include/linux/highmem.h: In function
`clear_user_highpage':
/usr/src/linux-2.4.4/include/linux/highmem.h:48: too few arguments to
function `clear_user_page'
/usr/src/linux-2.4.4/include/linux/highmem.h: In function
`copy_user_highpage':
/usr/src/linux-2.4.4/include/linux/highmem.h:90: too few arguments to
function `copy_user_page'
init/main.c: In function `do_linuxrc':
/usr/src/linux-2.4.4/include/asm/unistd.h:290: warning: `dummy2' might
be used uninitialized in this function
/usr/src/linux-2.4.4/include/asm/unistd.h:290: warning: `dummy3' might
be used uninitialized in this function
....tons of more dummyX might be used bla, bla, bla removed.


Mark                                                                       =
          =20

--
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Mark Buckaway             Tel: 416-203-4582   http://www.platespin.com
Sr. Software Developer    Fax: 416-203-0621   Email: markb@platespin.com
Platespin Inc.      Reception: 416-203-6565
--------------------------------------------------------------------------
The statements made in this message are the opinions of the author and
may or may not reflect the opinions of Platespin Inc.
--------------------------------------------------------------------------

