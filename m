From: Thierry Reding <thierry.reding@gmail.com>
Date: Mon, 28 Jul 2014 15:01:49 +0000
Subject: [PATCH 2/2] [IA64] Do not needlessly convert between pointers and integers
Message-Id: <1406559709-9401-2-git-send-email-thierry.reding@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1406559709-9401-1-git-send-email-thierry.reding@gmail.com>
In-Reply-To: <1406559709-9401-1-git-send-email-thierry.reding@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

From: Thierry Reding <treding@nvidia.com>

The nasid_to_try variable is an array of integers, so plain integers can
be used when assigning values to the elements rather than casting a NULL
pointer to an integer, which results in the following warning from GCC:

	arch/ia64/sn/kernel/bte.c:117:22: warning: cast from pointer to integer of different size [-Wpointer-to-int-cast]
	    nasid_to_try[1] = (int)NULL;
	                      ^
	arch/ia64/sn/kernel/bte.c:125:22: warning: cast from pointer to integer of different size [-Wpointer-to-int-cast]
	    nasid_to_try[1] = (int)NULL;
	                      ^

Replace (int)NULL with a simple 0 to silence these warnings.

Signed-off-by: Thierry Reding <treding@nvidia.com>
---
 arch/ia64/sn/kernel/bte.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/sn/kernel/bte.c b/arch/ia64/sn/kernel/bte.c
index cad775a1a157..b2eb48490754 100644
--- a/arch/ia64/sn/kernel/bte.c
+++ b/arch/ia64/sn/kernel/bte.c
@@ -114,7 +114,7 @@ bte_result_t bte_copy(u64 src, u64 dest, u64 len, u64 mode, void *notification)
 		if (mode & BTE_USE_ANY) {
 			nasid_to_try[1] = my_nasid;
 		} else {
-			nasid_to_try[1] = (int)NULL;
+			nasid_to_try[1] = 0;
 		}
 	} else {
 		/* try local then remote */
@@ -122,7 +122,7 @@ bte_result_t bte_copy(u64 src, u64 dest, u64 len, u64 mode, void *notification)
 		if (mode & BTE_USE_ANY) {
 			nasid_to_try[1] = NASID_GET(dest);
 		} else {
-			nasid_to_try[1] = (int)NULL;
+			nasid_to_try[1] = 0;
 		}
 	}
 
-- 
2.0.2

