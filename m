From: Grant Grundler <grundler@parisc-linux.org>
Date: Wed, 10 Oct 2007 06:35:32 +0000
Subject: compile 2.6.23 for zx2000?
Message-Id: <20071010063532.GA15655@colo.lackof.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi folks,
After a long break, I'm trying to update the kernel on my ia64 HP zx2000.
Config file is attached. Two issues with kernel.org 2.6.23:

1) Can't build with NUMA=n and DISCONTIG=y.
   Build quickly dies with NODE_DATA being undefined.
   I tried to "work around" it with two changes:
   a) include <asm/nodedata.h> from asm/mmzone.h. Not the other way around!
   No one includes asm/nodedata.h (except processor.h).
   Everyone includes linux/mmzone.h (which includes asm/mmzone.h).
   That needs to include nodedata.h to provide NODE_DATA.
   The few arches I checked define NODE_DATA in their asm/mmzone.h.

   b) added defined(CONFIG_NEED_MULTIPLE_NODES) to a few places that
   check CONFIG_NUMA so NODE_DATA would get properly defined.
   e.g. asm/processor.h for
#if defined(CONFIG_NUMA) || defined(CONFIG_NEED_MULTIPLE_NODES)
        struct ia64_node_data *node_data;
#endif


   I decided this wasn't meant to be when node_cpuid was not defined.
   Forcing CONFIG_NUMA when DISCONTIG was enabled got me alot further:

--- linux-2.6.23/arch/ia64/Kconfig-ORIG	2007-10-09 13:31:38.000000000 -0700
+++ linux-2.6.23/arch/ia64/Kconfig	2007-10-09 22:51:19.000000000 -0700
@@ -101,6 +101,7 @@
 config IA64_GENERIC
 	bool "generic"
 	select NUMA
+	select NEED_MULTIPLE_NODES
 	select ACPI_NUMA
 	select SWIOTLB
 	help
@@ -358,6 +359,7 @@
 	depends on !IA64_HP_SIM && !FLATMEM
 	default y if IA64_SGI_SN2
 	select ACPI_NUMA if ACPI
+	select NEED_MULTIPLE_NODES
 	help
 	  Say Y to compile the kernel to support NUMA (Non-Uniform Memory
 	  Access).  This option is for configuring high-end multiprocessor


2) But I'm getting this error:
  CC [M]  drivers/char/ipmi/ipmi_si_intf.o
drivers/char/ipmi/ipmi_si_intf.c:1095: error: __param_hotmod causes a section type conflict
make[3]: *** [drivers/char/ipmi/ipmi_si_intf.o] Error 1

I've no idea what's going on here. config file is attached.

Lastly, I've failed to boot with a 2.6.22-2-mckinley on my zx2000.
But I suspect it's failing because I don't have "noasync" and will
retry with that. (This zx2000 has u320 SCSI card for it's internal disks.)

thanks,
grant
