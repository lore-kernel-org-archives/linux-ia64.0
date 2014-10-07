From: Guenter Roeck <linux@roeck-us.net>
Date: Tue, 07 Oct 2014 05:28:39 +0000
Subject: [PATCH 37/44] sh: Register with kernel poweroff handler
Message-Id: <1412659726-29957-38-git-send-email-linux@roeck-us.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1412659726-29957-1-git-send-email-linux@roeck-us.net>
In-Reply-To: <1412659726-29957-1-git-send-email-linux@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: adi-buildroot-devel@lists.sourceforge.net, devel@driverdev.osuosl.org, devicetree@vger.kernel.org, lguest@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-alpha@vger.kernel.org, linux-am33-list@redhat.com, linux-cris-kernel@axis.com, linux-efi@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-m32r-ja@ml.linux-m32r.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-tegra@vger.kernel.org, linux-xtensa@linux-xtensa.org, openipmi-developer@lists.sourceforge.net, user-mode-linux-devel@lists.sourceforge.net, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linux-pm@vger.kernel.org, linux-sh@vger.kernel.org, xen-devel@lists.xenproject.org, Guenter Roeck <linux@roeck-us.net>

Register with kernel poweroff handler instead of setting pm_power_off
directly.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 arch/sh/boards/board-sh7785lcr.c       | 2 +-
 arch/sh/boards/board-urquell.c         | 2 +-
 arch/sh/boards/mach-highlander/setup.c | 2 +-
 arch/sh/boards/mach-landisk/setup.c    | 2 +-
 arch/sh/boards/mach-r2d/setup.c        | 2 +-
 arch/sh/boards/mach-sdk7786/setup.c    | 2 +-
 6 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/arch/sh/boards/board-sh7785lcr.c b/arch/sh/boards/board-sh7785lcr.c
index 2c4771e..c092402 100644
--- a/arch/sh/boards/board-sh7785lcr.c
+++ b/arch/sh/boards/board-sh7785lcr.c
@@ -332,7 +332,7 @@ static void __init sh7785lcr_setup(char **cmdline_p)
 
 	printk(KERN_INFO "Renesas Technology Corp. R0P7785LC0011RL support.\n");
 
-	pm_power_off = sh7785lcr_power_off;
+	register_poweroff_handler_simple(sh7785lcr_power_off, 128);
 
 	/* sm501 DRAM configuration */
 	sm501_reg = ioremap_nocache(SM107_REG_ADDR, SM501_DRAM_CONTROL);
diff --git a/arch/sh/boards/board-urquell.c b/arch/sh/boards/board-urquell.c
index b52abcc..b3fa56f 100644
--- a/arch/sh/boards/board-urquell.c
+++ b/arch/sh/boards/board-urquell.c
@@ -204,7 +204,7 @@ static void __init urquell_setup(char **cmdline_p)
 {
 	printk(KERN_INFO "Renesas Technology Corp. Urquell support.\n");
 
-	pm_power_off = urquell_power_off;
+	register_poweroff_handler_simple(urquell_power_off, 128);
 
 	register_smp_ops(&shx3_smp_ops);
 }
diff --git a/arch/sh/boards/mach-highlander/setup.c b/arch/sh/boards/mach-highlander/setup.c
index 4a52590..998f1a5 100644
--- a/arch/sh/boards/mach-highlander/setup.c
+++ b/arch/sh/boards/mach-highlander/setup.c
@@ -385,7 +385,7 @@ static void __init highlander_setup(char **cmdline_p)
 
 	__raw_writew(__raw_readw(PA_IVDRCTL) | 0x01, PA_IVDRCTL);	/* Si13112 */
 
-	pm_power_off = r7780rp_power_off;
+	register_poweroff_handler_simple(r7780rp_power_off, 128);
 }
 
 static unsigned char irl2irq[HL_NR_IRL];
diff --git a/arch/sh/boards/mach-landisk/setup.c b/arch/sh/boards/mach-landisk/setup.c
index f1147ca..c817d80 100644
--- a/arch/sh/boards/mach-landisk/setup.c
+++ b/arch/sh/boards/mach-landisk/setup.c
@@ -89,7 +89,7 @@ static void __init landisk_setup(char **cmdline_p)
 	__raw_writeb(__raw_readb(PA_LED) | 0x03, PA_LED);
 
 	printk(KERN_INFO "I-O DATA DEVICE, INC. \"LANDISK Series\" support.\n");
-	pm_power_off = landisk_power_off;
+	register_poweroff_handler_simple(landisk_power_off, 128);
 }
 
 /*
diff --git a/arch/sh/boards/mach-r2d/setup.c b/arch/sh/boards/mach-r2d/setup.c
index 4b98a52..a759d39 100644
--- a/arch/sh/boards/mach-r2d/setup.c
+++ b/arch/sh/boards/mach-r2d/setup.c
@@ -279,7 +279,7 @@ static void __init rts7751r2d_setup(char **cmdline_p)
 					(ver >> 4) & 0xf, ver & 0xf);
 
 	__raw_writew(0x0000, PA_OUTPORT);
-	pm_power_off = rts7751r2d_power_off;
+	register_poweroff_handler_simple(rts7751r2d_power_off, 128);
 
 	/* sm501 dram configuration:
 	 * ColSizeX = 11 - External Memory Column Size: 256 words.
diff --git a/arch/sh/boards/mach-sdk7786/setup.c b/arch/sh/boards/mach-sdk7786/setup.c
index c29268b..cb26336 100644
--- a/arch/sh/boards/mach-sdk7786/setup.c
+++ b/arch/sh/boards/mach-sdk7786/setup.c
@@ -252,7 +252,7 @@ static void __init sdk7786_setup(char **cmdline_p)
 	pr_info("\tPCB revision:\t%d\n", fpga_read_reg(PCBRR) & 0xf);
 
 	machine_ops.restart = sdk7786_restart;
-	pm_power_off = sdk7786_power_off;
+	register_poweroff_handler_simple(sdk7786_power_off, 128);
 
 	register_smp_ops(&shx3_smp_ops);
 }
-- 
1.9.1

