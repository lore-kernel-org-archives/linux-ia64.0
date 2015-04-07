From: Daniel Axtens <dja@axtens.net>
Date: Tue, 07 Apr 2015 07:04:26 +0000
Subject: Re: [PATCH v9 14/30] PCI: Introduce pci_host_bridge_ops to support host specific operations
Message-Id: <1428390266.14169.1.camel@axtens.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-+p8vPjV/hW23nWb2qOTV"
List-Id: <linux-ia64.vger.kernel.org>
References: <1428053164-28277-1-git-send-email-wangyijing@huawei.com>
	 <1428053164-28277-16-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1428053164-28277-16-git-send-email-wangyijing@huawei.com>
To: Yijing Wang <wangyijing@huawei.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>, Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>


--=-+p8vPjV/hW23nWb2qOTV
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-04-03 at 17:25 +0800, Yijing Wang wrote:
> Now we have weak functions like pcibios_root_bridge_prepare()
> to setup pci host bridge, We could introduce pci_host_bridge_ops
> which contain host bridge specific ops to setup pci_host_bridge.
> Then host bridge driver could add pci_host_bridge_ops hooks
> intead of weak function to setup pci_host_bridge.
> This patch add following pci_host_bridge_ops hooks:
>=20
> pci_host_bridge_ops {
> 	struct pci_ops *ops;
Trivial nit, but this is 'struct pci_ops *pci_ops' in the code below.

> +struct pci_host_bridge;
> +struct pci_host_bridge_ops {
> +	struct pci_ops *pci_ops;
> +	int (*prepare)(struct pci_host_bridge *host);
> +	void (*set_root_bus_speed)(struct pci_host_bridge *host);
> +	int (*scan_bus)(struct pci_host_bridge *host);
> +};
> +

Regards,
Daniel

--=-+p8vPjV/hW23nWb2qOTV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: GPGTools - https://gpgtools.org

iQIcBAABCAAGBQJVI4F6AAoJEPC3R3P2I92FjZwQAJw/0Bh3rRl6fwPkYFP66J+c
2ZnbAeR25jp8VwFrHLBjTOLB/FYNkYnc1rOa6lrLi2Tzl9JupQ4Qr0GqkrUlU6tU
z5mIxlBYbXGxquDSKlriq4Jh/7hP7Jsbztbo+WWz2oEH5QMD4bPcnAlXp26Y+h/D
3kbiMiKQ9nbp9/AaME1PReUSVd1ZMvvu2Mb9IZaf0g+XR0QWBQTLuxI8KESdlozp
wFY3sr9GtjcHLbjneeM4oiknWgnabIbcksBnBcajUItz/N8ik/56ofMevx+fMG6I
TduJRjJdObe7vfnuPVQu9aOhgIOtGuqmzAUy9fpOkC967f7+nv0yn8CjVLhsSEYj
DCyZfkEQ0YthVFUc/yBrYI89VBceyLxq0yCv8nOpWYRXHV2NZd+T5iahKZr0skHA
Gu7WVC/mED3UOxRempwGFlDgMOakOYHjZVFRnjAnVzD3cCS9cCCfHhFfjAzR3CJG
78QxuZxiV1nGH0AAvoGpVqQk8wbNrHa2ARPsku9Obf/tOp/GUC7zmDJj+1uNVlIt
tLP6MVpv2y2nk2j6NK8HeTX1rdDontaBUIQk3wtPC8xGZuaDifgXPnEA5K6zpmzD
SmcBfxXW4gA2Eh49XAA37poVZg/B/LbfuBXemqPhkdqO1HwZVRi4aVKp78C0dEnI
ibpvlkMwd4AhMN4hcj4g
=8gut
-----END PGP SIGNATURE-----

--=-+p8vPjV/hW23nWb2qOTV--

