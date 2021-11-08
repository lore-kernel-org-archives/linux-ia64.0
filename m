From: Jonathan =?utf-8?Q?Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>
Date: Mon, 08 Nov 2021 11:22:32 +0000
Subject: Re: [PATCH v2 27/45] mfd: ntxec: Use devm_register_power_handler()
Message-Id: <YYkIeBSCFka9yrqC@latitude>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="SrzUzzmYivmDpJiW"
List-Id: <linux-ia64.vger.kernel.org>
References: <20211027211715.12671-1-digetx@gmail.com>
 <20211027211715.12671-28-digetx@gmail.com>
 <YYbqlmOM95q7Hbjo@latitude>
 <be0c74c6-05a9-cad5-c285-6626d05f8860@gmail.com>
 <9a22c22d-94b1-f519-27a2-ae0b8bbf6e99@roeck-us.net>
 <658cf796-e3b1-f816-1e15-9e9e08b8ade0@gmail.com>
 <5a17fee3-4214-c2b9-abc1-ab9d6071591b@roeck-us.net>
 <c0b52994-51f5-806b-b07e-3e70d8217ffc@gmail.com>
In-Reply-To: <c0b52994-51f5-806b-b07e-3e70d8217ffc@gmail.com>
To: Dmitry Osipenko <digetx@gmail.com>
Cc: Guenter Roeck <linux@roeck-us.net>, Jonathan =?utf-8?Q?Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>, Thierry Reding <thierry.reding@gmail.com>, Jonathan Hunter <jonathanh@nvidia.com>, Lee Jones <lee.jones@linaro.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Mark Brown <broonie@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Russell King <linux@armlinux.org.uk>, Daniel Lezcano <daniel.lezcano@linaro.org>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Ulf Hansson <ulf.hansson@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Guo Ren <guoren@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Joshua Thompson <funaho@jurai.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Nick Hu <nickhu@andestech.com>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Stefano Stabellini <sstabellini@kernel.org>, Len Brown <lenb@kernel.org>, Santosh Shilimkar <ssantosh@kernel.org>, Krzysztof Kozlowski <krzysztof.kozlowski@canonical.com>, Linus Walleij <linus.walleij@linaro.org>, Chen-Yu Tsai <wens@csie.org>, Tony Lindgren <tony@atomide.com>, Liam Girdwood <lgirdwood@gmail.com>, Philipp Zabel <p.zabel@pengutronix.de>, Vladimir Zapolskiy <vz@mleia.com>, Avi Fishman <avifishman70@gmail.com>, Tomer Maimon <tmaimon77@gmail.com>, Tali Perry <tali.perry1@gmail.com>, Patrick Venture <venture@google.com>, Nancy Yuen <yuenn@google.com>, Benjamin Fair <benjaminfair@google.com>, Pavel Machek <pavel@ucw.cz>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-sh@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, linux-omap@vger.kernel.org, openbmc@lists.ozlabs.org, linux-tegra@vger.kernel.org, linux-pm@vger.kernel.org


--SrzUzzmYivmDpJiW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Nov 07, 2021 at 08:42:33PM +0300, Dmitry Osipenko wrote:
[...]
> EC drivers tend to use higher priority in general. Jonathan, could you
> please confirm that NTXEC driver is a more preferable restart method
> than the watchdog?

Yes. The original firmware uses the NTXEC to restart, and it works well,
so I do think it's preferable.


Best regards,
Jonathan

--SrzUzzmYivmDpJiW
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEvHAHGBBjQPVy+qvDCDBEmo7zX9sFAmGJCE4ACgkQCDBEmo7z
X9vVoBAAyZoJJUbTWWKI6c/HY4wq3sRDukultq5nSNIOH4RAFsTFD2FbiBB7LDaG
v/9oOqoTUDuR3AkaHFnk5+h5gLRqeePoH1KU8fa7bc7NPatTUVt54SqhQSRfUfrF
+0eRt3WHt2lZpZjaY8kj/vz5AkubzCmwVqSKoLUdCW/qi+UphZHp75E2XXypK/o3
dt1dmPA1D0pXB1WdwLSZjtCn5lIOucdssKLl1UyXQzFmuKBPkjOcuuQqwm5Ietoz
T4EEl/js2iIbui0e5ml9611nZoTLhVYMkxRcLi7gRHWTn9NmVzzJdubJH6Ajwp8E
M9TOi2NtYbSk+pGvTwawfKaw+aROUuKqGOGc+9TFeu+V5pCMAIZ1wybNExZph5jp
/o58QQUdszFwjMq7A4zdXSufKug8CpsYILhtcSx57wtGJ/OW7ZDtmX679x4jAvgX
XeMWuW8x08UFauDBHsvw9aIIgKg7ZlJ+bQ5WdgtsiuXrZEEbTNbW1kjbKAvHS9dP
o3MB/Lbi/rN/448ImnHtShmihh7ug6s+oUDbW6wFzCFvcfLbOs/Sfz35f5wNTHQW
ReNPRgH+pTvzZvulDdrSA6GAnH8mfFE7IkC/3BP6BJE28ug1GvJrRtvylwp29ZW/
Qu0z+FCaFjPu5yOr8rspC9YUdGolKnMg1msMwjgbe58vH9+EDDQ=
=fkgc
-----END PGP SIGNATURE-----

--SrzUzzmYivmDpJiW--
