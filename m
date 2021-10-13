From: Uwe =?utf-8?Q?Kleine-K=C3=B6nig?= <u.kleine-koenig@pengutronix.de>
Date: Wed, 13 Oct 2021 08:45:38 +0000
Subject: Re: [PATCH AUTOSEL 5.10 11/11] firmware: include drivers/firmware/Kconfig unconditionally
Message-Id: <20211013084538.vitv6u5ahds7arpw@pengutronix.de>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="gkwcmkxhwgtfgtae"
List-Id: <linux-ia64.vger.kernel.org>
References: <20211013005532.700190-1-sashal@kernel.org>
 <20211013005532.700190-11-sashal@kernel.org>
 <YWZ1om+pLmV3atTd@kroah.com>
 <CAK8P3a2AC9-ogoxi1q+NQyBqMwrFqSZtHvZVdJ9HF+OLB3O62g@mail.gmail.com>
In-Reply-To: <CAK8P3a2AC9-ogoxi1q+NQyBqMwrFqSZtHvZVdJ9HF+OLB3O62g@mail.gmail.com>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Greg KH <gregkh@linuxfoundation.org>, Sasha Levin <sashal@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "# 3.4.x" <stable@vger.kernel.org>, Bjorn Andersson <bjorn.andersson@linaro.org>, Charles Keepax <ckeepax@opensource.cirrus.com>, Will Deacon <will@kernel.org>, Mark Brown <broonie@kernel.org>, Liam Girdwood <lgirdwood@gmail.com>, Simon Trimmer <simont@opensource.cirrus.com>, Michael Ellerman <mpe@ellerman.id.au>, Russell King - ARM Linux <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, James Bottomley <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, the arch/x86 maintainers <x86@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, Geert Uytterhoeven <geert+renesas@glider.be>, Russell King <rmk+kernel@armlinux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Anshuman Khandual <anshuman.khandual@arm.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ardb@kernel.org>, Mike Rapoport <rppt@kernel.org>, Lukas Bulwahn <lukas.bulwahn@gmail.com>, Kefeng Wang <wangkefeng.wang@huawei.com>, Sergei Trofimovich <slyfox@gentoo.org>, Jens Axboe <axboe@kernel.dk>, ben.widawsky@intel.com, Dan Williams <dan.j.williams@intel.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-ia64@vger.kernel.org, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, Parisc List <linux-parisc@vger.kernel.org>, linux-riscv <linux-riscv@lists.infradead.org>


--gkwcmkxhwgtfgtae
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Oct 13, 2021 at 10:38:01AM +0200, Arnd Bergmann wrote:
> On Wed, Oct 13, 2021 at 7:58 AM Greg KH <gregkh@linuxfoundation.org> wrot=
e:
> > On Tue, Oct 12, 2021 at 08:55:31PM -0400, Sasha Levin wrote:
> >
> > This isn't for stable kernels, it should be dropped from all of your
> > AUTOSEL queues.
>=20
> Agreed. The second patch that depends on this does fix a (randconfig)
> build issue in stable kernels as well, but that patch is currently broken,

Fixing randconfig issues isn't important for stable, is it? The target
audience for 5.10.74 are people running a kernel between 5.10 and
5.10.73, and those don't suffer from this type of build problem, right?

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig            |
Industrial Linux Solutions                 | https://www.pengutronix.de/ |

--gkwcmkxhwgtfgtae
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCgAdFiEEfnIqFpAYrP8+dKQLwfwUeK3K7AkFAmFmnK8ACgkQwfwUeK3K
7And8Af+K7OLJ/QFBmWZbDMcrq5QGKfPWOm0ntnqP00EF6M9WuzDhXwYSRnkxrUL
gB8rnQzNTAremhUgxxWWYf1b+jcy9McUcKiFrZFcFzI+Msu/lFoJs954A1A/LIwC
gv2Yr2yfkJwro0nmnPonuaG6aBdO7hhuGbPcksgfQ822GDrckbS3WluAZcC3/j0O
DzTBgBmlZEv7CdvM/DJbfxqV01oRg3C3zcn3tFY7c+3PUJs2oumNQRW6zfvUW1Bx
NrWKG1K6REFzfJ1RJO8BBaK2qT7oEDecgCOrpsXClHm+08bxJ06CbZ3pcA2Qd9Kt
40Yg+5KjHWr8vqioHLbH+w7bwi4d1w==
=e2xG
-----END PGP SIGNATURE-----

--gkwcmkxhwgtfgtae--
