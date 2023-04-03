From: Gavin Shan <gshan@redhat.com>
Date: Mon, 03 Apr 2023 06:25:36 +0000
Subject: Re: [RFC PATCH 00/32] ACPI/arm64: add support for virtual cpuhotplug
Message-Id: <972ed7df-78cd-e02a-7376-78c806181b5f@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230203135043.409192-1-james.morse@arm.com>
 <e17627fb-283e-dd42-94c1-f89dea167577@redhat.com>
In-Reply-To: <e17627fb-283e-dd42-94c1-f89dea167577@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Shaoqin Huang <shahuang@redhat.com>, James Morse <james.morse@arm.com>, linux-pm@vger.kernel.org, loongarch@lists.linux.dev, kvmarm@lists.linux.dev, kvm@vger.kernel.org, linux-acpi@vger.kernel.org, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org
Cc: Marc Zyngier <maz@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Lorenzo Pieralisi <lpieralisi@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Sudeep Holla <sudeep.holla@arm.com>, Borislav Petkov <bp@alien8.de>, H Peter Anvin <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Huacai Chen <chenhuacai@kernel.org>, Suzuki K Poulose <suzuki.poulose@arm.com>, Oliver Upton <oliver.upton@linux.dev>, Len Brown <lenb@kernel.org>, Rafael Wysocki <rafael@kernel.org>, WANG Xuerui <kernel@xen0n.name>, Salil Mehta <salil.mehta@huawei.com>, Russell King <linux@armlinux.org.uk>, Jean-Philippe Brucker <jean-philippe@linaro.org>

Hi Shaoqin,

On 3/29/23 1:52 PM, Shaoqin Huang wrote:
> On 2/3/23 21:50, James Morse wrote:

[...]

>>
>> The first patch has already been posted as a fix here:
>> https://www.spinics.net/lists/linux-ia64/msg21920.html
>> I've only build tested Loongarch and ia64.
>>
>>
>> If folk want to play along at home, you'll need a copy of Qemu that supports this.
>> https://github.com/salil-mehta/qemu.git salil/virt-cpuhp-armv8/rfc-v1-port29092022.psci.present
>>
>> You'll need to fix the numbers of KVM_CAP_ARM_HVC_TO_USER and KVM_CAP_ARM_PSCI_TO_USER
>> to match your host kernel. Replace your '-smp' argument with something like:
>> | -smp cpus=1,maxcpus=3,cores=3,threads=1,sockets=1
>>
>> then feed the following to the Qemu montior;
>> | (qemu) device_add driver=host-arm-cpu,core-id=1,id=cpu1
>> | (qemu) device_del cpu1
>>
>>
>> This series is based on v6.2-rc3, and can be retrieved from:
>> https://git.kernel.org/pub/scm/linux/kernel/git/morse/linux.git/ virtual_cpu_hotplug/rfc/v1
> 
> I applied this patch series on v6.2-rc3 and using the QEMU cloned from the salil-mehta/qemu.git repo. But when I try to run the QEMU, it shows:
> 
> $ qemu-system-aarch64: -accel kvm: Failed to enable KVM_CAP_ARM_PSCI_TO_USER cap.
> 
> Here is the command I use:
> 
> $ qemu-system-aarch64
> -machine virt
> -bios /usr/share/qemu-efi-aarch64/QEMU_EFI.fd
> -accel kvm
> -m 4096
> -smp cpus=1,maxcpus=3,cores=3,threads=1,sockets=1
> -cpu host
> -qmp unix:./src.socket,server,nowait
> -hda ./XXX.qcow2
> -serial unix:./src.serial,server,nowait
> -monitor stdio
> 
> It seems something related to your notice: You'll need to fix the numbers of KVM_CAP_ARM_HVC_TO_USER and KVM_CAP_ARM_PSCI_TO_USER
> to match your host kernel.
> 
> But I'm not actually understand what should I fix, since I haven't review the patch series. Could you give me some more information? Maybe I'm doing something wrong.
> 

When the kernel is rebased to v6.2.rc3, the two capabilities are conflictsing
between QEMU and host kernel. Please adjust them like below and have a try:

In qemu/linux-headers/linux/kvm.h

#define KVM_CAP_ARM_HVC_TO_USER 250 /* TODO: as per linux 6.1-rc2 */
#define KVM_CAP_ARM_PSCI_TO_USER 251 /* TODO: as per linux 6.1-rc2 */

In linux/include/uapi/linux/kvm.h

#define KVM_CAP_ARM_HVC_TO_USER 250
#define KVM_CAP_ARM_PSCI_TO_USER 251

Thanks,
Gavin

