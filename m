From: Daniel Axtens <dja@axtens.net>
Date: Mon, 06 Apr 2015 23:35:34 +0000
Subject: Re: [PATCH v9 19/30] powerpc/pci: Use pci_scan_host_bridge() for simplicity
Message-Id: <1428363334.22268.9.camel@axtens.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-JBi1R6/zCXZTQ4qH8SNQ"
List-Id: <linux-ia64.vger.kernel.org>
References: <1428053164-28277-1-git-send-email-wangyijing@huawei.com>
	 <1428053164-28277-21-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1428053164-28277-21-git-send-email-wangyijing@huawei.com>
To: Yijing Wang <wangyijing@huawei.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>, Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, linuxppc-dev@lists.ozlabs.org


--=-JBi1R6/zCXZTQ4qH8SNQ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

I've been looking at this patch series for a while now, and I now
believe it's ready on the PowerPC side.

I was originally concerned that it would break odd corner cases,
particularly where similar code appears (namely kernel/pci_hotplug.c and
kernel/pci_of_scan.c). However, upon further examination, talking with
Yijing, and some testing, I'm now convinced that it is indeed restricted
to the generic code, and doesn't change behaviour.

This is both a plus and a minus: because it's currently restricted to
generic code, I'm confident it works, but the down side is that it
doesn't yet simplify our arch-specific complexity. We'll need to do some
more work on our side to reap the full benefits.

I tested this entire series on a PowerNV machine, including doing EEH
injection to trigger PCI hotplug:
Tested-by: Daniel Axtens <dja@axtens.net>
For completeness, it would be good to test it on Cell, as they are the
only remaining user of pci_of_scan.c

In conclusion, this patch is
Reviewed-by: Daniel Axtens <dja@axtens.net>

Regards,
Daniel Axtens


On Fri, 2015-04-03 at 17:25 +0800, Yijing Wang wrote:
> Now we could use pci_scan_host_bridge() to scan
> pci buses, provide powerpc specific pci_host_bridge_ops.
>=20
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
> CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> CC: linuxppc-dev@lists.ozlabs.org
> ---
>  arch/powerpc/kernel/pci-common.c |   62 +++++++++++++++++++++++---------=
-----
>  1 files changed, 38 insertions(+), 24 deletions(-)
>=20
> diff --git a/arch/powerpc/kernel/pci-common.c b/arch/powerpc/kernel/pci-c=
ommon.c
> index 2c58200..50b32f6 100644
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
>  /* This header fixup will do the resource fixup for all devices as they =
are
>   * probed, but not for bridge ranges
>   */
> @@ -1585,6 +1608,11 @@ struct device_node *pcibios_get_phb_of_node(struct=
 pci_bus *bus)
>  	return of_node_get(hose->dn);
>  }
> =20
> +static struct pci_host_bridge_ops pci_host_ops =3D {
> +	.set_root_bus_speed =3D pcibios_set_root_bus_speed,
> +	.scan_bus =3D pci_host_scan_bus,
> +};
> +
>  /**
>   * pci_scan_phb - Given a pci_controller, setup and scan the PCI bus
>   * @hose: Pointer to the PCI host controller instance structure
> @@ -1592,9 +1620,8 @@ struct device_node *pcibios_get_phb_of_node(struct =
pci_bus *bus)
>  void pcibios_scan_phb(struct pci_controller *hose)
>  {
>  	LIST_HEAD(resources);
> -	struct pci_bus *bus;
> +	struct pci_host_bridge *host;
>  	struct device_node *node =3D hose->dn;
> -	int mode;
> =20
>  	pr_debug("PCI: Scanning PHB %s\n", of_node_full_name(node));
> =20
> @@ -1609,30 +1636,17 @@ void pcibios_scan_phb(struct pci_controller *hose=
)
>  	hose->busn.flags =3D IORESOURCE_BUS;
>  	pci_add_resource(&resources, &hose->busn);
> =20
> +	pci_host_ops.pci_ops =3D hose->ops;
>  	/* Create an empty bus for the toplevel */
> -	bus =3D pci_create_root_bus(hose->parent, hose->global_number,
> -			hose->first_busno, hose->ops, hose, &resources);
> -	if (bus =3D=3D NULL) {
> -		pr_err("Failed to create bus for PCI domain %04x\n",
> -			hose->global_number);
> +	host =3D pci_scan_host_bridge(hose->parent, hose->global_number,
> +			hose->first_busno, hose, &resources, &pci_host_ops);
> +	if (host =3D=3D NULL) {
> +		pr_err("Failed to create host bridge for pci%04x:%02x\n",
> +			hose->global_number, hose->first_busno);
>  		pci_free_resource_list(&resources);
>  		return;
>  	}
> -	hose->bus =3D bus;
> -
> -	/* Get probe mode and perform scan */
> -	mode =3D PCI_PROBE_NORMAL;
> -	if (node && ppc_md.pci_probe_mode)
> -		mode =3D ppc_md.pci_probe_mode(bus);
> -	pr_debug("    probe mode: %d\n", mode);
> -	if (mode =3D=3D PCI_PROBE_DEVTREE)
> -		of_scan_bus(node, bus);
> -
> -	if (mode =3D=3D PCI_PROBE_NORMAL) {
> -		pci_bus_update_busn_res_end(bus, 255);
> -		hose->last_busno =3D pci_scan_child_bus(bus);
> -		pci_bus_update_busn_res_end(bus, hose->last_busno);
> -	}
> +	hose->bus =3D host->bus;
> =20
>  	/* Platform gets a chance to do some global fixups before
>  	 * we proceed to resource allocation
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


--=-JBi1R6/zCXZTQ4qH8SNQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: GPGTools - https://gpgtools.org

iQIcBAABCAAGBQJVIxhSAAoJEPC3R3P2I92FGEkQAM0to7tMdeHcxvzb0mN4AVKY
G2iyNjiSb0olgDa9iCjsJxr6Eg0cnL2kTSng+iWIyAywCEL8P438f2QX1bcRiLL4
vhmsLAwpr6pf4kloaol/T8oFrg+uFRlTdiJE1D0omL94qj0A5INeDy7e9PwY+wrE
mugTHnCG/O5O/DOthK+cPZ59BISZaKga4Uor6C7AgKiitsNQgNFWMOtLhpuKKUtD
7OlbKc4HhTY40rJWikevOAlY/d5Hq1w3s0yvhugX4ForUes7frq4qMRtKRacS/Vg
WMKF/9js3pX5S0YIscFe/A8UMT35wPfNwJUjHKPgWrQdOVw8ipAs0ga2F9bK6ipX
6F/6d7DSDeNHpvFoS4A+zn/2wTjBGbNfKyO5c+hJFjlmRN4dRfA5MvQS3+vXrDC7
muZuY6pwH2lsTM8UgwfXbmwOfOh47c0ohNLuX3Wpfkjz3jvuAUjyKAqFjwsdh3NW
bWPv7ay1W1GcXJhfCI+5dK2MZzQ1JmGZnH/M8cl5qLiOSVlNgKXJxFVt3PEDZzB+
CKe0wSbtw528pC2/P/utk4kFzEK+QMVCzi1H80b6XhFvgZLpU1bzLSZQR0p6C4g4
2O46VVKu7alxphGyIlTavVXGiJzo8GoAgLSceHF3bnxwtizPF0yJN3Y9fQYxXh7Z
bc65BhJ/bJiVnJXJx+gj
=CqP4
-----END PGP SIGNATURE-----

--=-JBi1R6/zCXZTQ4qH8SNQ--

