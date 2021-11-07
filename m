From: Dmitry Osipenko <digetx@gmail.com>
Date: Sun, 07 Nov 2021 16:53:00 +0000
Subject: Re: [PATCH v2 27/45] mfd: ntxec: Use devm_register_power_handler()
Message-Id: <be0c74c6-05a9-cad5-c285-6626d05f8860@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211027211715.12671-1-digetx@gmail.com>
 <20211027211715.12671-28-digetx@gmail.com> <YYbqlmOM95q7Hbjo@latitude>
In-Reply-To: <YYbqlmOM95q7Hbjo@latitude>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: =?UTF-8?Q?Jonathan_Neusch=c3=a4fer?= <j.neuschaefer@gmx.net>
Cc: Thierry Reding <thierry.reding@gmail.com>, Jonathan Hunter <jonathanh@nvidia.com>, Lee Jones <lee.jones@linaro.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Mark Brown <broonie@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Guenter Roeck <linux@roeck-us.net>, Russell King <linux@armlinux.org.uk>, Daniel Lezcano <daniel.lezcano@linaro.org>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Ulf Hansson <ulf.hansson@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Guo Ren <guoren@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Joshua Thompson <funaho@jurai.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Nick Hu <nickhu@andestech.com>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Stefano Stabellini <sstabellini@kernel.org>, Len Brown <lenb@kernel.org>, Santosh Shilimkar <ssantosh@kernel.org>, Krzysztof Kozlowski <krzysztof.kozlowski@canonical.com>, Linus Walleij <linus.walleij@linaro.org>, Chen-Yu Tsai <wens@csie.org>, Tony Lindgren <tony@atomide.com>, Liam Girdwood <lgirdwood@gmail.com>, Philipp Zabel <p.zabel@pengutronix.de>, Vladimir Zapolskiy <vz@mleia.com>, Avi Fishman <avifishman70@gmail.com>, Tomer Maimon <tmaimon77@gmail.com>, Tali Perry <tali.perry1@gmail.com>, Patrick Venture <venture@google.com>, Nancy Yuen <yuenn@google.com>, Benjamin Fair <benjaminfair@google.com>, Pavel Machek <pavel@ucw.cz>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-sh@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, linux-omap@vger.kernel.org, openbmc@lists.ozlabs.org, linux-tegra@vger.kernel.org, linux-pm@vger.kernel.org

06.11.2021 23:54, Jonathan Neuschäfer пишет:
> Hi,
> 
> On Thu, Oct 28, 2021 at 12:16:57AM +0300, Dmitry Osipenko wrote:
>> Use devm_register_power_handler() that replaces global pm_power_off
>> variable and allows to register multiple power-off handlers. It also
>> provides restart-handler support, i.e. all in one API.
>>
>> Signed-off-by: Dmitry Osipenko <digetx@gmail.com>
>> ---
> 
> When I boot with (most of) this patchset applied, I get the warning at
> kernel/reboot.c:187:
> 
> 	/*
> 	 * Handler must have unique priority. Otherwise call order is
> 	 * determined by registration order, which is unreliable.
> 	 */
> 	WARN_ON(!atomic_notifier_has_unique_priority(&restart_handler_list, nb));
> 
> As the NTXEC driver doesn't specify a priority, I think this is an issue
> to be fixed elsewhere.
> 
> Other than that, it works and looks good, as far as I can tell.
> 
> 
> For this patch:
> 
> Reviewed-by: Jonathan Neuschäfer <j.neuschaefer@gmx.net>
> Tested-by: Jonathan Neuschäfer <j.neuschaefer@gmx.net>

Thank you. You have conflicting restart handlers, apparently NTXEC
driver should have higher priority than the watchdog driver. It should
be a common problem for the watchdog drivers, I will lower watchdog's
default priority to fix it.
