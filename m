From: Thierry Reding <thierry.reding@gmail.com>
Date: Thu, 25 Sep 2014 07:26:20 +0000
Subject: Re: [PATCH v2 06/22] PCI/MSI: Introduce weak arch_find_msi_chip() to find MSI chip
Message-Id: <20140925072619.GI12423@ulmo>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="wZdghQXYJzyo6AGC"
List-Id: <linux-ia64.vger.kernel.org>
References: <1411614872-4009-1-git-send-email-wangyijing@huawei.com>
 <1411614872-4009-7-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1411614872-4009-7-git-send-email-wangyijing@huawei.com>
To: Yijing Wang <wangyijing@huawei.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, linux-arch@vger.kernel.org, arnab.basu@freescale.com, Bharat.Bhushan@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Ralf Baechle <ralf@linux-mips.org>, Lucas Stach <l.stach@pengutronix.de>, David Vrabel <david.vrabel@citrix.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Michael Ellerman <mpe@ellerman.id.au>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>


--wZdghQXYJzyo6AGC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Sep 25, 2014 at 11:14:16AM +0800, Yijing Wang wrote:
> Introduce weak arch_find_msi_chip() to find the match msi_chip.
> Currently, MSI chip associates pci bus to msi_chip. Because in
> ARM platform, there may be more than one MSI controller in system.
> Associate pci bus to msi_chip help pci device to find the match
> msi_chip and setup MSI/MSI-X irq correctly. But in other platform,
> like in x86. we only need one MSI chip, because all device use
> the same MSI address/data and irq etc. So it's no need to associate
> pci bus to MSI chip, just use a arch function, arch_find_msi_chip()
> to return the MSI chip for simplicity. The default weak
> arch_find_msi_chip() used in ARM platform, find the MSI chip
> by pci bus.

Can't x86 simply set the bus' .msi field anyway? It would seem to be
easy to do and unifies the code rather than driving it further apart
using even more of the __weak functions.

Thierry

--wZdghQXYJzyo6AGC
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUI8ObAAoJEN0jrNd/PrOhuC4P/jIBmvnDAEtAA8p9/uMyo4ub
35EbcR8vyvkUOhtovW5OYqkxRnKAfsYNHAbYYijRRWopeBkmqYj1EiW8F3M3MbKT
FD+87Kx/0mNqy1mNdoPnIttpaCyY9igbhmeWhE5gFFqI4L715gT4AVg7tG79gsas
BObGQrGqdsEcdHsMae9wIm6X46Q2HcECiOp5T619C7P6/4DRXoQ6CreiwtWgh8GN
HdDemrevFvVZI72ceWPPPSY813vykzLhvxbiMhjhiYtZSbtqmYJoNQBbeQIlhfYV
mdIBuGWQlSAyy4+IZq/IBJ/lO4BtU4zevDvSCOnKhCUlHAZ7qNpxLtDXaZmxRQ1W
/9BeZHt+IDeev7rXTA97oQXAwzbAabafN1FWyCUWZEq28xIYmAqQZeFA9+KKRQQm
QMs10F3xpcayjlUXPNp7pLoWgcffcb0g8YocMo4DdMgMFQ9Pnx7jIrQ9Z46n4o+i
u2Qb275YAwisvL1ol3S2lZ+19CdVEwp+ly/66aYviHzVYeDm2C11myPCbfCbNcPg
M/qS6KwZzn+LyyCiLT0dmcm90UTIPZ7uw0sbwcVbq80skjhZxLT5NS7xHYnP/znG
62a/6pxngsPcnk+b7pv2htjbxkKDjJkpn8kXGiR6sGwun0b7HheNwzanLbDPs/7B
3QkCbl7txteq7GjETQqt
=LNzZ
-----END PGP SIGNATURE-----

--wZdghQXYJzyo6AGC--
