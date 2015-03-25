From: Daniel Axtens <dja@axtens.net>
Date: Wed, 25 Mar 2015 22:13:51 +0000
Subject: Re: [PATCH v8 19/30] powerpc/pci: Use pci_scan_host_bridge() for simplicity
Message-Id: <1427321631.2575.3.camel@axtens.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-kGkB4ipJ9dr1gy57APLQ"
List-Id: <linux-ia64.vger.kernel.org>
References: <1427168064-8657-1-git-send-email-wangyijing@huawei.com>
		 <1427168064-8657-20-git-send-email-wangyijing@huawei.com>
	 <1427241523.2685.18.camel@axtens.net> <551266DE.3030609@huawei.com>
In-Reply-To: <551266DE.3030609@huawei.com>
To: Yijing Wang <wangyijing@huawei.com>
Cc: Liviu Dudau <liviu@dudau.co.uk>, Rusty Russell <rusty@rustcorp.com.au>, linux-ia64@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Marc Zyngier <marc.zyngier@arm.com>, linux-pci@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, linuxppc-dev@lists.ozlabs.org, linux-m68k@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, linux-alpha@vger.kernel.org, Bjorn Helgaas <bhelgaas@google.com>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@linux.intel.com>, linux-arm-kernel@lists.infradead.org


--=-kGkB4ipJ9dr1gy57APLQ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Yijing,

I wasn't quite sure I understood your comments, so I was trying to apply
your patch series and test it, but patch 3 doesn't apply cleanly to
4.0-rc5 or master. Can you respin the series?

Thanks,
Daniel


> Hi Daniel, thanks for your review and comments. We want to make a generic=
 pci_host_bridge,
> which would hold the common host information, for example, pci domain is =
common info for
> pci host bridge, this series saved domain in pci_host_bridge, then we no =
need to
> extract out domain by pci_bus->sysdata by platform specific pci_domain_nr=
().
> Also we store the sysdata in pci_host_bridge, and pci_bus_to_host() is th=
e platform
> interface, I think use the common interface would be better.
>=20
> >> +
> >> +	/* Get probe mode and perform scan */
> >> +	if (hose->dn && ppc_md.pci_probe_mode)
> >> +		mode =3D ppc_md.pci_probe_mode(bus);
> >> +
> >> +	pr_debug("    probe mode: %d\n", mode);
> >> +	if (mode =3D=3D PCI_PROBE_DEVTREE)
> >> +		of_scan_bus(hose->dn, bus);
> >> +
> >> +	if (mode =3D=3D PCI_PROBE_NORMAL) {
> >> +		pci_bus_update_busn_res_end(bus, 255);
> >> +		hose->last_busno =3D pci_scan_child_bus(bus);
> >> +		pci_bus_update_busn_res_end(bus, hose->last_busno);
> >> +	}
> >> +
> >> +	return pci_bus_child_max_busnr(bus);
> >> +}
> >> +
> > I'm having trouble convincing myself that this patch covers every
> > variation within our PCI implementations. In particular, there's a
> > stanza in of_scan_pci_bridge in kernel/pci_of_scan.c that's almost
> > identical to this function. Does that implementation need to be cleaned
> > up and replaced with this function too?
> >=20
>=20
> This is a pci_host_bridge_ops hook function, which would be called in
> PCI core, and after applied this series, we only need to call pci_scan_ho=
st_bridge()
> to scan pci devices, and this function is also extracted from the pcibios=
_scan_phb(),
> it's not the redundant code.
>=20
> >=20
> >> @@ -1641,9 +1655,9 @@ void pcibios_scan_phb(struct pci_controller *hos=
e)
> >>  		ppc_md.pcibios_fixup_phb(hose);
> >> =20
> >>  	/* Configure PCI Express settings */
> >> -	if (bus && !pci_has_flag(PCI_PROBE_ONLY)) {
> >> +	if (host->bus && !pci_has_flag(PCI_PROBE_ONLY)) {
> >>  		struct pci_bus *child;
> >> -		list_for_each_entry(child, &bus->children, node)
> >> +		list_for_each_entry(child, &host->bus->children, node)
> >>  			pcie_bus_configure_settings(child);
> >>  	}
> >>  }
> > Two things: Firstly, the function uses hose throughout, not host.
> > Secondly, you're not deleting the bus variable: what's the purpose of
> > this change?
>=20
> host is the common pci_host_bridge which is created by PCI core for pci h=
ost bridge driver,
> the hose is the platform data used in powerpc. The purpose of the patch/s=
eries is to simplify
> pci enumeration interface, and try to reduce the weak functions which wer=
e used to setup pci bus/devices
> during PCI enumeration.
>=20
> >=20
> > Regards,
> > Daniel
> >=20
>=20
>=20


--=-kGkB4ipJ9dr1gy57APLQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: GPGTools - https://gpgtools.org

iQIcBAABCAAGBQJVEzM2AAoJEPC3R3P2I92FQZwP/R5SRv7SsQeRdyiOrXCMLC7a
JfCwcSHgDdhyWYCAYuSeOKjJjPiDz9QNm9KS8ntynhe6VJVBGcHpLslWxZTpI9Dl
PHO/1b4i68YKxmjeXk19bQa38wDmuGxw8+ni1XX2ZzTIvm3fvOy9JZefde2lebi1
dB/D0GSRQu7CcuKcyEYWEyvqwbfPqb8VbiKpEFUiImjMFjboP6Yl5dOcVye0NNnQ
J36BOPHBj/FvIwK1ySUe5BE5mHjQUDijj9NkfqE5ED5Inf+/kjRYp9l0uBh3m8O1
oGbpMp0b/7L0cXk4WuF0UFcaNkkI7+n24O2QJ8tBCIL8B+9U7nb41xqTcI2kbWGE
9uKGGUDHQI1pERNtDKgLOsD+tFuyHo8oI99Oc8GFfWPnbvr576qEBBQaQI6Dwpdi
dbejgs48MB8IRVdur3oWu8uibQhUddtk02CIfpTF3OT7rx9ay/CKC8NX/odUGtY6
AYqqzNF6OxlfZXhrlS1nE1YWFacX+PKRiqulsgDE4peyq9cGse9ZYrOkkyL9VXdy
ja3H43wace2qaa0JpzOu//uN/vULylpSh8QOfeqgLRCDlF29NbKn23gNbhzr+4yw
xASO+O4SAR1IKM0hW2mqLE4/1TI8cDj5jX5emAhnCZi3uCnPkEAbq9C9ZqfJ2hEP
+2/0/9fEImcp/ma9tmc1
=I0so
-----END PGP SIGNATURE-----

--=-kGkB4ipJ9dr1gy57APLQ--

