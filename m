From: "Lee, Jung-Ik" <jung-ik.lee@intel.com>
Date: Thu, 31 Oct 2002 04:49:24 +0000
Subject: [Linux-ia64] RE: [Pcihpd-discuss] PCI hotplug broken on IA64
Message-Id: <marc-linux-ia64-105590709805303@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I don't think the current way of accessing PCI configuration space
> with temporary pci_dev and pci_bus is definitive answer but we
> are depending on it now.
> Could someone enlighten me?
> Any ideas?

All pci config space access before pci_dev/pci_bus are built
should be able to make direct call to
pci_config_{read|write}(seg, bus, dev, func, offset, size, value).

Thanks,
J.I.

