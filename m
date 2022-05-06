From: Dmitry Osipenko <dmitry.osipenko@collabora.com>
Date: Fri, 06 May 2022 14:10:24 +0000
Subject: Re: [PATCH v7 04/20] kernel: Add combined power-off+restart handler call chain API
Message-Id: <ca422804-0fa0-5fef-07e2-a9ff005a495c@collabora.com>
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
>>>> +       POWEROFF_PREPARE,
>>>> +};
>>>> +
>>>> +/**
>>>> + * struct power_off_data - Power-off callback argument
>>>> + *
>>>> + * @cb_data: Callback data.
>>>> + */
>>>> +struct power_off_data {
>>>> +       void *cb_data;
>>>> +};
>>>> +
>>>> +/**
>>>> + * struct power_off_prep_data - Power-off preparation callback argument
>>>> + *
>>>> + * @cb_data: Callback data.
>>>> + */
>>>> +struct power_off_prep_data {
>>>> +       void *cb_data;
>>>> +};
>>> Why does this need to be a separate data type?
>> To allow us extend the "struct power_off_prep_data" with more parameters
>> later on without a need to update each driver with the new arguments.

> I'm not really sure what you mean here.  Can you give an example?
> 

The restart callbacks use more than the cb_data and we have:

struct restart_data {
	void *cb_data;
	const char *cmd;
	bool stop_chain;
	enum reboot_mode mode;
};

If we'll ever need to extended struct power_off_data similarly to the
restart_data, then we will need to update all the power-off callbacks
instead of adding a new field to the power_off_data.

Hence, for example, if you'll want to extend power_off_data with "enum
poweroff_mode mode", then for each driver you'll need to do this change:

-power_off(void *cb_data)
+power_off(void *cb_data, enum poweroff_mode mode)

and you won't need to do that using struct power_off_data.

Why do we need this? Because I saw in the past people changing kernel
APIs that way when they wanted to add new arguments and then needed to
update every call site around the kernel.

-- 
Best regards,
Dmitry
