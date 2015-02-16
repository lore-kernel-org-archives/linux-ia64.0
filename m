From: Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>
Date: Mon, 16 Feb 2015 17:46:29 +0000
Subject: Re: [PATCH v2 23/30] PCI/mvebu: Use pci_common_init_dev() to simplify code
Message-Id: <20150216174628.GA13861@red-moon>
List-Id: <linux-ia64.vger.kernel.org>
References: <1421800225-26230-1-git-send-email-wangyijing@huawei.com>
 <1421800225-26230-24-git-send-email-wangyijing@huawei.com>
 <20150122184000.63ba06bb@free-electrons.com>
In-Reply-To: <20150122184000.63ba06bb@free-electrons.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Cc: Yijing Wang <wangyijing@huawei.com>, Bjorn Helgaas <bhelgaas@google.com>, Jiang Liu <jiang.liu@linux.intel.com>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, Yinghai Lu <yinghai@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Marc Zyngier <Marc.Zyngier@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Russell King <linux@arm.linux.org.uk>, "x86@kernel.org" <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-m68k@vger.kernel.org" <linux-m68k@vger.kernel.org>, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Jason Cooper <jason@lakedaemon.net>, Gregory =?iso-8859-1?Q?Cl=E9ment?= <gregory.clement@free-electrons.com>, Lior Amsalem <alior@marvell.com>, Nadav Haklai <nadavh@marvell.com>

Hi Thomas,

On Thu, Jan 22, 2015 at 05:40:00PM +0000, Thomas Petazzoni wrote:
> Dear Yijing Wang,
> 
> On Wed, 21 Jan 2015 08:30:18 +0800, Yijing Wang wrote:
> > Mvebu_pcie_scan_bus() is not necessary, we could use
> > pci_common_init_dev() instead of pci_common_init(),
> > and pass the device pointer as the parent. Then
> > pci_scan_root_bus() will be called to scan the pci busses.
> > 
> > Signed-off-by: Yijing Wang <wangyijing@huawei.com>
> > CC: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> > CC: Jason Cooper <jason@lakedaemon.net>
> 
> While I'm fine with the change to pci_common_init_dev(), I am not so
> sure about the removal of mvebu_pcie_scan_bus(). I vaguely remember
> that we intentionally did not use the default function for a specific
> reason. Of course, this was a long time ago, and I don't remember the
> reason. I would have to take a bit of time to 1/ review the archives of
> the discussion surrounding the pcie-mvebu driver, and 2/ test your
> patch to validate it works fine on HW.

I guess the reason: by providing the scan pointer to pcibios through
the hw_pci struct you were preventing calling pci_scan_root_bus() in
bios32.c that in turn can add devices before the resources are assigned.

Basically mvebu_pci_scan_bus() was doing what pci_scan_root_bus() does
except for calling pci_bus_add_devices().

Yijing patches remove pci_bus_add_devices() from pci_scan_root_bus() so
his change should be fine and it actually improves the current behaviour
which is quite hard to untangle, and not just on mvebu (I suspect
drivers/pci/host/pcie-xilinx.c can suffer from the same problem).

Lorenzo

> 
> Thanks!
> 
> Thomas
> -- 
> Thomas Petazzoni, CTO, Free Electrons
> Embedded Linux, Kernel and Android engineering
> http://free-electrons.com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-pci" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
