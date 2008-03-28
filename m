From: Akio Takebe <takebe_akio@jp.fujitsu.com>
Date: Fri, 28 Mar 2008 12:36:48 +0000
Subject: Re: [14/17][PATCH] kvm/ia64: Add guest interruption injection support.
Message-Id: <87C890D0641F40takebe_akio@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDCFF7EF2@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDCFF7EF2@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Zhang, Xiantao" <xiantao.zhang@intel.com>, Avi Kivity <avi@qumranet.com>, "Luck, Tony" <tony.luck@intel.com>, "Xu, Anthony" <anthony.xu@intel.com>, Jes Sorensen <jes@sgi.com>, kv

Hi, Xiantao

It's good, I have some small comments.

>+
>+/* SDM vol2 5.5 - IVA based interruption handling */
>+#define INITIAL_PSR_VALUE_AT_INTERRUPTION 0x0000001808028034
>+
Xen also use this value, you had better use macros of PSR bits.
Or you can add the same comments as Xen.


>+
>+/*
>+ * Handle floating-point assist faults and traps for domain.
>+ */
>+unsigned long vmm_handle_fpu_swa(int fp_fault, REGS *regs, unsigned
>long isr)
>+{
>+	struct kvm_vcpu *v = current_vcpu;
>+	IA64_BUNDLE bundle;
>+	unsigned long fault_ip;
>+	fpswa_ret_t ret;
>+
>+	fault_ip = regs->cr_iip;
>+	/*
>+	 * When the FP trap occurs, the trapping instruction is
>completed.
>+	 * If ipsr.ri = 0, there is the trapping instruction in
>previous
>+	 * bundle.
>+	 */
>+	if (!fp_fault && (ia64_psr(regs)->ri = 0))
>+		fault_ip -= 16;
>+
>+	if (fetch_code(v, fault_ip, &bundle))
>+		return -EAGAIN;
>+
>+	if (!bundle.i64[0] && !bundle.i64[1]) {
>+		return -EACCES;
>+	}
>+
>+	ret = vmm_fp_emulate(fp_fault, &bundle, &regs->cr_ipsr,
>&regs->ar_fpsr,
>+			&isr, &regs->pr, &regs->cr_ifs, regs);
>+	return ret.status;
>+}
>+
>+void reflect_interruption(u64 ifa, u64 isr, u64 iim,
>+		u64 vec, REGS *regs)
>+{
>+	u64 vector;
>+	int status ;
>+	VCPU *vcpu = current_vcpu;
>+	u64 vpsr = VCPU(vcpu, vpsr);
>+
>+	vector = vec2off[vec];
>+
>+	if (!(vpsr & IA64_PSR_IC) && (vector !>IA64_DATA_NESTED_TLB_VECTOR)) {
>+		panic_vm(vcpu);
>+		return;
>+	}
>+
>+	switch (vec) {
>+	case 32:
I want to add a comment of IA64_FP_FAULT_VECTOR.

>+		status = vmm_handle_fpu_swa(1, regs, isr);
>+		if (!status) {
>+			vcpu_increment_iip(vcpu);
>+			return;
>+		} else if (-EAGAIN = status)
>+			return;
>+		break;
>+	case 33:
ditto, I want to add a comments of IA64_FP_TRAP_VECTOR.

>+		status = vmm_handle_fpu_swa(0, regs, isr);
>+		if (!status)
>+			return ;
>+		else if (-EAGAIN = status) {
>+			vcpu_decrement_iip(vcpu);
>+			return ;
>+		}
>+		break;
>+	}
>+
>+	VCPU(vcpu, isr) = isr;
>+	VCPU(vcpu, iipa) = regs->cr_iip;
>+	if (vector = IA64_BREAK_VECTOR || vector =
>IA64_SPECULATION_VECTOR)
>+		VCPU(vcpu, iim) = iim;
>+	else {
>+		set_ifa_itir_iha(vcpu, ifa, 1, 1, 1);
>+	}
>+	inject_guest_interruption(vcpu, vector);
>+}
>+
>

Best Regards,

Akio Takebe

