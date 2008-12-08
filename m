From: Robin Holt <holt@sgi.com>
Date: Mon, 08 Dec 2008 14:43:46 +0000
Subject: [Patch 2/4] Clear up section mismatch for sn_check_wars.
Message-Id: <20081208144346.429106143@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


The generic_defconfig has three section mismatches.  This clears up
sn_check_wars().


Signed-off-by: Robin Holt <holt@sgi.com>
Signed-off-by: Jack Steiner <steiner@sgi.com>

---

 arch/ia64/sn/kernel/setup.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)
Index: v2.6.28-rc7-20081208-218d11a/arch/ia64/sn/kernel/setup.c
=================================--- v2.6.28-rc7-20081208-218d11a.orig/arch/ia64/sn/kernel/setup.c	2008-12-08 08:23:35.067501669 -0600
+++ v2.6.28-rc7-20081208-218d11a/arch/ia64/sn/kernel/setup.c	2008-12-08 08:23:56.046117537 -0600
@@ -200,7 +200,7 @@ static int __cpuinitdata shub_1_1_found;
  * Set flag for enabling shub specific wars
  */
 
-static inline int __init is_shub_1_1(int nasid)
+static inline int __cpuinit is_shub_1_1(int nasid)
 {
 	unsigned long id;
 	int rev;
@@ -212,7 +212,7 @@ static inline int __init is_shub_1_1(int
 	return rev <= 2;
 }
 
-static void __init sn_check_for_wars(void)
+static void __cpuinit sn_check_for_wars(void)
 {
 	int cnode;
 

