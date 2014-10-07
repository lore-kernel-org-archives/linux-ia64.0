From: Guenter Roeck <linux@roeck-us.net>
Date: Tue, 07 Oct 2014 05:28:42 +0000
Subject: [PATCH 40/44] x86: intel-mid: Drop registration of dummy poweroff handlers
Message-Id: <1412659726-29957-41-git-send-email-linux@roeck-us.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1412659726-29957-1-git-send-email-linux@roeck-us.net>
In-Reply-To: <1412659726-29957-1-git-send-email-linux@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: adi-buildroot-devel@lists.sourceforge.net, devel@driverdev.osuosl.org, devicetree@vger.kernel.org, lguest@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-alpha@vger.kernel.org, linux-am33-list@redhat.com, linux-cris-kernel@axis.com, linux-efi@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-m32r-ja@ml.linux-m32r.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-tegra@vger.kernel.org, linux-xtensa@linux-xtensa.org, openipmi-developer@lists.sourceforge.net, user-mode-linux-devel@lists.sourceforge.net, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linux-pm@vger.kernel.org, linux-sh@vger.kernel.org, xen-devel@lists.xenproject.org, Guenter Roeck <linux@roeck-us.net>, Thomas

A dummy poweroff handler does not serve any purpose. Drop it.

Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 arch/x86/platform/intel-mid/intel-mid.c | 5 -----
 arch/x86/platform/intel-mid/mfld.c      | 5 -----
 2 files changed, 10 deletions(-)

diff --git a/arch/x86/platform/intel-mid/intel-mid.c b/arch/x86/platform/intel-mid/intel-mid.c
index 1bbedc4..4b70666 100644
--- a/arch/x86/platform/intel-mid/intel-mid.c
+++ b/arch/x86/platform/intel-mid/intel-mid.c
@@ -67,10 +67,6 @@ static void *(*get_intel_mid_ops[])(void) = INTEL_MID_OPS_INIT;
 enum intel_mid_cpu_type __intel_mid_cpu_chip;
 EXPORT_SYMBOL_GPL(__intel_mid_cpu_chip);
 
-static void intel_mid_power_off(void)
-{
-};
-
 static void intel_mid_reboot(void)
 {
 	intel_scu_ipc_simple_command(IPCMSG_COLD_BOOT, 0);
@@ -183,7 +179,6 @@ void __init x86_intel_mid_early_setup(void)
 
 	legacy_pic = &null_legacy_pic;
 
-	pm_power_off = intel_mid_power_off;
 	machine_ops.emergency_restart  = intel_mid_reboot;
 
 	/* Avoid searching for BIOS MP tables */
diff --git a/arch/x86/platform/intel-mid/mfld.c b/arch/x86/platform/intel-mid/mfld.c
index 23381d2..cf6842f 100644
--- a/arch/x86/platform/intel-mid/mfld.c
+++ b/arch/x86/platform/intel-mid/mfld.c
@@ -23,10 +23,6 @@ static struct intel_mid_ops penwell_ops = {
 	.arch_setup = penwell_arch_setup,
 };
 
-static void mfld_power_off(void)
-{
-}
-
 static unsigned long __init mfld_calibrate_tsc(void)
 {
 	unsigned long fast_calibrate;
@@ -61,7 +57,6 @@ static unsigned long __init mfld_calibrate_tsc(void)
 static void __init penwell_arch_setup(void)
 {
 	x86_platform.calibrate_tsc = mfld_calibrate_tsc;
-	pm_power_off = mfld_power_off;
 }
 
 void *get_penwell_ops(void)
-- 
1.9.1

