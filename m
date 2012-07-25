From: Fengguang Wu <fengguang.wu@intel.com>
Date: Wed, 25 Jul 2012 07:46:21 +0000
Subject: [PATCH] fix nouveau build error on !CONFIG_MXM_WMI
Message-Id: <20120725074621.GA17467@localhost>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Airlie <airlied@redhat.com>
Cc: dri-devel@lists.freedesktop.org, LKML <linux-kernel@vger.kernel.org>, Ben Skeggs <bskeggs@redhat.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

Fix build error on IA64:

ERROR: "mxm_wmi_supported" [drivers/gpu/drm/nouveau/nouveau.ko] undefined!

Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 include/linux/mxm-wmi.h |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/include/linux/mxm-wmi.h b/include/linux/mxm-wmi.h
index 617a295..f6a6214 100644
--- a/include/linux/mxm-wmi.h
+++ b/include/linux/mxm-wmi.h
@@ -28,6 +28,14 @@
 #define MXM_MXDS_ADAPTER_IGD 0x10
 int mxm_wmi_call_mxds(int adapter);
 int mxm_wmi_call_mxmx(int adapter);
+
+#if IS_ENABLED(CONFIG_MXM_WMI)
 bool mxm_wmi_supported(void);
+#else
+static inline bool mxm_wmi_supported(void)
+{
+	return false;
+}
+#endif
 
 #endif
-- 
1.7.10

