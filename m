From: Alex Williamson <alex.williamson@hp.com>
Date: Tue, 06 Nov 2007 17:31:07 +0000
Subject: [PATCH] Move dmi_scan_machine() call ealier
Message-Id: <1194370267.31834.176.camel@bling>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


   I'd like to move our call to dmi_scan_machine up earlier in the boot
process so that we can take advantage of a DMI hook, called out of
acpi_early_init, to enable _OSI(Linux) on Xen HVM domains.  Since the
SMBIOS parsing makes use of ioremap, which Bjorn pointed out is fragile
early in boot, I'm reluctant to move this too much earlier.  Given those
restrictions, it seems best to simply move this up into our check_bugs
function.  Since the DMI hooks are mainly used for adjusting code path
based on platform, it doesn't seem like such an unreasonable place to
set it up.  Please let me know if you have comments.  Thanks,

	Alex

Signed-off-by: Alex Williamson <alex.williamson@hp.com>
--

diff -r c7f1be4e5832 arch/ia64/kernel/setup.c
--- a/arch/ia64/kernel/setup.c	Thu Nov 01 12:09:33 2007 -0700
+++ b/arch/ia64/kernel/setup.c	Tue Nov 06 09:17:32 2007 -0700
@@ -982,11 +982,5 @@ check_bugs (void)
 {
 	ia64_patch_mckinley_e9((unsigned long) __start___mckinley_e9_bundles,
 			       (unsigned long) __end___mckinley_e9_bundles);
-}
-
-static int __init run_dmi_scan(void)
-{
 	dmi_scan_machine();
-	return 0;
-}
-core_initcall(run_dmi_scan);
+}


