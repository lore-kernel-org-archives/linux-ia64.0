From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 17 Jun 2021 01:23:37 +0000
Subject: Re: + mm-rename-pud_page_vaddr-to-pud_pgtable-and-make-it-return-pmd_t.patch
Message-Id: <20210617112337.465c2607@canb.auug.org.au>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Sig_/a/+9AWFMGRAeBWcsE/82QFB"
List-Id: <linux-ia64.vger.kernel.org>
References: <20210615233808.hzjGO1gF2%akpm@linux-foundation.org>
        <202106162159.MurvDMy6-lkp@intel.com>
        <87zgvpnbl7.fsf@linux.ibm.com>
        <20210616160904.cf834ee8c9e7a26008aa833e@linux-foundation.org>
In-Reply-To: <20210616160904.cf834ee8c9e7a26008aa833e@linux-foundation.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, kernel test robot <lkp@intel.com>, linux-alpha@vger.kernel.org, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org, kbuild-all@lists.01.org

--Sig_/a/+9AWFMGRAeBWcsE/82QFB
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Wed, 16 Jun 2021 16:09:04 -0700 Andrew Morton <akpm@linux-foundation.org=
> wrote:
>
> On Wed, 16 Jun 2021 19:41:32 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux=
.ibm.com> wrote:
>=20
> > We may want to fixup pgd_page_vaddr correctly later. pgd_page_vaddr() g=
ets
> > cast to different pointer types based on architecture. But for now this
> > should work? This ensure we keep the pgd_page_vaddr() same as before.  =
=20
>=20
> I'll drop
>=20
> mm-rename-pud_page_vaddr-to-pud_pgtable-and-make-it-return-pmd_t.patch
> mm-rename-p4d_page_vaddr-to-p4d_pgtable-and-make-it-return-pud_t.patch   =
      =20
>=20
> for now.

Dropped form linux-next today (along with my fix from yesterday).

--=20
Cheers,
Stephen Rothwell

--Sig_/a/+9AWFMGRAeBWcsE/82QFB
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAmDKpBkACgkQAVBC80lX
0GzE6Qf9F9328LVgfB4V5Iv/4uPQk5jfyblmoxIn6ZJqV0uqu+dplGIY4vT0wwV5
K1aQ3HB1ESIFEAiSXffgkj3zETi5BkR8O32X08gwXq7yYbHEWZ+pQvJfSFzU6g9g
j6xql8TjMtYUFuvNT5QWrz38nRKB5IGvAA9YDxYsJPX6RKlCjWyIkF9Iooscg5s3
2lTSr2KZ8hUXF++sM1VXUCtksGbcZsdsugOGYpi1VBwvIT+Jc/WUSO3pp5Hrb02y
gDFtYDryQiN/XIdjYCDqLWjhQ7cnjTZJY0q9j5pUjFvQdgrgmT/5n63BxxegqQ65
vUoFVdDhDmKUeJ1s8LTXpvIliUuZWg==
=zFs2
-----END PGP SIGNATURE-----

--Sig_/a/+9AWFMGRAeBWcsE/82QFB--
