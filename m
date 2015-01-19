From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 19 Jan 2015 08:23:13 +0000
Subject: Re: [PATCH 01/28] PCI: Rip out pci_bus_add_devices() from pci_scan_bus()
Message-Id: <1877825.44iMOx15du@wuerfel>
List-Id: <linux-ia64.vger.kernel.org>
References: <1421372666-12288-1-git-send-email-wangyijing@huawei.com> <CAE9FiQUoocCzBKsHL_D4ypH1-DV7XxZMdREX7n=Tz1Kq3kHHeA@mail.gmail.com> <CAE9FiQV97PuDWBZYRxh8R0ADnUFTbo1NO3wAufj97en0yseYSQ@mail.gmail.com>
In-Reply-To: <CAE9FiQV97PuDWBZYRxh8R0ADnUFTbo1NO3wAufj97en0yseYSQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yinghai Lu <yinghai@kernel.org>
Cc: Yijing Wang <wangyijing@huawei.com>, Bjorn Helgaas <bhelgaas@google.com>, Jiang Liu <jiang.liu@linux.intel.com>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Russell King <linux@arm.linux.org.uk>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Geert Uytterhoeven <geert@linux-m68k.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>

On Friday 16 January 2015 15:16:28 Yinghai Lu wrote:
> On Fri, Jan 16, 2015 at 3:15 PM, Yinghai Lu <yinghai@kernel.org> wrote:
> > On Thu, Jan 15, 2015 at 5:43 PM, Yijing Wang <wangyijing@huawei.com> wrote:
> >> Pci_bus_add_devices() should not be placed in pci_scan_bus().
> >> Now pci device will be added to driver core once its
> >> creation. All things left in pci_bus_add_devices() are
> >> driver attachment and other trivial sysfs things.
> >> Pci_scan_bus() should be the function responsible for
> >> scanning PCI devices, not including driver attachment.
> >> Other, some callers(m68k,unicore32,alpha) of pci_scan_bus()
> >> will call pci_bus_size_bridges() and pci_bus_assign_resources()
> >> after pci_scan_bus().
> >>
> >> E.g.
> >> In m68k
> >> mcf_pci_init()
> >>         pci_scan_bus()
> >>                 ...
> >>                 pci_bus_add_devices() --- try to attach driver
> >>         pci_fixup_irqs()
> >>         pci_bus_size_bridges()
> >>         pci_bus_assign_resources()
> >>
> >> It is not correct, resources should be assigned correctly
> >> before attaching driver.
> >
> No, for booting path, at that time pci drivers are *NOT* loaded yet.

This may be true for the m68k example, and traditionally for all
PCI hosts, but as we move to a more modular architecture with
drivers/pci/hosts, you can have PCI host drivers that are loadable
modules and get loaded after the built-in drivers are initialized,
or you can have host drivers that depend on a resource (clock,
regulator, reset, gpio, ...) that in turn comes from a driver
that gets initialized later.

	Arnd
