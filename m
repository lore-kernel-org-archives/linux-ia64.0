From: Marc Zyngier <maz@kernel.org>
Date: Wed, 08 Feb 2023 08:40:09 +0000
Subject: Re: [RFC PATCH 29/32] KVM: arm64: Pass hypercalls to userspace
Message-Id: <878rh81rfa.wl-maz@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230203135043.409192-1-james.morse@arm.com>
	<20230203135043.409192-30-james.morse@arm.com>
	<865ycg1kv2.wl-maz@kernel.org>
	<7462738f-e837-cd99-f441-8e7c29d250cd@arm.com>
In-Reply-To: <7462738f-e837-cd99-f441-8e7c29d250cd@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Morse <james.morse@arm.com>
Cc: linux-pm@vger.kernel.org, loongarch@lists.linux.dev, kvmarm@lists.linux.dev, kvm@vger.kernel.org, linux-acpi@vger.kernel.org, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Lorenzo Pieralisi <lpieralisi@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Sudeep Holla <sudeep.holla@arm.com>, Borislav Petkov <bp@alien8.de>, H Peter Anvin <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Huacai Chen <chenhuacai@kernel.org>, Suzuki K Poulose <suzuki.poulose@arm.com>, Oliver Upton <oliver.upton@linux.dev>, Len Brown <lenb@kernel.org>, Rafael Wysocki <rafael@kernel.org>, WANG Xuerui <kernel@xen0n.name>, Salil Mehta <salil.mehta@huawei.com>, Russell King <linux@armlinux.org.uk>, Jean-Philippe Brucker <jean-philippe@linaro.org>

On Tue, 07 Feb 2023 17:50:58 +0000,
James Morse <james.morse@arm.com> wrote:
> 
> Hi Marc,
> 
> On 05/02/2023 10:12, Marc Zyngier wrote:
> > On Fri, 03 Feb 2023 13:50:40 +0000,
> > James Morse <james.morse@arm.com> wrote:
> >>
> >> From: Jean-Philippe Brucker <jean-philippe@linaro.org>
> >>
> >> When capability KVM_CAP_ARM_HVC_TO_USER is available, userspace can
> >> request to handle all hypercalls that aren't handled by KVM. With the
> >> help of another capability, this will allow userspace to handle PSCI
> >> calls.
> 
> > On top of Oliver's ask not to make this a blanket "steal everything",
> > but instead to have an actual request for ranges of forwarded
> > hypercalls:
> > 
> >> Notes on this implementation:
> >>
> >> * A similar mechanism was proposed for SDEI some time ago [1]. This RFC
> >>   generalizes the idea to all hypercalls, since that was suggested on
> >>   the list [2, 3].
> >>
> >> * We're reusing kvm_run.hypercall. I copied x0-x5 into
> >>   kvm_run.hypercall.args[] to help userspace but I'm tempted to remove
> >>   this, because:
> >>   - Most user handlers will need to write results back into the
> >>     registers (x0-x3 for SMCCC), so if we keep this shortcut we should
> >>     go all the way and read them back on return to kernel.
> >>   - QEMU doesn't care about this shortcut, it pulls all vcpu regs before
> >>     handling the call.
> >>   - SMCCC uses x0-x16 for parameters.
> >>   x0 does contain the SMCCC function ID and may be useful for fast
> >>   dispatch, we could keep that plus the immediate number.
> >>
> >> * Add a flag in the kvm_run.hypercall telling whether this is HVC or
> >>   SMC?  Can be added later in those bottom longmode and pad fields.
> 
> > We definitely need this. A nested hypervisor can (and does) use SMCs
> > as the conduit.
> 
> Christoffer's comments last time round on this was that EL2 guests
> get SMC with this, and EL1 guests get HVC. The VMM could never get
> both...

I agree with the first half of the statement (EL2 guest using SMC),
but limiting EL1 guests to HVC is annoying. On systems that have a
secure side, it would make sense to be able to route the guest's SMC
calls to userspace and allow it to emulate/proxy/deny such calls.

This would solve the 10 year old question of "how do we allow a guest
to call into secure services...

> 
> 
> > The question is whether they represent two distinct
> > namespaces or not. I *think* we can unify them, but someone should
> > check and maybe get clarification from the owners of the SMCCC spec.
> 
> i.e. the VMM requests 0xC400_0000:0xC400_001F regardless of SMC/HVC?
> 
> I don't yet see how a VMM could get HVC out of a virtual-EL2 guest....

My statement was badly formulated, and I conflated the need for SMC in
EL2 guests with the (separate) need to handle SMC for EL1 guests.

>
> 
> >> * On top of this we could share with userspace which HVC ranges are
> >>   available and which ones are handled by KVM. That can actually be added
> >>   independently, through a vCPU/VM device attribute which doesn't consume
> >>   a new ioctl:
> >>   - userspace issues HAS_ATTR ioctl on the vcpu fd to query whether this
> >>     feature is available.
> >>   - userspace queries the number N of HVC ranges using one GET_ATTR.
> >>   - userspace passes an array of N ranges using another GET_ATTR. The
> >>     array is filled and returned by KVM.
> 
> > As mentioned above, I think this interface should go both ways.
> > Userspace should request the forwarding of a certain range of
> > hypercalls via a similar SET_ATTR interface.
> 
> Yup, I'll sync up with Oliver about that.
> 
> 
> > Another question is how we migrate VMs that have these forwarding
> > requirements. Do we expect the VMM to replay the forwarding as part of
> > the setting up on the other side? Or do we save/restore this via a
> > firmware pseudo-register?
> 
> Pfff. VMMs problem. Enabling these things means it has its own
> internal state to migrate.  (is this vCPU on or off?), I doubt it
> needs reminding that the state exists.

I'm perfectly OK with the VMM being in the driving seat here and that
it'd have to replay its own state. But it needs some level of
documentation.

> That said, Salil is looking at making this work with migration in Qemu.

Yup, that'd be needed.

Thanks,

	M.

-- 
Without deviation from the norm, progress is not possible.
