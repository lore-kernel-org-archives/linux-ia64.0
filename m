From: Brent Casavant <bcasavan@sgi.com>
Date: Thu, 27 Apr 2006 20:10:59 +0000
Subject: [PATCH resend] IOC4 config option ordering
Message-Id: <20060427150402.M46549@chenjesu.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

SERIAL_SGI_IOC4 and BLK_DEV_SGIIOC4 depend upon SGI_IOC4, and
SERIAL_SGI_IOC3 depends upon SGI_IOC3.  Currently the definitions
are out of order in the config sequence.

Fix by including drivers/sn/Kconfig immediately after SGI_SN,
upon which SGI_IOC4 and SGI_IOC3 depend.

Signed-off-by: Brent Casavant <bcasavan@sgi.com>
---
Tony,

I saw no objection to this patch.  Could you pick up this patch and push
upstream at your convenience.  If you'd prefer, I could instead send it
directly to lkml.

Thanks,
Brent

 arch/ia64/Kconfig |    2 ++
 drivers/Kconfig   |    2 --
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 9f40eef..0f3076a 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -413,6 +413,8 @@ config IA64_PALINFO
 config SGI_SN
 	def_bool y if (IA64_SGI_SN2 || IA64_GENERIC)
 
+source "drivers/sn/Kconfig"
+
 source "drivers/firmware/Kconfig"
 
 source "fs/Kconfig.binfmt"
diff --git a/drivers/Kconfig b/drivers/Kconfig
index 5c91d6a..aeb5ab2 100644
--- a/drivers/Kconfig
+++ b/drivers/Kconfig
@@ -68,8 +68,6 @@ source "drivers/leds/Kconfig"
 
 source "drivers/infiniband/Kconfig"
 
-source "drivers/sn/Kconfig"
-
 source "drivers/edac/Kconfig"
 
 source "drivers/rtc/Kconfig"
