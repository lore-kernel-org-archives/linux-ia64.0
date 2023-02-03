From: Oliver Upton <oliver.upton@linux.dev>
Date: Fri, 03 Feb 2023 21:08:00 +0000
Subject: Re: [RFC PATCH 29/32] KVM: arm64: Pass hypercalls to userspace
Message-Id: <Y913sIqWxmf4O5oG@google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230203135043.409192-1-james.morse@arm.com>
 <20230203135043.409192-30-james.morse@arm.com>
In-Reply-To: <20230203135043.409192-30-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Morse <james.morse@arm.com>
Cc: linux-pm@vger.kernel.org, loongarch@lists.linux.dev, kvmarm@lists.linux.dev, kvm@vger.kernel.org, linux-acpi@vger.kernel.org, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, Marc Zyngier <maz@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Lorenzo Pieralisi <lpieralisi@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Sudeep Holla <sudeep.holla@arm.com>, Borislav Petkov <bp@alien8.de>, H Peter Anvin <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Huacai Chen <chenhuacai@kernel.org>, Suzuki K Poulose <suzuki.poulose@arm.com>, Len Brown <lenb@kernel.org>, Rafael Wysocki <rafael@kernel.org>, WANG Xuerui <kernel@xen0n.name>, Salil Mehta <salil.mehta@huawei.com>, Russell King <linux@armlinux.org.uk>, Jean-Philippe Brucker <jean-philippe@linaro.org>

Hi James,

On Fri, Feb 03, 2023 at 01:50:40PM +0000, James Morse wrote:
> From: Jean-Philippe Brucker <jean-philippe@linaro.org>
> 
> When capability KVM_CAP_ARM_HVC_TO_USER is available, userspace can
> request to handle all hypercalls that aren't handled by KVM.

I would very much prefer we not go down this route. This capability
effectively constructs an ABI out of what KVM presently does not
implement. What would happen if KVM decides to implement a new set
of hypercalls later down the road that were previously forwarded to
userspace?

Instead of a catch-all I think we should take the approach of having
userspace explicitly request which hypercalls should be forwarded to
userspace. I proposed something similar [1], but never got around to
respinning it (oops).

Let me dust those patches off and align with Marc's suggestions.

[1]: https://lore.kernel.org/kvmarm/20221110015327.3389351-1-oliver.upton@linux.dev/

--
Thanks,
Oliver
