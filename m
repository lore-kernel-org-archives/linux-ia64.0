From: Marc Zyngier <maz@kernel.org>
Date: Wed, 08 Feb 2023 09:02:09 +0000
Subject: Re: [RFC PATCH 29/32] KVM: arm64: Pass hypercalls to userspace
Message-Id: <877cws1qem.wl-maz@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230203135043.409192-1-james.morse@arm.com>
	<20230203135043.409192-30-james.morse@arm.com>
	<Y913sIqWxmf4O5oG@google.com>
	<0621bf8e-06f2-70f2-6d2b-f311c5a4ffce@arm.com>
In-Reply-To: <0621bf8e-06f2-70f2-6d2b-f311c5a4ffce@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Morse <james.morse@arm.com>
Cc: Oliver Upton <oliver.upton@linux.dev>, linux-pm@vger.kernel.org, loongarch@lists.linux.dev, kvmarm@lists.linux.dev, kvm@vger.kernel.org, linux-acpi@vger.kernel.org, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Lorenzo Pieralisi <lpieralisi@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Sudeep Holla <sudeep.holla@arm.com>, Borislav Petkov <bp@alien8.de>, H Peter Anvin <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Huacai Chen <chenhuacai@kernel.org>, Suzuki K Poulose <suzuki.poulose@arm.com>, Len Brown <lenb@kernel.org>, Rafael Wysocki <rafael@kernel.org>, WANG Xuerui <kernel@xen0n.name>, Salil Mehta <salil.mehta@huawei.com>, Russell King <linux@armlinux.org.uk>, Jean-Philippe Brucker <jean-philippe@linaro.org>

On Tue, 07 Feb 2023 17:50:59 +0000,
James Morse <james.morse@arm.com> wrote:
> 
> Hi Oliver,
> 
> On 03/02/2023 21:08, Oliver Upton wrote:
> > On Fri, Feb 03, 2023 at 01:50:40PM +0000, James Morse wrote:
> >> From: Jean-Philippe Brucker <jean-philippe@linaro.org>
> >>
> >> When capability KVM_CAP_ARM_HVC_TO_USER is available, userspace can
> >> request to handle all hypercalls that aren't handled by KVM.
> 
> > I would very much prefer we not go down this route. This capability
> > effectively constructs an ABI out of what KVM presently does not
> > implement. What would happen if KVM decides to implement a new set
> > of hypercalls later down the road that were previously forwarded to
> > userspace?
> 
> The user-space support would never get called. If we have a
> wild-west allocation of IDs in this area we have bigger
> problems. I'd hope in this example it would be a VMM or an in-kernel
> implementation of the same feature.
> 
> When I floated something like this before for supporting SDEI in
> guests, Christoffer didn't like tie-ing KVM to SMC-CC - hence the
> all or nothing.
> 
> Since then we've had things like Spectre, which I don't think the
> VMM should ever be allowed to handle, which makes the whole thing
> much murkier.

That ship has sailed a long time ago. We also have grown a bunch of
in-kernel SMCCC services that are KVM specific (the silly PTP stuff,
for example, not to mention all the pKVM hypercalls...).

It is also likely that these ranges will grow over time (it has been a
long time since the last drop of Spectre-like crap, and something must
be brewing somewhere), so a level of discrimination is important.

	M.

-- 
Without deviation from the norm, progress is not possible.
