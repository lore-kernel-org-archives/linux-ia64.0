From: Dmitry Osipenko <digetx@gmail.com>
Date: Mon, 29 Nov 2021 11:52:25 +0000
Subject: Re: [PATCH v4 08/25] kernel: Add combined power-off+restart handler call chain API
Message-Id: <33d1dfa7-e90e-d174-7375-836c15e7f818@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211126180101.27818-1-digetx@gmail.com>
 <20211126180101.27818-9-digetx@gmail.com> <YaLQqks8cB0vWp6Q@qmqm.qmqm.pl>
 <9213569e-0f40-0df1-4710-8dab564e12d6@gmail.com>
 <YaPx0kY7poGpwCL9@qmqm.qmqm.pl>
 <1fa2d9d5-f5f6-77f5-adf6-827921acce49@gmail.com>
 <YaQgiLw03lPyvuhr@qmqm.qmqm.pl>
In-Reply-To: <YaQgiLw03lPyvuhr@qmqm.qmqm.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Cc: Thierry Reding <thierry.reding@gmail.com>, Jonathan Hunter <jonathanh@nvidia.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Guo Ren <guoren@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Joshua Thompson <funaho@jurai.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Sebastian Reichel <sre@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, Philipp Zabel <p.zabel@pengutronix.de>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Stefano Stabellini <sstabellini@kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Len Brown <lenb@kernel.org>, Santosh Shilimkar <ssantosh@kernel.org>, Krzysztof Kozlowski <krzysztof.kozlowski@canonical.com>, Liam Girdwood <lgirdwood@gmail.com>, Mark Brown <broonie@kernel.org>, Pavel Machek <pavel@ucw.cz>, Lee Jones <lee.jones@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Guenter Roeck <linux@roeck-us.net>, Daniel Lezcano <daniel.lezcano@linaro.org>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Ulf Hansson <ulf.hansson@linaro.org>, alankao@andestech.com, "K . C . Kuen-Chern Lin" <kclin@andestech.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-sh@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, linux-pm@vger.kernel.org, linux-tegra@vger.kernel.org

29.11.2021 03:36, Michał Mirosław пишет:
> On Mon, Nov 29, 2021 at 12:53:51AM +0300, Dmitry Osipenko wrote:
>> 29.11.2021 00:17, Michał Mirosław пишет:
>>>> I'm having trouble with parsing this comment. Could you please try to
>>>> rephrase it? I don't see how you could check whether power-off handler
>>>> is available if you'll mix all handlers together.
>>> If notify_call_chain() would be fixed to return NOTIFY_OK if any call
>>> returned NOTIFY_OK, then this would be a clear way to gather the
>>> answer if any of the handlers will attempt the final action (reboot or
>>> power off).
>> Could you please show a code snippet that implements your suggestion?
> 
> A rough idea is this:
> 
>  static int notifier_call_chain(struct notifier_block **nl,
>  			       unsigned long val, void *v,
>  			       int nr_to_call, int *nr_calls)
>  {
> -	int ret = NOTIFY_DONE;
> +	int ret, result = NOTIFY_DONE;
>  	struct notifier_block *nb, *next_nb;
>  
>  	nb = rcu_dereference_raw(*nl);
>  
>  	while (nb && nr_to_call) {
> ...
>  		ret = nb->notifier_call(nb, val, v);
> +
> +		/* Assuming NOTIFY_STOP-carrying return is always greater than non-stopping one. */
> +		if (result < ret)
> +			result = ret;
> ... 
>  	}
> -	return ret;
> +	return result;
>  }
> 
> Then:
> 
> bool prepare_reboot()
> {
> 	int ret = xx_notifier_call_chain(&shutdown_notifier, PREPARE_REBOOT, ...);
> 	return ret = NOTIFY_OK;
> }
> 
> And the return value would signify whether the reboot will be attempted
> when calling the chain for the REBOOT action. (Analogously for powering off.)

If you started to execute call chain, then you began the power-off /
restart sequence, this is a point of no return. Sorry, I still don't
understand what you're trying to achieve.

The approach of having separate call chains is simple and intuitive, I
don't see reasons to change it.
