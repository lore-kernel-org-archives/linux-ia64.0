From: Dmitry Osipenko <digetx@gmail.com>
Date: Thu, 17 Feb 2022 10:12:57 +0000
Subject: Re: [PATCH v6 00/21] Introduce power-off+restart call chain API
Message-Id: <4f0d1b50-9f55-dd81-f0c7-f5e0dfd75c2a@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220130233718.21544-1-digetx@gmail.com>
 <635e8121-fca4-580c-6af5-d9317a2eee1b@gmail.com>
 <CAJZ5v0g0MrBm2+GwctkB7kUyBEt6HTAexRCFFRmTF1UKDrVQ-g@mail.gmail.com>
 <de2cbd2a-8d0d-8678-e514-b153d04546cc@gmx.de>
In-Reply-To: <de2cbd2a-8d0d-8678-e514-b153d04546cc@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Helge Deller <deller@gmx.de>, "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org, Linux-sh list <linux-sh@vger.kernel.org>, xen-devel@lists.xenproject.org, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux PM <linux-pm@vger.kernel.org>, linux-tegra <linux-tegra@vger.kernel.org>, Thierry Reding <thierry.reding@gmail.com>, Jonathan Hunter <jonathanh@nvidia.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Guo Ren <guoren@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Joshua Thompson <funaho@jurai.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Sebastian Reichel <sre@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, Philipp Zabel <p.zabel@pengutronix.de>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, the arch/x86 maintainers <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Stefano Stabellini <sstabellini@kernel.org>, Len Brown <lenb@kernel.org>, Santosh Shilimkar <ssantosh@kernel.org>, Krzysztof Kozlowski <krzysztof.kozlowski@canonical.com>, Liam Girdwood <lgirdwood@gmail.com>, Mark Brown <broonie@kernel.org>, Pavel Machek <pavel@ucw.cz>, Lee Jones <lee.jones@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Guenter Roeck <linux@roeck-us.net>, Daniel Lezcano <daniel.lezcano@linaro.org>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Ulf Hansson <ulf.hansson@linaro.org>, alankao@andestech.com, "K . C . Kuen-Chern Lin" <kclin@andestech.com>, =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>

16.02.2022 23:30, Helge Deller пишет:
> On 2/16/22 13:25, Rafael J. Wysocki wrote:
>> On Tue, Feb 15, 2022 at 11:00 PM Dmitry Osipenko <digetx@gmail.com> wrote:
>>>
>>> 31.01.2022 02:36, Dmitry Osipenko пишет:
>>>> Problem
>>>> -------
>>>>
>>>> SoC devices require power-off call chaining functionality from kernel.
>>>> We have a widely used restart chaining provided by restart notifier API,
>>>> but nothing for power-off.
>>>>
>>>> Solution
>>>> --------
>>>>
>>>> Introduce new API that provides both restart and power-off call chains.
>>>>
>>>> Why combine restart with power-off? Because drivers often do both.
>>>> More practical to have API that provides both under the same roof.
>>>>
>>>> The new API is designed with simplicity and extensibility in mind.
>>>> It's built upon the existing restart and reboot APIs. The simplicity
>>>> is in new helper functions that are convenient for drivers. The
>>>> extensibility is in the design that doesn't hardcode callback
>>>> arguments, making easy to add new parameters and remove old.
>>>>
>>>> This is a third attempt to introduce the new API. First was made by
>>>> Guenter Roeck back in 2014, second was made by Thierry Reding in 2017.
>>>> In fact the work didn't stop and recently arm_pm_restart() was removed
>>>> from v5.14 kernel, which was a part of preparatory work started by
>>>> Guenter Roeck. I took into account experience and ideas from the
>>>> previous attempts, extended and polished them.
>>>
>>>
>>> Rafael and all, do you see anything critical that needs to be improved
>>> in this v6?
>>>
>>> Will be great if you could take this patchset via the power tree if it
>>> looks okay, or give an ack.
>>
>> I need some more time for this, sorry.

No worries, we're not in a rush.

>> I'm a bit concerned about seeing no response to this set from anyone.
>>
>> It looks like multiple platforms may be affected by it in principle,
>> so doesn't anyone care?

The platforms that didn't provide ack so far are: SH, x86, IA64, MIPS
and NDS32. At least x86 and MIPS are alive, not sure why maintainers
didn't bother to answer yet.

> I did looked into the whole patch set after applying it locally.
> 
> While I agree a new combined API is good, and the beginning looked promising,
> after some time I started to ask myself if the whole infrastructure might
> be a little overdesigned.
> 
> Anyway, I tested it and it works for me on parisc.
> And it's probably better than what we have today.

Thank you!
