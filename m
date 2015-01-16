From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 16 Jan 2015 09:23:11 +0000
Subject: Re: [PATCH 11/28] PCI: Introduce pci_host_bridge_ops to setup host bridge
Message-Id: <1443278.UW4hQ0rXtr@wuerfel>
List-Id: <linux-ia64.vger.kernel.org>
References: <1421372666-12288-1-git-send-email-wangyijing@huawei.com> <1421372666-12288-12-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1421372666-12288-12-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Yijing Wang <wangyijing@huawei.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>, Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Geert Uytterhoeven <geert@linux-m68k.org>

On Friday 16 January 2015 09:44:09 Yijing Wang wrote:
> @@ -2064,7 +2073,7 @@ struct pci_bus *pci_scan_root_bus(struct device *pa=
rent, u32 db,
>  {
>         struct pci_host_bridge *host;
> =20
> -       host =3D pci_create_host_bridge(parent, db, resources, sysdata);
> +       host =3D pci_create_host_bridge(parent, db, resources, sysdata, N=
ULL);
>         if (!host)
>                 return NULL;
> =20
>=20

Same comment as for patch 10: If we leave this out of the pci_create_host_b=
ridge
argument but set it later, =FEe interface becomes simpler for callers that
don't have custom pci_host_bridge_ops.

This would break your phb_prepare() callback, but I assume a host driver
can just make a direct function call before entering pci_create_host_bridge
for this. Let me know if I'm missing something here.

	Arnd
