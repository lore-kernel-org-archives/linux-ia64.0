From: Dmitry Osipenko <digetx@gmail.com>
Date: Fri, 10 Dec 2021 19:33:32 +0000
Subject: Re: [PATCH v4 03/25] notifier: Add atomic/blocking_notifier_has_unique_priority()
Message-Id: <fd158245-aa9a-2e48-0145-004f30005a66@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211126180101.27818-1-digetx@gmail.com>
 <20211126180101.27818-4-digetx@gmail.com>
 <CAJZ5v0jTJ3f7oUUR690PGaPJsxA8yzua9XDa8MONBHMzHnDfOQ@mail.gmail.com>
 <e6ff1cea-a168-1cb0-25c5-fb16c681cf4a@gmail.com>
 <CAJZ5v0gwnY07vg71_NB8RDWyv84FtMsmx7UTDd8TkUd7vFzc6A@mail.gmail.com>
In-Reply-To: <CAJZ5v0gwnY07vg71_NB8RDWyv84FtMsmx7UTDd8TkUd7vFzc6A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Thierry Reding <thierry.reding@gmail.com>, Jonathan Hunter <jonathanh@nvidia.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Guo Ren <guoren@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Joshua Thompson <funaho@jurai.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Sebastian Reichel <sre@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, Philipp Zabel <p.zabel@pengutronix.de>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, the arch/x86 maintainers <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Stefano Stabellini <sstabellini@kernel.org>, Len Brown <lenb@kernel.org>, Santosh Shilimkar <ssantosh@kernel.org>, Krzysztof Kozlowski <krzysztof.kozlowski@canonical.com>, Liam Girdwood <lgirdwood@gmail.com>, Mark Brown <broonie@kernel.org>, Pavel Machek <pavel@ucw.cz>, Lee Jones <lee.jones@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Guenter Roeck <linux@roeck-us.net>, Daniel Lezcano <daniel.lezcano@linaro.org>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Ulf Hansson <ulf.hansson@linaro.org>, alankao@andestech.com, "K . C . Kuen-Chern Lin" <kclin@andestech.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-riscv@lists.infradead.org, Linux-sh list <linux-sh@vger.kernel.org>, xen-devel@lists.xenproject.org, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux PM <linux-pm@vger.kernel.org>, linux-tegra <linux-tegra@vger.kernel.org>

10.12.2021 22:05, Rafael J. Wysocki пишет:
> On Fri, Dec 10, 2021 at 7:52 PM Dmitry Osipenko <digetx@gmail.com> wrote:
>>
>> 10.12.2021 21:19, Rafael J. Wysocki пишет:
>> ...
>>>> +bool atomic_notifier_has_unique_priority(struct atomic_notifier_head *nh,
>>>> +               struct notifier_block *n)
>>>> +{
>>>> +       unsigned long flags;
>>>> +       bool ret;
>>>> +
>>>> +       spin_lock_irqsave(&nh->lock, flags);
>>>> +       ret = notifier_has_unique_priority(&nh->head, n);
>>>> +       spin_unlock_irqrestore(&nh->lock, flags);
>>>
>>> This only works if the caller can prevent new entries from being added
>>> to the list at this point or if the caller knows that they cannot be
>>> added for some reason, but the kerneldoc doesn't mention this
>>> limitation.
>>
>> I'll update the comment.
>>
>> ..
>>>> +bool blocking_notifier_has_unique_priority(struct blocking_notifier_head *nh,
>>>> +               struct notifier_block *n)
>>>> +{
>>>> +       bool ret;
>>>> +
>>>> +       /*
>>>> +        * This code gets used during boot-up, when task switching is
>>>> +        * not yet working and interrupts must remain disabled. At such
>>>> +        * times we must not call down_read().
>>>> +        */
>>>> +       if (system_state != SYSTEM_BOOTING)
>>>
>>> No, please don't do this, it makes the whole thing error-prone.
>>
>> What should I do then?
> 
> First of all, do you know of any users who may want to call this
> during early initialization?  If so, then why may they want to do
> that?

I'll need to carefully review all those dozens of platform restart
handlers to answer this question.

> Depending on the above, I would consider adding a special mechanism for them.

Please notice that every blocking_notifier_*() function has this
SYSTEM_BOOTING check, it's not my invention. Notifier API needs to be
generic.

>>>> +               down_read(&nh->rwsem);
>>>> +
>>>> +       ret = notifier_has_unique_priority(&nh->head, n);
>>>> +
>>>> +       if (system_state != SYSTEM_BOOTING)
>>>> +               up_read(&nh->rwsem);
>>>
>>> And still what if a new entry with a non-unique priority is added to
>>> the chain at this point?
>>
>> If entry with a non-unique priority is added after the check, then
>> obviously it won't be detected.
> 
> Why isn't this a problem?>> I don't understand the question. These
>> down/up_read() are the locks that prevent the race, if that's the question.
> 
> Not really, they only prevent the race from occurring while
> notifier_has_unique_priority() is running.
> 
> If anyone depends on this check for correctness, they need to lock the
> rwsem, do the check, do the thing depending on the check while holding
> the rwsem and then release the rwsem.  Otherwise it is racy.
> 

It's fine that it's a bit "racy" since in the context of this series. We
always do the check after adding new entry, so it's not a problem.

There are two options:

1. Use blocking_notifier_has_unique_priority() like it's done in this
patchset. Remove it after all drivers are converted to the new API and
add blocking_notifier_chain_register_unique().

2. Add blocking_notifier_chain_register_unique(), but don't let it fail
the registration of non-unique entries until all drivers are converted
to the new API.
