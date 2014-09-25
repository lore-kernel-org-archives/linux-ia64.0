From: Thierry Reding <thierry.reding@gmail.com>
Date: Thu, 25 Sep 2014 07:19:20 +0000
Subject: Re: [PATCH v2 03/22] MSI: Remove the redundant irq_set_chip_data()
Message-Id: <20140925071919.GH12423@ulmo>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="mhjHhnbe5PrRcwjY"
List-Id: <linux-ia64.vger.kernel.org>
References: <1411614872-4009-1-git-send-email-wangyijing@huawei.com>
 <1411614872-4009-4-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1411614872-4009-4-git-send-email-wangyijing@huawei.com>
To: Yijing Wang <wangyijing@huawei.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, linux-arch@vger.kernel.org, arnab.basu@freescale.com, Bharat.Bhushan@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Ralf Baechle <ralf@linux-mips.org>, Lucas Stach <l.stach@pengutronix.de>, David Vrabel <david.vrabel@citrix.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Michael Ellerman <mpe@ellerman.id.au>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>


--mhjHhnbe5PrRcwjY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Sep 25, 2014 at 11:14:13AM +0800, Yijing Wang wrote:
> Currently, pcie-designware, pcie-rcar, pci-tegra drivers
> use irq chip_data to save the msi_chip pointer. They
> already call irq_set_chip_data() in their own MSI irq map
> functions. So irq_set_chip_data() in arch_setup_msi_irq()
> is useless.

Again, I think this should be the other way around. If drivers do
something that's already handled by the core, then the duplicate code
should be dropped from the drivers.

Thierry

--mhjHhnbe5PrRcwjY
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUI8H3AAoJEN0jrNd/PrOhD9gP/irz9NSH3coHma+k59CgfNee
Eadp8ruJoWHsk+kNc+VP4X8QUfFbawc4Y9GarISl2soj926zV/hj8I7CSKn7im1g
OEWOG1+IoZY+1142DUhZRfqgw+kPIsHL2nKRK6RJCWhpIxIrh1f7/LcSyrWUbS9r
7t6FJUljEAZ4oSmW8FDuK4hrK9s53zIKQkvv2zfbOv7sAvnYuJM4r5EteKEkxVqy
VEwvbqgS5Ccf4PKJKnISrCAV9z4H8kYF2PN0e7+8x9l6WOsdz5yEszOJmoREGMzG
eCUaBYi7Tl7jAqdQkJfEePdK7BotGIbuffF2j76j1TTgOKp2HEoMlTxLv9SldxMa
9NoNSP5NzJzSyK6Pawx84xkhKnMd5TWLD7IMcDvfcMIbQ+IZiXDnNjQ9diG3RjhT
zLyMRZc5MdOfL8ScPzrYYUATbIEFmJdB0rUZ6u9ivHdRsVqZ6pJbRz/C/QPfd92M
dDXoVvcRDGGgaM66PbfYykArWhGI+hPG4ip3t5CpA2KLqLm9BapvqSc0H6V9y5w8
nuBHS0pk3mojCR9naMzuOy0nqME7SU9QiOiMMvv6uZztE2y3udRmkZNHX32DSi7l
6YLq84EA/LyOtPp9jrRH1eKZLty5qyY2mO9Le46GAragc909SMnKpNAWJyV+RLLm
9fhn8sFnEUFKzDPptCkB
=WmVy
-----END PGP SIGNATURE-----

--mhjHhnbe5PrRcwjY--
