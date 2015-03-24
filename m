From: Daniel Axtens <dja@axtens.net>
Date: Tue, 24 Mar 2015 23:58:43 +0000
Subject: Re: [PATCH v8 19/30] powerpc/pci: Use pci_scan_host_bridge() for simplicity
Message-Id: <1427241523.2685.18.camel@axtens.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-f8VqFOdjSIDYlQlsKBNk"
List-Id: <linux-ia64.vger.kernel.org>
References: <1427168064-8657-1-git-send-email-wangyijing@huawei.com>
	 <1427168064-8657-20-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1427168064-8657-20-git-send-email-wangyijing@huawei.com>
To: Yijing Wang <wangyijing@huawei.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>, linux-ia64@vger.kernel.org, linux-pci@vger.kernel.org, Guan Xuetao <gxt@mprc.pku.edu.cn>, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, Marc Zyngier <marc.zyngier@arm.com>, Rusty Russell <rusty@rustcorp.com.au>, linux-m68k@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Yinghai Lu <yinghai@kernel.org>, linux-arm-kernel@lists.infradead.org, Liviu Dudau <liviu@dudau.co.uk>, Tony Luck <tony.luck@intel.com>, linux-kernel@vger.kernel.org, Jiang Liu <jiang.liu@linux.intel.com>, linux-alpha@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>


--=-f8VqFOdjSIDYlQlsKBNk
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-03-24 at 11:34 +0800, Yijing Wang wrote:
> Now we could use pci_scan_host_bridge() to scan
> pci buses, provide powerpc specific pci_host_bridge_ops.
>=20
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
> CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> CC: linuxppc-dev@lists.ozlabs.org
> ---
>  arch/powerpc/kernel/pci-common.c |   60 +++++++++++++++++++++++---------=
-----
>  1 files changed, 37 insertions(+), 23 deletions(-)

> diff --git a/arch/powerpc/kernel/pci-common.c b/arch/powerpc/kernel/pci-c=
ommon.c
> index 2c58200..e2b50a2 100644
> --- a/arch/powerpc/kernel/pci-common.c
> +++ b/arch/powerpc/kernel/pci-common.c
> @@ -773,6 +773,29 @@ void pcibios_set_root_bus_speed(struct pci_host_brid=
ge *bridge)
>  		return ppc_md.pcibios_set_root_bus_speed(bridge);
>  }
> =20
> +static int pci_host_scan_bus(struct pci_host_bridge *host)
> +{
> +	int mode =3D PCI_PROBE_NORMAL;
> +	struct pci_bus *bus =3D host->bus;
> +	struct pci_controller *hose =3D dev_get_drvdata(&host->dev);
Is there any reason this isn't *hose =3D pci_bus_to_host(bus)?
> +
> +	/* Get probe mode and perform scan */
> +	if (hose->dn && ppc_md.pci_probe_mode)
> +		mode =3D ppc_md.pci_probe_mode(bus);
> +
> +	pr_debug("    probe mode: %d\n", mode);
> +	if (mode =3D=3D PCI_PROBE_DEVTREE)
> +		of_scan_bus(hose->dn, bus);
> +
> +	if (mode =3D=3D PCI_PROBE_NORMAL) {
> +		pci_bus_update_busn_res_end(bus, 255);
> +		hose->last_busno =3D pci_scan_child_bus(bus);
> +		pci_bus_update_busn_res_end(bus, hose->last_busno);
> +	}
> +
> +	return pci_bus_child_max_busnr(bus);
> +}
> +
I'm having trouble convincing myself that this patch covers every
variation within our PCI implementations. In particular, there's a
stanza in of_scan_pci_bridge in kernel/pci_of_scan.c that's almost
identical to this function. Does that implementation need to be cleaned
up and replaced with this function too?


> @@ -1641,9 +1655,9 @@ void pcibios_scan_phb(struct pci_controller *hose)
>  		ppc_md.pcibios_fixup_phb(hose);
> =20
>  	/* Configure PCI Express settings */
> -	if (bus && !pci_has_flag(PCI_PROBE_ONLY)) {
> +	if (host->bus && !pci_has_flag(PCI_PROBE_ONLY)) {
>  		struct pci_bus *child;
> -		list_for_each_entry(child, &bus->children, node)
> +		list_for_each_entry(child, &host->bus->children, node)
>  			pcie_bus_configure_settings(child);
>  	}
>  }
Two things: Firstly, the function uses hose throughout, not host.
Secondly, you're not deleting the bus variable: what's the purpose of
this change?

Regards,
Daniel


--=-f8VqFOdjSIDYlQlsKBNk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: GPGTools - https://gpgtools.org

iQIcBAABCAAGBQJVEfo/AAoJEPC3R3P2I92FxmIQAIshxMc6nPL6aTLS4mmTONnj
6s9KW71n2ni64pT74/Q97KF4YJ/KLAPPNUpOZtZ46MbLtCXyFkZyxGtb+dArOUfy
1G0LpoZOk06zszw/KuNwRSscZEYWf7AT35E4/BlONWjoPoNL2BQUexICrd38+/aE
gV6zZfWZJrRzWtdxAIMsyoz33bKhRJgf6WGBGwh8aJj9TtXCc/Bz9UZT4ZbhIkWG
QH7jly1n06OPXTn6Ap74VlbIGDnJBtvfm+hduFXqL5NlgmZJh9YSktjpq4PgmWVT
EcNE5xfHyD884GpxYjckWqC+qKUynrFMtGT2a7t3HoylfcCQSbdYScAw4VHbDUR8
yEvtbuWvoKUxdGKG8xBbNwIVkASoZMSld377hC9WVO5b42670JMIncGCZOr4svO0
cCufQm9i01cplYD25rEwU7GEI7ZU+JLKsb/gihBmjht37Z4wjMtsiAgl+zuY9Tb5
ilIUJJb00sXCLKYWhenplcVrTxX8RUbrU3FUG5M4FM+/WDYVLiMRcjTJshC897Em
N/K2kXAYLYAi4THnRwS8wqFeYqEYUSKaTC2kz/LcEAg0rUwt1VPvwMJu/HeaBNLu
b6Tpgf3QKihKqv78cY4oACebmzaSQBXPPs2p4uM5v/Xuk3M2KKWzcFdbXnBRiBk4
wOFxmReRgVfXP7L2rniG
=dWhE
-----END PGP SIGNATURE-----

--=-f8VqFOdjSIDYlQlsKBNk--

