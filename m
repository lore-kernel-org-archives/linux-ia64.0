From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Tue, 07 Dec 2004 07:21:01 +0000
Subject: [PATCH] IRQ resource deallocation[0/2]
Message-Id: <41B559DD.7040307@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>, Len Brown <len.brown@intel.com>, "Luck, Tony" <tony.luck@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, acpi-devel@lists.sourceforge.net

Hi,

I had posted the IRQ resource deallocation patch a couple of monthes
ago and I had incorporated all feedbacks from the mailing list
(http://marc.theaimsgroup.com/?l=linux-kernel&m9688530703122&w=2).
But it doesn't seems to be included yet, so I would like to try again.
I hope my patch is included onto -mm tree since I want the patches
be tested by many people.

Here is a brief description:

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

For now, the following set of patches has ia64 implementation only.
i386 and x86_64 implementations are TBD.

The patches are against 2.6.10-rc3.

Thanks,
Kenji Kaneshige



