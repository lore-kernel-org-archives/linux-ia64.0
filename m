From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Mon, 20 Nov 2006 01:40:32 +0000
Subject: RE: 05e0caad3b7bd0d0fbeff980bca22f186241a501 breaks ia64 kdump
Message-Id: <10EA09EFD8728347A513008B6B0DA77A086B2D@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061026075951.GA30910@verge.net.au>
In-Reply-To: <20061026075951.GA30910@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> -----Original Message-----
> From: Luck, Tony
> Sent: 2006=C4=EA11=D4=C217=C8=D5 1:36
> To: Zou, Nanhai; 'Mel Gorman'
> Cc: 'Horms'; 'Andy Whitcroft'; 'Linux-IA64'; 'Bob Picco'; 'Andrew Morton';
> 'Dave Hansen'; 'Andi Kleen'; 'Benjamin Herrenschmidt'; 'Paul Mackerras';
> 'Keith Mannthey'; 'KAMEZAWA Hiroyuki'; 'Yasunori Goto'; 'Khalid Aziz'
> Subject: RE: 05e0caad3b7bd0d0fbeff980bca22f186241a501 breaks ia64 kdump
>=20
>=20
> > I think that depends on the init value of memmap, if they
> > are all zero, free_pages_check will be happy and not report
> > any thing. So I guess we may see this bug in normal kernel
> > with a warm reboot, or with a machine which PROM does not
> > clear memory to all zero.
>=20
> I don't think there is any requirement that PROM clear memory
> to zero ... if the kernel is making that assumption anywhere,
> then this is a bug.  I thought that the initialization code
> wrote to each of the fields of the page struct that it needed
> to (certainly ->count and ->flags are set by __free_pages_bootmem,
> but I'm not so sure about ->mapping ... which free_pages_check()
> looks at).
>
  Yes, so the add_active_range in discontigmem need fix.=20
  I think Bob's patch is ok, it is almost the same as mine except the CONFI=
G_KEXEC part. So we may first include Bob's patch, I will add CONFIG_KEXEC =
part after KEXEC_KDUMP patch is in mainstream.
  Thanks
  Zou Nan hai
> -Tony
