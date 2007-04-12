From: Milind Arun Choudhary <milindchoudhary@gmail.com>
Date: Thu, 12 Apr 2007 20:43:13 +0000
Subject: [KJ][PATCH 01/03]ROUND_UP|DOWN macro cleanup in arch/ia64,x86_64
Message-Id: <20070412203113.GA9353@arun.site>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kernel-janitors@lists.osdl.org, linux-ia64@vger.kernel.org, discuss@x86-64.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, tony.luck@intel.com, ak@suse.de

Add ALIGN_DOWN and round_down macros to kernel.h

Signed-off-by: Milind Arun Choudhary <milindchoudhary@gmail.com>

---
 kernel.h |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index 9ddf25c..f8648b2 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -34,11 +34,13 @@ extern const char linux_proc_banner[];
 
 #define ALIGN(x,a)		__ALIGN_MASK(x,(typeof(x))(a)-1)
 #define __ALIGN_MASK(x,mask)	(((x)+(mask))&~(mask))
+#define ALIGN_DOWN(x,a)         ((x)&~((typeof(x))(a)-1))
+#define DIV_ROUND_UP(n,d) (((n) + (d) - 1) / (d))
+#define roundup(x, y) ((((x) + ((y) - 1)) / (y)) * (y))
+#define round_down(x, y) (((x) / (y)) * (y))
 
 #define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
 #define FIELD_SIZEOF(t, f) (sizeof(((t*)0)->f))
-#define DIV_ROUND_UP(n,d) (((n) + (d) - 1) / (d))
-#define roundup(x, y) ((((x) + ((y) - 1)) / (y)) * (y))
 
 #define	KERN_EMERG	"<0>"	/* system is unusable			*/
 #define	KERN_ALERT	"<1>"	/* action must be taken immediately	*/

-- 
Milind Arun Choudhary
