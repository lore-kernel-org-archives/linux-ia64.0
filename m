From: Martin Waitz <tali@admingilde.org>
Date: Tue, 05 Sep 2006 11:20:57 +0000
Subject: Re: [RFC][PATCH 3/9] actual generic PAGE_SIZE infrastructure
Message-Id: <20060905112056.GJ17042@admingilde.org>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="EVh9lyqKgK19OcEf"
List-Id: <linux-ia64.vger.kernel.org>
References: <20060830221604.E7320C0F@localhost.localdomain> <20060830221606.40937644@localhost.localdomain>
In-Reply-To: <20060830221606.40937644@localhost.localdomain>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org


--EVh9lyqKgK19OcEf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

hoi :)

On Wed, Aug 30, 2006 at 03:16:06PM -0700, Dave Hansen wrote:
> * Define ASM_CONST() macro to help using constants in both assembly
>   and C code.  Several architectures have some form of this, and
>   they will be consolidated around this one.

arm uses UL() for this and I think this is much more readable than
ASM_CONST().  Can we please change the name of this macro?

--=20
Martin Waitz

--EVh9lyqKgK19OcEf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFE/V2Yj/Eaxd/oD7IRAlW5AJwOaK27o73iX/riP1NB2LyQjw9uxACffAu8
r+mLEYn/BZ3UAWoHDopViS8=
=WfbZ
-----END PGP SIGNATURE-----

--EVh9lyqKgK19OcEf--
