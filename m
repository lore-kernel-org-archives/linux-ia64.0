From: Martin Pool <mbp@sourcefrog.net>
Date: Fri, 16 Jan 2004 07:01:47 +0000
Subject: Re: a question about memory access on IA64
Message-Id: <20040116070147.GC766@happy.sourcefrog.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="VywGB/WGlW4DM4P8"
List-Id: <linux-ia64.vger.kernel.org>
References: <40075464.6010202@sinosoft.com.cn>
In-Reply-To: <40075464.6010202@sinosoft.com.cn>
To: linux-ia64@vger.kernel.org


--VywGB/WGlW4DM4P8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Please reply to the list, not to me.

On 16 Jan 2004, liuduo <liuduo@sinosoft.com.cn> wrote:
> Martin Pool wrote:
> >On 16 Jan 2004, liuduo <liuduo@sinosoft.com.cn> wrote:
> >>David:
> >>Sorry, i only describe the process about the error occurs .
> >>
> >>  typedef struct b{
> >>    char*  pDescriptName;
> >>    char*           pVendorName;
> >>    unsigned int	RevisionID;
> >>   }B;
> >>
> >>  typedef struct pci{
> >>   int c;
> >>   struct b bb[512];
> >>   }PCI;
> >>
> >>int main()
> >>{
> >>
> >>
> >>   struct pci a;
> >>
> >>   //function for operation a
> >>   func(&a);
> >>   return 0;
> >>}
> >>
> >
> >>the func is in an lib, it's an lib export function, and the func is as=
=20
> >>follows;
> >>
> >
> >Do you mean that it works if you use the first struct definition, and
> >if you pu the func into the same file?=20
> >
> yes
>=20
> >Does it have to be in a
> >library to fail?
> >
> yes
>=20
> >
> >
> >Could it be that you are using different structure packing for
> >building the library, either through compiler options or #pragmas in
> >some other header file?
> >
> we use the #pragma pack (1)  in the file that the func is in it.

Don't do that then.  If you access a struct with different packing
conventions, your program will lose its fingers.

> >>func(struct pci* a)
> >>{
> >>    char tmp[256];
> >>   for(num=3D0;num<512;num++)
> >>   {
> >>    a->bb[num].pDescriptName =3D (char*)malloc(100);
> >>    strcpy(a->bb[num].pDescriptName , "dddd");
> >>    a->bb[num].pVendorName =3D (char*)malloc(100);
> >>    strcpy(a->bb[num].pVendorName , "fffff");
> >>    a->bb[num].RevisionID =3D 22;
> >>   }
> >>   a->c =3D 512;
> >>}
> >>when call the func , the segmentation fault occurs,
> >>and then we modified the struct A as follows
> >>   typedef struct pci{
> >>   struct b bb[512];
> >>   int c;
> >>   }PCI;
> >>it's normal.
> >>please tell me why?
> >>thanks a lot.

--=20
Martin

--VywGB/WGlW4DM4P8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFAB4xbPGPKP6Cz6IsRAsc1AJ0WIA9TEWiJuCMA8Cp7hcWbjL9pywCfbVuh
FTRET8kfdiHNe44KHKkaCS8=
=aPdv
-----END PGP SIGNATURE-----

--VywGB/WGlW4DM4P8--
