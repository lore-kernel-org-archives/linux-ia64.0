From: Yijing Wang <wangyijing@huawei.com>
Date: Thu, 23 Oct 2014 07:45:32 +0000
Subject: Re: [PATCH v3 00/27] Use MSI chip framework to configure MSI/MSI-X in all platforms
Message-Id: <5448B21C.1020906@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1413342435-7876-1-git-send-email-wangyijing@huawei.com> <20141023054326.GF4795@google.com>
In-Reply-To: <20141023054326.GF4795@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, linux-arch@vger.kernel.org, arnab.basu@freescale.com, Bharat.Bhushan@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Ralf Baechle <ralf@linux-mips.org>, Lucas Stach <l.stach@pengutronix.de>, David Vrabel <david.vrabel@citrix.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Michael Ellerman <mpe@ellerman.id.au>, Thierry Reding <thierry.reding@gmail.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Liviu Dudau <liviu@dudau.co.uk>

>> v1->v2:
>> Add a patch to make s390 MSI code build happy between patch "x86/xen/MSI: E.."
>> and "s390/MSI: Use MSI..". Fix several typo problems found by Lucas.
>>
>> RFC->v1: 
>> Updated "[patch 4/21] x86/xen/MSI: Eliminate...", export msi_chip instead
>> of #ifdef to fix MSI bug in xen running in x86. 
>> Rename arch_get_match_msi_chip() to arch_find_msi_chip().
>> Drop use struct device as the msi_chip argument, we will do that
>> later in another patchset.
>>
>> Yijing Wang (27):
> 
> This is a lot of stuff, and it's not all related, so putting it all
> together in one series makes it hard for me to deal with it.
> 
>>   MSI: Remove the redundant irq_set_chip_data()

OK, will post it out separately.

> 
> This doesn't seem related to eliminating weak functions.
> 
>>   x86/xen/MSI: Eliminate arch_msix_mask_irq() and arch_msi_mask_irq()
>>   s390/MSI: Use __msi_mask_irq() instead of default_msi_mask_irq()

Will update your comments and post these together.

> 
> These two seem to go together.
> 
>>   arm/MSI: Save MSI chip in pci_sys_data
>>   PCI: tegra: Save msi chip in pci_sys_data
>>   PCI: designware: Save msi chip in pci_sys_data
>>   PCI: rcar: Save msi chip in pci_sys_data
>>   PCI: mvebu: Save msi chip in pci_sys_data
>>   arm/PCI: Clean unused pcibios_add_bus() and pcibios_remove_bus()
>>   PCI/MSI: Remove useless bus->msi assignment
> 
> These seem to go together (it'd be nice if they were all capitalized the
> same).

OK, will update the titles and post together.

> 
> I don't like the "msi_chip" name because the "chip" part doesn't convey
> much information, other than telling us that apparently some sort of
> semiconductor integrated circuit is involved.  I sort of assumed that
> much :)

I think so, msi_chip easily make me confuse with x86 irq_chip msi_chip.

> 
> Something like "msi_controller" would be more descriptive since we're
> talking about an interrupt controller that accepts writes from a device and
> turns them into CPU interrupts, e.g., a LAPIC.

Hm, it's a better one, arm also use "msi-controller" to represent the msi related
object in DTS file.


> 
>>   PCI/MSI: Refactor struct msi_chip to make it become more common
>>   x86/MSI: Use MSI chip framework to configure MSI/MSI-X irq
>>   x86/xen/MSI: Use MSI chip framework to configure MSI/MSI-X irq
>>   Irq_remapping/MSI: Use MSI chip framework to configure MSI/MSI-X irq
>>   x86/MSI: Remove unused MSI weak arch functions
>>   Mips/MSI: Save msi chip in pci sysdata
>>   MIPS/Octeon/MSI: Use MSI chip framework to configure MSI/MSI-X irq
>>   MIPS/Xlp: Remove the dead function destroy_irq() to fix build error
>>   MIPS/Xlp/MSI: Use MSI chip framework to configure MSI/MSI-X irq
>>   MIPS/Xlr/MSI: Use MSI chip framework to configure MSI/MSI-X irq
>>   Powerpc/MSI: Use MSI chip framework to configure MSI/MSI-X irq
>>   s390/MSI: Use MSI chip framework to configure MSI/MSI-X irq
>>   arm/iop13xx/MSI: Use MSI chip framework to configure MSI/MSI-X irq
>>   IA64/MSI: Use MSI chip framework to configure MSI/MSI-X irq
>>   Sparc/MSI: Use MSI chip framework to configure MSI/MSI-X irq
>>   tile/MSI: Use MSI chip framework to configure MSI/MSI-X irq
>>   PCI/MSI: Clean up unused MSI arch functions
>>
>>  arch/arm/include/asm/mach/pci.h                 |   10 +-
>>  arch/arm/include/asm/pci.h                      |    9 ++
>>  arch/arm/kernel/bios32.c                        |   19 +---
>>  arch/arm/mach-iop13xx/include/mach/pci.h        |    4 +
>>  arch/arm/mach-iop13xx/iq81340mc.c               |    3 +
>>  arch/arm/mach-iop13xx/iq81340sc.c               |    5 +-
>>  arch/arm/mach-iop13xx/msi.c                     |   11 ++-
>>  arch/ia64/include/asm/pci.h                     |   10 ++
>>  arch/ia64/kernel/msi_ia64.c                     |   14 ++-
>>  arch/ia64/pci/pci.c                             |    1 +
>>  arch/mips/include/asm/netlogic/xlp-hal/pcibus.h |    1 +
>>  arch/mips/include/asm/octeon/pci-octeon.h       |    4 +
>>  arch/mips/include/asm/pci.h                     |   14 +++
>>  arch/mips/pci/msi-octeon.c                      |   31 +++---
>>  arch/mips/pci/msi-xlp.c                         |   15 ++-
>>  arch/mips/pci/pci-octeon.c                      |    3 +
>>  arch/mips/pci/pci-xlp.c                         |    3 +
>>  arch/mips/pci/pci-xlr.c                         |   17 +++-
>>  arch/powerpc/include/asm/pci-bridge.h           |   15 +++
>>  arch/powerpc/kernel/msi.c                       |   12 ++-
>>  arch/powerpc/kernel/pci-common.c                |    3 +
>>  arch/s390/include/asm/pci.h                     |    9 ++
>>  arch/s390/pci/pci.c                             |   16 ++-
>>  arch/sparc/kernel/pci.c                         |   14 ++-
>>  arch/sparc/kernel/pci_impl.h                    |   12 ++
>>  arch/tile/include/asm/pci.h                     |   10 ++
>>  arch/tile/kernel/pci_gx.c                       |   13 ++-
>>  arch/x86/include/asm/pci.h                      |   18 +++-
>>  arch/x86/include/asm/x86_init.h                 |    7 --
>>  arch/x86/kernel/apic/io_apic.c                  |   12 ++-
>>  arch/x86/kernel/x86_init.c                      |   34 ------
>>  arch/x86/pci/acpi.c                             |    1 +
>>  arch/x86/pci/common.c                           |    3 +
>>  arch/x86/pci/xen.c                              |   72 +++++++------
>>  drivers/iommu/irq_remapping.c                   |   13 ++-
>>  drivers/pci/host/pci-mvebu.c                    |   10 +--
>>  drivers/pci/host/pci-tegra.c                    |   13 +--
>>  drivers/pci/host/pcie-designware.c              |   15 +--
>>  drivers/pci/host/pcie-rcar.c                    |   13 +--
>>  drivers/pci/msi.c                               |  133 ++++++++++-------------
>>  drivers/pci/probe.c                             |    1 -
>>  include/linux/msi.h                             |   24 ++---
>>  include/linux/pci.h                             |    1 +
>>  43 files changed, 379 insertions(+), 269 deletions(-)
> 
> Huh.  I was hoping this was going to simplify things, and maybe it does
> somehow, but it's unfortunate that it adds 110 lines of code overall.  Does
> that seem right to you?  Why does it add code?

I filter out these patches which add code.

[PATCH v3 04/27] arm/MSI: Save MSI chip in pci_sys_data
 5 files changed, 33 insertions(+), 0 deletions(-)
Insertions code mainly to introduce arch specific pci_msi_chip() to extract msi_chip from pci_sys_data, and temporary #ifdef

[PATCH v3 11/27] PCI/MSI: Refactor struct msi_chip to make it become more common
 2 files changed, 19 insertions(+), 0 deletions(-)
Insertions here is to add msi ops like restore, teardown to msi_chip.

[PATCH v3 12/27] x86/MSI: Use MSI chip framework to configure MSI/MSI-X irq
 4 files changed, 36 insertions(+), 0 deletions(-)
Arch specific pci_msi_chip() and declaration of msi_chip in x86, also some temporary code to compile ok.

[PATCH v3 13/27] x86/xen/MSI: Use MSI chip framework to configure MSI/MSI-X irq
 1 files changed, 39 insertions(+), 19 deletions(-)
To avoid call default_teardown_msi_irq(), copy the default_teardown_msi_irq() code in this file.

[PATCH v3 16/27] Mips/MSI: Save msi chip in pci sysdata
 1 files changed, 14 insertions(+), 0 deletions(-)
Arch specific pci_msi_chip() and some #ifdef code

[PATCH v3 17/27] MIPS/Octeon/MSI: Use MSI chip framework to configure MSI/MSI-X irq
 3 files changed, 25 insertions(+), 13 deletions(-)

Archs Use msi chip framework to configure MSI/MSI-x
 3 files changed, 13 insertions(+), 2 deletions(-)
 1 files changed, 15 insertions(+), 2 deletions(-)
 3 files changed, 28 insertions(+), 2 deletions(-)
 2 files changed, 19 insertions(+), 2 deletions(-)
 4 files changed, 20 insertions(+), 3 deletions(-)
 3 files changed, 21 insertions(+), 4 deletions(-)
 2 files changed, 24 insertions(+), 2 deletions(-)
 2 files changed, 21 insertions(+), 2 deletions(-)

So the most adding code is to introduce arch specific pci_msi_chip(), this one will be removed after we make
pci_host_bridge generic and save msi_chip in it. There are also lots of #ifdef in arm code for msi_chip.

> 
> Who do you want to apply this?  I can take it if that makes the most sense,

I hope you can apply this.

> but I'd like acks from the architecture folks for their pieces, and
> especially one from Thomas for the overall direction and the x86 parts.

OK.

> 
> If you want me to take this, can you refresh it to be based on v3.18-rc1?
> I tried to apply it on v3.18-rc1, but [15/27] didn't apply because of
> conflicts in arch/x86/kernel/apic/io_apic.c.

OK.

> 
> I'll look at these more tomorrow, I'm getting bleary-eyed tonight.

Thanks for your review and comments very much!

Thanks!
Yijing.

> 
> Bjorn
> 
> .
> 


-- 
Thanks!
Yijing

