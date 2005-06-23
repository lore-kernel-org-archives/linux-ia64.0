From: Rusty Lynch <rusty.lynch@intel.com>
Date: Thu, 23 Jun 2005 01:18:23 +0000
Subject: [ia64][patch] Fix 2.6.12-mm1 default tiger config
Message-Id: <200506230118.j5N1INsc016585@linux.jf.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

With the addition of the CONFIG_FUSION_FC and CONFIG_FUSION_SPI
config entries, the ia64 default tiger configuration is broken
(because system fails to mount root device.)  This patch fixes
the default for tiger systems.

    --rusty

signed-off-by: Rusty Lynch <rusty.lynch@intel.com>

 arch/ia64/configs/tiger_defconfig |    2 ++
 1 files changed, 2 insertions(+)

Index: linux-2.6.12-mm1/arch/ia64/configs/tiger_defconfig
=================================--- linux-2.6.12-mm1.orig/arch/ia64/configs/tiger_defconfig
+++ linux-2.6.12-mm1/arch/ia64/configs/tiger_defconfig
@@ -366,6 +366,8 @@ CONFIG_DM_ZERO=m
 # Fusion MPT device support
 #
 CONFIG_FUSION=y
+CONFIG_FUSION_SPI=y
+# CONFIG_FUSION_FC is not set
 CONFIG_FUSION_MAX_SGE@
 # CONFIG_FUSION_CTL is not set
 
