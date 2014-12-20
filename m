From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Date: Sat, 20 Dec 2014 22:54:39 +0000
Subject: [PATCH] arch: ia64: kernel: irq_ia64.c:  Remove some unused functions
Message-Id: <1419116079-13052-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
List-Id: <linux-ia64.vger.kernel.org>
References: <1419095222-9942-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
In-Reply-To: <1419095222-9942-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>, Thomas Gleixner <tglx@linutronix.de>, Grant Likely <grant.likely@linaro.org>, Christoph Lameter <cl@linux.com>, Tejun Heo <tj@kernel.org>, Michael Opdenacker <michael.opdenacker@free-electrons.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Removes some functions that are not used anywhere:
rnat_consumption() inat_page_consumption() privilege_reg()
unimpl_daddr() privilege_op() rsv_reg_field() illegal_dep()

This was partially found by using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 arch/ia64/kvm/process.c |   70 -----------------------------------------------
 1 file changed, 70 deletions(-)

diff --git a/arch/ia64/kvm/process.c b/arch/ia64/kvm/process.c
index b039874..ab9d9e7 100644
--- a/arch/ia64/kvm/process.c
+++ b/arch/ia64/kvm/process.c
@@ -302,56 +302,6 @@ void illegal_op(struct kvm_vcpu *vcpu)
 	_general_exception(vcpu);
 }
 
-/*
- * Illegal Dependency Fault
- *  @ General Exception Vector
- * Refer to SDM Vol2 Table 5-6 & 8-1
- */
-void illegal_dep(struct kvm_vcpu *vcpu)
-{
-	_general_exception(vcpu);
-}
-
-/*
- * Reserved Register/Field Fault
- *  @ General Exception Vector
- * Refer to SDM Vol2 Table 5-6 & 8-1
- */
-void rsv_reg_field(struct kvm_vcpu *vcpu)
-{
-	_general_exception(vcpu);
-}
-/*
- * Privileged Operation Fault
- *  @ General Exception Vector
- * Refer to SDM Vol2 Table 5-6 & 8-1
- */
-
-void privilege_op(struct kvm_vcpu *vcpu)
-{
-	_general_exception(vcpu);
-}
-
-/*
- * Unimplement Data Address Fault
- *  @ General Exception Vector
- * Refer to SDM Vol2 Table 5-6 & 8-1
- */
-void unimpl_daddr(struct kvm_vcpu *vcpu)
-{
-	_general_exception(vcpu);
-}
-
-/*
- * Privileged Register Fault
- *  @ General Exception Vector
- * Refer to SDM Vol2 Table 5-6 & 8-1
- */
-void privilege_reg(struct kvm_vcpu *vcpu)
-{
-	_general_exception(vcpu);
-}
-
 /* Deal with
  *  Nat consumption vector
  * Parameter:
@@ -370,26 +320,6 @@ static void _nat_consumption_fault(struct kvm_vcpu *vcpu, u64 vadr,
 }
 
 /*
- * Instruction Nat Page Consumption Fault
- *  @ Nat Consumption Vector
- * Refer to SDM Vol2 Table 5-6 & 8-1
- */
-void inat_page_consumption(struct kvm_vcpu *vcpu, u64 vadr)
-{
-	_nat_consumption_fault(vcpu, vadr, INSTRUCTION);
-}
-
-/*
- * Register Nat Consumption Fault
- *  @ Nat Consumption Vector
- * Refer to SDM Vol2 Table 5-6 & 8-1
- */
-void rnat_consumption(struct kvm_vcpu *vcpu)
-{
-	_nat_consumption_fault(vcpu, 0, REGISTER);
-}
-
-/*
  * Data Nat Page Consumption Fault
  *  @ Nat Consumption Vector
  * Refer to SDM Vol2 Table 5-6 & 8-1
-- 
1.7.10.4

