From: Liviu Dudau <liviu@dudau.co.uk>
Date: Thu, 25 Sep 2014 14:48:55 +0000
Subject: Re: [PATCH v2 00/22] Use MSI chip framework to configure MSI/MSI-X in all platforms
Message-Id: <20140925144855.GB31157@bart.dudau.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <1411614872-4009-1-git-send-email-wangyijing@huawei.com>
 <20140925074235.GN12423@ulmo>
In-Reply-To: <20140925074235.GN12423@ulmo>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thierry Reding <thierry.reding@gmail.com>
Cc: Yijing Wang <wangyijing@huawei.com>, Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, linux-arch@vger.kernel.org, arnab.basu@freescale.com, Bharat.Bhushan@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Ralf Baechle <ralf@linux-mips.org>, Lucas Stach <l.stach@pengutronix.de>, David Vrabel <david.vrabel@citrix.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Michael Ellerman <mpe@ellerman.id.au>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>

On Thu, Sep 25, 2014 at 09:42:36AM +0200, Thierry Reding wrote:
> On Thu, Sep 25, 2014 at 11:14:10AM +0800, Yijing Wang wrote:
> > This series is based Bjorn's pci/msi branch
> > git://git.kernel.org/pub/scm/linux/kernel/git/helgaas/pci.git pci/msi
> > 
> > Currently, there are a lot of weak arch functions in MSI code.
> > Thierry Reding Introduced MSI chip framework to configure MSI/MSI-X in arm.
> > This series use MSI chip framework to refactor MSI code across all platforms
> > to eliminate weak arch functions. Then all MSI irqs will be managed in a 
> > unified framework. Because this series changed a lot of ARCH MSI code,
> > so tests in the platforms which MSI code modified are warmly welcomed!
> 
> Apart from the comments to the individual patches I very much like where
> this is going. Thanks for taking care of this.
> 
> Thierry

I am actually in disagreement with you, Thierry. I don't like the general direction
of the patches, or at least I don't like the fact that we don't have a portable
way of setting up the msi_chip without having to rely on weak architectural hooks.
I'm surprised no one considers the case of a platform having more than one host
bridge and possibly more than one MSI unit. With the current proposed patchset I
can't see how that would work.

What I would like to see is a way of creating the pci_host_bridge structure outside
the pci_create_root_bus(). That would then allow us to pass this sort of platform
details like associated msi_chip into the host bridge and the child busses will
have an easy way of finding the information needed by finding the root bus and then
the host bridge structure. Then the generic pci_scan_root_bus() can be used by (mostly)
everyone and the drivers can remove their kludges that try to work around the
current limitations.

Best regards,
Liviu

---------------------
   .oooO
   (   )
    \ (  Oooo.
     \_) (   )
          ) /
         (_/

 One small step
   for me ...

