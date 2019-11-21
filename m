From: Corentin Labbe <clabbe@baylibre.com>
Date: Thu, 21 Nov 2019 08:14:44 +0000
Subject: [PATCH v2 4/5] agp: Add bridge parameter documentation
Message-Id: <1574324085-4338-5-git-send-email-clabbe@baylibre.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1574324085-4338-1-git-send-email-clabbe@baylibre.com>
In-Reply-To: <1574324085-4338-1-git-send-email-clabbe@baylibre.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: airlied@redhat.com, airlied@linux.ie, arnd@arndb.de, fenghua.yu@intel.com, gregkh@linuxfoundation.org, tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Corentin Labbe <clabbe@baylibre.com>

This patch add documentation about the bridge parameter in several
function.

This will fix the following build warning:
drivers/char/agp/generic.c:220: warning: No description found for parameter 'bridge'
drivers/char/agp/generic.c:364: warning: No description found for parameter 'bridge'
drivers/char/agp/generic.c:1283: warning: No description found for parameter 'bridge'

Signed-off-by: Corentin Labbe <clabbe@baylibre.com>
---
 drivers/char/agp/generic.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/char/agp/generic.c b/drivers/char/agp/generic.c
index 4d2eb0800b2a..ab154a75acf0 100644
--- a/drivers/char/agp/generic.c
+++ b/drivers/char/agp/generic.c
@@ -207,6 +207,7 @@ EXPORT_SYMBOL(agp_free_memory);
 /**
  *	agp_allocate_memory  -  allocate a group of pages of a certain type.
  *
+ *	@bridge: an agp_bridge_data struct allocated for the AGP host bridge.
  *	@page_count:	size_t argument of the number of pages
  *	@type:	u32 argument of the type of memory to be allocated.
  *
@@ -355,6 +356,7 @@ EXPORT_SYMBOL_GPL(agp_num_entries);
 /**
  *	agp_copy_info  -  copy bridge state information
  *
+ *	@bridge: an agp_bridge_data struct allocated for the AGP host bridge.
  *	@info:		agp_kern_info pointer.  The caller should insure that this pointer is valid.
  *
  *	This function copies information about the agp bridge device and the state of
@@ -1277,6 +1279,7 @@ EXPORT_SYMBOL(agp_generic_destroy_page);
 /**
  * agp_enable  -  initialise the agp point-to-point connection.
  *
+ * @bridge: an agp_bridge_data struct allocated for the AGP host bridge.
  * @mode:	agp mode register value to configure with.
  */
 void agp_enable(struct agp_bridge_data *bridge, u32 mode)
-- 
2.23.0
