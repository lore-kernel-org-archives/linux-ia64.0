From: Thierry Reding <thierry.reding@gmail.com>
Date: Mon, 25 Aug 2014 13:37:53 +0000
Subject: Re: [PATCH v4 0/8] asm-generic/io.h overhaul
Message-Id: <20140825133752.GI4163@ulmo.nvidia.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="D6z0c4W1rkZNF4Vu"
List-Id: <linux-ia64.vger.kernel.org>
References: <1407925738-26170-1-git-send-email-thierry.reding@gmail.com>
 <CAFLxGvyyW5J0En1bFwonZiMwoJK+XDgtHvC2PQOhqgvyF4F-uQ@mail.gmail.com>
 <20140825122734.GD4163@ulmo.nvidia.com>
 <53FB3189.10109@nod.at>
In-Reply-To: <53FB3189.10109@nod.at>
To: Richard Weinberger <richard@nod.at>
Cc: Arnd Bergmann <arnd@arndb.de>, Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Stephen Boyd <sboyd@codeaurora.org>, Sam Ravnborg <sam@ravnborg.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-ia64@vger.kernel.org, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, sparclinux@vger.kernel.org, "x86@kernel.org" <x86@kernel.org>, linux-serial@vger.kernel.org, Linux-Arch <linux-arch@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>


--D6z0c4W1rkZNF4Vu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Aug 25, 2014 at 02:52:25PM +0200, Richard Weinberger wrote:
> Am 25.08.2014 14:27, schrieb Thierry Reding:
> > On Mon, Aug 25, 2014 at 01:53:30PM +0200, Richard Weinberger wrote:
> >> On Wed, Aug 13, 2014 at 12:28 PM, Thierry Reding
> >> <thierry.reding@gmail.com> wrote:
> >>> From: Thierry Reding <treding@nvidia.com>
> >>>
> >>> Hi,
> >>>
> >>> Here is the fourth version of a series that started out as an attempt=
 to
> >>> provide string versions of the read*() and write*() accessors to more
> >>> architectures so that drivers can use them portably. The series has
> >>> since evolved into a more general cleanup of asm-generic/io.h and the
> >>> functions defined therein.
> >>>
> >>> Patch 1 is trivial and removes a redundant redefinition of PCI_IOBASE
> >>> from the asm/io.h header on ARC. Patches 2 and 3 remove unnecessary
> >>> volatile keywoards from some functions, which is a prerequisite to cl=
ean
> >>> up some of the functions in subsequent patches.
> >>>
> >>> The xlate_dev_{kmem,mem}_ptr() functions are used to map memory when =
the
> >>> /dev/mem device is accessed. Patches 4 and 5 use more consistent data
> >>> types for these functions, which will get a "standard" prototype in t=
he
> >>> asm-generic/io.h header in a subsequent patch.
> >>>
> >>> Patch 6 is the bulk of this series. It implements the string variants=
 of
> >>> the read*() and write*() accessors and cleans up various other parts =
of
> >>> the asm-generic/io.h header file. Macros are converted to static inli=
ne
> >>> functions for better type checking. Overriding generic implementations
> >>> in architectures is handled more consistently.
> >>>
> >>> Patches 7 and 8, finally, make use of the asm-generic/io.h header on =
the
> >>> 32-bit and 64-bit ARM architectures.
> >>>
> >>> This is compile- and runtime-tested on 32-bit and 64-bit ARM and comp=
ile
> >>> tested on IA64, Microblaze, s390, SPARC, x86 and Xtensa. For ARC,
> >>> Blackfin, Metag, OpenRISC, Score and Unicore32 which also use
> >>> asm-generic/io.h I couldn't find or build a cross-compiler that would
> >>> run on my system. But by code inspection they shouldn't break with th=
is
> >>> patch.
> >>>
> >>> To ensure bisectability I built multi_v7_defconfig on 32-bit ARM and =
the
> >>> defconfig for 64-bit ARM, IA64, Microblaze, s390, SPARC, x86 and Xten=
sa
> >>> after each commit and verified that the series does not introduce any
> >>> build errors or warnings.
> >>>
> >>> Provided there are no objections to the patches there's still the mat=
ter
> >>> of how to merge them. Patch 6 depends on patches 1-5 to avoid warnings
> >>> and/or errors during the build. Patches 7 and 8 depend on patch 6. In=
 my
> >>> opinion it doesn't make much sense to split them up, so I guess we'll
> >>> need a volunteer to take them all into one tree. Ideally that tree wo=
uld
> >>> feed into linux-next so that we can get as much build and test-covera=
ge
> >>> as possible during the 3.17 release cycle so that these patches can go
> >>> into 3.18.
> >>>
> >>> Arnd, I'm opportunistically sending this To: you in the hopes that you
> >>> can take it into your asm-generic tree which seems like the best fit =
for
> >>> this.
> >>
> >> Do you have a git tree for that?
> >> Would be nice for testing UML, it depends also on generic io.
> >=20
> > Yes, it's all here:
> >=20
> > 	https://github.com/thierryreding/linux.git staging/asm-generic-io
> >=20
> > That branch is based on today's linux-next (next-20140825).
>=20
> Looks good, UML builds and boots fine here.

Excellent, thanks for testing.

Thierry

--D6z0c4W1rkZNF4Vu
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJT+zwwAAoJEN0jrNd/PrOhM74P/RHwzwkWYaRikhqvRspDINeq
GdhqxZBdnSO9z/rve+wSTc7QSSMHi63xRy1JIqJ2kWhdTz1KSu8VbTQl/BsUx52u
M9x992vmoXViW5+KQWli2Q4S9uUbCjUgJdU7u8CqOUvEx+N05dgv5VwCRwS3ZsdI
dzZr10A36mzleYKAAjt2ckvV+ppMWSACDJsPy+HU8MqkRFS4u66IVESvnvVhq5YO
wHONAU37xdtgij9jvlPz0mqxdAeCacTeZGH3ahEvzlj96x2ryWs26cOIkbgyW00K
7JjhMA7Ie/ndVal6JjE1jKsXmyuIfW6rq2obpyc+4ACUXZ676sp8r+1z6tTX/1k7
v2F4lj16dgh/jaEO9Mgv+e7oVrEu1PhsCG91d1UcwHweRoOWZM1iK1tBdYYqa4CE
jQdXkZcmOrbeuhEfznOsy9ggLxMGlmFTzlitZOqWbCF0FY44yWxGulBqg+v7WwPm
/lfXhmIiqg79mDTmJgaR7SMw43y/cu2gk9VUPass58uW0ry5CVqBAU3XZi25W++w
BcLHjIFayoyctYcAvVGEfDNBUffVObVEp8NJjqCh1ngJrBOO8asYu2dK0NVUuSok
vnrzKoeYFIavo+u+vpZAMLjRjRdDbyKTfNfDYmAFT1ERNi/JyHSvey0uBWnRhEum
XcXEBj2dACyCi2Au+eFt
=Jr4q
-----END PGP SIGNATURE-----

--D6z0c4W1rkZNF4Vu--
