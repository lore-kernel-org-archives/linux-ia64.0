From: Fengguang Wu <fengguang.wu@intel.com>
Date: Wed, 25 Jul 2012 08:00:08 +0000
Subject: [PATCH] nouveau: fix build error on IA64
Message-Id: <20120725080008.GA18012@localhost>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Airlie <airlied@redhat.com>
Cc: dri-devel@lists.freedesktop.org, LKML <linux-kernel@vger.kernel.org>, Ben Skeggs <bskeggs@redhat.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

I'm not sure if this is the best way, however it does fix the last 2
allmodconfig errors on IA64:

ERROR: "wmi_has_guid" [drivers/gpu/drm/nouveau/nouveau.ko] undefined!
ERROR: "wmi_evaluate_method" [drivers/gpu/drm/nouveau/nouveau.ko] undefined!

Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 drivers/gpu/drm/nouveau/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/gpu/drm/nouveau/Kconfig b/drivers/gpu/drm/nouveau/Kconfig
index 97a8126..046bb56 100644
--- a/drivers/gpu/drm/nouveau/Kconfig
+++ b/drivers/gpu/drm/nouveau/Kconfig
@@ -11,7 +11,7 @@ config DRM_NOUVEAU
 	select FRAMEBUFFER_CONSOLE if !EXPERT
 	select FB_BACKLIGHT if DRM_NOUVEAU_BACKLIGHT
 	select ACPI_VIDEO if ACPI && X86 && BACKLIGHT_CLASS_DEVICE && VIDEO_OUTPUT_CONTROL && INPUT
-	select ACPI_WMI if ACPI
+	select ACPI_WMI if ACPI && !IA64
 	select MXM_WMI if ACPI
 	select POWER_SUPPLY
 	help
-- 
1.7.10

