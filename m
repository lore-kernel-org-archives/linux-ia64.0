From: Will Cohen <wcohen@redhat.com>
Date: Thu, 29 May 2003 21:49:30 +0000
Subject: [Linux-ia64] hp_simserial_driver required for real kernel
Message-Id: <marc-linux-ia64-105590723706081@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I am starting with the linux-2.5.69.tar.bz2 and 
linux-2.5.69-ia64-030521.diff.bz2 to generate kernel sources. It appears 
there is a problem with this version of the code. I am building akernel 
for a real ia64 machine with the following options turned off:

CONFIG_IA64_GENERIC=y
# CONFIG_IA64_HP_SIM is not set

# HP Simulator drivers
#
# CONFIG_HP_SIMETH is not set
# CONFIG_HP_SIMSERIAL is not set
# CONFIG_HP_SIMSCSI is not set

The "make compressed" fails with the following error message:


         ld  -static -T arch/ia64/vmlinux.lds.s arch/ia64/kernel/head.o 
arch/ia64/kernel/init_task.o   init/built-in.o --start-group 
usr/built-in.o  arch/ia64/kernel/built-in.o  arch/ia64/mm/built-in.o 
arch/ia64/dig/built-in.o  kernel/built-in.o  mm/built-in.o 
fs/built-in.o  ipc/built-in.o  security/built-in.o  crypto/built-in.o 
lib/lib.a  arch/ia64/lib/lib.a  drivers/built-in.o  sound/built-in.o 
arch/ia64/pci/built-in.o  arch/ia64/hp/common/built-in.o 
arch/ia64/hp/zx1/built-in.o  arch/ia64/hp/sim/built-in.o 
arch/ia64/oprofile/built-in.o  net/built-in.o --end-group  -o .tmp_vmlinux1
arch/ia64/hp/sim/built-in.o(.text+0x101): In function 
`simcons_console_device':
arch/ia64/hp/sim/hpsim_console.c:64: undefined reference to 
`hp_simserial_driver'
arch/ia64/hp/sim/built-in.o(.text+0x111):arch/ia64/hp/sim/hpsim_console.c:64: 
undefined reference to `hp_simserial_driver'
make: *** [.tmp_vmlinux1] Error 1

Certainly when building for a real machine there should be no need for 
the simulator serial port. Is there a fix for this? Has anyone 
successfully built the  2.5.69 kernel with the patch for a real machine?

-Will


