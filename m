From: Corentin Labbe <clabbe@baylibre.com>
Date: Thu, 21 Nov 2019 08:14:43 +0000
Subject: [PATCH v2 3/5] agp: remove unused variable num_segments
Message-Id: <1574324085-4338-4-git-send-email-clabbe@baylibre.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1574324085-4338-1-git-send-email-clabbe@baylibre.com>
In-Reply-To: <1574324085-4338-1-git-send-email-clabbe@baylibre.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: airlied@redhat.com, airlied@linux.ie, arnd@arndb.de, fenghua.yu@intel.com, gregkh@linuxfoundation.org, tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Corentin Labbe <clabbe@baylibre.com>

This patch fix the following build warning:
warning: variable 'num_segments' set but not used [-Wunused-but-set-variable]

Signed-off-by: Corentin Labbe <clabbe@baylibre.com>
---
 drivers/char/agp/frontend.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/char/agp/frontend.c b/drivers/char/agp/frontend.c
index f6955888e676..47098648502d 100644
--- a/drivers/char/agp/frontend.c
+++ b/drivers/char/agp/frontend.c
@@ -102,14 +102,13 @@ agp_segment_priv *agp_find_seg_in_client(const struct agp_client *client,
 					    int size, pgprot_t page_prot)
 {
 	struct agp_segment_priv *seg;
-	int num_segments, i;
+	int i;
 	off_t pg_start;
 	size_t pg_count;
 
 	pg_start = offset / 4096;
 	pg_count = size / 4096;
 	seg = *(client->segments);
-	num_segments = client->num_segments;
 
 	for (i = 0; i < client->num_segments; i++) {
 		if ((seg[i].pg_start = pg_start) &&
-- 
2.23.0
