From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 18 Dec 2009 01:05:03 +0000
Subject: [PATCH] Fix kvm build for ia64
Message-Id: <4b2ad53f6113bd0d@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Len Brown pointed out that allmodconfig is broken for
ia64 because of:

arch/ia64/kvm/vmm.c: In function 'vmm_spin_unlock':
arch/ia64/kvm/vmm.c:70: error: 'spinlock_t' has no member named 'raw_lock'

KVM has it's own spinlock routines. It should not depend on the base kernel
spinlock_t type (which changed when ia64 switched to ticket locks).  Define
its own vmm_spinlock_t type.

Signed-off-by: Tony Luck <tony.luck@intel.com>

---

repost with Signed-off-by and re-written commit log.

diff --git a/arch/ia64/kvm/vcpu.h b/arch/ia64/kvm/vcpu.h
index 360724d..988911b 100644
--- a/arch/ia64/kvm/vcpu.h
+++ b/arch/ia64/kvm/vcpu.h
@@ -388,6 +388,9 @@ static inline u64 __gpfn_is_io(u64 gpfn)
 #define _vmm_raw_spin_lock(x)	 do {}while(0)
 #define _vmm_raw_spin_unlock(x) do {}while(0)
 #else
+typedef struct {
+	volatile unsigned int lock;
+} vmm_spinlock_t;
 #define _vmm_raw_spin_lock(x)						\
 	do {								\
 		__u32 *ia64_spinlock_ptr = (__u32 *) (x);		\
@@ -405,12 +408,12 @@ static inline u64 __gpfn_is_io(u64 gpfn)
 
 #define _vmm_raw_spin_unlock(x)				\
 	do { barrier();				\
-		((spinlock_t *)x)->raw_lock.lock = 0; } \
+		((vmm_spinlock_t *)x)->lock = 0; } \
 while (0)
 #endif
 
-void vmm_spin_lock(spinlock_t *lock);
-void vmm_spin_unlock(spinlock_t *lock);
+void vmm_spin_lock(vmm_spinlock_t *lock);
+void vmm_spin_unlock(vmm_spinlock_t *lock);
 enum {
 	I_TLB = 1,
 	D_TLB = 2
diff --git a/arch/ia64/kvm/vmm.c b/arch/ia64/kvm/vmm.c
index f4b4c89..7a62f75 100644
--- a/arch/ia64/kvm/vmm.c
+++ b/arch/ia64/kvm/vmm.c
@@ -60,12 +60,12 @@ static void __exit kvm_vmm_exit(void)
 	return ;
 }
 
-void vmm_spin_lock(spinlock_t *lock)
+void vmm_spin_lock(vmm_spinlock_t *lock)
 {
 	_vmm_raw_spin_lock(lock);
 }
 
-void vmm_spin_unlock(spinlock_t *lock)
+void vmm_spin_unlock(vmm_spinlock_t *lock)
 {
 	_vmm_raw_spin_unlock(lock);
 }
diff --git a/arch/ia64/kvm/vtlb.c b/arch/ia64/kvm/vtlb.c
index 20b3852..4332f7e 100644
--- a/arch/ia64/kvm/vtlb.c
+++ b/arch/ia64/kvm/vtlb.c
@@ -182,7 +182,7 @@ void mark_pages_dirty(struct kvm_vcpu *v, u64 pte, u64 ps)
 {
 	u64 i, dirty_pages = 1;
 	u64 base_gfn = (pte&_PAGE_PPN_MASK) >> PAGE_SHIFT;
-	spinlock_t *lock = __kvm_va(v->arch.dirty_log_lock_pa);
+	vmm_spinlock_t *lock = __kvm_va(v->arch.dirty_log_lock_pa);
 	void *dirty_bitmap = (void *)KVM_MEM_DIRTY_LOG_BASE;
 
 	dirty_pages <<= ps <= PAGE_SHIFT ? 0 : ps - PAGE_SHIFT;
