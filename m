From: Bernhard Walle <bwalle@suse.de>
Date: Thu, 26 Jun 2008 12:53:11 +0000
Subject: [PATCH] Remove experimental status of kdump on IA64
Message-Id: <1214484791-25439-1-git-send-email-bwalle@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, vgoyal@redhat.com, kexec@lists.infradead.org, Bernhard Walle <bwalle@suse.de>

This patch removes the experimental status of kdump on IA64. kdump is on IA64
now since more than one year and it has proven to be stable.


Signed-off-by: Bernhard Walle <bwalle@suse.de>
---
 arch/ia64/Kconfig |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 16be414..f548e43 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -539,8 +539,8 @@ config KEXEC
 	  strongly in flux, so no good recommendation can be made.
 
 config CRASH_DUMP
-	  bool "kernel crash dumps (EXPERIMENTAL)"
-	  depends on EXPERIMENTAL && IA64_MCA_RECOVERY && !IA64_HP_SIM && (!SMP || HOTPLUG_CPU)
+	  bool "kernel crash dumps"
+	  depends on IA64_MCA_RECOVERY && !IA64_HP_SIM && (!SMP || HOTPLUG_CPU)
 	  help
 	    Generate crash dump after being started by kexec.
 
-- 
1.5.6

