From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Tue, 01 Apr 2008 02:16:09 +0000
Subject: RE: [04/17] [PATCH] Add kvm arch-specific core code for kvm/ia64.-V8
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDC01048488@pdsmsx415.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDC01048245@pdsmsx415.ccr.corp.intel.com> <47F0FAA5.2090109@de.ibm.com>
In-Reply-To: <47F0FAA5.2090109@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: carsteno@de.ibm.com
Cc: Avi Kivity <avi@qumranet.com>, "Luck, Tony" <tony.luck@intel.com>, "Xu, Anthony" <anthony.xu@intel.com>, Jes Sorensen <jes@sgi.com>, Akio Takebe <takebe_akio@jp.fujitsu.com>, kvm-devel@lists.sourceforge.net, kvm-ia64-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, virtualization@lists.linux-foundation.org

Carsten Otte wrote:
> Zhang, Xiantao wrote:
>> +static struct kvm_vcpu *lid_to_vcpu(struct kvm *kvm, unsigned long
>> id, +			unsigned long eid) +{
>> +	ia64_lid_t lid;
>> +	int i;
>> +
>> +	for (i = 0; i < KVM_MAX_VCPUS; i++) {
>> +		if (kvm->vcpus[i]) {
>> +			lid.val = VCPU_LID(kvm->vcpus[i]);
>> +			if (lid.id = id && lid.eid = eid)
>> +				return kvm->vcpus[i];
>> +		}
>> +	}
>> +
>> +	return NULL;
>> +}
>> +
>> +static int handle_ipi(struct kvm_vcpu *vcpu, struct kvm_run
>> *kvm_run) +{ +	struct exit_ctl_data *p kvm_get_exit_data(vcpu);
>> +	struct kvm_vcpu *target_vcpu;
>> +	struct kvm_pt_regs *regs;
>> +	ia64_ipi_a addr = p->u.ipi_data.addr;
>> +	ia64_ipi_d data = p->u.ipi_data.data;
>> +
>> +	target_vcpu = lid_to_vcpu(vcpu->kvm, addr.id, addr.eid); +
if
>> (!target_vcpu) +		return handle_vm_error(vcpu, kvm_run);
>> +
>> +	if (!target_vcpu->arch.launched) {
>> +		regs = vcpu_regs(target_vcpu);
>> +
>> +		regs->cr_iip = vcpu->kvm->arch.rdv_sal_data.boot_ip;
>> +		regs->r1 = vcpu->kvm->arch.rdv_sal_data.boot_gp; +
>> +		target_vcpu->arch.mp_state = VCPU_MP_STATE_RUNNABLE;
>> +		if (waitqueue_active(&target_vcpu->wq))
>> +			wake_up_interruptible(&target_vcpu->wq);
>> +	} else {
>> +		vcpu_deliver_ipi(target_vcpu, data.dm, data.vector); +
if
>> (target_vcpu != vcpu) +
kvm_vcpu_kick(target_vcpu);
>> +	}
>> +
>> +	return 1;
>> +}
> *Shrug*. This looks highly racy to me. You do access various values in
> target_vcpu without any lock! I know that taking the target vcpu's
> lock does'nt work because that one is held all the time during
> KVM_VCPU_RUN. My solution to that was struct local_interrupt, which
> has its own lock, and has the waitqueue plus everything I need to send
> a sigp [that's our flavor of ipi].
ex
Hi, Carsten 
     Why do you think it is racy?  In this function,
target_vcpu->arch.launched should be set to 1 for the first run, and
keep its value all the time.  Except the first IPI to wake up the vcpu,
all IPIs received by target vcpu should go into "else" condition. So you
mean the race condition exist in "else"  code ?
Xiantao
