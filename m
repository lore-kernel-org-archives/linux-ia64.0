From: Dmitry Osipenko <dmitry.osipenko@collabora.com>
Date: Fri, 06 May 2022 14:46:57 +0000
Subject: Re: [PATCH v7 04/20] kernel: Add combined power-off+restart handler call chain API
Message-Id: <f8075f97-4cc7-b802-97af-c0ef5a969624@collabora.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220411233832.391817-1-dmitry.osipenko@collabora.com>
 <20220411233832.391817-5-dmitry.osipenko@collabora.com>
 <CAJZ5v0gnTSoeNP+QXwrZ45FQY4howVkJMuCjM=j+_-2BngJdQg@mail.gmail.com>
 <990621e7-9f8a-8b4a-02ec-fd6c1e1f48ff@collabora.com>
 <CAJZ5v0jxXtwot0qpib4UG8Tz8Hd1dEbgo58tEdPFboU8xwKHNw@mail.gmail.com>
In-Reply-To: <CAJZ5v0jxXtwot0qpib4UG8Tz8Hd1dEbgo58tEdPFboU8xwKHNw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Thierry Reding <thierry.reding@gmail.com>, Jonathan Hunter <jonathanh@nvidia.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Guo Ren <guoren@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Joshua Thompson <funaho@jurai.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Sebastian Reichel <sre@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, Philipp Zabel <p.zabel@pengutronix.de>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, the arch/x86 maintainers <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Stefano Stabellini <sstabellini@kernel.org>, Len Brown <lenb@kernel.org>, Santosh Shilimkar <ssantosh@kernel.org>, Krzysztof Kozlowski <krzk@kernel.org>, Liam Girdwood <lgirdwood@gmail.com>, Mark Brown <broonie@kernel.org>, Pavel Machek <pavel@ucw.cz>, Lee Jones <lee.jones@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Guenter Roeck <linux@roeck-us.net>, Daniel Lezcano <daniel.lezcano@linaro.org>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Ulf Hansson <ulf.hansson@linaro.org>, =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org, Linux-sh list <linux-sh@vger.kernel.org>, xen-devel@lists.xenproject.org, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux PM <linux-pm@vger.kernel.org>, linux-tegra <linux-tegra@vger.kernel.org>

On 4/20/22 21:47, Rafael J. Wysocki wrote:
>>>> +/**
>>>> + *     devm_register_prioritized_power_off_handler - Register prioritized power-off callback
>>>> + *     @dev: Device that registers callback
>>>> + *     @priority: Callback's priority
>>>> + *     @callback: Callback function
>>>> + *     @cb_data: Callback's argument
>>>> + *
>>>> + *     Registers resource-managed power-off callback with a given priority.
>>>> + *     It will be called as last step of the power-off sequence. Callbacks
>>>> + *     chaining is disabled, i.e. further lower priority callbacks won't
>>>> + *     be executed if this @callback will fail to execute.
>>>> + *
>>>> + *     Returns zero on success, or error code on failure.
>>> What's the case in which this should be used instead of registering a
>>> full sys_off handler?
>> There are a lot of drivers that just want to register power-off handler
>> with a non-default priority and don't need to stop the chain or do
>> anything else special. This is a convinient helper for them.
>>
>> Please note that the callback here takes only the cb_data for the
>> argument, while sys_off uses "struct power_off_data".
>>
>> Similar for the reset of the convinient helpers.
> So if there is a way to do this, why would anyone prefer to use the
> full sys_off handler at all?

There are couple occurrences around kernel where there is no device
available for the devm_ functions, like this for example [1].

[1]
https://gitlab.collabora.com/dmitry.osipenko/linux-kernel-rd/-/commit/184dfd3983e774d3cf9050dc5b4ec23a662a9551

-- 
Best regards,
Dmitry
