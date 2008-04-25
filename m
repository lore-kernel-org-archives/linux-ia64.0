From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Fri, 25 Apr 2008 14:13:09 +0000
Subject: [PATCH] ia64 bugfix: nptcg breaks cpu-hotadd
Message-Id: <4811E6F5.9000600@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

If "max_purges" from PAL is 0, it actually means 1.

However it was not handled later when a hot-added cpu pass the
max_purges from PAL.  This makes systems easy to go BUG_ON().

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
---
 arch/ia64/mm/tlb.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/mm/tlb.c b/arch/ia64/mm/tlb.c
index d52ec4e..8caf424 100644
--- a/arch/ia64/mm/tlb.c
+++ b/arch/ia64/mm/tlb.c
@@ -168,7 +168,10 @@ setup_ptcg_sem(int max_purges, int nptcg_from)
 	static int firstcpu = 1;

 	if (toolatetochangeptcgsem) {
-		BUG_ON(max_purges < nptcg);
+		if (nptcg_from = NPTCG_FROM_PAL && max_purges = 0)
+			BUG_ON(1 < nptcg);
+		else
+			BUG_ON(max_purges < nptcg);
 		return;
 	}


