From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Fri, 03 Nov 2006 01:19:24 +0000
Subject: RE: 05e0caad3b7bd0d0fbeff980bca22f186241a501 breaks ia64 kdump
Message-Id: <10EA09EFD8728347A513008B6B0DA77A086B10@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061026075951.GA30910@verge.net.au>
In-Reply-To: <20061026075951.GA30910@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org
> [mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Zou, Nanhai
> Sent: 2006=C4=EA11=D4=C23=C8=D5 8:29
> To: Mel Gorman; Horms
> Cc: Andy Whitcroft; linux-ia64@vger.kernel.org; Bob Picco; Andrew Morton;=
 Dave
> Hansen; Andi Kleen; Benjamin Herrenschmidt; Paul Mackerras; Keith Mannthe=
y;
> Luck, Tony; KAMEZAWA Hiroyuki; Yasunori Goto; Khalid Aziz
> Subject: RE: 05e0caad3b7bd0d0fbeff980bca22f186241a501 breaks ia64 kdump
>=20
> Hi,
> 	This patch should fix the issue.
>=20
> Thanks
> Zou Nan hai

Some description of the issue,
	When ia64 kernel is configured as discontinuous memory model,=20
active_pages are added through efi_memmap_walk(filter_rsvd_memory, count_no=
de_pages).=20
filter_rsvd_memory  will filter out all regions in rsvd_regions include=20
- boot param
- mem map
- initrd
- command line
- **** kernel code and data ***
- kernel map built from efi memmap
- crash kernel reserved region
So the kernel code and data is excluded even without kdump support,
check /proc/iomem and dmesg for early_node_data can verify that.
But magically, the first kernel boots happily without any complain...,
I guess that is related to the init value in memmap.=20

This patch use another filter to add_acvitive_pages, only exclude crash ker=
nel reserved region if CONFIG_KEXEC is on.

However I am still not understand what the start =3D OREDERROUNDDOWN(start)=
 in cound_node_page is used for, it round up mem_data[node].min_pfn to a ve=
ry huge alignment.
I guess we can get rid of this by not using filter_rsvd_memory to call coun=
t_node_pages.

Thanks
Zou Nan hai









