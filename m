From: Rob Landley <rob@landley.net>
Date: Fri, 17 Jan 2020 04:20:28 +0000
Subject: Re: [PATCH RESEND v4] reboot: support offline CPUs before reboot
Message-Id: <a701522f-73aa-2277-4a25-f84a27f38118@landley.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200114110620.164861-1-hsinyi@chromium.org>
In-Reply-To: <20200114110620.164861-1-hsinyi@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hsin-Yi Wang <hsinyi@chromium.org>, Thomas Gleixner <tglx@linutronix.de>
Cc: Mark Rutland <mark.rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, Guenter Roeck <groeck@chromium.org>, Will Deacon <will@kernel.org>, Ingo Molnar <mingo@kernel.org>, linux-s390@vger.kernel.org, linux-csky@vger.kernel.org, Aaro Koskinen <aaro.koskinen@nokia.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-pm@vger.kernel.org, linux-xtensa@linux-xtensa.org, Stephen Boyd <swboyd@chromium.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Pavankumar Kondeti <pkondeti@codeaurora.org>, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mips@vger.kernel.org, James Morse <james.morse@arm.com>, Jiri Kosina <jkosina@suse.cz>, Vitaly Kuznetsov <vkuznets@redhat.com>, linuxppc-dev@lists.ozlabs.org

On 1/14/20 5:06 AM, Hsin-Yi Wang wrote:
> This patch adds a config ARCH_OFFLINE_CPUS_ON_REBOOT, which would offline cpus in
> migrate_to_reboot_cpu(). If non reboot cpus are all offlined here, the loop for
> checking online cpus would be an empty loop. If architecture don't enable this
> config, or some cpus somehow fails to offline, it would fallback to ipi
> function.

I'm curious:

> +# Select to do a full offline on secondary CPUs before reboot.
> +config ARCH_OFFLINE_CPUS_ON_REBOOT
> +	bool "Support for offline CPUs before reboot"
> +	depends on HOTPLUG_CPU

The new symbol can't be selected without the other symbol.

> +	select ARCH_OFFLINE_CPUS_ON_REBOOT if HOTPLUG_CPU

And the other symbol automatically selects the new one.

Why are you adding a second symbol that means the same thing as the existing symbol?

> +#if defined(CONFIG_PM_SLEEP_SMP) || defined(CONFIG_ARCH_OFFLINE_CPUS_ON_REBOOT)
> +extern int freeze_secondary_cpus(int primary, bool reboot);
> +#endif

Couldn't that just test HOTPLUG_CPU? What's the second symbol for? (You can have
empty stub functions when architectures don't support a thing...)

Rob
