From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 27 Nov 2001 00:25:14 +0000
Subject: Re: [Linux-ia64] null pointer in iosapic_pci_fixup()
Message-Id: <marc-linux-ia64-105590698805546@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805543@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805543@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 26 Nov 2001 17:17:26 +0100 (NFT), Xavier Bru  <Xavier.Bru@bull.net> said:

  Xavier> When a device is found behind a pci/pci bridge and this
  Xavier> device has no IRQ decribed in the ACPI table, Linux prints a
  Xavier> warning message: " PCI: Couldn't map irq for (...)"
  Xavier> unfortunately there is a null "bridge" pointer at that
  Xavier> point. This makes the system hang in release 2.4.9 and have
  Xavier> a wrong print of bus , device and irq in kernel 2.4.13.

The previous printk() seems to suffer from the same bug.  I changed
both of them.

Thanks,

	--david


