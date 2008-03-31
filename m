From: Carsten Otte <cotte@de.ibm.com>
Date: Mon, 31 Mar 2008 14:52:21 +0000
Subject: Re: [04/17] [PATCH] Add kvm arch-specific core code for kvm/ia64.-V8
Message-Id: <47F0FAA5.2090109@de.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDC01048245@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDC01048245@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Cc: Avi Kivity <avi@qumranet.com>, "Luck, Tony" <tony.luck@intel.com>, "Xu, Anthony" <anthony.xu@intel.com>, Jes Sorensen <jes@sgi.com>, Akio Takebe <takebe_akio@jp.fujitsu.com>, kvm-devel@lists.sourceforge.net, kvm-ia64-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, virtualization@lists.linux-foundation.org

Zhang, Xiantao wrote:
> +static struct kvm_vcpu *lid_to_vcpu(struct kvm *kvm, unsigned long id,
> +			unsigned long eid)
> +{
> +	ia64_lid_t lid;
> +	int i;
> +
> +	for (i = 0; i < KVM_MAX_VCPUS; i++) {
> +		if (kvm->vcpus[i]) {
> +			lid.val = VCPU_LID(kvm->vcpus[i]);
> +			if (lid.id = id && lid.eid = eid)
> +				return kvm->vcpus[i];
> +		}
> +	}
> +
> +	return NULL;
> +}
> +
> +static int handle_ipi(struct kvm_vcpu *vcpu, struct kvm_run *kvm_run)
> +{
> +	struct exit_ctl_data *p = kvm_get_exit_data(vcpu);
> +	struct kvm_vcpu *target_vcpu;
> +	struct kvm_pt_regs *regs;
> +	ia64_ipi_a addr = p->u.ipi_data.addr;
> +	ia64_ipi_d data = p->u.ipi_data.data;
> +
> +	target_vcpu = lid_to_vcpu(vcpu->kvm, addr.id, addr.eid);
> +	if (!target_vcpu)
> +		return handle_vm_error(vcpu, kvm_run);
> +
> +	if (!target_vcpu->arch.launched) {
> +		regs = vcpu_regs(target_vcpu);
> +
> +		regs->cr_iip = vcpu->kvm->arch.rdv_sal_data.boot_ip;
> +		regs->r1 = vcpu->kvm->arch.rdv_sal_data.boot_gp;
> +
> +		target_vcpu->arch.mp_state = VCPU_MP_STATE_RUNNABLE;
> +		if (waitqueue_active(&target_vcpu->wq))
> +			wake_up_interruptible(&target_vcpu->wq);
> +	} else {
> +		vcpu_deliver_ipi(target_vcpu, data.dm, data.vector);
> +		if (target_vcpu != vcpu)
> +			kvm_vcpu_kick(target_vcpu);
> +	}
> +
> +	return 1;
> +}
*Shrug*. This looks highly racy to me. You do access various values in 
target_vcpu without any lock! I know that taking the target vcpu's 
lock does'nt work because that one is held all the time during 
KVM_VCPU_RUN. My solution to that was struct local_interrupt, which 
has its own lock, and has the waitqueue plus everything I need to send 
a sigp [that's our flavor of ipi].

> +int kvm_emulate_halt(struct kvm_vcpu *vcpu)
> +{
> +
> +	ktime_t kt;
> +	long itc_diff;
> +	unsigned long vcpu_now_itc;
> +
> +	unsigned long expires;
> +	struct hrtimer *p_ht = &vcpu->arch.hlt_timer;
That makes me jealous, I'd love to have hrtimer on s390 for this. I've 
got to round up to the next jiffie. *Sigh*

> +int kvm_arch_vcpu_ioctl_set_sregs(struct kvm_vcpu *vcpu,
> +		struct kvm_sregs *sregs)
> +{
> +	printk(KERN_WARNING"kvm:kvm_arch_vcpu_ioctl_set_sregs
> called!!\n");
> +	return 0;
> +}
> +
> +int kvm_arch_vcpu_ioctl_get_sregs(struct kvm_vcpu *vcpu,
> +		struct kvm_sregs *sregs)
> +{
> +	printk(KERN_WARNING"kvm:kvm_arch_vcpu_ioctl_get_sregs
> called!!\n");
> +	return 0;
> +
> +}
Suggestion: if get/set sregs does'nt seem useful on ia64, why not 
return -EINVAL? In that case, you could also not print a kern warning, 
the user will either handle that situation or complain.

> +int kvm_arch_vcpu_init(struct kvm_vcpu *vcpu)
> +{
<snip>
> +	/*FIXME:Need to removed it later!!\n*/
> +	vcpu->arch.apic = kzalloc(sizeof(struct kvm_lapic), GFP_KERNEL);
> +	vcpu->arch.apic->vcpu = vcpu;
Fixme!

> +static int vti_vcpu_setup(struct kvm_vcpu *vcpu, int id)
> +{
> +	unsigned long psr;
> +	int r;
> +
> +	local_irq_save(psr);
> +	r = kvm_insert_vmm_mapping(vcpu);
> +	if (r)
> +		goto fail;
> +	r = kvm_vcpu_init(vcpu, vcpu->kvm, id);
> +	if (r)
> +		goto fail;
Maybe change to return r, rather then goto fail?

> +int kvm_arch_vcpu_ioctl_get_fpu(struct kvm_vcpu *vcpu, struct kvm_fpu
> *fpu)
> +{
> +	printk(KERN_WARNING"kvm:IA64 doesn't need to export"
> +			"fpu to userspace!\n");
> +	return 0;
> +}
> +
> +int kvm_arch_vcpu_ioctl_set_fpu(struct kvm_vcpu *vcpu, struct kvm_fpu
> *fpu)
> +{
> +	printk(KERN_WARNING"kvm:IA64 doesn't need to export"
> +					"fpu to userspace !\n");
> +	return 0;
> +}
maybe -EINVAL?

> +static int find_highest_bits(int *dat)
> +{
> +	u32  bits, bitnum;
> +	int i;
> +
> +	/* loop for all 256 bits */
> +	for (i = 7; i >= 0 ; i--) {
> +		bits = dat[i];
> +		if (bits) {
> +			bitnum = fls(bits);
> +			return i * 32 + bitnum - 1;
> +		}
> +	}
> +
> +	return -1;
> +}
Should be in asm/bitops.h. Look at find_first_bit() and friends, this 
is duplicate.

