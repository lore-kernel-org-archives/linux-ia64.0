From: Thierry Reding <thierry.reding@gmail.com>
Date: Tue, 24 Mar 2015 12:31:40 +0000
Subject: Re: [PATCH v8 24/30] PCI/tegra: Remove redundant tegra_pcie_scan_bus()
Message-Id: <20150324123139.GA11625@ulmo.nvidia.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="bp/iNruPH9dso1Pn"
List-Id: <linux-ia64.vger.kernel.org>
References: <1427168064-8657-1-git-send-email-wangyijing@huawei.com>
 <1427168064-8657-25-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1427168064-8657-25-git-send-email-wangyijing@huawei.com>
To: Yijing Wang <wangyijing@huawei.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>, Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@lists.linux-m68k.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, linux-tegra@vger.kernel.org


--bp/iNruPH9dso1Pn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Mar 24, 2015 at 11:34:18AM +0800, Yijing Wang wrote:
> Now pci_scan_root_bus() is almost similar to
> pci_create_root_bus() + pci_scan_child_bus().
> So we could use common pci_scan_root_bus() in
> pci_common_init_dev() to scan pci busses.
> tegra_pcie_scan_bus() is redundant, remove it.
>=20
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
> CC: Thierry Reding <thierry.reding@gmail.com>
> CC: linux-tegra@vger.kernel.org
> ---
>  drivers/pci/host/pci-tegra.c |   16 ----------------
>  1 files changed, 0 insertions(+), 16 deletions(-)

Jetson TK1 still boots over NFS root via the onboard PCIe network card
with this series applied, so:

Tested-by: Thierry Reding <treding@nvidia.com>
Acked-by: Thierry Reding <treding@nvidia.com>

--bp/iNruPH9dso1Pn
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCAAGBQJVEVknAAoJEN0jrNd/PrOhgSAQAKCC9PfTMZLcgurKsdBmqctU
7WkCuoKLDv1sbEfF1mzfk8VI/9kROf6bIyKKgvXV2V50p8OHBbJBJmjR5U48/37v
iDGVlSrSII4+G3Mv/HWx/Dvh1whXYp/TH+SNUPNY1BdSIRmvjmLQ3QYBuC6P3N6W
kjd5NW5KkgZ0NPORWfXzEabkXIGEjIk8fsB6ILXxBVJMdUxiLA4LyOQAmmuzoviW
TAsboT7liAJPbiM2mjnYqo6ZdDR7Y8hotXBf8KtIxlzns12VQZl40GdtvZ7zWi4R
tH3zyYqJuhyg6VjvDMZzKZsmU4hctOQ2sgeYOFn52t8nPIZqJMoLT3nAabgUw+7x
NNI+oZGD8Wo4XGDXQyiY1ihjObLCD2uDfpKfdwmCRlYFef66rEWW0gImACCCprEc
9jqQgqZAN9AXX+1OkNyX+Ioiy2v7yicVi/JMHawdEEdszSuG3RuZIQQWku+T2UDy
WmpI2MdZRUEAJiW1V5rOBibae2uvGEHedkZmOqkjG2NLFqt633FlUg416ucPD+eJ
VKWNXwsJyqBtGpifsUaFZfSNFsvSZ4gceI+/KD0ZpmhhAXkh+AVoNTa1iZLjq3X9
q8J1YflS6mHPbE+D37LRDLg47XoHRIf0Ly/9GukoXbowfnP3/Fy1532Zy+1eXyBb
Lk3IVyxC8BFsZ0j1FZKG
=0jIA
-----END PGP SIGNATURE-----

--bp/iNruPH9dso1Pn--
