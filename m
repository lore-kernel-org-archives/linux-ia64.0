From: Thierry Reding <thierry.reding@gmail.com>
Date: Thu, 25 Sep 2014 07:06:01 +0000
Subject: Re: [PATCH v2 02/22] PCI/MSI: Remove useless bus->msi assignment
Message-Id: <20140925070601.GF12423@ulmo>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="kbCYTQG2MZjuOjyn"
List-Id: <linux-ia64.vger.kernel.org>
References: <1411614872-4009-1-git-send-email-wangyijing@huawei.com>
 <1411614872-4009-3-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1411614872-4009-3-git-send-email-wangyijing@huawei.com>
To: Yijing Wang <wangyijing@huawei.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, linux-arch@vger.kernel.org, arnab.basu@freescale.com, Bharat.Bhushan@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Ralf Baechle <ralf@linux-mips.org>, Lucas Stach <l.stach@pengutronix.de>, David Vrabel <david.vrabel@citrix.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Michael Ellerman <mpe@ellerman.id.au>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>


--kbCYTQG2MZjuOjyn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Sep 25, 2014 at 11:14:12AM +0800, Yijing Wang wrote:
> Currently, PCI drivers will initialize bus->msi in
> pcibios_add_bus(). pcibios_add_bus() will be called
> in every pci bus initialization. So the bus->msi
> assignment in pci_alloc_child_bus() is useless.

I think this should be the other way around. The default should be to
inherit bus->msi from the parent. That way drivers don't typically have
to do it, yet they can still opt to override it if they need to.

For Tegra for example I think it would work if we assigned the MSI chip
to the root bus (in tegra_pcie_scan_bus()) and then have it propagated
to child busses in pci_alloc_child_bus() so that tegra_pcie_add_bus()
can be removed altogether.

Thierry

--kbCYTQG2MZjuOjyn
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUI77YAAoJEN0jrNd/PrOhZ/IQAMCSt26z+T6Q8TozfHBY40d1
VjyfIqF++JMHsJp9JBnJk7W/SdKcW+ClXvgZjtR4hqvTRlYUBPk6Sn3JWpi3RslY
GHt/y1pNGzk05qLADjlA8CAGVjq0Vspw5WO5SLjzu10gfvcddAX7YKRcWz5vW9uv
TcG+NFcDyGRaNg+ATkJ8Ep4rVN3eIkh9te9CE/pG5zQAV+NEZkaN4v9hRFubWIPy
HUXyDu+8aTJ3YUyhrXkbGR23i0lLzcWsqhrcjbbbQj0swxngijMgBbzJU2jJ0rxx
5CjTbs0mgvqKfsX1WQ3Df61rSN/krlMiZeD66YuMTuWdlzZkGJqpHCDkKdx2rITZ
o2IXg6faK1OARr8JfubrXil2utfpJkvBJR2fWmH0j37ZkEb249skTCAnb2yroyhJ
Mz3BmS+nAgPJkQUTTVZigeR+90KASb/WQrFPZhvOPK/ioMy0UyGy6uvNYm4rLXK+
gWN2TjIaniEFM60xJLFPgsVuf9XXKUZ0REybeTiDM65mofLUSkxtMbK/mrcBdHgF
kdO+JJ93hN6vnnqpqA/QjKNJebZm0PUjSTZvXIlzBs/v+gOh4bWewATJLbcgll/g
w85vBMPaceGBcjBIBul927T7Uf+2pLOmJHmM+eCzXSdxAyQ8qx75Su9uWOY3sX3Q
JDxVrWb34Dj7sIqL36a3
=f2MC
-----END PGP SIGNATURE-----

--kbCYTQG2MZjuOjyn--
