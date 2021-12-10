From: Dmitry Osipenko <digetx@gmail.com>
Date: Fri, 10 Dec 2021 18:52:01 +0000
Subject: Re: [PATCH v4 03/25] notifier: Add atomic/blocking_notifier_has_unique_priority()
Message-Id: <e6ff1cea-a168-1cb0-25c5-fb16c681cf4a@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211126180101.27818-1-digetx@gmail.com>
 <20211126180101.27818-4-digetx@gmail.com>
 <CAJZ5v0jTJ3f7oUUR690PGaPJsxA8yzua9XDa8MONBHMzHnDfOQ@mail.gmail.com>
In-Reply-To: <CAJZ5v0jTJ3f7oUUR690PGaPJsxA8yzua9XDa8MONBHMzHnDfOQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Thierry Reding <thierry.reding@gmail.com>, Jonathan Hunter <jonathanh@nvidia.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Guo Ren <guoren@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Joshua Thompson <funaho@jurai.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Sebastian Reichel <sre@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, Philipp Zabel <p.zabel@pengutronix.de>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, the arch/x86 maintainers <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Stefano Stabellini <sstabellini@kernel.org>, Len Brown <lenb@kernel.org>, Santosh Shilimkar <ssantosh@kernel.org>, Krzysztof Kozlowski <krzysztof.kozlowski@canonical.com>, Liam Girdwood <lgirdwood@gmail.com>, Mark Brown <broonie@kernel.org>, Pavel Machek <pavel@ucw.cz>, Lee Jones <lee.jones@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Guenter Roeck <linux@roeck-us.net>, Daniel Lezcano <daniel.lezcano@linaro.org>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Ulf Hansson <ulf.hansson@linaro.org>, alankao@andestech.com, "K . C . Kuen-Chern Lin" <kclin@andestech.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-riscv@lists.infradead.org, Linux-sh list <linux-sh@vger.kernel.org>, xen-devel@lists.xenproject.org, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux PM <linux-pm@vger.kernel.org>, linux-tegra <linux-tegra@vger.kernel.org>

10.12.2021 21:19, Rafael J. Wysocki пишет:
...
>> +bool atomic_notifier_has_unique_priority(struct atomic_notifier_head *nh,
>> +               struct notifier_block *n)
>> +{
>> +       unsigned long flags;
>> +       bool ret;
>> +
>> +       spin_lock_irqsave(&nh->lock, flags);
>> +       ret = notifier_has_unique_priority(&nh->head, n);
>> +       spin_unlock_irqrestore(&nh->lock, flags);
> 
> This only works if the caller can prevent new entries from being added
> to the list at this point or if the caller knows that they cannot be
> added for some reason, but the kerneldoc doesn't mention this
> limitation.

I'll update the comment.

..
>> +bool blocking_notifier_has_unique_priority(struct blocking_notifier_head *nh,
>> +               struct notifier_block *n)
>> +{
>> +       bool ret;
>> +
>> +       /*
>> +        * This code gets used during boot-up, when task switching is
>> +        * not yet working and interrupts must remain disabled. At such
>> +        * times we must not call down_read().
>> +        */
>> +       if (system_state != SYSTEM_BOOTING)
> 
> No, please don't do this, it makes the whole thing error-prone.

What should I do then?

>> +               down_read(&nh->rwsem);
>> +
>> +       ret = notifier_has_unique_priority(&nh->head, n);
>> +
>> +       if (system_state != SYSTEM_BOOTING)
>> +               up_read(&nh->rwsem);
> 
> And still what if a new entry with a non-unique priority is added to
> the chain at this point?

If entry with a non-unique priority is added after the check, then
obviously it won't be detected. I don't understand the question. These
down/up_read() are the locks that prevent the race, if that's the question.
