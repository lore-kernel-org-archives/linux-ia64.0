From: Dmitry Osipenko <dmitry.osipenko@collabora.com>
Date: Thu, 19 May 2022 10:57:31 +0000
Subject: Re: [PATCH v8 00/27] Introduce power-off+restart call chain API
Message-Id: <43133a4d-8bad-93ba-c376-21d30d039b15@collabora.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220509233235.995021-1-dmitry.osipenko@collabora.com>
 <CAJZ5v0jhWs-8ChHddebTZcaH6kA05sLEMsXM9Op7kHWAQDxeYA@mail.gmail.com>
In-Reply-To: <CAJZ5v0jhWs-8ChHddebTZcaH6kA05sLEMsXM9Op7kHWAQDxeYA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Thierry Reding <thierry.reding@gmail.com>, Jonathan Hunter <jonathanh@nvidia.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Guo Ren <guoren@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Joshua Thompson <funaho@jurai.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Sebastian Reichel <sre@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, Philipp Zabel <p.zabel@pengutronix.de>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, the arch/x86 maintainers <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Stefano Stabellini <sstabellini@kernel.org>, Len Brown <lenb@kernel.org>, Santosh Shilimkar <ssantosh@kernel.org>, Krzysztof Kozlowski <krzk@kernel.org>, Liam Girdwood <lgirdwood@gmail.com>, Mark Brown <broonie@kernel.org>, Pavel Machek <pavel@ucw.cz>, Lee Jones <lee.jones@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Guenter Roeck <linux@roeck-us.net>, Daniel Lezcano <daniel.lezcano@linaro.org>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Ulf Hansson <ulf.hansson@linaro.org>, =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org, Linux-sh list <linux-sh@vger.kernel.org>, xen-devel@lists.xenproject.org, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux PM <linux-pm@vger.kernel.org>, linux-tegra <linux-tegra@vger.kernel.org>

On 5/18/22 17:46, Rafael J. Wysocki wrote:
> On Tue, May 10, 2022 at 1:33 AM Dmitry Osipenko
> <dmitry.osipenko@collabora.com> wrote:
...
>> Introduce new API that provides call chains support for all restart and
>> power-off modes. The new API is designed with simplicity and extensibility
>> in mind.
...
> The v8 looks much better than the previous versions to me.
> 
> I actually don't really have any comments on it except for the minor
> remark regarding patch [1/27] sent separately.
> 
> Please just send an update of that one patch and I will queue up the
> series for 5.19.
> 
> However, I'm going to send a pull request with it in the second half
> of the merge window, after the majority of the other changes in the
> subsystems touched by it have been integrated.

Thanks, Rafael. I sent out the updated [1/27] patch to you.

For the reference, the updated patch can be found here as well:

https://lore.kernel.org/all/20220519105015.1195955-1-dmitry.osipenko@collabora.com/T/#u

-- 
Best regards,
Dmitry
