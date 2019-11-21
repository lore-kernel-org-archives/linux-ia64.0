From: Corentin Labbe <clabbe@baylibre.com>
Date: Thu, 21 Nov 2019 08:14:42 +0000
Subject: [PATCH v2 2/5] agp: move AGPGART_MINOR to include/linux/miscdevice.h
Message-Id: <1574324085-4338-3-git-send-email-clabbe@baylibre.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1574324085-4338-1-git-send-email-clabbe@baylibre.com>
In-Reply-To: <1574324085-4338-1-git-send-email-clabbe@baylibre.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: airlied@redhat.com, airlied@linux.ie, arnd@arndb.de, fenghua.yu@intel.com, gregkh@linuxfoundation.org, tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Corentin Labbe <clabbe@baylibre.com>

This patch move the define for AGPGART_MINOR to include/linux/miscdevice.h.
It is better that all minor number definitions are in the same place.

Signed-off-by: Corentin Labbe <clabbe@baylibre.com>
---
 include/linux/agpgart.h    | 2 --
 include/linux/miscdevice.h | 1 +
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/include/linux/agpgart.h b/include/linux/agpgart.h
index c6b61ca97053..21b34a96cfd8 100644
--- a/include/linux/agpgart.h
+++ b/include/linux/agpgart.h
@@ -30,8 +30,6 @@
 #include <linux/agp_backend.h>
 #include <uapi/linux/agpgart.h>
 
-#define AGPGART_MINOR 175
-
 struct agp_info {
 	struct agp_version version;	/* version of the driver        */
 	u32 bridge_id;		/* bridge vendor/device         */
diff --git a/include/linux/miscdevice.h b/include/linux/miscdevice.h
index b06b75776a32..becde6981a95 100644
--- a/include/linux/miscdevice.h
+++ b/include/linux/miscdevice.h
@@ -33,6 +33,7 @@
 #define SGI_MMTIMER		153
 #define STORE_QUEUE_MINOR	155	/* unused */
 #define I2O_MINOR		166
+#define AGPGART_MINOR		175
 #define HWRNG_MINOR		183
 #define MICROCODE_MINOR		184
 #define IRNET_MINOR		187
-- 
2.23.0
