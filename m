From: "Eric S. Raymond" <esr@thyrsus.com>
Date: Thu, 13 Dec 2001 02:33:07 +0000
Subject: [Linux-ia64] We're down to just 32 missing Configure.help symbols
Message-Id: <marc-linux-ia64-105590698805689@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We're down to just 32 missing Configure.help entries, thanks to excellent
cooperation from the ARM developers and a siege of rooting through kernel 
sources by yours truly.  That's a big improvement from 96 last week.

If you can supply a Configure.help entry for any of these

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

IA64 port:

IA64_SGI_AUTOTEST: arch/ia64/config.in arch/ia64/sn/sn1/Makefile arch/ia64/sn/sn1/llsc4.c arch/ia64/sn/sn1/sn1_asm.S
SERIAL_SGI_L1_PROTOCOL: arch/ia64/config.in arch/ia64/sn/sn1/setup.c arch/ia64/sn/io/eeprom.c arch/ia64/sn/io/hubspc.c arch/ia64/sn/io/l1.c

Miscellaneous:

ITE_I2C_ADAP: drivers/i2c/Config.in drivers/i2c/Makefile
ITE_I2C_ALGO: drivers/i2c/Config.in drivers/i2c/Makefile
MTD_ARM_INTEGRATOR: drivers/mtd/maps/Config.in drivers/mtd/maps/Makefile
VLAN_8021Q: include/linux/autoconf.h net/Makefile net/netsyms.c net/Config.in net/ipv4/af_inet.c
-- 
		<a href="http://www.tuxedo.org/~esr/">Eric S. Raymond</a>

It will be of little avail to the people, that the laws are made by
men of their own choice, if the laws be so voluminous that they cannot
be read, or so incoherent that they cannot be understood; if they be
repealed or revised before they are promulgated, or undergo such
incessant changes that no man, who knows what the law is to-day, can
guess what it will be to-morrow. Law is defined to be a rule of
action; but how can that be a rule, which is little known, and less
fixed?
	-- James Madison, Federalist Papers 62

