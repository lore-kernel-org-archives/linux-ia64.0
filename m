From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Thu, 01 Feb 2007 02:43:31 +0000
Subject: RE: [PATCH] IA64 kexec-tools: efi_memmap overflow on large systems
Message-Id: <10EA09EFD8728347A513008B6B0DA77A086BCA@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <45C1484E.3020300@sgi.com>
In-Reply-To: <45C1484E.3020300@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> -----Original Message-----
> From: Jay Lan [mailto:jlan@sgi.com]
> Sent: 2007=C4=EA2=D4=C21=C8=D5 9:54
> To: fastboot
> Cc: Linux-IA64; Zou, Nanhai
> Subject: [PATCH] IA64 kexec-tools: efi_memmap overflow on large systems
>=20
> This patch fixes a efi_memmap overflow problem on large system.
> Currently the kexec allocates statically 16k buffer to contain
> efi_memmap. It can hold about 333 entries. It causes data
> corruption on large system.
>=20
> This patch would let kexec allocate the efi_memmap at run time using
> the actual size allocated in the production kernel.
>=20
>=20
> Signed-off-by: Jay Lan <jlan@sgi.com>


Another hardcode limit needs to be eliminated, the CRASH_MAX_MEMORY_RANGE i=
n crashdump-ia64.c.=20
Since SN systems may scale to hundreds of nodes, each node may contain up t=
o 12 DIMMs.

I guess the current 1024 limit is not enough for those super computers.

So we need to count crash memory ranges from /proc/iomem and allocated cras=
h_memory_range dynamically.

Thanks
Zou Nan hai=20
  =20
