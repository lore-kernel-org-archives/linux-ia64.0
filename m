From: Milind Arun Choudhary <milindchoudhary@gmail.com>
Date: Sun, 15 Apr 2007 17:33:23 +0000
Subject: [KJ][PATCH]SPIN_LOCK_UNLOCKED macro cleanup in arch/ia64
Message-Id: <20070415172123.GA9296@arun.site>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kernel Janitors <kernel-janitors@lists.osdl.org>, IA64 <linux-ia64@vger.kernel.org>
Cc: Andrw Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Tony Luck <tony.luck@intel.com>

SPIN_LOCK_UNLOCKED macro cleanup, use __SPIN_LOCK_UNLOCKED instead.

Signed-off-by: Milind Arun Choudhary <milindchoudhary@gmail.com>

---
 kernel/traps.c  |    6 +++---
 kernel/unwind.c |    2 +-
 mm/tlb.c        |    6 +++---
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/arch/ia64/kernel/traps.c b/arch/ia64/kernel/traps.c
index 765cbe5..cd5189f 100644
--- a/arch/ia64/kernel/traps.c
+++ b/arch/ia64/kernel/traps.c
@@ -59,9 +59,9 @@ die (const char *str, struct pt_regs *regs, long err)
 		u32 lock_owner;
 		int lock_owner_depth;
 	} die = {
-		.lock =			SPIN_LOCK_UNLOCKED,
-		.lock_owner =		-1,
-		.lock_owner_depth =	0
+		.lock =	__SPIN_LOCK_UNLOCKED(die.lock),
+		.lock_owner = -1,
+		.lock_owner_depth = 0
 	};
 	static int die_counter;
 	int cpu = get_cpu();
diff --git a/arch/ia64/kernel/unwind.c b/arch/ia64/kernel/unwind.c
index 93d5a3b..e3be21c 100644
--- a/arch/ia64/kernel/unwind.c
+++ b/arch/ia64/kernel/unwind.c
@@ -145,7 +145,7 @@ static struct {
 # endif
 } unw = {
 	.tables = &unw.kernel_table,
-	.lock = SPIN_LOCK_UNLOCKED,
+	.lock = __SPIN_LOCK_UNLOCKED(unw.lock),
 	.save_order = {
 		UNW_REG_RP, UNW_REG_PFS, UNW_REG_PSP, UNW_REG_PR,
 		UNW_REG_UNAT, UNW_REG_LC, UNW_REG_FPSR, UNW_REG_PRI_UNAT_GR
diff --git a/arch/ia64/mm/tlb.c b/arch/ia64/mm/tlb.c
index ffad762..fa4e6d4 100644
--- a/arch/ia64/mm/tlb.c
+++ b/arch/ia64/mm/tlb.c
@@ -32,9 +32,9 @@ static struct {
 } purge;
 
 struct ia64_ctx ia64_ctx = {
-	.lock =		SPIN_LOCK_UNLOCKED,
-	.next =		1,
-	.max_ctx =	~0U
+	.lock =	__SPIN_LOCK_UNLOCKED(ia64_ctx.lock),
+	.next =	1,
+	.max_ctx = ~0U
 };
 
 DEFINE_PER_CPU(u8, ia64_need_tlb_flush);
-- 
Milind Arun Choudhary
