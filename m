From: "Eric S. Raymond" <esr@thyrsus.com>
Date: Thu, 13 Dec 2001 05:05:42 +0000
Subject: [Linux-ia64] Re: [RFC/PATCH] wide Configure.help entries (was Re: We're down to just 32...)
Message-Id: <marc-linux-ia64-105590698805692@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Barry K. Nathan <barryn@pobox.com>:
> Which brings up the question of whether this problem (of entries being
> too wide for menuconfig) should be fixed, and if so, for which kernel
> versions/series. IMO, the problem should be fixed for the 2.4 kernels,
> since (if I'm not mistaken) it's going to be a while before CML2 becomes
> standard for 2.4 kernels, if it ever happens at all. For 2.5, OTOH,
> perhaps the help entries should be left alone in this regard since
> CML2's menuconfig isn't affected by this problem and CML2 is going to be
> merged into 2.5.

On the other hand, the 2.4 and 2.5 Configure.help files have not forked yet,
and the overhead of fixing this problem is low.

Here's what I've done.  First, I have applied your patch.  Next, I added
the following line near the bottom of Configure.help.

# compile-command: "egrep -n '^  .{71,}[^ ]+' Configure.help /dev/null"

Now I can do compile-command in my Emacs and step through the wide entries,
correcting them where possible.  Sometimes it's not; there are some *long* URLs 
in the file.  

I'll clean this up before each Configure.help release.

We're now down to 29 missing entries, by the way; I got three almost immediately
on posting the request, and congratualations to the IA64 port group who are now
completely clean.  Here is the revised list:

ARM port:

CPU_ARM1020_CPU_IDLE: arch/arm/mm/proc-arm1020.S
CPU_ARM1020_D_CACHE_ON: arch/arm/config.in arch/arm/mm/proc-arm1020.S
CPU_ARM1020_FORCE_WRITE_THROUGH: arch/arm/config.in arch/arm/mm/proc-arm1020.S
CPU_ARM1020_I_CACHE_ON: arch/arm/config.in arch/arm/mm/proc-arm1020.S
CPU_ARM1020_ROUND_ROBIN: arch/arm/config.in arch/arm/mm/proc-arm1020.S
CPU_ARM920_CPU_IDLE: arch/arm/config.in arch/arm/mm/proc-arm920.S
CPU_ARM920_D_CACHE_ON: arch/arm/config.in arch/arm/mm/proc-arm920.S
CPU_ARM920_I_CACHE_ON: arch/arm/config.in arch/arm/mm/proc-arm920.S
CPU_ARM920_WRITETHROUGH: arch/arm/config.in arch/arm/mm/proc-arm920.S
CPU_ARM926_CPU_IDLE: arch/arm/config.in arch/arm/mm/proc-arm926.S
CPU_ARM926_D_CACHE_ON: arch/arm/config.in arch/arm/mm/proc-arm926.S
CPU_ARM926_I_CACHE_ON: arch/arm/config.in arch/arm/mm/proc-arm926.S
CPU_ARM926_ROUND_ROBIN: arch/arm/config.in arch/arm/mm/proc-arm926.S
CPU_ARM926_WRITETHROUGH: arch/arm/config.in arch/arm/mm/proc-arm926.S
CPU_FREQ: drivers/video/sa1100fb.c drivers/video/sa1100fb.h drivers/pcmcia/sa1100_generic.c arch/arm/config.in arch/arm/mach-sa1100/Makefile arch/arm/mach-sa1100/generic.c arch/arm/mach-integrator/cpu.c

S390 port:

DASD_AUTO_DIAG: drivers/s390/Config.in drivers/s390/block/dasd.c
DASD_AUTO_ECKD: drivers/s390/Config.in drivers/s390/block/dasd.c
DASD_AUTO_FBA: drivers/s390/Config.in drivers/s390/block/dasd.c
HWC_CPI: drivers/s390/Config.in drivers/s390/char/Makefile
PFAULT: arch/s390/config.in arch/s390/kernel/smp.c arch/s390/kernel/traps.c arch/s390/mm/fault.c arch/s390x/config.in arch/s390x/kernel/smp.c arch/s390x/kernel/traps.c arch/s390x/mm/fault.c
SHARED_KERNEL: arch/s390/Makefile arch/s390/config.in arch/s390/kernel/head.S arch/s390x/Makefile arch/s390x/config.in arch/s390x/kernel/head.S

CRIS port:

ETRAX_ETHERNET_LPSLAVE: arch/cris/drivers/Config.in arch/cris/drivers/Makefile arch/cris/kernel/head.S
ETRAX_ETHERNET_LPSLAVE_HAS_LEDS: arch/cris/drivers/Config.in arch/cris/drivers/lpslave/e100lpslave.S
ETRAX_NETWORK_LED_ON_WHEN_ACTIVITY: arch/cris/drivers/Config.in arch/cris/drivers/ethernet.c arch/cris/drivers/lpslave/e100lpslave.S
ETRAX_NETWORK_LED_ON_WHEN_LINK: arch/cris/drivers/Config.in arch/cris/drivers/ethernet.c arch/cris/drivers/lpslave/e100lpslave.S
ETRAX_SHUTDOWN_BIT: include/asm-cris/io.h arch/cris/config.in

Miscellaneous:

ITE_I2C_ADAP: drivers/i2c/Config.in drivers/i2c/Makefile
ITE_I2C_ALGO: drivers/i2c/Config.in drivers/i2c/Makefile
MTD_ARM_INTEGRATOR: drivers/mtd/maps/Config.in drivers/mtd/maps/Makefile
-- 
		<a href="http://www.tuxedo.org/~esr/">Eric S. Raymond</a>

Government is actually the worst failure of civilized man. There has
never been a really good one, and even those that are most tolerable
are arbitrary, cruel, grasping and unintelligent.
	-- H. L. Mencken 

