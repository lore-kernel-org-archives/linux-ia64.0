From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Tue, 21 Sep 2004 08:52:22 +0000
Subject: [PATCH] PCI IRQ resource deallocation support [0/3]
Message-Id: <414FEBC6.4030901@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@osdl.org, greg@kroah.com, len.brown@intel.com, tony.luck@intel.com, linux-kernel@vger.kernel.org, acpi-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org

Hi,

Architecture dependent IRQ resources such as interrupt vector for PCI
devices are allocated at pci_enable_device() time on i386, x86-64 and
ia64 platform. Today, however, these IRQ resources are never
deallocated even if they are no longer used. The following set of
patches adds supports to deallocate IRQ resources at
pci_disable_device() time.

The motivation of the set of patches is as follows:

    - IRQ resources such as interrupt vectors should be freed if they
      are no longer used because the amount of these resources are
      limited. By deallocating IRQ resources, we can recycle them.

    - I think some hardwares will support hot-pluggable I/O units with
      I/O xAPICs in the near future. So I/O xAPIC hot-plug support by
      OS will be needed soon. IRQ resouces deallocation will be one of
      the most important stuff for I/O xAPIC hot-plug.

To realize IRQ resource deallocation, the following set of patches
defines new interfaces:

    - void pcibios_disable_device (struct pci_dev *dev)

      This is a opposite portion of pcibios_enable_device(). It's a
      hook to call architecture specific code for deallocating PCI
      resources.
      
    - void acpi_unregister_gsi (int irq)

      This is a opposite portion of acpi_register_gsi(). This has a
      responsibility for deallocating IRQ resources associated with
      the specified linux IRQ number. 

For details of these interfaces, please see the description in each
patch.

The set of patches containes the following patches:

    - add_pcibios_disable_device_hook.patch

      This patch defines new a interface pcibios_disable_device(). It
      has already been posted to LKML before. Please see:
      http://marc.theaimsgroup.com/?l=linux-kernel&m9533945101033&w=2

    - IRQ_deallocation_acpi.patch

      This is a acpi portion of IRQ resource deallocation. It defines
      a new interface acpi_unregister_gsi().

    - IRQ_deallocation_ia64.patch

      This is a ia64 portion of IRQ resource deallocation. It
      implements pcibios_disable_device() and acpi_unregister_gsi()
      for ia64.

For now, the following set of patches has ia64 implementation only.
i386 and x86_64 implementations are TBD.

Thanks,
Kenji Kaneshige

