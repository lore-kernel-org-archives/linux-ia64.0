From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Mon, 04 Oct 2004 10:17:35 +0000
Subject: take2: [Patch 1/3] Updated patches for PCI IRQ deallocation support
Message-Id: <4161233F.8010607@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg KH <greg@kroah.com>
Cc: Andrew Morton <akpm@osdl.org>, Len Brown <len.brown@intel.com>, "Luck, Tony" <tony.luck@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, acpi-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org

Greg,

This is a patch for PCI code that has no dependencies.
Please note that this patch has been already included in 2.6.9-rc3-mm1.

Please apply.

Thanks,
Kenji Kaneshige

----
Name:		add_pcibios_disable_device_hook.patch
Kernel Version:	2.6.9-rc3
Depends:	none
Note:		This patch is already included in 2.6.9-rc3-mm1.
Change Log:

    - Ported to 2.6.9-rc3

    - Chaged to use __attrubute__ ((weak)) instead of modifying all
      arch specific code.

Description:

This patch adds a hook 'pcibios_disable_device()' into
pci_disable_device() to call architecture specific PCI resource
deallocation code. It's a opposite part of pcibios_enable_device().
We need this hook to deallocate architecture specific PCI resource
such as IRQ resource, etc.. This patch is just for adding the hook, so
'pcibios_disable_device()' is defined as a null function on all
architecture so far.

I tested this patch on i386, x86_64 and ia64. But it has not been
tested on other architectures because I don't have these machines.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

---

 linux-2.6.9-rc3-kanesige/drivers/pci/pci.c |   12 ++++++++++++
 1 files changed, 12 insertions(+)

diff -puN drivers/pci/pci.c~add_pcibios_disable_device_hook drivers/pci/pci.c
--- linux-2.6.9-rc3/drivers/pci/pci.c~add_pcibios_disable_device_hook	2004-10-04 17:01:59.329143129 +0900
+++ linux-2.6.9-rc3-kanesige/drivers/pci/pci.c	2004-10-04 17:01:59.332072838 +0900
@@ -387,6 +387,16 @@ pci_enable_device(struct pci_dev *dev)
 }
 
 /**
+ * pcibios_disable_device - disable arch specific PCI resources for device dev
+ * @dev: the PCI device to disable
+ *
+ * Disables architecture specific PCI resources for the device. This
+ * is the default implementation. Architecture implementations can
+ * override this.
+ */
+void __attribute__ ((weak)) pcibios_disable_device (struct pci_dev *dev) {}
+
+/**
  * pci_disable_device - Disable PCI device after use
  * @dev: PCI device to be disabled
  *
@@ -406,6 +416,8 @@ pci_disable_device(struct pci_dev *dev)
 		pci_command &= ~PCI_COMMAND_MASTER;
 		pci_write_config_word(dev, PCI_COMMAND, pci_command);
 	}
+
+	pcibios_disable_device(dev);
 }
 
 /**

_

