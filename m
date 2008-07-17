From: Jes Sorensen <jes@sgi.com>
Date: Thu, 17 Jul 2008 11:33:21 +0000
Subject: [patch] KVM/ia64 update to new smp_call_function API
Message-Id: <487F2E01.1090608@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------010908070009080403040605"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------010908070009080403040605
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

This one makes KVM/ia64 build and boot again.

Cheers,
Jes


--------------010908070009080403040605
Content-Type: text/plain;
 name="ia64-fix-kvm-smp-call.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ia64-fix-kvm-smp-call.diff"

Convert KVM/ia64 to use the updated smp_call_function api, removing
the restart parameter.

Signed-off-by: Jes Sorensen <jes@sgi.com>

---
 arch/ia64/kvm/kvm-ia64.c |    4 ++--
 arch/ia64/kvm/kvm_fw.c   |    3 +--
 2 files changed, 3 insertions(+), 4 deletions(-)

Index: linux-2.6.git/arch/ia64/kvm/kvm-ia64.c
===================================================================
--- linux-2.6.git.orig/arch/ia64/kvm/kvm-ia64.c
+++ linux-2.6.git/arch/ia64/kvm/kvm-ia64.c
@@ -395,7 +395,7 @@
 		if (kvm->vcpus[i]->cpu != -1) {
 			call_data.vcpu = kvm->vcpus[i];
 			smp_call_function_single(kvm->vcpus[i]->cpu,
-					vcpu_global_purge, &call_data, 0, 1);
+					vcpu_global_purge, &call_data, 1);
 		} else
 			printk(KERN_WARNING"kvm: Uninit vcpu received ipi!\n");
 
@@ -1693,7 +1693,7 @@
 		wake_up_interruptible(&vcpu->wq);
 
 	if (vcpu->guest_mode)
-		smp_call_function_single(ipi_pcpu, vcpu_kick_intr, vcpu, 0, 0);
+		smp_call_function_single(ipi_pcpu, vcpu_kick_intr, vcpu, 0);
 }
 
 int kvm_apic_set_irq(struct kvm_vcpu *vcpu, u8 vec, u8 trig)
Index: linux-2.6.git/arch/ia64/kvm/kvm_fw.c
===================================================================
--- linux-2.6.git.orig/arch/ia64/kvm/kvm_fw.c
+++ linux-2.6.git/arch/ia64/kvm/kvm_fw.c
@@ -129,8 +129,7 @@
 	gr30 &= ~PAL_CACHE_FLUSH_CHK_INTRS;
 	args.cache_type = gr29;
 	args.operation = gr30;
-	smp_call_function(remote_pal_cache_flush,
-				(void *)&args, 1, 1);
+	smp_call_function(remote_pal_cache_flush, (void *)&args, 1);
 	if (args.status != 0)
 		printk(KERN_ERR"pal_cache_flush error!,"
 				"status:0x%lx\n", args.status);

--------------010908070009080403040605--
