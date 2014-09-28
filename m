From: Yijing Wang <wangyijing@huawei.com>
Date: Sun, 28 Sep 2014 06:11:44 +0000
Subject: Re: [PATCH v2 00/22] Use MSI chip framework to configure MSI/MSI-X in all platforms
Message-Id: <5427A6A0.5040703@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1411614872-4009-1-git-send-email-wangyijing@huawei.com> <20140925074235.GN12423@ulmo> <20140925144855.GB31157@bart.dudau.co.uk> <20140925164937.GB30382@ulmo> <20140925171612.GC31157@bart.dudau.co.uk> <542505B3.7040208@huawei.com> <20140926085430.GG31106@ulmo> <20140926090537.GH31106@ulmo> <54277327.6070500@huawei.com>
In-Reply-To: <54277327.6070500@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thierry Reding <thierry.reding@gmail.com>
Cc: Liviu Dudau <liviu@dudau.co.uk>, Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, linux-arch@vger.kernel.org, arnab.basu@freescale.com, Bharat.Bhushan@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Ralf Baechle <ralf@linux-mips.org>, Lucas Stach <l.stach@pengutronix.de>, David Vrabel <david.vrabel@citrix.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Michael Ellerman <mpe@ellerman.id.au>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>

On 2014/9/28 10:32, Yijing Wang wrote:
> On 2014/9/26 17:05, Thierry Reding wrote:
>> On Fri, Sep 26, 2014 at 10:54:32AM +0200, Thierry Reding wrote:
>> [...]
>>> At least for Tegra it's trivial to just hook it up in tegra_pcie_scan_bus()
>>> directly (patch attached).
>>
>> Really attached this time.
>>
>> Thierry
>>
> 
> It looks good to me, so I will update the arm pci hostbridge driver to assign
> pci root bus the msi chip instead of current pcibios_add_bus(). But for other
> platforms which only have a one msi chip, I will kept the arch_find_msi_chip()
> temporarily for more comments, especially from Bjorn.

Oh, sorry, I found designware and rcar use pci_scan_root_bus(), so we can not simply
assign msi chip to root bus in all host drivers's scan functions.

> 
> Thanks!
> Yijing.
> 


-- 
Thanks!
Yijing

