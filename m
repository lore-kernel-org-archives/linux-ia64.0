From: Marc Zyngier <maz@kernel.org>
Date: Tue, 07 Feb 2023 11:23:40 +0000
Subject: Re: [RFC PATCH 29/32] KVM: arm64: Pass hypercalls to userspace
Message-Id: <86sffhzpkz.wl-maz@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230203135043.409192-1-james.morse@arm.com>
	<20230203135043.409192-30-james.morse@arm.com>
	<865ycg1kv2.wl-maz@kernel.org>
	<cffde8a1-74e4-9b61-1eea-544ba3405ed4@arm.com>
	<86wn4vynyr.wl-maz@kernel.org>
	<985abd9c-b3f9-3f9d-eec7-df1f26733762@arm.com>
In-Reply-To: <985abd9c-b3f9-3f9d-eec7-df1f26733762@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Suzuki K Poulose <suzuki.poulose@arm.com>
Cc: James Morse <james.morse@arm.com>, linux-pm@vger.kernel.org, loongarch@lists.linux.dev, kvmarm@lists.linux.dev, kvm@vger.kernel.org, linux-acpi@vger.kernel.org, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Lorenzo Pieralisi <lpieralisi@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Sudeep Holla <sudeep.holla@arm.com>, Borislav Petkov <bp@alien8.de>, H Peter Anvin <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Huacai Chen <chenhuacai@kernel.org>, Oliver Upton <oliver.upton@linux.dev>, Len Brown <lenb@kernel.org>, Rafael Wysocki <rafael@kernel.org>, WANG Xuerui <kernel@xen0n.name>, Salil Mehta <salil.mehta@huawei.com>, Russell King <linux@armlinux.org.uk>, Jean-Philippe Brucker <jean-philippe@linaro.org>

On Tue, 07 Feb 2023 09:41:54 +0000,
Suzuki K Poulose <suzuki.poulose@arm.com> wrote:
> 
> Hi Marc,
> 
> On 06/02/2023 12:31, Marc Zyngier wrote:
> > On Mon, 06 Feb 2023 10:10:41 +0000,
> > Suzuki K Poulose <suzuki.poulose@arm.com> wrote:
> >> 
> >> This may not be always possible, e.g., for Realms. GET_ONE_REG is
> >> not supported. So using an explicit passing down of the args is
> >> preferrable.
> > 
> > What is the blocker for CCA to use GET_ONE_REG? The value obviously
> > exists and is made available to the host. pKVM is perfectly able to
> > use GET_ONE_REG and gets a bunch of zeroes for things that the
> > hypervisor has decided to hide from the host.
> > 
> 
> It is not impossible. On a "HOST CALL" (explicit calls to the Host
> from Realm), the GPRs are made available to the host and can be
> stashed into the vcpu reg state and the request can be
> serviced. However, it is a bit odd, to make this exception - "the
> GET_ONE_REG is valid now", while in almost all other cases it is
> invalid (exception of MMIO).

But that's an RMM decision. If the RMM decides to forward the
hypercall to the host (irrespective of the potential forwarding to
userspace), it makes the GPRs available.

If the hypercall is forwarded to userspace, then the host is
responsible to check with the RMM that it will be willing to provide
the required information (passed as GPRs or not).

> Of course we could always return what is stashed in the vcpu state,
> which is may be invalid/ 0. But given the construct of "host doesn't
> have access to the register state", it may be a good idea to say,
> request always fails, to indicate that the Host is probably doing
> something wrong, than silently passing on incorrect information.

I disagree. Either you fail at the delegation point, or you don't. On
getting a hypercall exit to userspace, you are guaranteed that the
GPRs are valid.

> > Of course, it requires that the hypervisor (the RMM in your case)
> > knows about the semantics of the hypercall, but that's obviously
> 
> RMM doesn't care about the semantics of hypercall, other than
> considering it just like an SMCCC compliant call. The hypercall
> arguments/results are passed down/up by the Realm in a separate
> structure.

That's because the RMM doesn't use registers to pass the data. But at
the end of the day, this is the same thing. The host gets the data
from the RMM, stashes it in the GPRs, and exit to userspace.

The important thing here is that GET_ONE_REG is valid in the context
where it matters. If the VMM tries to use it outside of the context of
a hypercall, it gets junk. It's not a bug, it's a feature.

Thanks,

	M.

-- 
Without deviation from the norm, progress is not possible.
