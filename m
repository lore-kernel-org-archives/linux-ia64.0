From: Dmitry Osipenko <digetx@gmail.com>
Date: Thu, 28 Oct 2021 21:58:32 +0000
Subject: Re: [PATCH v2 08/45] kernel: Add combined power-off+restart handler call chain API
Message-Id: <28560da7-8ab6-3bd5-b4d6-e34b21a9bbb0@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211027211715.12671-1-digetx@gmail.com>
 <20211027211715.12671-9-digetx@gmail.com>
 <CAJZ5v0gpu2ezMhWr=grg6M8aWAx58DQozbXHoZaiPqUaZxJi4Q@mail.gmail.com>
In-Reply-To: <CAJZ5v0gpu2ezMhWr=grg6M8aWAx58DQozbXHoZaiPqUaZxJi4Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Thierry Reding <thierry.reding@gmail.com>, Jonathan Hunter <jonathanh@nvidia.com>, Lee Jones <lee.jones@linaro.org>, Mark Brown <broonie@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Guenter Roeck <linux@roeck-us.net>, Russell King <linux@armlinux.org.uk>, Daniel Lezcano <daniel.lezcano@linaro.org>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Ulf Hansson <ulf.hansson@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Guo Ren <guoren@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Joshua Thompson <funaho@jurai.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, the arch/x86 maintainers <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Stefano Stabellini <sstabellini@kernel.org>, Len Brown <lenb@kernel.org>, Santosh Shilimkar <ssantosh@kernel.org>, Krzysztof Kozlowski <krzysztof.kozlowski@canonical.com>, Linus Walleij <linus.walleij@linaro.org>, Chen-Yu Tsai <wens@csie.org>, =?UTF-8?Q?Jonathan_Neusch=c3=a4fer?= <j.neuschaefer@gmx.net>, Tony Lindgren <tony@atomide.com>, Liam Girdwood <lgirdwood@gmail.com>, Philipp Zabel <p.zabel@pengutronix.de>, Vladimir Zapolskiy <vz@mleia.com>, Avi Fishman <avifishman70@gmail.com>, Tomer Maimon <tmaimon77@gmail.com>, Tali Perry <tali.perry1@gmail.com>, Patrick Venture <venture@google.com>, Nancy Yuen <yuenn@google.com>, Benjamin Fair <benjaminfair@google.com>, Pavel Machek <pavel@ucw.cz>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-riscv@lists.infradead.org, Linux-sh list <linux-sh@vger.kernel.org>, xen-devel@lists.xenproject.org, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux OMAP Mailing List <linux-omap@vger.kernel.org>, openbmc@lists.ozlabs.org, linux-tegra <linux-tegra@vger.kernel.org>, Linux PM <linux-pm@vger.kernel.org>

28.10.2021 12:59, Rafael J. Wysocki пишет:
>> +#define RESTART_PRIO_RESERVED          0
>> +#define RESTART_PRIO_DEFAULT           128
>> +#define RESTART_PRIO_HIGH              192
>>
>>  enum reboot_mode {
>>         REBOOT_UNDEFINED = -1,
>> @@ -49,6 +55,167 @@ int register_restart_handler(struct notifier_block *);
>>  int unregister_restart_handler(struct notifier_block *);
>>  void do_kernel_restart(char *cmd);
>>
>> +/*
>> + * Unified poweroff + restart API.
>> + */
>> +
>> +#define POWEROFF_PRIO_RESERVED         0
>> +#define POWEROFF_PRIO_PLATFORM         1
>> +#define POWEROFF_PRIO_DEFAULT          128
>> +#define POWEROFF_PRIO_HIGH             192
>> +#define POWEROFF_PRIO_FIRMWARE         224
> Also I'm wondering why these particular numbers were chosen, here and above?

These values are chosen based on priorities that drivers already use. I looked thorough them all and ended with this scheme that fulfills the needs of the current API users.

I'll add these comments in v3:

/*
 * Standard restart priority levels. Intended to be set in the
 * sys_off_handler.restart_priority field.
 *
 * Use `RESTART_PRIO_XXX +- prio` style for additional levels.
 *
 * RESTART_PRIO_RESERVED:	Falls back to RESTART_PRIO_DEFAULT.
 *				Drivers may leave priority initialized
 *				to zero, to auto-set it to the default level.
 *
 * RESTART_PRIO_DEFAULT:	Use this for generic handler.
 *
 * RESTART_PRIO_HIGH:		Use this if you have multiple handlers and
 *				this handler has higher priority than the
 *				default handler.
 */

/*
 * Standard power-off priority levels. Intended to be set in the
 * sys_off_handler.power_off_priority field.
 *
 * Use `POWEROFF_PRIO_XXX +- prio` style for additional levels.
 *
 * POWEROFF_PRIO_RESERVED:	Falls back to POWEROFF_PRIO_DEFAULT.
 *				Drivers may leave priority initialized
 *				to zero, to auto-set it to the default level.
 *
 * POWEROFF_PRIO_PLATFORM:	Intended to be used by platform-level handler.
 *				Has lowest priority since device drivers are
 *				expected to take over platform handler which
 *				doesn't allow further callback chaining.
 *
 * POWEROFF_PRIO_DEFAULT:	Use this for generic handler.
 *
 * POWEROFF_PRIO_HIGH:		Use this if you have multiple handlers and
 *				this handler has higher priority than the
 *				default handler.
 *
 * POWEROFF_PRIO_FIRMWARE:	Use this if handler uses firmware call.
 *				Has highest priority since firmware is expected
 *				to know best how to power-off hardware properly.
 */
