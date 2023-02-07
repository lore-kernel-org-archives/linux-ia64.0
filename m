From: Suzuki K Poulose <suzuki.poulose@arm.com>
Date: Tue, 07 Feb 2023 09:41:54 +0000
Subject: Re: [RFC PATCH 29/32] KVM: arm64: Pass hypercalls to userspace
Message-Id: <985abd9c-b3f9-3f9d-eec7-df1f26733762@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230203135043.409192-1-james.morse@arm.com>
 <20230203135043.409192-30-james.morse@arm.com> <865ycg1kv2.wl-maz@kernel.org>
 <cffde8a1-74e4-9b61-1eea-544ba3405ed4@arm.com> <86wn4vynyr.wl-maz@kernel.org>
In-Reply-To: <86wn4vynyr.wl-maz@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Marc Zyngier <maz@kernel.org>
Cc: James Morse <james.morse@arm.com>, linux-pm@vger.kernel.org, loongarch@lists.linux.dev, kvmarm@lists.linux.dev, kvm@vger.kernel.org, linux-acpi@vger.kernel.org, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Lorenzo Pieralisi <lpieralisi@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Sudeep Holla <sudeep.holla@arm.com>, Borislav Petkov <bp@alien8.de>, H Peter Anvin <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Huacai Chen <chenhuacai@kernel.org>, Oliver Upton <oliver.upton@linux.dev>, Len Brown <lenb@kernel.org>, Rafael Wysocki <rafael@kernel.org>, WANG Xuerui <kernel@xen0n.name>, Salil Mehta <salil.mehta@huawei.com>, Russell King <linux@armlinux.org.uk>, Jean-Philippe Brucker <jean-philippe@linaro.org>

Hi Marc,

On 06/02/2023 12:31, Marc Zyngier wrote:
> On Mon, 06 Feb 2023 10:10:41 +0000,
> Suzuki K Poulose <suzuki.poulose@arm.com> wrote:
>>
>> Hi,
>>
>> A few cents from the Realm support point of view.
>>
>> On 05/02/2023 10:12, Marc Zyngier wrote:
>>> On Fri, 03 Feb 2023 13:50:40 +0000,
>>> James Morse <james.morse@arm.com> wrote:
>>>>
>>>> From: Jean-Philippe Brucker <jean-philippe@linaro.org>
>>>>
>>>> When capability KVM_CAP_ARM_HVC_TO_USER is available, userspace can
>>>> request to handle all hypercalls that aren't handled by KVM. With the
>>>> help of another capability, this will allow userspace to handle PSCI
>>>> calls.
>>>>
>>>> Suggested-by: James Morse <james.morse@arm.com>
>>>> Signed-off-by: Jean-Philippe Brucker <jean-philippe@linaro.org>
>>>> Signed-off-by: James Morse <james.morse@arm.com>
>>>>
>>>> ---
>>>>
>>>
>>> On top of Oliver's ask not to make this a blanket "steal everything",
>>> but instead to have an actual request for ranges of forwarded
>>> hypercalls:
>>>
>>>> Notes on this implementation:
>>>>
>>>> * A similar mechanism was proposed for SDEI some time ago [1]. This RFC
>>>>     generalizes the idea to all hypercalls, since that was suggested on
>>>>     the list [2, 3].
>>>>
>>>> * We're reusing kvm_run.hypercall. I copied x0-x5 into
>>>>     kvm_run.hypercall.args[] to help userspace but I'm tempted to remove
>>>>     this, because:
>>>>     - Most user handlers will need to write results back into the
>>>>       registers (x0-x3 for SMCCC), so if we keep this shortcut we should
>>>>       go all the way and read them back on return to kernel.
>>>>     - QEMU doesn't care about this shortcut, it pulls all vcpu regs before
>>>>       handling the call.
>>
>> This may not be always possible, e.g., for Realms. GET_ONE_REG is
>> not supported. So using an explicit passing down of the args is
>> preferrable.
> 
> What is the blocker for CCA to use GET_ONE_REG? The value obviously
> exists and is made available to the host. pKVM is perfectly able to
> use GET_ONE_REG and gets a bunch of zeroes for things that the
> hypervisor has decided to hide from the host.
> 

It is not impossible. On a "HOST CALL" (explicit calls to the Host from
Realm), the GPRs are made available to the host and can be stashed into 
the vcpu reg state and the request can be serviced. However, it is a bit
odd, to make this exception - "the GET_ONE_REG is valid now", while in 
almost all other cases it is invalid (exception of MMIO).

Of course we could always return what is stashed in the vcpu state,
which is may be invalid/ 0. But given the construct of "host doesn't
have access to the register state", it may be a good idea to say, 
request always fails, to indicate that the Host is probably doing 
something wrong, than silently passing on incorrect information.


> Of course, it requires that the hypervisor (the RMM in your case)
> knows about the semantics of the hypercall, but that's obviously

RMM doesn't care about the semantics of hypercall, other than
considering it just like an SMCCC compliant call. The hypercall
arguments/results are passed down/up by the Realm in a separate structure.

> already a requirement (or you wouldn't be able to use PSCI at all).

Realm PSCI calls are always serviced by the RMM. RMM may request
the Hyp for specific information in certain cases, but that doesn't
need to go down to the VMM.

Thanks
Suzuki


> 
> Thanks,
> 
> 	M.
> 
