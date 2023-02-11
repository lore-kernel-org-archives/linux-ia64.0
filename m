From: Oliver Upton <oliver.upton@linux.dev>
Date: Sat, 11 Feb 2023 01:44:59 +0000
Subject: Re: [RFC PATCH 29/32] KVM: arm64: Pass hypercalls to userspace
Message-Id: <Y+bzG6JH5gY9afNW@linux.dev>
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
Cc: Marc Zyngier <maz@kernel.org>, linux-pm@vger.kernel.org, loongarch@lists.linux.dev, kvmarm@lists.linux.dev, kvm@vger.kernel.org, linux-acpi@vger.kernel.org, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Lorenzo Pieralisi <lpieralisi@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Sudeep Holla <sudeep.holla@arm.com>, Borislav Petkov <bp@alien8.de>, H Peter Anvin <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Huacai Chen <chenhuacai@kernel.org>, Suzuki K Poulose <suzuki.poulose@arm.com>, Len Brown <lenb@kernel.org>, Rafael Wysocki <rafael@kernel.org>, WANG Xuerui <kernel@xen0n.name>, Salil Mehta <salil.mehta@huawei.com>, Russell King <linux@armlinux.org.uk>, Jean-Philippe Brucker <jean-philippe@linaro.org>

Hey James,

On Tue, Feb 07, 2023 at 05:50:58PM +0000, James Morse wrote:

[...]

> > As mentioned above, I think this interface should go both ways.
> > Userspace should request the forwarding of a certain range of
> > hypercalls via a similar SET_ATTR interface.
> 
> Yup, I'll sync up with Oliver about that.

Sorry, I was tied up with some unrelated stuff at work this week. I
polished up what I had and sent out an RFC v2 for SMCCC filtering [1].
Mentioning it here because my email service gives up if I Cc too many
recipients so I didn't include everyone on this series.

[1]: https://lore.kernel.org/linux-arm-kernel/20230211013759.3556016-1-oliver.upton@linux.dev/

-- 
Thanks,
Oliver
