From: Mark Brown <broonie@kernel.org>
Date: Thu, 28 Oct 2021 11:59:08 +0000
Subject: Re: [PATCH v2 24/45] regulator: pfuze100: Use devm_register_power_handler()
Message-Id: <YXqQjG+5Eshm9fl5@sirena.org.uk>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Wle3PKA2/qG6+6Vj"
List-Id: <linux-ia64.vger.kernel.org>
References: <20211027211715.12671-1-digetx@gmail.com>
 <20211027211715.12671-25-digetx@gmail.com>
In-Reply-To: <20211027211715.12671-25-digetx@gmail.com>
To: Dmitry Osipenko <digetx@gmail.com>
Cc: Thierry Reding <thierry.reding@gmail.com>, Jonathan Hunter <jonathanh@nvidia.com>, Lee Jones <lee.jones@linaro.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Guenter Roeck <linux@roeck-us.net>, Russell King <linux@armlinux.org.uk>, Daniel Lezcano <daniel.lezcano@linaro.org>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Ulf Hansson <ulf.hansson@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Guo Ren <guoren@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Joshua Thompson <funaho@jurai.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Nick Hu <nickhu@andestech.com>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Stefano Stabellini <sstabellini@kernel.org>, Len Brown <lenb@kernel.org>, Santosh Shilimkar <ssantosh@kernel.org>, Krzysztof Kozlowski <krzysztof.kozlowski@canonical.com>, Linus Walleij <linus.walleij@linaro.org>, Chen-Yu Tsai <wens@csie.org>, Jonathan =?iso-8859-1?Q?Neusch=E4fer?= <j.neuschaefer@gmx.net>, Tony Lindgren <tony@atomide.com>, Liam Girdwood <lgirdwood@gmail.com>, Philipp Zabel <p.zabel@pengutronix.de>, Vladimir Zapolskiy <vz@mleia.com>, Avi Fishman <avifishman70@gmail.com>, Tomer Maimon <tmaimon77@gmail.com>, Tali Perry <tali.perry1@gmail.com>, Patrick Venture <venture@google.com>, Nancy Yuen <yuenn@google.com>, Benjamin Fair <benjaminfair@google.com>, Pavel Machek <pavel@ucw.cz>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-sh@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, linux-omap@vger.kernel.org, openbmc@lists.ozlabs.org, linux-tegra@vger.kernel.org, linux-pm@vger.kernel.org


--Wle3PKA2/qG6+6Vj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Oct 28, 2021 at 12:16:54AM +0300, Dmitry Osipenko wrote:

> Use devm_register_power_handler() that replaces global pm_power_off_prepare
> variable and allows to register multiple power-off handlers.

Acked-by: Mark Brown <broonie@kernel.org>

--Wle3PKA2/qG6+6Vj
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCgAdFiEEreZoqmdXGLWf4p/qJNaLcl1Uh9AFAmF6kIwACgkQJNaLcl1U
h9AyhAf+Nziuu181EjKis21sdValh/0I2qd5n6cZmpuLUeA7g6K6TyFH79y+tEkd
Itu0nx35rsztyjl7+A8ECF9S9uJGD1N0o3cruhqU01R5Kloz9mrUDRii5R3Uh+fm
wjXlm+iYDXdXIzRmM07WyWi8rUTpLrhHx7ogAb291MVxgxc1LqxOBAwk6hcvnDCB
aLDZSKk0LT7/yHSU+s5sBmll+K1S09x+XUfo/7VEuf9WqctxN8t6DgnigNeg1sU1
S3cmBREB1bkkqHuPWJhOyUeW6YyuYI8inCcpXRNtdydg4jwo5l2h16fE8e0db953
VsD3Y2dmLQu1qKxLNZUqHCelyjTPow==
=sNsl
-----END PGP SIGNATURE-----

--Wle3PKA2/qG6+6Vj--
