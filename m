From: Julia Lawall <julia@diku.dk>
Date: Wed, 26 May 2010 15:57:05 +0000
Subject: [PATCH 10/17] arch/ia64/kvm: Add missing spin_unlock
Message-Id: <Pine.LNX.4.64.1005261756490.23743@ask.diku.dk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Avi Kivity <avi@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>, Xiantao Zhang <xiantao.zhang@intel.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, kvm@vger.kernel.org, kvm-ia64@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org

From: Julia Lawall <julia@diku.dk>

Add a spin_unlock missing on the error path.

The semantic match that finds this problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
expression E1;
@@

* spin_lock(E1,...);
  <+... when != E1
  if (...) {
    ... when != E1
*   return ...;
  }
  ...+>
* spin_unlock(E1,...);
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 arch/ia64/kvm/kvm-ia64.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/ia64/kvm/kvm-ia64.c b/arch/ia64/kvm/kvm-ia64.c
index d5f4e91..21b7013 100644
--- a/arch/ia64/kvm/kvm-ia64.c
+++ b/arch/ia64/kvm/kvm-ia64.c
@@ -144,6 +144,7 @@ int kvm_arch_hardware_enable(void *garbage)
 				VP_INIT_ENV : VP_INIT_ENV_INITALIZE,
 			__pa(kvm_vm_buffer), KVM_VM_BUFFER_BASE, &tmp_base);
 	if (status != 0) {
+		spin_unlock(&vp_lock);
 		printk(KERN_WARNING"kvm: Failed to Enable VT Support!!!!\n");
 		return -EINVAL;
 	}
