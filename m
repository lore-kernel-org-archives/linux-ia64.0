From: "Siddha, Suresh B" <suresh.b.siddha@intel.com>
Date: Fri, 16 Nov 2001 18:44:38 +0000
Subject: RE: [Linux-ia64] PATCH: Fix for 4KB kernel corruption
Message-Id: <marc-linux-ia64-105590698805530@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805523@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805523@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi Philippe,

You may or mayn't see this problem. It depends up on the EFI memory map. In
our case, it is so happening that bootmap is allocated from the end of one
of the reserved regions and corrupting that reserved region.

Thanks,
Suresh

> -----Original Message-----
> From: Philippe Gramoull=E9 [mailto:philippe.gramoulle@mmania.com]
> Sent: Friday, November 16, 2001 2:24 AM
> To: Siddha, Suresh B
> Cc: linux-ia64@linuxia64.org
> Subject: Re: [Linux-ia64] PATCH: Fix for 4KB kernel corruption
>=20
>=20
>=20
> Hi Siddha,
>=20
> Can this corruption happen with on lion with 4Go of memory also ?
>=20
> Thanks,
>=20
> Philippe.
>=20
> "Siddha, Suresh B" wrote:
> >=20
> > Hi,
> >=20
> > 4KB page size kernel is broken on Lion with 8GB memory.=20
> ia64_boot_param
> > structure was getting corrupted. Appended patch fixes this problem.
> >=20
> > PAGE_ALIGN is required because: rsvd_region[i].end need not=20
> be page aligned
> > and in the next iteration of the for loop this can=20
> potentially become
> > bootmap_start. This can lead to corruption of rsvd_region[i] as
> > init_bootmem() takes the pfn of bootmap_start and=20
> initialises the bootmem.
> >=20
> > Thanks,
> > Suresh
> >=20
> > diff -u linux-2.4.14/arch/ia64/kernel/setup.c~
> > linux-2.4.14/arch/ia64/kernel/setup.c
> > --- linux-2.4.14/arch/ia64/kernel/setup.c~      Thu Nov 15=20
> 16:27:23 2001
> > +++ linux-2.4.14/arch/ia64/kernel/setup.c       Thu Nov 15=20
> 16:28:01 2001
> > @@ -175,7 +175,7 @@
> >                 /* nothing more available in this segment */
> >                 if (range_end =3D=3D end) return 0;
> >=20
> > -               free_start =3D rsvd_region[i].end;
> > +               free_start =3D PAGE_ALIGN(rsvd_region[i].end);
> >         }
> >         return 0;
> >  }
> >=20
> > _______________________________________________
> > Linux-IA64 mailing list
> > Linux-IA64@linuxia64.org
> > http://lists.linuxia64.org/lists/listinfo/linux-ia64
>=20

