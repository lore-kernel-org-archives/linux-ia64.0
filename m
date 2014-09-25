From: Thierry Reding <thierry.reding@gmail.com>
Date: Thu, 25 Sep 2014 07:36:09 +0000
Subject: Re: [PATCH v2 14/22] MIPS/Xlp/MSI: Use MSI chip framework to configure MSI/MSI-X irq
Message-Id: <20140925073608.GK12423@ulmo>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="6K2R/cS9K4qvcBNq"
List-Id: <linux-ia64.vger.kernel.org>
References: <1411614872-4009-1-git-send-email-wangyijing@huawei.com>
 <1411614872-4009-15-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1411614872-4009-15-git-send-email-wangyijing@huawei.com>
To: Yijing Wang <wangyijing@huawei.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, linux-arch@vger.kernel.org, arnab.basu@freescale.com, Bharat.Bhushan@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Ralf Baechle <ralf@linux-mips.org>, Lucas Stach <l.stach@pengutronix.de>, David Vrabel <david.vrabel@citrix.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Michael Ellerman <mpe@ellerman.id.au>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>


--6K2R/cS9K4qvcBNq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Sep 25, 2014 at 11:14:24AM +0800, Yijing Wang wrote:
> Use MSI chip framework instead of arch MSI functions to configure
> MSI/MSI-X irq. So we can manage MSI/MSI-X irq in a unified framework.

Nit: s/irq/IRQ/ in the above.

> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
> ---
>  arch/mips/pci/msi-xlp.c |   14 ++++++++++++--
>  1 files changed, 12 insertions(+), 2 deletions(-)
>=20
> diff --git a/arch/mips/pci/msi-xlp.c b/arch/mips/pci/msi-xlp.c
> index e469dc7..6b791ef 100644
> --- a/arch/mips/pci/msi-xlp.c
> +++ b/arch/mips/pci/msi-xlp.c
> @@ -245,7 +245,7 @@ static struct irq_chip xlp_msix_chip =3D {
>  	.irq_unmask	=3D unmask_msi_irq,
>  };
> =20
> -void arch_teardown_msi_irq(unsigned int irq)
> +void xlp_teardown_msi_irq(unsigned int irq)

Should this not be static now as well?

Thierry

--6K2R/cS9K4qvcBNq
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUI8XoAAoJEN0jrNd/PrOhrs4P/Rg10uO2/sCyBwOPDpHaskVO
8blYsnipag0xv7pyGtAeiEVLgpzcQpv+zjXPmti+R1qI1OVkUXblvYhNtz/CDMvg
AN6CaoZI3llRg3fZwiayj3m/i1HpiXTPqYPK3sWanCUMmZJe73eUj8zMt6bH7yPG
WsuUwWTrc2hcscIDucigcNopQ0fuh0vLYLWgiZe+qJdJIrvGkvGN4h0pHuqIkk0o
DUyMUme8HOL1irxSWYnnmkTPx3TOAWDn7VJVxJgpIKEG0A/X1GCi/4wCkMMxtuxH
1V0aRu/k9AsOR5BVDROfyZCHvuTVLZeXP54ehWxAyA1GwS55Z36FNsl/JLtZ2WhO
95CX6ac9NMDLgmGr9W19SAffXn47Yy/1fvK5zq0F+taK005ajIxufmnoSVrzZsH8
dS8MoFslKB8B2EKW5874CFVUKGx5hZTARp12WWvTfJehLTYfJNpSpdjRdI7LBggj
/PNzvpDkiwwSVzXcJUU45wOZvaS0ImoH3Xn2GF91D/kO+jfFc52lI8Tv8Ixw7Hgl
pJObojrzrQJe20K2NJP9xuCNXUXiI0/EbfwZf/MxE5u/FSxigS8vajMY8CFMlQ5N
4sSi2qWsKa2ZrGMo5dyDfblWSjy1U1O752LQXn+8ddng18wDV/tk/tzZU0Xsywy6
jGgaMyNaRi22AESZhUqv
=xvjk
-----END PGP SIGNATURE-----

--6K2R/cS9K4qvcBNq--
