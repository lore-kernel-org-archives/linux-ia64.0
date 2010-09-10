From: Phil Carmody <ext-phil.2.carmody@nokia.com>
Date: Fri, 10 Sep 2010 10:40:44 +0000
Subject: [PATCH 1/2] ia64: unwind: remove preprocesser noise, and correct comment
Message-Id: <1284115245-23876-2-git-send-email-ext-phil.2.carmody@nokia.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1284115245-23876-1-git-send-email-ext-phil.2.carmody@nokia.com>
In-Reply-To: <1284115245-23876-1-git-send-email-ext-phil.2.carmody@nokia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: fenghua.yu@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

The expression in the comment was mis-bracketted.
There was also no need to introduce a coding-style breaking
macro for a single use, so just made it a static const.

Signed-off-by: Phil Carmody <ext-phil.2.carmody@nokia.com>
---
 arch/ia64/kernel/unwind.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/kernel/unwind.c b/arch/ia64/kernel/unwind.c
index b6c0e63..f47217b 100644
--- a/arch/ia64/kernel/unwind.c
+++ b/arch/ia64/kernel/unwind.c
@@ -1204,10 +1204,10 @@ desc_spill_sprel_p (unsigned char qp, unw_word t, unsigned char abreg, unw_word
 static inline unw_hash_index_t
 hash (unsigned long ip)
 {
-#	define hashmagic	0x9e3779b97f4a7c16UL	/* based on (sqrt(5)/2-1)*2^64 */
+	/* magic number = ((sqrt(5)-1)/2)*2^64 */
+	static const unsigned long hashmagic = 0x9e3779b97f4a7c16UL;
 
-	return (ip >> 4)*hashmagic >> (64 - UNW_LOG_HASH_SIZE);
-#undef hashmagic
+	return (ip >> 4) * hashmagic >> (64 - UNW_LOG_HASH_SIZE);
 }
 
 static inline long
-- 
1.7.2.rc1.37.gf8c40

