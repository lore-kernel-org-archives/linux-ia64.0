From: Martin Pool <mbp@sourcefrog.net>
Date: Fri, 16 Jan 2004 04:16:24 +0000
Subject: Re: a question about memory access on IA64
Message-Id: <20040116041624.GA766@happy.sourcefrog.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="IS0zKkzwUGydFO0o"
List-Id: <linux-ia64.vger.kernel.org>
References: <40075464.6010202@sinosoft.com.cn>
In-Reply-To: <40075464.6010202@sinosoft.com.cn>
To: linux-ia64@vger.kernel.org


--IS0zKkzwUGydFO0o
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 16 Jan 2004, liuduo <liuduo@sinosoft.com.cn> wrote:
> David:
> Sorry, i only describe the process about the error occurs .
>=20
>    typedef struct b{
>      char*  pDescriptName;
>      char*           pVendorName;
>      unsigned int	RevisionID;
>     }B;
>=20
>    typedef struct pci{
>     int c;
>     struct b bb[512];
>     }PCI;
>=20
> int main()
> {
>=20
>=20
>     struct pci a;
>=20
>     //function for operation a
>     func(&a);
>     return 0;
> }

> the func is in an lib, it's an lib export function, and the func is as=20
> follows;

Do you mean that it works if you use the first struct definition, and
if you pu the func into the same file?  Does it have to be in a
library to fail?

Could it be that you are using different structure packing for
building the library, either through compiler options or #pragmas in
some other header file?

>=20
> func(struct pci* a)
> {
>      char tmp[256];
>     for(num=3D0;num<512;num++)
>     {
>      a->bb[num].pDescriptName =3D (char*)malloc(100);
>      strcpy(a->bb[num].pDescriptName , "dddd");
>      a->bb[num].pVendorName =3D (char*)malloc(100);
>      strcpy(a->bb[num].pVendorName , "fffff");
>      a->bb[num].RevisionID =3D 22;
>     }
>     a->c =3D 512;
> }
> when call the func , the segmentation fault occurs,
> and then we modified the struct A as follows
>     typedef struct pci{
>     struct b bb[512];
>     int c;
>     }PCI;
> it's normal.
> please tell me why?
> thanks a lot.
> --=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> Liu duo
> tel:(010)62570007-509
> email:liuduo@sinosoft.com.cn
> Sinosoft Software.Co.Ltd.
> Esmpro Group.Secic Department
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
>=20
>=20
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--=20
Martin

"all the hardcore hackers use aol"
    - Joseph "joey" Sarrach <mrfr0sty@home.com>

--IS0zKkzwUGydFO0o
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFAB2WYPGPKP6Cz6IsRAtoCAKDUa4trgicpXHzj8NRdA6PZRmdXegCgvLPI
2VPo8wajEEbp6cC1J1f9QZ4=
=LqDl
-----END PGP SIGNATURE-----

--IS0zKkzwUGydFO0o--
