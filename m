From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 20 Nov 2014 13:15:19 +0000
Subject: Re: [RFC PATCH 00/16] Refine PCI host bridge scan interfaces
Message-Id: <2756150.eOnxg6jMdK@wuerfel>
List-Id: <linux-ia64.vger.kernel.org>
References: <1416219710-26088-1-git-send-email-wangyijing@huawei.com> <1534030.bkpIToWlHq@wuerfel> <546DD804.4010105@linaro.org>
In-Reply-To: <546DD804.4010105@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linuxppc-dev@lists.ozlabs.org
Cc: Tomasz Nowicki <tomasz.nowicki@linaro.org>, Yijing Wang <wangyijing@huawei.com>, Liviu Dudau <liviu@dudau.co.uk>, Tony Luck <tony.luck@intel.com>, Russell King <linux@arm.linux.org.uk>, linux-pci@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Thierry Reding <thierry.reding@gmail.com>, Suravee.Suthikulpanit@amd.com, Bjorn Helgaas <bhelgaas@google.com>, linux-ia64@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org

On Thursday 20 November 2014 13:01:08 Tomasz Nowicki wrote:
> On 18.11.2014 13:27, Arnd Bergmann wrote:
> > On Tuesday 18 November 2014 20:17:57 Yijing Wang wrote:
> >>
> >>>>
> >>>> I hope platforms with ACPI or DT could both use pci_create_host_bridge().
> >>>> Why we need to use two different ways to process it ?
> >>>
> >>> These are completely different use cases:
> >>>
> >>> a) For DT, we want loadable device drivers that start by probing a host
> >>>     bridge device which was added through the DT platform code. The
> >>>     driver is self-contained, and eventually we want to be able to unload
> >>>     it. We have lots of different per-soc drivers that require different
> >>>     quirks
> >>>
> >>> b) For ACPI, the interface is defined in the ACPI spec across architectures
> >>>     and SoCs, we don't have host bridge drivers and the code that initializes
> >>>     the PCI is required early during boot and called from architecture
> >>>     code. There is no parent device, as ACPI sees PCI as a fundamental building
> >>>     block by itself, and there are no drivers because the firmware does
> >>>     the initial hardware setup, so we only have to access the config space.
> >>
> >> Hmmm, I'm a little confused, so why you think ACPI host driver should not use
> >> pci_create_host_bridge(), because ACPI PCI driver has no parent device ?
> >
> > It's one of the difference. Having a parent device can certainly make your
> > life simpler, since you have devm_kzalloc(), dev_info(), etc. Coming from
> > the other end, I think ACPI needs PCI to be available during early boot,
> > at a time where we might not want pci_create_host_bridge() to do the
> > right thing.
> 
> Device pointer is not required for ACPI, struct acpi_device is all we 
> need to get all that info. If pci_create_host_bridge() would be DT 
> specific, it would be nice to have sth similar for ACPI but that is out 
> of this patch set scope.

My point was more that we don't need to have something like it for ACPI,
since we don't get random drivers that need to be probed that way,
just one common implementation that calls into the PCI core. We should
of course share the common bits with pci_create_host_bridge() in some
form, but that can be done by moving the x86 pci_acpi_scan_root
function and/or acpi_pci_root_add() to a common place in drivers/pci
and then refactoring the internals.

	Arnd
