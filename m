From: "Zhu, Yi" <yi.zhu@intel.com>
Date: Thu, 25 Dec 2003 01:11:33 +0000
Subject: Re: segv at strcmp
Message-Id: <marc-linux-ia64-107231504814264@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107230762310061@msgid-missing>
In-Reply-To: <marc-linux-ia64-107230762310061@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Thu, 25 Dec 2003, umut aymakoglu wrote:

> We have hit a problem with strcmp() on UnitedLinux 1.0
> with kernel: 2.4.19 and glibc: 2.2.5.
> I am wondering if anybody has seen something like it
> or knows if already there is a patch. I do not have a
> small repro but i will try to explain:
>=20
> The segv happens at memcmp() at a line like:
> 'strcmp(x, "this is 24 chars long")' where x is a char
> pointer with a length of 7 and the constant has a
> length of 24. x is located at the first 8 bytes of the
> last 16 bytes at the end of a non-contiguous shared
> memory segment. memcmp() segvs when it tries to load 8
> bytes from the "r19" register which initially has the
> address of x and points to the end of the segment when
> the segv happens.

I met the similar scenario for strchr(), it was fixed after I explicitly
adding a #include <string.h>.

> any help would be appreciated,
> thanks,
> Umut
>=20
>=20
> __________________________________
> Do you Yahoo!?
> New Yahoo! Photos - easier uploading and sharing.
> http://photos.yahoo.com/
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at=A0 http://vger.kernel.org/majordomo-info.html
>=20
> FLAGS (\Seen \Recent))
>=20

--=20
-----------------------------------------------------------------
Opinions expressed are those of the author and do not represent
Intel Corp.

Zhu Yi (Chuyee)
Intel China Software Lab (ICSL)
22nd Floor, ShanghaiMart Tower No. 2299 Yan'an Road(West)
Shanghai 200336, PRC
Tel: 8621-52574545-1261
Fax: 8621-62360011

GnuPG v1.0.6 (GNU/Linux)
http://cn.geocities.com/chewie_chuyee/gpg.txt or
$ gpg --keyserver wwwkeys.pgp.net --recv-keys 71C34820
1024D/71C34820 C939 2B0B FBCE 1D51 109A  55E5 8650 DB90 71C3 4820

