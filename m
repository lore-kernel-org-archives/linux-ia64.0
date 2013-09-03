From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 03 Sep 2013 22:31:21 +0000
Subject: [PATCH] lockref: Implement lockref for Itanium
Message-Id: <0228140@agluck-desk.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

All the cool kids are doing this, join in the fun.

Signed-off-by: Tony Luck <tony.luck@intel.com>
---
 arch/ia64/Kconfig                | 1 +
 arch/ia64/include/asm/spinlock.h | 5 +++++
 2 files changed, 6 insertions(+)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 5a768ad..a486442 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -43,6 +43,7 @@ config IA64
 	select SYSCTL_ARCH_UNALIGN_NO_WARN
 	select HAVE_MOD_ARCH_SPECIFIC
 	select MODULES_USE_ELF_RELA
+	select ARCH_USE_CMPXCHG_LOCKREF
 	default y
 	help
 	  The Itanium Processor Family is Intel's 64-bit successor to
diff --git a/arch/ia64/include/asm/spinlock.h b/arch/ia64/include/asm/spinlock.h
index 54ff557..45698cd 100644
--- a/arch/ia64/include/asm/spinlock.h
+++ b/arch/ia64/include/asm/spinlock.h
@@ -102,6 +102,11 @@ static inline int __ticket_spin_is_contended(arch_spinlock_t *lock)
 	return ((tmp - (tmp >> TICKET_SHIFT)) & TICKET_MASK) > 1;
 }
 
+static __always_inline int arch_spin_value_unlocked(arch_spinlock_t lock)
+{
+	return !(((lock.lock >> TICKET_SHIFT) ^ lock.lock) & TICKET_MASK);
+}
+
 static inline int arch_spin_is_locked(arch_spinlock_t *lock)
 {
 	return __ticket_spin_is_locked(lock);
-- 
1.8.1.4

