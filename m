From: Allen Pais <allen.lkml@gmail.com>
Date: Fri, 22 Sep 2017 11:38:00 +0000
Subject: [PATCH 1/3] ia64: bte: use setup_timer() helper.
Message-Id: <1506079562-5068-2-git-send-email-allen.lkml@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   Use setup_timer function instead of initializing timer with the
   function and data fields.

Signed-off-by: Allen Pais <allen.lkml@gmail.com>
---
 arch/ia64/sn/kernel/bte.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/sn/kernel/bte.c b/arch/ia64/sn/kernel/bte.c
index b2eb484..fff6c4b 100644
--- a/arch/ia64/sn/kernel/bte.c
+++ b/arch/ia64/sn/kernel/bte.c
@@ -436,9 +436,8 @@ void bte_init_node(nodepda_t * mynodepda, cnodeid_t cnode)
 	 * will point at this one bte_recover structure to get the lock.
 	 */
 	spin_lock_init(&mynodepda->bte_recovery_lock);
-	init_timer(&mynodepda->bte_recovery_timer);
-	mynodepda->bte_recovery_timer.function = bte_error_handler;
-	mynodepda->bte_recovery_timer.data = (unsigned long)mynodepda;
+	setup_timer(&mynodepda->bte_recovery_timer, bte_error_handler,
+		    (unsigned long)mynodepda);
 
 	for (i = 0; i < BTES_PER_NODE; i++) {
 		u64 *base_addr;
-- 
2.7.4

