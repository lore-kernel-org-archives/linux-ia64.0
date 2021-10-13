From: Mark Brown <broonie@kernel.org>
Date: Wed, 13 Oct 2021 11:16:44 +0000
Subject: Re: [PATCH AUTOSEL 5.14 17/17] firmware: include drivers/firmware/Kconfig unconditionally
Message-Id: <YWbAHCYS/IsGyeEw@sirena.org.uk>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Hzj7Ij7mixgewbmh"
List-Id: <linux-ia64.vger.kernel.org>
References: <20211013005441.699846-1-sashal@kernel.org>
 <20211013005441.699846-17-sashal@kernel.org>
In-Reply-To: <20211013005441.699846-17-sashal@kernel.org>
To: Sasha Levin <sashal@kernel.org>
Cc: linux-kernel@vger.kernel.org, stable@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Bjorn Andersson <bjorn.andersson@linaro.org>, Charles Keepax <ckeepax@opensource.cirrus.com>, Will Deacon <will@kernel.org>, Liam Girdwood <lgirdwood@gmail.com>, Simon Trimmer <simont@opensource.cirrus.com>, Michael Ellerman <mpe@ellerman.id.au>, linux@armlinux.org.uk, catalin.marinas@arm.com, tsbogend@alpha.franken.de, James.Bottomley@hansenpartnership.com, deller@gmx.de, paul.walmsley@sifive.com, palmer@dabbelt.com, aou@eecs.berkeley.edu, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, x86@kernel.org, geert+renesas@glider.be, linus.walleij@linaro.org, rmk+kernel@armlinux.org.uk, akpm@linux-foundation.org, anshuman.khandual@arm.com, rppt@kernel.org, ardb@kernel.org, u.kleine-koenig@pengutronix.de, lukas.bulwahn@gmail.com, mark.rutland@arm.com, wangkefeng.wang@huawei.com, slyfox@gentoo.org, axboe@kernel.dk, rientjes@google.com, dan.j.williams@intel.com, gregkh@linuxfoundation.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org


--Hzj7Ij7mixgewbmh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Oct 12, 2021 at 08:54:41PM -0400, Sasha Levin wrote:
> From: Arnd Bergmann <arnd@arndb.de>
>=20
> [ Upstream commit 951cd3a0866d29cb9c01ebc1d9c17590e598226e ]
>=20
> Compile-testing drivers that require access to a firmware layer
> fails when that firmware symbol is unavailable. This happened
> twice this week:

This seems *way* too invasive a change for stable.  It exposes code to
building on entire new architectures.

--Hzj7Ij7mixgewbmh
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCgAdFiEEreZoqmdXGLWf4p/qJNaLcl1Uh9AFAmFmwBsACgkQJNaLcl1U
h9AFjgf9HNz1iDlvraGZuINQkg4b76glybMJpIJI9Q9/fCTbm75p34EctvP3YnrO
TCUYnuynKAfFn6bLAoHN4AO5JLYPELiK1jd3olKo4QbWgHL449nF7NwkBR/bjHNZ
jwefNQMINnMo7bhrsdhmvYjoC9GuSHPSrHkHLKZRBsiCdc1SopabE67oBmTQ06+4
6JOnbKmjExje2UT0JyJwgp59/YVbDOd06QLxA6gLuCPRmCTgYGqXS3/V1e89VwH1
tK4vtT5ICEUVeBinsBUb2MMEAY41vB410JxWhNL9HFVg30fvQw/YDW7mQSdvCL0G
Gf+lxOl5vhEl0xrMPE8gIqtfQ4Kyyw==
=dgIM
-----END PGP SIGNATURE-----

--Hzj7Ij7mixgewbmh--
