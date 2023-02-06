From: Suzuki K Poulose <suzuki.poulose@arm.com>
Date: Mon, 06 Feb 2023 10:10:41 +0000
Subject: Re: [RFC PATCH 29/32] KVM: arm64: Pass hypercalls to userspace
Message-Id: <cffde8a1-74e4-9b61-1eea-544ba3405ed4@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230203135043.409192-1-james.morse@arm.com>
 <20230203135043.409192-30-james.morse@arm.com> <865ycg1kv2.wl-maz@kernel.org>
In-Reply-To: <865ycg1kv2.wl-maz@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Marc Zyngier <maz@kernel.org>, James Morse <james.morse@arm.com>
Cc: linux-pm@vger.kernel.org, loongarch@lists.linux.dev, kvmarm@lists.linux.dev, kvm@vger.kernel.org, linux-acpi@vger.kernel.org, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Lorenzo Pieralisi <lpieralisi@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Sudeep Holla <sudeep.holla@arm.com>, Borislav Petkov <bp@alien8.de>, H Peter Anvin <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Huacai Chen <chenhuacai@kernel.org>, Oliver Upton <oliver.upton@linux.dev>, Len Brown <lenb@kernel.org>, Rafael Wysocki <rafael@kernel.org>, WANG Xuerui <kernel@xen0n.name>, Salil Mehta <salil.mehta@huawei.com>, Russell King <linux@armlinux.org.uk>, Jean-Philippe Brucker <jean-philippe@linaro.org>

Hi,

A few cents from the Realm support point of view.

On 05/02/2023 10:12, Marc Zyngier wrote:
> On Fri, 03 Feb 2023 13:50:40 +0000,
> James Morse <james.morse@arm.com> wrote:
>>
>> From: Jean-Philippe Brucker <jean-philippe@linaro.org>
>>
>> When capability KVM_CAP_ARM_HVC_TO_USER is available, userspace can
>> request to handle all hypercalls that aren't handled by KVM. With the
>> help of another capability, this will allow userspace to handle PSCI
>> calls.
>>
>> Suggested-by: James Morse <james.morse@arm.com>
>> Signed-off-by: Jean-Philippe Brucker <jean-philippe@linaro.org>
>> Signed-off-by: James Morse <james.morse@arm.com>
>>
>> ---
>>
> 
> On top of Oliver's ask not to make this a blanket "steal everything",
> but instead to have an actual request for ranges of forwarded
> hypercalls:
> 
>> Notes on this implementation:
>>
>> * A similar mechanism was proposed for SDEI some time ago [1]. This RFC
>>    generalizes the idea to all hypercalls, since that was suggested on
>>    the list [2, 3].
>>
>> * We're reusing kvm_run.hypercall. I copied x0-x5 into
>>    kvm_run.hypercall.args[] to help userspace but I'm tempted to remove
>>    this, because:
>>    - Most user handlers will need to write results back into the
>>      registers (x0-x3 for SMCCC), so if we keep this shortcut we should
>>      go all the way and read them back on return to kernel.
>>    - QEMU doesn't care about this shortcut, it pulls all vcpu regs before
>>      handling the call.

This may not be always possible, e.g., for Realms. GET_ONE_REG is
not supported. So using an explicit passing down of the args is
preferrable.

Thanks
Suzuki
