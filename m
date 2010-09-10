From: Phil Carmody <ext-phil.2.carmody@nokia.com>
Date: Fri, 10 Sep 2010 10:40:45 +0000
Subject: [PATCH 2/2] ia64: unwind - optimise linked-list searches for modules
Message-Id: <1284115245-23876-3-git-send-email-ext-phil.2.carmody@nokia.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1284115245-23876-1-git-send-email-ext-phil.2.carmody@nokia.com>
In-Reply-To: <1284115245-23876-1-git-send-email-ext-phil.2.carmody@nokia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: fenghua.yu@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

It's clear from the comment in the code about keeping the
kernel's unwind table at the front of the list that some
attention has been paid to access patterns. Tests on other
architectures have shown that a move-to-front optimisation
improves searches dramatically.

Signed-off-by: Phil Carmody <ext-phil.2.carmody@nokia.com>

---
This might not be a useful optimisation for the ia64
due to the caching that's already in place. If someone
can count the number of linked list operations with and
without this patch in a real-world scenario, I'd be
grateful.
---
 arch/ia64/kernel/unwind.c |   17 ++++++++++++++++-
 1 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/kernel/unwind.c b/arch/ia64/kernel/unwind.c
index f47217b..fed6afa 100644
--- a/arch/ia64/kernel/unwind.c
+++ b/arch/ia64/kernel/unwind.c
@@ -1531,7 +1531,7 @@ build_script (struct unw_frame_info *info)
 	struct unw_labeled_state *ls, *next;
 	unsigned long ip = info->ip;
 	struct unw_state_record sr;
-	struct unw_table *table;
+	struct unw_table *table, *prev;
 	struct unw_reg_info *r;
 	struct unw_insn insn;
 	u8 *dp, *desc_end;
@@ -1560,11 +1560,26 @@ build_script (struct unw_frame_info *info)
 
 	STAT(parse_start = ia64_get_itc());
 
+	prev = NULL;
 	for (table = unw.tables; table; table = table->next) {
 		if (ip >= table->start && ip < table->end) {
+			/*
+			 * Leave the kernel unwind table at the very front,
+			 * lest moving it breaks some assumption elsewhere.
+			 * Otherwise, move the matching table to the second
+			 * position in the list so that traversals can benefit
+			 * from commonality in backtrace paths.
+			 */
+			if (prev && prev != unw.tables) {
+				/* unw is safe - we're already spinlocked */
+				prev->next = table->next;
+				table->next = unw.tables->next;
+				unw.tables->next = table;
+			}
 			e = lookup(table, ip - table->segment_base);
 			break;
 		}
+		prev = table;
 	}
 	if (!e) {
 		/* no info, return default unwinder (leaf proc, no mem stack, no saved regs)  */
-- 
1.7.2.rc1.37.gf8c40

