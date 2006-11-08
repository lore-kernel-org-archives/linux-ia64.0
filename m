From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Wed, 08 Nov 2006 02:01:04 +0000
Subject: RE: [PATCH]send slave cpus to SAL slave loop on crash (IA64)
Message-Id: <10EA09EFD8728347A513008B6B0DA77A086B13@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4546623D.5000105@engr.sgi.com>
In-Reply-To: <4546623D.5000105@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> -----Original Message-----
> From: Jay Lan [mailto:jlan@sgi.com]
> Sent: 2006=C4=EA11=D4=C24=C8=D5 1:42
> To: Zou, Nanhai
> Cc: fastboot; Linux-IA64; Jack Steiner; Luck, Tony
> Subject: Re: [PATCH]send slave cpus to SAL slave loop on crash (IA64)
>=20
> Zou, Nanhai wrote:
> >   --noio patch should be the same to my original sugguestion..., it byp=
ass
> all PIO and MMIO in purgatory with --noio option. I need to have a check =
though.
>=20
> Hi Nanhai,
>=20
> I finally got a chance to look at this further.
>=20
> Your patch touched four files:
>     kexec/arch/ia64/kexec-elf-ia64.c
>     purgatory/arch/ia64/entry.S
>     purgatory/arch/ia64/include/arch/io.h
>     purgatory/arch/ia64/io.h
>=20
> I replaced both of the io.h with my version and it still
> failed. So, it should be the way --noio option being handled
> that made the difference.
>=20
> I did have debug messages showing that "noio" option was
> processed in elf_rel_set_symbol() in my testing. Does
> kernel code need to know about this option? Somehow
> this change makes kernel fail in init().
>=20
  No, kernel does not need to know this. Kexec-tools pass this option to pu=
rgatory code by relocating at kexec load time.

 Zou Nan hai
