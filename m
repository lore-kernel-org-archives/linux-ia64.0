From: Corentin Labbe <clabbe@baylibre.com>
Date: Thu, 21 Nov 2019 08:14:41 +0000
Subject: [PATCH v2 1/5] agp: remove unused variable size in agp_generic_create_gatt_table
Message-Id: <1574324085-4338-2-git-send-email-clabbe@baylibre.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1574324085-4338-1-git-send-email-clabbe@baylibre.com>
In-Reply-To: <1574324085-4338-1-git-send-email-clabbe@baylibre.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: airlied@redhat.com, airlied@linux.ie, arnd@arndb.de, fenghua.yu@intel.com, gregkh@linuxfoundation.org, tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Corentin Labbe <clabbe@baylibre.com>

This patch fix the following warning:
drivers/char/agp/generic.c:853:6: attention : variable ‘size’ set but not used [-Wunused-but-set-variable]
by removing the unused variable size in agp_generic_create_gatt_table

Signed-off-by: Corentin Labbe <clabbe@baylibre.com>
---
 drivers/char/agp/generic.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/char/agp/generic.c b/drivers/char/agp/generic.c
index df1edb5ec0ad..4d2eb0800b2a 100644
--- a/drivers/char/agp/generic.c
+++ b/drivers/char/agp/generic.c
@@ -850,7 +850,6 @@ int agp_generic_create_gatt_table(struct agp_bridge_data *bridge)
 {
 	char *table;
 	char *table_end;
-	int size;
 	int page_order;
 	int num_entries;
 	int i;
@@ -864,25 +863,22 @@ int agp_generic_create_gatt_table(struct agp_bridge_data *bridge)
 	table = NULL;
 	i = bridge->aperture_size_idx;
 	temp = bridge->current_size;
-	size = page_order = num_entries = 0;
+	page_order = num_entries = 0;
 
 	if (bridge->driver->size_type != FIXED_APER_SIZE) {
 		do {
 			switch (bridge->driver->size_type) {
 			case U8_APER_SIZE:
-				size = A_SIZE_8(temp)->size;
 				page_order  				    A_SIZE_8(temp)->page_order;
 				num_entries  				    A_SIZE_8(temp)->num_entries;
 				break;
 			case U16_APER_SIZE:
-				size = A_SIZE_16(temp)->size;
 				page_order = A_SIZE_16(temp)->page_order;
 				num_entries = A_SIZE_16(temp)->num_entries;
 				break;
 			case U32_APER_SIZE:
-				size = A_SIZE_32(temp)->size;
 				page_order = A_SIZE_32(temp)->page_order;
 				num_entries = A_SIZE_32(temp)->num_entries;
 				break;
@@ -890,7 +886,7 @@ int agp_generic_create_gatt_table(struct agp_bridge_data *bridge)
 			case FIXED_APER_SIZE:
 			case LVL2_APER_SIZE:
 			default:
-				size = page_order = num_entries = 0;
+				page_order = num_entries = 0;
 				break;
 			}
 
@@ -920,7 +916,6 @@ int agp_generic_create_gatt_table(struct agp_bridge_data *bridge)
 			}
 		} while (!table && (i < bridge->driver->num_aperture_sizes));
 	} else {
-		size = ((struct aper_size_info_fixed *) temp)->size;
 		page_order = ((struct aper_size_info_fixed *) temp)->page_order;
 		num_entries = ((struct aper_size_info_fixed *) temp)->num_entries;
 		table = alloc_gatt_pages(page_order);
-- 
2.23.0
