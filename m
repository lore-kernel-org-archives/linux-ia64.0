From: Thierry Reding <thierry.reding@gmail.com>
Date: Thu, 25 Sep 2014 07:42:36 +0000
Subject: Re: [PATCH v2 00/22] Use MSI chip framework to configure MSI/MSI-X in all platforms
Message-Id: <20140925074235.GN12423@ulmo>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="O27Gs9jTTFWz3gAR"
List-Id: <linux-ia64.vger.kernel.org>
References: <1411614872-4009-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1411614872-4009-1-git-send-email-wangyijing@huawei.com>
To: Yijing Wang <wangyijing@huawei.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, linux-arch@vger.kernel.org, arnab.basu@freescale.com, Bharat.Bhushan@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Ralf Baechle <ralf@linux-mips.org>, Lucas Stach <l.stach@pengutronix.de>, David Vrabel <david.vrabel@citrix.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Michael Ellerman <mpe@ellerman.id.au>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>


--O27Gs9jTTFWz3gAR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Sep 25, 2014 at 11:14:10AM +0800, Yijing Wang wrote:
> This series is based Bjorn's pci/msi branch
> git://git.kernel.org/pub/scm/linux/kernel/git/helgaas/pci.git pci/msi
>=20
> Currently, there are a lot of weak arch functions in MSI code.
> Thierry Reding Introduced MSI chip framework to configure MSI/MSI-X in ar=
m.
> This series use MSI chip framework to refactor MSI code across all platfo=
rms
> to eliminate weak arch functions. Then all MSI irqs will be managed in a=
=20
> unified framework. Because this series changed a lot of ARCH MSI code,
> so tests in the platforms which MSI code modified are warmly welcomed!

Apart from the comments to the individual patches I very much like where
this is going. Thanks for taking care of this.

Thierry

--O27Gs9jTTFWz3gAR
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUI8drAAoJEN0jrNd/PrOhRSAQALsX6+rt+ih0Gd1v6P/pa7qN
OXrKB5iUQqBdwt1YLNoZ55Ojb03D1gWrXOV4DE2Ot+oWcChhDHqOflN7mOfNHLwj
94ZiLJMuHN97GQPNxto1U+ExV52tdbA8FIUIxXgeIV+PeDB55N/NQjJPXOLsLj/3
8yDXEOE3ZTdLDCNCFPBO4NFSRSvzTMkl4He0IOcMTDqom0YZfHzLb+pJR0DPNq0n
gpUb03/YTMlSgjIM9Ltq2wb5AdttZeJ4+MG7k/gyLJjFJr178R1szKz23l7cYZfq
7TowM+iBQV/g3v5l/TabQOeBQDYqIl/2iSJAxc17ECtoxrW1SqSckRJfTqcPmcPi
r0vplvHDqRXBrv+NH92zhjSts8N5nPZMjiDdSknrOJwJUFFQku8U/2A/XMX3SRxn
H+BbOXdut+fvidu7HPtrEqlfUIK9Lvh0l8XfnBoeZdLOnZoQV4wI9NBSH4D4HLpA
o/H5Cq5xh6o2xQFABJHoFOIdMEz5NoWZ8BPiqQJ5nWn9ErGrBmbKcll6S2rIRqZP
/UhLXKnd3ju7cQF1kH6gu2zL8l2mWIEISUZWJ1dPsc51Y4164W6olvTZ95BGmLQc
QunHexGBsu0mVlTLtcfVey5K9+m8zcJQel6KThgh2MSBNt54p6IEuLT4fS3e4mXE
VE4kNZ+YiwcZhdZXalp+
=IFC0
-----END PGP SIGNATURE-----

--O27Gs9jTTFWz3gAR--
