From: Dmitry Osipenko <dmitry.osipenko@collabora.com>
Date: Fri, 06 May 2022 15:28:49 +0000
Subject: Re: [PATCH v7 04/20] kernel: Add combined power-off+restart handler call chain API
Message-Id: <296e6f6f-e96d-2db1-77b9-288dc47d1b98@collabora.com>
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
>>>> +       spin_unlock(&platform_power_off_lock);
>>>> +
>>>> +       if (ret)
>>>> +               return ret;
>>>> +
>>>> +       ret = register_power_off_handler(&priv->power_off_nb);
>>>> +       if (ret)
>>>> +               priv->platform_power_off_cb = NULL;
>>>> +
>>>> +       return ret;
>>>> +}
>>>> +EXPORT_SYMBOL_GPL(register_platform_power_off);
>>>> +
>>>> +/**
>>>> + *     unregister_platform_power_off - Unregister platform-level power-off callback
>>>> + *     @power_off: Power-off callback
>>>> + *
>>>> + *     Unregisters previously registered platform power-off callback.
>>>> + *
>>>> + *     Returns zero on success, or error code on failure.
>>>> + */
>>>> +int unregister_platform_power_off(void (*power_off)(void))
>>>> +{
>>>> +       struct sys_off_handler_private_data *priv;
>>>> +       int ret;
>>>> +
>>>> +       priv = sys_off_handler_private_data(&platform_power_off_handler);
>>>> +
>>>> +       if (priv->platform_power_off_cb != power_off)
>>>> +               return -EINVAL;
>>>> +
>>>> +       ret = unregister_power_off_handler(&priv->power_off_nb);
>>>> +       priv->platform_power_off_cb = NULL;
>>>> +
>>>> +       return ret;
>>>> +}
>>>> +EXPORT_SYMBOL_GPL(unregister_platform_power_off);
>>>> +
>>>> +/**
>>>> + *     do_kernel_power_off - Execute kernel power-off handler call chain
>>>> + *
>>>> + *     Calls functions registered with register_power_off_handler.
>>>> + *
>>>> + *     Expected to be called as last step of the power-off sequence.
>>>> + *
>>>> + *     Powers off the system immediately if a power-off handler function has
>>>> + *     been registered. Otherwise does nothing.
>>>> + */
>>>> +void do_kernel_power_off(void)
>>>> +{
>>>> +       /* legacy pm_power_off() is unchained and has highest priority */
>>>> +       if (pm_power_off && pm_power_off != dummy_pm_power_off)
>>>> +               return pm_power_off();
>>>> +
>>>> +       blocking_notifier_call_chain(&power_off_handler_list, POWEROFF_NORMAL,
>>>> +                                    NULL);
>>>> +}
>>>> +
>>>> +static void do_kernel_power_off_prepare(void)
>>>> +{
>>>> +       /* legacy pm_power_off_prepare() is unchained and has highest priority */
>>>> +       if (pm_power_off_prepare)
>>>> +               return pm_power_off_prepare();
>>>> +
>>>> +       blocking_notifier_call_chain(&power_off_handler_list, POWEROFF_PREPARE,
>>>> +                                    NULL);
>>>> +}
>>>> +
>>>>  /**
>>>>   *     kernel_power_off - power_off the system
>>>>   *
>>>> @@ -304,8 +893,7 @@ EXPORT_SYMBOL_GPL(kernel_halt);
>>>>  void kernel_power_off(void)
>>>>  {
>>>>         kernel_shutdown_prepare(SYSTEM_POWER_OFF);
>>>> -       if (pm_power_off_prepare)
>>>> -               pm_power_off_prepare();
>>>> +       do_kernel_power_off_prepare();
>>>>         migrate_to_reboot_cpu();
>>>>         syscore_shutdown();
>>>>         pr_emerg("Power down\n");
>>>> @@ -314,6 +902,16 @@ void kernel_power_off(void)
>>>>  }
>>>>  EXPORT_SYMBOL_GPL(kernel_power_off);
>>>>
>>>> +bool kernel_can_power_off(void)
>>>> +{
>>>> +       if (!pm_power_off &&
>>>> +           blocking_notifier_call_chain_is_empty(&power_off_handler_list))
>>>> +               return false;
>>>> +
>>>> +       return true;
>>> return pm_power_off ||
>>> blocking_notifier_call_chain_is_empty(&power_off_handler_list);
>> Thank you for the thorough review!
> You're very welcome!

Thanks again for taking a look at the patches. I don't have strong
preferences about the names and etc, so I'll update it all in v8 like
you suggested.

-- 
Best regards,
Dmitry
