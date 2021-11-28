From: Dmitry Osipenko <digetx@gmail.com>
Date: Sun, 28 Nov 2021 21:04:43 +0000
Subject: Re: [PATCH v4 22/25] memory: emif: Use kernel_can_power_off()
Message-Id: <98c5c3d3-1635-3a06-b57f-8facd409796a@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211126180101.27818-1-digetx@gmail.com>
 <20211126180101.27818-23-digetx@gmail.com> <YaLaH3Yt2M/Gko//@qmqm.qmqm.pl>
In-Reply-To: <YaLaH3Yt2M/Gko//@qmqm.qmqm.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Cc: Thierry Reding <thierry.reding@gmail.com>, Jonathan Hunter <jonathanh@nvidia.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Guo Ren <guoren@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Joshua Thompson <funaho@jurai.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Sebastian Reichel <sre@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, Philipp Zabel <p.zabel@pengutronix.de>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Stefano Stabellini <sstabellini@kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Len Brown <lenb@kernel.org>, Santosh Shilimkar <ssantosh@kernel.org>, Krzysztof Kozlowski <krzysztof.kozlowski@canonical.com>, Liam Girdwood <lgirdwood@gmail.com>, Mark Brown <broonie@kernel.org>, Pavel Machek <pavel@ucw.cz>, Lee Jones <lee.jones@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Guenter Roeck <linux@roeck-us.net>, Daniel Lezcano <daniel.lezcano@linaro.org>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Ulf Hansson <ulf.hansson@linaro.org>, alankao@andestech.com, "K . C . Kuen-Chern Lin" <kclin@andestech.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-sh@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, linux-pm@vger.kernel.org, linux-tegra@vger.kernel.org

28.11.2021 04:23, Michał Mirosław пишет:
> On Fri, Nov 26, 2021 at 09:00:58PM +0300, Dmitry Osipenko wrote:
>> Replace legacy pm_power_off with kernel_can_power_off() helper that
>> is aware about chained power-off handlers.
>>
>> Signed-off-by: Dmitry Osipenko <digetx@gmail.com>
>> ---
>>  drivers/memory/emif.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/memory/emif.c b/drivers/memory/emif.c
>> index 762d0c0f0716..cab10d5274a0 100644
>> --- a/drivers/memory/emif.c
>> +++ b/drivers/memory/emif.c
>> @@ -630,7 +630,7 @@ static irqreturn_t emif_threaded_isr(int irq, void *dev_id)
>>  		dev_emerg(emif->dev, "SDRAM temperature exceeds operating limit.. Needs shut down!!!\n");
>>  
>>  		/* If we have Power OFF ability, use it, else try restarting */
>> -		if (pm_power_off) {
>> +		if (kernel_can_power_off()) {
>>  			kernel_power_off();
>>  		} else {
>>  			WARN(1, "FIXME: NO pm_power_off!!! trying restart\n");
> 
> BTW, this part of the code seems to be better moved to generic code that
> could replace POWER_OFF request with REBOOT like it is done for reboot()
> syscall.

Not sure that it can be done. Somebody will have to verify that it won't
break all those platform power-off handlers. Better to keep this code
as-is in the context of this patchset.
