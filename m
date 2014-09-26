From: Thierry Reding <thierry.reding@gmail.com>
Date: Fri, 26 Sep 2014 08:09:22 +0000
Subject: Re: [PATCH v2 03/22] MSI: Remove the redundant irq_set_chip_data()
Message-Id: <20140926080921.GE31106@ulmo>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="2qXFWqzzG3v1+95a"
List-Id: <linux-ia64.vger.kernel.org>
References: <1411614872-4009-1-git-send-email-wangyijing@huawei.com>
 <1411614872-4009-4-git-send-email-wangyijing@huawei.com>
 <20140925071919.GH12423@ulmo>
 <5424C9BD.3040506@huawei.com>
In-Reply-To: <5424C9BD.3040506@huawei.com>
To: Yijing Wang <wangyijing@huawei.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, linux-arch@vger.kernel.org, arnab.basu@freescale.com, Bharat.Bhushan@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Ralf Baechle <ralf@linux-mips.org>, Lucas Stach <l.stach@pengutronix.de>, David Vrabel <david.vrabel@citrix.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Michael Ellerman <mpe@ellerman.id.au>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>


--2qXFWqzzG3v1+95a
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Sep 26, 2014 at 10:04:45AM +0800, Yijing Wang wrote:
> On 2014/9/25 15:19, Thierry Reding wrote:
> > On Thu, Sep 25, 2014 at 11:14:13AM +0800, Yijing Wang wrote:
> >> Currently, pcie-designware, pcie-rcar, pci-tegra drivers
> >> use irq chip_data to save the msi_chip pointer. They
> >> already call irq_set_chip_data() in their own MSI irq map
> >> functions. So irq_set_chip_data() in arch_setup_msi_irq()
> >> is useless.
> >=20
> > Again, I think this should be the other way around. If drivers do
> > something that's already handled by the core, then the duplicate code
> > should be dropped from the drivers.
>=20
> Hi Thierry, this is different thing, because chip_data is specific to IRQ
> controller, and in other platform, like in x86, chip_data is used to save=
 irq_cfg.
> So we can not call irq_set_chip_data() in core code.
>=20
> x86 irq piece code
>=20
> int arch_setup_hwirq(unsigned int irq, int node)
> {
> 	struct irq_cfg *cfg;
> 	unsigned long flags;
> 	int ret;
>=20
> 	cfg =3D alloc_irq_cfg(irq, node);
> 	if (!cfg)
> 		return -ENOMEM;
>=20
> 	raw_spin_lock_irqsave(&vector_lock, flags);
> 	ret =3D __assign_irq_vector(irq, cfg, apic->target_cpus());
> 	raw_spin_unlock_irqrestore(&vector_lock, flags);
>=20
> 	if (!ret)
> 		irq_set_chip_data(irq, cfg);  ------------->Save irq_cfg
> 	else
> 		free_irq_cfg(irq, cfg);
> 	return ret;
> }

Okay, makes sense to keep irq_set_chip_data() for driver-specific data
then.

Thierry

--2qXFWqzzG3v1+95a
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUJR8xAAoJEN0jrNd/PrOhmZMP/0tFUjT9MXPrTuCEiBWtia+2
ElYucD565UV4FjK6aINM4dHtmn0wUW+dDXB2YDSkAp10Ku534Tfi0zNfQd/xSe6M
SLBNIW/EK67YANcL5AvN2W1wSUn/t24SBwWJIvsoZfNJbsAcETvYySMnmLZJ2L05
k1v9mR+KAR52QhCs9nwga/dePFV/DBQ2bFrblq6Rxu/+hxki9EqgM9JtkRXS0F7d
DU1BqMERPy9AtP+oX5Wih6+8P15JALo4n/SETOfeeToDkhN2Zbh8Y3AoAmVAL1l1
ym3t6fPW7CFvJIX+Qpt02+wVvFu1amMpY8mXfzQmi18VccvTqQ9ylkaaVQ+ZsK/a
M/8qEyiKUc4T8obwUr8qb484vw7QxAlFynvU5A6AX1zlHU+yUVEklTBlVY9Av5jj
EW6MzXAPrhro6KKqu3m8h+P0O72K+oSZOT5bPri9/MfRfW3JCzMsCNIjeGXZ50fr
Komek7HKSPDIaIoavV7Fym7j9zddKbLvAj8DfkztLT7jmQ7i8EVb6eHwy8uMDXI7
cds9cH4RKRvE3ArNaHaOyEomxAD1fyAsQ3SPM2vuf92pJtiwoXpGc5qgrRusMjHw
ZfggWh7lVNYq9TP1fXQalqNmFvATMz3s1HW7lCsIf8AeuNvDkAm3pQRojX1vKPvc
uRsheVegzi0JliNoFkzC
=m1fq
-----END PGP SIGNATURE-----

--2qXFWqzzG3v1+95a--
