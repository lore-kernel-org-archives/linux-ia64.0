From: Jonathan =?utf-8?Q?Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>
Date: Sat, 06 Nov 2021 20:54:06 +0000
Subject: Re: [PATCH v2 27/45] mfd: ntxec: Use devm_register_power_handler()
Message-Id: <YYbqlmOM95q7Hbjo@latitude>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="EIEte5+tjVxDHmE6"
List-Id: <linux-ia64.vger.kernel.org>
References: <20211027211715.12671-1-digetx@gmail.com>
 <20211027211715.12671-28-digetx@gmail.com>
In-Reply-To: <20211027211715.12671-28-digetx@gmail.com>
To: Dmitry Osipenko <digetx@gmail.com>
Cc: Thierry Reding <thierry.reding@gmail.com>, Jonathan Hunter <jonathanh@nvidia.com>, Lee Jones <lee.jones@linaro.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Mark Brown <broonie@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Guenter Roeck <linux@roeck-us.net>, Russell King <linux@armlinux.org.uk>, Daniel Lezcano <daniel.lezcano@linaro.org>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Ulf Hansson <ulf.hansson@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Guo Ren <guoren@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Joshua Thompson <funaho@jurai.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Nick Hu <nickhu@andestech.com>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Stefano Stabellini <sstabellini@kernel.org>, Len Brown <lenb@kernel.org>, Santosh Shilimkar <ssantosh@kernel.org>, Krzysztof Kozlowski <krzysztof.kozlowski@canonical.com>, Linus Walleij <linus.walleij@linaro.org>, Chen-Yu Tsai <wens@csie.org>, Jonathan =?utf-8?Q?Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>, Tony Lindgren <tony@atomide.com>, Liam Girdwood <lgirdwood@gmail.com>, Philipp Zabel <p.zabel@pengutronix.de>, Vladimir Zapolskiy <vz@mleia.com>, Avi Fishman <avifishman70@gmail.com>, Tomer Maimon <tmaimon77@gmail.com>, Tali Perry <tali.perry1@gmail.com>, Patrick Venture <venture@google.com>, Nancy Yuen <yuenn@google.com>, Benjamin Fair <benjaminfair@google.com>, Pavel Machek <pavel@ucw.cz>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-sh@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, linux-omap@vger.kernel.org, openbmc@lists.ozlabs.org, linux-tegra@vger.kernel.org, linux-pm@vger.kernel.org


--EIEte5+tjVxDHmE6
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Thu, Oct 28, 2021 at 12:16:57AM +0300, Dmitry Osipenko wrote:
> Use devm_register_power_handler() that replaces global pm_power_off
> variable and allows to register multiple power-off handlers. It also
> provides restart-handler support, i.e. all in one API.
>=20
> Signed-off-by: Dmitry Osipenko <digetx@gmail.com>
> ---

When I boot with (most of) this patchset applied, I get the warning at
kernel/reboot.c:187:

	/*
	 * Handler must have unique priority. Otherwise call order is
	 * determined by registration order, which is unreliable.
	 */
	WARN_ON(!atomic_notifier_has_unique_priority(&restart_handler_list, nb));

As the NTXEC driver doesn't specify a priority, I think this is an issue
to be fixed elsewhere.

Other than that, it works and looks good, as far as I can tell.


For this patch:

Reviewed-by: Jonathan Neusch=C3=A4fer <j.neuschaefer@gmx.net>
Tested-by: Jonathan Neusch=C3=A4fer <j.neuschaefer@gmx.net>


Best regards,
Jonathan
---

Full Oops log:

[    3.523294] ------------[ cut here ]------------
[    3.528193] WARNING: CPU: 0 PID: 1 at kernel/reboot.c:187 register_resta=
rt_handler+0x4c/0x58
[    3.536975] Modules linked in:
[    3.540312] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 5.15.0-00021-gcb24=
c628b307 #622
[    3.548214] Hardware name: Freescale i.MX50 (Device Tree Support)
[    3.554357] [<c0111540>] (unwind_backtrace) from [<c010cdd0>] (show_stac=
k+0x10/0x14)
[    3.562183] [<c010cdd0>] (show_stack) from [<c0bf240c>] (dump_stack_lvl+=
0x58/0x70)
[    3.569824] [<c0bf240c>] (dump_stack_lvl) from [<c0127604>] (__warn+0xd4=
/0x154)
[    3.577191] [<c0127604>] (__warn) from [<c0bec844>] (warn_slowpath_fmt+0=
x74/0xa8)
[    3.584727] [<c0bec844>] (warn_slowpath_fmt) from [<c01593c8>] (register=
_restart_handler+0x4c/0x58)
[    3.593823] [<c01593c8>] (register_restart_handler) from [<c08676c8>] (_=
_watchdog_register_device+0x13c/0x27c)
[    3.603889] [<c08676c8>] (__watchdog_register_device) from [<c0867868>] =
(watchdog_register_device+0x60/0xb4)
[    3.613764] [<c0867868>] (watchdog_register_device) from [<c08678f8>] (d=
evm_watchdog_register_device+0x3c/0x84)
[    3.623898] [<c08678f8>] (devm_watchdog_register_device) from [<c1146454=
>] (imx2_wdt_probe+0x254/0x2ac)
[    3.633346] [<c1146454>] (imx2_wdt_probe) from [<c06feb74>] (platform_pr=
obe+0x58/0xb8)
[    3.641314] [<c06feb74>] (platform_probe) from [<c06fb2f8>] (call_driver=
_probe+0x24/0x108)
[    3.649636] [<c06fb2f8>] (call_driver_probe) from [<c06fbe08>] (really_p=
robe.part.0+0xa8/0x358)
[    3.658384] [<c06fbe08>] (really_probe.part.0) from [<c06fc1c4>] (__driv=
er_probe_device+0x94/0x208)
[    3.667470] [<c06fc1c4>] (__driver_probe_device) from [<c06fc368>] (driv=
er_probe_device+0x30/0xc8)
[    3.676468] [<c06fc368>] (driver_probe_device) from [<c06fcb0c>] (__driv=
er_attach+0xe0/0x1c4)
[    3.685032] [<c06fcb0c>] (__driver_attach) from [<c06f9a20>] (bus_for_ea=
ch_dev+0x74/0xc0)
[    3.693253] [<c06f9a20>] (bus_for_each_dev) from [<c06faeb8>] (bus_add_d=
river+0x100/0x208)
[    3.701563] [<c06faeb8>] (bus_add_driver) from [<c06fd8a0>] (driver_regi=
ster+0x88/0x118)
[    3.709696] [<c06fd8a0>] (driver_register) from [<c06fe920>] (__platform=
_driver_probe+0x44/0xdc)
[    3.718522] [<c06fe920>] (__platform_driver_probe) from [<c01022ac>] (do=
_one_initcall+0x78/0x388)
[    3.727444] [<c01022ac>] (do_one_initcall) from [<c1101708>] (do_initcal=
ls+0xcc/0x110)
[    3.735413] [<c1101708>] (do_initcalls) from [<c110198c>] (kernel_init_f=
reeable+0x1ec/0x250)
[    3.743896] [<c110198c>] (kernel_init_freeable) from [<c0bfe724>] (kerne=
l_init+0x10/0x128)
[    3.752224] [<c0bfe724>] (kernel_init) from [<c010011c>] (ret_from_fork+=
0x14/0x38)
[    3.759844] Exception stack(0xc40adfb0 to 0xc40adff8)
[    3.764933] dfa0:                                     00000000 00000000 =
00000000 00000000
[    3.773143] dfc0: 00000000 00000000 00000000 00000000 00000000 00000000 =
00000000 00000000
[    3.781351] dfe0: 00000000 00000000 00000000 00000000 00000013 00000000
[    3.788347] irq event stamp: 143613
[    3.792102] hardirqs last  enabled at (143623): [<c01a3ebc>] __up_consol=
e_sem+0x50/0x60
[    3.800397] hardirqs last disabled at (143632): [<c01a3ea8>] __up_consol=
e_sem+0x3c/0x60
[    3.808491] softirqs last  enabled at (143612): [<c0101518>] __do_softir=
q+0x2f8/0x5b0
[    3.816591] softirqs last disabled at (143603): [<c01307dc>] __irq_exit_=
rcu+0x160/0x1d8
[    3.825014] ---[ end trace 7f6709d2c89774b4 ]---

--EIEte5+tjVxDHmE6
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEvHAHGBBjQPVy+qvDCDBEmo7zX9sFAmGG624ACgkQCDBEmo7z
X9s6ChAAk6BAeo5fWoSSZHjjpn6ATqjK8ym6Qwe2EuauLkxbrtHK3OsbljBzCdtj
p4LUnHOvUjWpnlBRfbbZSXKo5B0LxFtUhe/Cz9IDICft4K2DmOExc+xY9zQNcjMO
rNIxDh4Q8qUdWv4c4B3p812s36yVKoaAGT6XHR9ISWOWmTWq/SNXiFetn9KdMaRs
INw4aNL0grB717V8ucg5RtEOcrLEHRPf6Rv0b6yhfRdBQGx5XCatsdkofBcM9Rlr
ECVr+SDk6hoMvPgqbnK3hh1fU0MGiDoyHN/+PhdW5k71EoqynneLlz1xhU4P1TAQ
4leH70X0lvTJSlpZ+dWkgVGkGzE8LtrjCwhCzZvf+UKqhKf4VWp9LInkiRU2mEaN
ZGeaNLEL/oEE2nHZuWuW8imYr/WoYQKyZX+rG/g+aViMxom4/RC/IF5GFWxInCgi
IBVFSiKxJOwKvKHZrsiJsk+zqcmb1TRObyYd0ecsOPD413IWwnFIl6502QRQolJH
UvdIANNtt2/XORmBBNNGCQtZJ82srfxBpn9jzBtCZu03m4RymWvURbqbIx7mAiz0
6nj5cArubiCB8WOnOcCmsgHzLZDzN2SAy5UFxsELy67LUXWjsGMG++sHbkDuaiji
/h71rvx5wmakG7quyBIQDCUtxgSMJL73yZA4N8UsQABCsmnNXgE=
=jBJI
-----END PGP SIGNATURE-----

--EIEte5+tjVxDHmE6--
