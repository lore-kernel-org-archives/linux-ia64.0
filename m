From: shiva shankar chetan <chetan@uiuc.edu>
Date: Mon, 26 Aug 2002 23:54:34 +0000
Subject: [Linux-ia64] error during kernel compile
Message-Id: <marc-linux-ia64-105590701905980@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi,

I have been trying to compile the kernel but then it throws out the
below error. I am compiling kernel 2.4.17 and have gcc 2.96. I am
doing a
make mrproper
make menuconfig
make dep
make

Please let me know whats going wrong.

bash-2.05$ make
scripts/split-include include/linux/autoconf.h include/config
gcc -D__KERNEL__ -I/mnt/ironman/Projects/Chetan/linux-2.4.17/include -Wall
-Wstrict-prototypes -Wno-trigraphs -O2 -fomit-frame-pointer
-fno-strict-aliasing -fno-common -pipe  -ffixed-r13
-mfixed-range=F10-f15,f32-f127 -falign-functions2 -mconstant-gp  -c -o
init/main.o init/main.c
In file included from
/mnt/ironman/Projects/Chetan/linux-2.4.17/include/linux/pagemap.h:16,
                 from
/mnt/ironman/Projects/Chetan/linux-2.4.17/include/linux/locks.h:8,
                 from
/mnt/ironman/Projects/Chetan/linux-2.4.17/include/linux/devfs_fs_kernel.h:6,
                 from init/main.c:16:
/mnt/ironman/Projects/Chetan/linux-2.4.17/include/linux/highmem.h: In
function `clear_user_highpage':
/mnt/ironman/Projects/Chetan/linux-2.4.17/include/linux/highmem.h:49: too
few arguments to function `clear_user_page'
/mnt/ironman/Projects/Chetan/linux-2.4.17/include/linux/highmem.h: In
function `copy_user_highpage':
/mnt/ironman/Projects/Chetan/linux-2.4.17/include/linux/highmem.h:91: too
few arguments to function `copy_user_page'
In file included from
/mnt/ironman/Projects/Chetan/linux-2.4.17/include/linux/irq.h:69,
                 from
/mnt/ironman/Projects/Chetan/linux-2.4.17/include/asm/hardirq.h:12,
                 from
/mnt/ironman/Projects/Chetan/linux-2.4.17/include/linux/interrupt.h:45,
                 from
/mnt/ironman/Projects/Chetan/linux-2.4.17/include/asm/smplock.h:6,
                 from
/mnt/ironman/Projects/Chetan/linux-2.4.17/include/linux/smp_lock.h:16,
                 from init/main.c:24:
/mnt/ironman/Projects/Chetan/linux-2.4.17/include/asm/hw_irq.h: In
function `__ia64_irq_desc':
/mnt/ironman/Projects/Chetan/linux-2.4.17/include/asm/hw_irq.h:94:
arithmetic on pointer to an incomplete type
/mnt/ironman/Projects/Chetan/linux-2.4.17/include/asm/hw_irq.h: At top
level:
/mnt/ironman/Projects/Chetan/linux-2.4.17/include/asm/hw_irq.h:122:
`irq_desc' redeclared as different kind of symbol
/mnt/ironman/Projects/Chetan/linux-2.4.17/include/linux/irq.h:67: previous
declaration of `irq_desc'
/mnt/ironman/Projects/Chetan/linux-2.4.17/include/asm/hw_irq.h:122:
warning: `irq_desc' was declared `extern' and later `static'
make: *** [init/main.o] Error 1

Thanks
Chetan



