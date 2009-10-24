From: "Luck, Tony" <tony.luck@intel.com>
Date: Sat, 24 Oct 2009 00:56:21 +0000
Subject: [PATCH] Re-implement spinaphores using ticket lock concepts
Message-Id: <4ae250b528223e356c@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bound the wait time for the ptcg_sem by using similar idea to the
ticket spin locks.  In this case we have only one instance of a
spinaphore, so make it 8 bytes rather than try to squeeze it into
4-bytes to keep the code simpler (and shorter).

Signed-off-by: Tony Luck <tony.luck@intel.com>

---

diff --git a/arch/ia64/mm/tlb.c b/arch/ia64/mm/tlb.c
index f426dc7..ee09d26 100644
--- a/arch/ia64/mm/tlb.c
+++ b/arch/ia64/mm/tlb.c
@@ -100,24 +100,36 @@ wrap_mmu_context (struct mm_struct *mm)
  * this primitive it can be moved up to a spinaphore.h header.
  */
 struct spinaphore {
-	atomic_t	cur;
+	unsigned long	ticket;
+	unsigned long	serve;
 };
 
 static inline void spinaphore_init(struct spinaphore *ss, int val)
 {
-	atomic_set(&ss->cur, val);
+	ss->ticket = 0;
+	ss->serve = val;
 }
 
 static inline void down_spin(struct spinaphore *ss)
 {
-	while (unlikely(!atomic_add_unless(&ss->cur, -1, 0)))
-		while (atomic_read(&ss->cur) = 0)
-			cpu_relax();
+	unsigned long t = ia64_fetchadd(1, &ss->ticket, acq), serve;
+
+	if (time_before(t, ss->serve))
+		return;
+
+	ia64_invala();
+
+	for (;;) {
+		asm volatile ("ld4.c.nc %0=[%1]" : "=r"(serve) : "r"(&ss->serve) : "memory");
+		if (time_before(t, serve))
+			return;
+		cpu_relax();
+	}
 }
 
 static inline void up_spin(struct spinaphore *ss)
 {
-	atomic_add(1, &ss->cur);
+	ia64_fetchadd(1, &ss->serve, rel);
 }
 
 static struct spinaphore ptcg_sem;
