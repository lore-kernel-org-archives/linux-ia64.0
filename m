From: Oliver Upton <oliver.upton@linux.dev>
Date: Mon, 06 Feb 2023 17:19:25 +0000
Subject: Re: [RFC PATCH 29/32] KVM: arm64: Pass hypercalls to userspace
Message-Id: <Y+E2nVnadj1emNs5@google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230203135043.409192-1-james.morse@arm.com>
 <20230203135043.409192-30-james.morse@arm.com>
 <865ycg1kv2.wl-maz@kernel.org>
In-Reply-To: <865ycg1kv2.wl-maz@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Marc Zyngier <maz@kernel.org>
Cc: James Morse <james.morse@arm.com>, linux-pm@vger.kernel.org, loongarch@lists.linux.dev, kvmarm@lists.linux.dev, kvm@vger.kernel.org, linux-acpi@vger.kernel.org, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Lorenzo Pieralisi <lpieralisi@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Sudeep Holla <sudeep.holla@arm.com>, Borislav Petkov <bp@alien8.de>, H Peter Anvin <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Huacai Chen <chenhuacai@kernel.org>, Suzuki K Poulose <suzuki.poulose@arm.com>, Len Brown <lenb@kernel.org>, Rafael Wysocki <rafael@kernel.org>, WANG Xuerui <kernel@xen0n.name>, Salil Mehta <salil.mehta@huawei.com>, Russell King <linux@armlinux.org.uk>, Jean-Philippe Brucker <jean-philippe@linaro.org>

On Sun, Feb 05, 2023 at 10:12:49AM +0000, Marc Zyngier wrote:
> On Fri, 03 Feb 2023 13:50:40 +0000,
> James Morse <james.morse@arm.com> wrote:
> > 
> > From: Jean-Philippe Brucker <jean-philippe@linaro.org>
> > 
> > When capability KVM_CAP_ARM_HVC_TO_USER is available, userspace can
> > request to handle all hypercalls that aren't handled by KVM. With the
> > help of another capability, this will allow userspace to handle PSCI
> > calls.
> > 
> > Suggested-by: James Morse <james.morse@arm.com>
> > Signed-off-by: Jean-Philippe Brucker <jean-philippe@linaro.org>
> > Signed-off-by: James Morse <james.morse@arm.com>
> > 
> > ---
> > 
> 
> On top of Oliver's ask not to make this a blanket "steal everything",
> but instead to have an actual request for ranges of forwarded
> hypercalls:
> 
> > Notes on this implementation:
> > 
> > * A similar mechanism was proposed for SDEI some time ago [1]. This RFC
> >   generalizes the idea to all hypercalls, since that was suggested on
> >   the list [2, 3].
> > 
> > * We're reusing kvm_run.hypercall. I copied x0-x5 into
> >   kvm_run.hypercall.args[] to help userspace but I'm tempted to remove
> >   this, because:
> >   - Most user handlers will need to write results back into the
> >     registers (x0-x3 for SMCCC), so if we keep this shortcut we should
> >     go all the way and read them back on return to kernel.
> >   - QEMU doesn't care about this shortcut, it pulls all vcpu regs before
> >     handling the call.
> >   - SMCCC uses x0-x16 for parameters.
> >   x0 does contain the SMCCC function ID and may be useful for fast
> >   dispatch, we could keep that plus the immediate number.
> > 
> > * Add a flag in the kvm_run.hypercall telling whether this is HVC or
> >   SMC?  Can be added later in those bottom longmode and pad fields.
> 
> We definitely need this. A nested hypervisor can (and does) use SMCs
> as the conduit. The question is whether they represent two distinct
> namespaces or not. I *think* we can unify them, but someone should
> check and maybe get clarification from the owners of the SMCCC spec.
> 
> >
> > * On top of this we could share with userspace which HVC ranges are
> >   available and which ones are handled by KVM. That can actually be added
> >   independently, through a vCPU/VM device attribute which doesn't consume
> >   a new ioctl:
> >   - userspace issues HAS_ATTR ioctl on the vcpu fd to query whether this
> >     feature is available.
> >   - userspace queries the number N of HVC ranges using one GET_ATTR.
> >   - userspace passes an array of N ranges using another GET_ATTR. The
> >     array is filled and returned by KVM.
> 
> As mentioned above, I think this interface should go both ways.
> Userspace should request the forwarding of a certain range of
> hypercalls via a similar SET_ATTR interface.
> 
> Another question is how we migrate VMs that have these forwarding
> requirements. Do we expect the VMM to replay the forwarding as part of
> the setting up on the other side? Or do we save/restore this via a
> firmware pseudo-register?

Personally I'd prefer we left that job to userspace.

We could also implement GET_ATTR, in case userspace has forgotten what
it wrote to the hypercall filter. The firmware pseudo-registers are
handy for moving KVM state back and forth 'for free', but I don't think
we need to bend over backwards to migrate state userspace is directly
responsible for.

-- 
Thanks,
Oliver
