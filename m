From: Oliver O'Halloran <oohall@gmail.com>
Date: Tue, 03 Apr 2018 05:34:01 +0000
Subject: [PATCH] drm/sti: Depend on OF rather than selecting it
Message-Id: <20180403053401.30045-1-oohall@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Oliver O'Halloran <oohall@gmail.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, Vincent Abriou <vincent.abriou@st.com>, David Airlie <airlied@linux.ie>, dri-devel@lists.freedesktop.org, linux-ia64@vger.kernel.org, stable@vger.kernel.org

Commit cc6b741c6f63 ("drm: sti: remove useless fields from vtg
structure") reworked some code inside of this driver and made it select
CONFIG_OF. This results in the entire OF layer being enabled when
building an allmodconfig on ia64. OF on ia64 is completely unsupported
so this isn't a great state of affairs.

The 0day robot noticed a link-time failure on ia64 caused by
using of_node_to_nid() in an otherwise unrelated driver. The
generic fallback for of_node_to_nid() only exists when:

	defined(CONFIG_OF) && defined(CONFIG_NUMA) = false

Since CONFIG_NUMA is usually selected for IA64 we get the link failure.
Fix this by making the driver depend on OF rather than selecting it,
odds are that was the original intent.

Link: https://lists.01.org/pipermail/kbuild-all/2018-March/045172.html
Fixes: cc6b741c6f63 ("drm: sti: remove useless fields from vtg structure")
Cc: Benjamin Gaignard <benjamin.gaignard@linaro.org>
Cc: Vincent Abriou <vincent.abriou@st.com>
Cc: David Airlie <airlied@linux.ie>
Cc: dri-devel@lists.freedesktop.org
Cc: linux-ia64@vger.kernel.org
Cc: stable@vger.kernel.org
Signed-off-by: Oliver O'Halloran <oohall@gmail.com>
---
Cc`ed to stable since the ia64 guys might want it backported. I'm not
bothered if it just goes into mainline.
---
 drivers/gpu/drm/sti/Kconfig | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/gpu/drm/sti/Kconfig b/drivers/gpu/drm/sti/Kconfig
index cca4b3c9aeb5..1963cc1b1cc5 100644
--- a/drivers/gpu/drm/sti/Kconfig
+++ b/drivers/gpu/drm/sti/Kconfig
@@ -1,6 +1,6 @@
 config DRM_STI
 	tristate "DRM Support for STMicroelectronics SoC stiH4xx Series"
-	depends on DRM && (ARCH_STI || ARCH_MULTIPLATFORM)
+	depends on OF && DRM && (ARCH_STI || ARCH_MULTIPLATFORM)
 	select RESET_CONTROLLER
 	select DRM_KMS_HELPER
 	select DRM_GEM_CMA_HELPER
@@ -8,6 +8,5 @@ config DRM_STI
 	select DRM_PANEL
 	select FW_LOADER
 	select SND_SOC_HDMI_CODEC if SND_SOC
-	select OF
 	help
 	  Choose this option to enable DRM on STM stiH4xx chipset
-- 
2.9.5

