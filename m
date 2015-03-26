From: Daniel Axtens <dja@axtens.net>
Date: Thu, 26 Mar 2015 05:19:40 +0000
Subject: Re: [PATCH v8 19/30] powerpc/pci: Use pci_scan_host_bridge() for simplicity
Message-Id: <1427347180.2575.91.camel@axtens.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-EtOc/hYhLJzchjc4+T9t"
List-Id: <linux-ia64.vger.kernel.org>
References: <1427168064-8657-1-git-send-email-wangyijing@huawei.com>
			 <1427168064-8657-20-git-send-email-wangyijing@huawei.com>
		 <1427241523.2685.18.camel@axtens.net> <551266DE.3030609@huawei.com>
	 <1427321631.2575.3.camel@axtens.net> <55135E16.6060909@huawei.com>
In-Reply-To: <55135E16.6060909@huawei.com>
To: Yijing Wang <wangyijing@huawei.com>
Cc: Liviu Dudau <liviu@dudau.co.uk>, Rusty Russell <rusty@rustcorp.com.au>, linux-ia64@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Marc Zyngier <marc.zyngier@arm.com>, linux-pci@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, linuxppc-dev@lists.ozlabs.org, linux-m68k@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, linux-alpha@vger.kernel.org, Bjorn Helgaas <bhelgaas@google.com>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@linux.intel.com>, linux-arm-kernel@lists.infradead.org


--=-EtOc/hYhLJzchjc4+T9t
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Yijing,

Pulled.

I'm now getting build errors:

/scratch/dja/linux-patches/arch/powerpc/kernel/pci-common.c: In function 'p=
cibios_scan_phb':
/scratch/dja/linux-patches/arch/powerpc/kernel/pci-common.c:1638:14: error:=
 'bus' undeclared (first use in this function)
/scratch/dja/linux-patches/arch/powerpc/kernel/pci-common.c:1638:14: note: =
each undeclared identifier is reported only once for each function it appea=
rs in

That relates to your changes to pcibios_scan_phb:
-       struct pci_bus *bus;
+       struct pci_host_bridge *host;
clashing with line 1638:
	hose->bus =3D bus;
which occurs later in the same unction.

If I fix that, I'll get more errors with lines in that function that
still reference hose instead of host.

As well as line 1638, there's still big chunks of the function that
reference hose, for example:

	/* Get some IO space for the new PHB */
	pcibios_setup_phb_io_space(hose);

	/* Wire up PHB bus resources */
	pcibios_setup_phb_resources(hose, &resources);

	hose->busn.start =3D hose->first_busno;
	hose->busn.end	 =3D hose->last_busno;
	hose->busn.flags =3D IORESOURCE_BUS;
	pci_add_resource(&resources, &hose->busn);

	pci_host_ops.pci_ops =3D hose->ops;


Basically, the changes in PowerPC need to be quite a bit more through
just to get the changes to build.

I'm keen to work on simplifying PCI code in PowerPC, but at this point,
it will need a lot more work before it's ready to go in.

Regards,
Daniel


On Thu, 2015-03-26 at 09:17 +0800, Yijing Wang wrote:
> On 2015/3/26 6:13, Daniel Axtens wrote:
> > Hi Yijing,
> >=20
> > I wasn't quite sure I understood your comments, so I was trying to appl=
y
> > your patch series and test it, but patch 3 doesn't apply cleanly to
> > 4.0-rc5 or master. Can you respin the series?
>=20
> Hi Daniel,
>    Could you pull the series from Bjorn's git tree ? The URL is
> https://git.kernel.org/pub/scm/linux/kernel/git/helgaas/pci.git pci/enume=
ration-yw8
>=20
> Thanks!
> Yijing.
>=20
> >=20
> > Thanks,
> > Daniel
> >=20
> >=20
> >> Hi Daniel, thanks for your review and comments. We want to make a gene=
ric pci_host_bridge,
> >> which would hold the common host information, for example, pci domain =
is common info for
> >> pci host bridge, this series saved domain in pci_host_bridge, then we =
no need to
> >> extract out domain by pci_bus->sysdata by platform specific pci_domain=
_nr().
> >> Also we store the sysdata in pci_host_bridge, and pci_bus_to_host() is=
 the platform
> >> interface, I think use the common interface would be better.
> >>
> >>>> +
> >>>> +	/* Get probe mode and perform scan */
> >>>> +	if (hose->dn && ppc_md.pci_probe_mode)
> >>>> +		mode =3D ppc_md.pci_probe_mode(bus);
> >>>> +
> >>>> +	pr_debug("    probe mode: %d\n", mode);
> >>>> +	if (mode =3D=3D PCI_PROBE_DEVTREE)
> >>>> +		of_scan_bus(hose->dn, bus);
> >>>> +
> >>>> +	if (mode =3D=3D PCI_PROBE_NORMAL) {
> >>>> +		pci_bus_update_busn_res_end(bus, 255);
> >>>> +		hose->last_busno =3D pci_scan_child_bus(bus);
> >>>> +		pci_bus_update_busn_res_end(bus, hose->last_busno);
> >>>> +	}
> >>>> +
> >>>> +	return pci_bus_child_max_busnr(bus);
> >>>> +}
> >>>> +
> >>> I'm having trouble convincing myself that this patch covers every
> >>> variation within our PCI implementations. In particular, there's a
> >>> stanza in of_scan_pci_bridge in kernel/pci_of_scan.c that's almost
> >>> identical to this function. Does that implementation need to be clean=
ed
> >>> up and replaced with this function too?
> >>>
> >>
> >> This is a pci_host_bridge_ops hook function, which would be called in
> >> PCI core, and after applied this series, we only need to call pci_scan=
_host_bridge()
> >> to scan pci devices, and this function is also extracted from the pcib=
ios_scan_phb(),
> >> it's not the redundant code.
> >>
> >>>
> >>>> @@ -1641,9 +1655,9 @@ void pcibios_scan_phb(struct pci_controller *h=
ose)
> >>>>  		ppc_md.pcibios_fixup_phb(hose);
> >>>> =20
> >>>>  	/* Configure PCI Express settings */
> >>>> -	if (bus && !pci_has_flag(PCI_PROBE_ONLY)) {
> >>>> +	if (host->bus && !pci_has_flag(PCI_PROBE_ONLY)) {
> >>>>  		struct pci_bus *child;
> >>>> -		list_for_each_entry(child, &bus->children, node)
> >>>> +		list_for_each_entry(child, &host->bus->children, node)
> >>>>  			pcie_bus_configure_settings(child);
> >>>>  	}
> >>>>  }
> >>> Two things: Firstly, the function uses hose throughout, not host.
> >>> Secondly, you're not deleting the bus variable: what's the purpose of
> >>> this change?
> >>
> >> host is the common pci_host_bridge which is created by PCI core for pc=
i host bridge driver,
> >> the hose is the platform data used in powerpc. The purpose of the patc=
h/series is to simplify
> >> pci enumeration interface, and try to reduce the weak functions which =
were used to setup pci bus/devices
> >> during PCI enumeration.
> >>
> >>>
> >>> Regards,
> >>> Daniel
> >>>
> >>
> >>
> >=20
>=20
>=20


--=-EtOc/hYhLJzchjc4+T9t
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: GPGTools - https://gpgtools.org

iQIcBAABCAAGBQJVE5bsAAoJEPC3R3P2I92FXz8QAM6EZdJbrxsM2bQA9Mazwkin
ZryfB+DSfP/TcFyOx7Hhw2Zz0OrxH6iUa+1/RdwWIzGOXMjhwMxA2CJIbU5YeEGu
9P4JquQto1g3aZcZLPku5eKiJlCooPBcwS7Zoir/PBAWyQg0EHjOw3yq2pWJl5nx
JLNCHZgEzdSFmTb1u0C+sAds5RoKwcijZZJJxWI6gtaj1gmOaLyDpX8GA1SlSd5C
wnthFTqOLmcac2iN1C172BiCsHTbc4MWUIBLTcrzqPz+/6z0XwsGDihYLAfwJdzn
XjRxtv9VLgfNZfwteTCcaF4b8eTCBfiPKyl5vPVosZOTgfZLzgKINemc5179zhHG
rS8qp1iOHOC+FTWYACnfLxD34CuytWQoBQLnGECuxJJgPFygjBg/AGX0Kh3HfWt4
CEo43dzVTcXlZ4vVr86cUnW9NFWKl7MVfzSGBkunvHHRkfLEBFV6ch1e5Hje7x/P
8UO60Stnq2HAJdarwGCzOZ0Ut4+a2K/7Yf6sx5TQeKzTGj5hDKSgSdDXb9gjaQpH
Tgl5FJnegZXsLLSHXcuo5dhlD1bVyhwaPWSGsPxdUKLGqnpuQYM/G5aBBcaXg5+2
C1+nJldjCsPWMImzJp0GG3UCxLAr+N3R41qnWzaanW67daQXebKsQzGUpny74IvD
Dr3JxwEt612+WPwsTEp2
=OlY6
-----END PGP SIGNATURE-----

--=-EtOc/hYhLJzchjc4+T9t--

