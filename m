From: Gavin Shan <gshan@redhat.com>
Date: Wed, 29 Mar 2023 02:35:17 +0000
Subject: Re: [RFC PATCH 00/32] ACPI/arm64: add support for virtual cpuhotplug
Message-Id: <41dd71ab-a6a7-fd93-73ec-64a6b0ca468e@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230203135043.409192-1-james.morse@arm.com>
In-Reply-To: <20230203135043.409192-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Morse <james.morse@arm.com>, linux-pm@vger.kernel.org, loongarch@lists.linux.dev, kvmarm@lists.linux.dev, kvm@vger.kernel.org, linux-acpi@vger.kernel.org, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org
Cc: Marc Zyngier <maz@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Lorenzo Pieralisi <lpieralisi@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Sudeep Holla <sudeep.holla@arm.com>, Borislav Petkov <bp@alien8.de>, H Peter Anvin <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Huacai Chen <chenhuacai@kernel.org>, Suzuki K Poulose <suzuki.poulose@arm.com>, Oliver Upton <oliver.upton@linux.dev>, Len Brown <lenb@kernel.org>, Rafael Wysocki <rafael@kernel.org>, WANG Xuerui <kernel@xen0n.name>, Salil Mehta <salil.mehta@huawei.com>, Russell King <linux@armlinux.org.uk>, Jean-Philippe Brucker <jean-philippe@linaro.org>

Hi James,

On 2/3/23 9:50 PM, James Morse wrote:

[...]

> 
> 
> The first patch has already been posted as a fix here:
> https://www.spinics.net/lists/linux-ia64/msg21920.html
> I've only build tested Loongarch and ia64.
> 

It has been merged to upstream.

> 
> If folk want to play along at home, you'll need a copy of Qemu that supports this.
> https://github.com/salil-mehta/qemu.git salil/virt-cpuhp-armv8/rfc-v1-port29092022.psci.present
> 
> You'll need to fix the numbers of KVM_CAP_ARM_HVC_TO_USER and KVM_CAP_ARM_PSCI_TO_USER
> to match your host kernel. Replace your '-smp' argument with something like:
> | -smp cpus=1,maxcpus=3,cores=3,threads=1,sockets=1
> 
> then feed the following to the Qemu montior;
> | (qemu) device_add driver=host-arm-cpu,core-id=1,id=cpu1
> | (qemu) device_del cpu1
> 
> 
> This series is based on v6.2-rc3, and can be retrieved from:
> https://git.kernel.org/pub/scm/linux/kernel/git/morse/linux.git/ virtual_cpu_hotplug/rfc/v1
> 

I give it a try, but the hot-added CPU needs to be put into online
state manually. I'm not sure if it's expected or not.

     /home/gavin/sandbox/qemu.main/build/qemu-system-aarch64                \
     -accel kvm,dirty-ring-sizee536                                       \
     -machine virt,gic-version=host,nvdimm=on                               \
     -cpu host -smp maxcpus=8,cpus=1,sockets=1,clusters=1,cores=8,threads=1 \
     -m 1024M,slots,maxmemdG                                           \
     -object memory-backend-ram,id=mem0,size24M                          \
     -numa node,nodeid=0,memdev=mem0                                        \
     -L /home/gavin/sandbox/qemu.main/build/pc-bios                         \
     -monitor none -serial mon:stdio -nographic -gdb tcp::1234              \
     -bios /home/gavin/sandbox/qemu.main/build/pc-bios/edk2-aarch64-code.fd \
     -kernel /home/gavin/sandbox/linux.guest/arch/arm64/boot/Image          \
     -initrd /home/gavin/sandbox/images/rootfs.cpio.xz                      \
     -append memhp_default_state=online_movable                             \
        :
        :
     guest# cat /proc/cpuinfo | grep "CPU implementer" | wc -l
     1
     (qemu) device_add driver=host-arm-cpu,core-id=1,id=cpu1
     guest# cat /proc/cpuinfo | grep "CPU implementer" | wc -l
     1
     guest# echo 1 > /sys/devices/system/cpu/cpu1/online
     guest# cat /proc/cpuinfo | grep "CPU implementer" | wc -l
     2
     (qemu) device_del cpu1
     guest# cat /proc/cpuinfo | grep "CPU implementer" | wc -l
     1

Note that the QEMU binary is directly built from Salil's repository and
the kernel image is built from v6.3-rc4, plus this patchset excluding the
first patch since it has been merged.

Thanks,
Gavin



