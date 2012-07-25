From: Fengguang Wu <fengguang.wu@intel.com>
Date: Wed, 25 Jul 2012 14:36:58 +0000
Subject: Re: [PATCH] nouveau: fix build error on IA64
Message-Id: <20120725143658.GA1651@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120725080008.GA18012@localhost>
In-Reply-To: <20120725080008.GA18012@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Airlie <airlied@redhat.com>
Cc: dri-devel@lists.freedesktop.org, LKML <linux-kernel@vger.kernel.org>, Ben Skeggs <bskeggs@redhat.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

> -	select ACPI_WMI if ACPI
> +	select ACPI_WMI if ACPI && !IA64
>  	select MXM_WMI if ACPI

Sorry, the MXM_WMI line should also be changed. Although MXM_WMI
depends on ACPI_WMI, "select" is dumb and will ignore that dependency..

Thanks,
Fengguang
---
From: Fengguang Wu <fengguang.wu@intel.com>
Date: Wed, 25 Jul 2012 15:56:35 +0800
Subject: [PATCH] nouveau: fix build error on IA64

I'm not sure if this is the best way, however it does fix these link
errors on IA64:

ERROR: "wmi_has_guid" [drivers/gpu/drm/nouveau/nouveau.ko] undefined!
ERROR: "wmi_evaluate_method" [drivers/gpu/drm/nouveau/nouveau.ko] undefined!

Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 drivers/gpu/drm/nouveau/Kconfig |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- linux.orig/drivers/gpu/drm/nouveau/Kconfig	2012-07-25 19:09:37.715358715 +0800
+++ linux/drivers/gpu/drm/nouveau/Kconfig	2012-07-25 22:34:43.775298923 +0800
@@ -11,8 +11,8 @@ config DRM_NOUVEAU
 	select FRAMEBUFFER_CONSOLE if !EXPERT
 	select FB_BACKLIGHT if DRM_NOUVEAU_BACKLIGHT
 	select ACPI_VIDEO if ACPI && X86 && BACKLIGHT_CLASS_DEVICE && VIDEO_OUTPUT_CONTROL && INPUT
-	select ACPI_WMI if ACPI
-	select MXM_WMI if ACPI
+	select ACPI_WMI if ACPI && !IA64
+	select MXM_WMI if ACPI && !IA64
 	select POWER_SUPPLY
 	help
 	  Choose this option for open-source nVidia support.
