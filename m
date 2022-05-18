From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Wed, 18 May 2022 14:46:15 +0000
Subject: Re: [PATCH v8 00/27] Introduce power-off+restart call chain API
Message-Id: <CAJZ5v0jhWs-8ChHddebTZcaH6kA05sLEMsXM9Op7kHWAQDxeYA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220509233235.995021-1-dmitry.osipenko@collabora.com>
In-Reply-To: <20220509233235.995021-1-dmitry.osipenko@collabora.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Dmitry Osipenko <dmitry.osipenko@collabora.com>
Cc: Thierry Reding <thierry.reding@gmail.com>, Jonathan Hunter <jonathanh@nvidia.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Guo Ren <guoren@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Joshua Thompson <funaho@jurai.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Sebastian Reichel <sre@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, Philipp Zabel <p.zabel@pengutronix.de>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, the arch/x86 maintainers <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Stefano Stabellini <sstabellini@kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Len Brown <lenb@kernel.org>, Santosh Shilimkar <ssantosh@kernel.org>, Krzysztof Kozlowski <krzk@kernel.org>, Liam Girdwood <lgirdwood@gmail.com>, Mark Brown <broonie@kernel.org>, Pavel Machek <pavel@ucw.cz>, Lee Jones <lee.jones@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Guenter Roeck <linux@roeck-us.net>, Daniel Lezcano <daniel.lezcano@linaro.org>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Ulf Hansson <ulf.hansson@linaro.org>, =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org, Linux-sh list <linux-sh@vger.kernel.org>, xen-devel@lists.xenproject.org, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux PM <linux-pm@vger.kernel.org>, linux-tegra <linux-tegra@vger.kernel.org>

On Tue, May 10, 2022 at 1:33 AM Dmitry Osipenko
<dmitry.osipenko@collabora.com> wrote:
>
> Problem
> -------
>
> SoC devices require power-off call chaining functionality from kernel.
> We have a widely used restart chaining provided by restart notifier API,
> but nothing for power-off.
>
> Solution
> --------
>
> Introduce new API that provides call chains support for all restart and
> power-off modes. The new API is designed with simplicity and extensibility
> in mind.
>
> This is a third attempt to introduce the new API. First was made by
> Guenter Roeck back in 2014, second was made by Thierry Reding in 2017.
> In fact the work didn't stop and recently arm_pm_restart() was removed
> from v5.14 kernel, which was a part of preparatory work started by
> Guenter Roeck.
>
> Adoption plan
> -------------
>
> This patchset introduces the new API. It also converts multiple drivers
> and arch code to the new API to demonstrate how it all looks in practice,
> removing the pm_power_off_prepare global variable.
>
> The plan is:
>
> 1. Merge the new API and convert arch code to use do_kernel_power_off().
>    For now the new API will co-exist with the older API.
>
> 2. Convert all drivers and platform code to the new API.
>
> 3. Remove obsoleted pm_power_off and pm_power_off_prepare variables.
>
> Results
> -------
>
> 1. Devices can be powered off properly.
>
> 2. Global variables are removed from drivers.
>
> 3. Global pm_power_off and pm_power_off_prepare callback variables are
> removed once all users are converted to the new API. The latter callback
> is removed by patch #24 of this series.
>
> 4. Ambiguous call chain ordering is prohibited for non-default priorities.
>
> Changelog:
>
> v8: - Reworked sys-off handler like was suggested by Rafael Wysocki in
>       the comments to v7.
>
>     - The struct sys-off handler now is private to kernel/reboot.c and
>       new API is simplified.
>
>     - There is a single sys-off API function for all handler types.
>       Users shall pass the required sys-off mode type (restart, power-off
>       and etc).
>
>     - There is single struct sys_off_data callback argument for all
>       handler modes.
>
>     - User's callback now must return NOTIFY_DONE or NOTIFY_STOP.
>
>     - The default priority level is zero now.
>
>     - Multiple handlers now allowed to be registered at the default
>       priority level.
>
>     - Power-off call chain is atomic now, like the restart chain.
>
>     - kernel/reboot.c changes are split up into several logical patches.
>
>     - Added r-b from Michał Mirosław to unmodified patches from v7.
>
>     - Added acks that were missing in v7 by accident.

The v8 looks much better than the previous versions to me.

I actually don't really have any comments on it except for the minor
remark regarding patch [1/27] sent separately.

Please just send an update of that one patch and I will queue up the
series for 5.19.

However, I'm going to send a pull request with it in the second half
of the merge window, after the majority of the other changes in the
subsystems touched by it have been integrated.

> v7: - Rebased on a recent linux-next. Dropped the recently removed
>       NDS32 architecture. Only SH and x86 arches left un-acked.
>
>     - Added acks from Thomas Bogendoerfer and Krzysztof Kozlowski
>       to the MIPS and memory/emif patches respectively.
>
>     - Made couple minor cosmetic improvements to the new API.
>
>     - A month ago I joined Collabora and continuing to work on this series
>       on the company's time, so changed my email address to collabora.com
>
> v6: - Rebased on a recent linux-next.
>
>     - Made minor couple cosmetic changes.
>
> v5: - Dropped patches which cleaned up notifier/reboot headers, as was
>       requested by Rafael Wysocki.
>
>     - Dropped WARN_ON() from the code, as was requested by Rafael Wysocki.
>       Replaced it with pr_err() appropriately.
>
>     - Dropped *_notifier_has_unique_priority() functions and added
>       *_notifier_chain_register_unique_prio() instead, as was suggested
>       by Michał Mirosław and Rafael Wysocki.
>
>     - Dropped export of blocking_notifier_call_chain_is_empty() symbol,
>       as was suggested by Rafael Wysocki.
>
>     - Michał Mirosław suggested that will be better to split up patch
>       that adds the new API to ease reviewing, but Rafael Wysocki asked
>       not add more patches, so I kept it as a single patch.
>
>     - Added temporary "weak" stub for pm_power_off() which fixes linkage
>       failure once symbol is removed from arch/* code. Previously I missed
>       this problem because was only compile-testing object files.
>
> v4: - Made a very minor improvement to doc comments, clarifying couple
>       default values.
>
>     - Corrected list of emails recipient by adding Linus, Sebastian,
>       Philipp and more NDS people. Removed bouncing emails.
>
>     - Added acks that were given to v3.
>
> v3: - Renamed power_handler to sys_off_handler as was suggested by
>       Rafael Wysocki.
>
>     - Improved doc-comments as was suggested by Rafael Wysocki. Added more
>       doc-comments.
>
>     - Implemented full set of 180 patches which convert whole kernel in
>       accordance to the plan, see link [1] above. Slightly adjusted API to
>       better suit for the remaining converted drivers.
>
>       * Added unregister_sys_off_handler() that is handy for a couple old
>         platform drivers.
>
>       * Dropped devm_register_trivial_restart_handler(), 'simple' variant
>         is enough to have.
>
>     - Improved "Add atomic/blocking_notifier_has_unique_priority()" patch,
>       as was suggested by Andy Shevchenko. Also replaced down_write() with
>       down_read() and factored out common notifier_has_unique_priority().
>
>     - Added stop_chain field to struct restart_data and reboot_prep_data
>       after discovering couple drivers wanting that feature.
>
>     - Added acks that were given to v2.
>
> v2: - Replaced standalone power-off call chain demo-API with the combined
>       power-off+restart API because this is what drivers want. It's a more
>       comprehensive solution.
>
>     - Converted multiple drivers and arch code to the new API. Suggested by
>       Andy Shevchenko. I skimmed through the rest of drivers, verifying that
>       new API suits them. The rest of the drivers will be converted once we
>       will settle on the new API, otherwise will be too many patches here.
>
>     - v2 API doesn't expose notifier to users and require handlers to
>       have unique priority. Suggested by Guenter Roeck.
>
>     - v2 API has power-off chaining disabled by default and require
>       drivers to explicitly opt-in to the chaining. This preserves old
>       behaviour for existing drivers once they are converted to the new
>       API.
>
> Dmitry Osipenko (27):
>   notifier: Add atomic_notifier_call_chain_is_empty()
>   notifier: Add blocking/atomic_notifier_chain_register_unique_prio()
>   kernel/reboot: Introduce sys-off handler API
>   kernel/reboot: Wrap legacy power-off callbacks into sys-off handlers
>   kernel/reboot: Add do_kernel_power_off()
>   kernel/reboot: Add stub for pm_power_off
>   kernel/reboot: Add kernel_can_power_off()
>   kernel/reboot: Add register_platform_power_off()
>   ARM: Use do_kernel_power_off()
>   csky: Use do_kernel_power_off()
>   riscv: Use do_kernel_power_off()
>   arm64: Use do_kernel_power_off()
>   parisc: Use do_kernel_power_off()
>   xen/x86: Use do_kernel_power_off()
>   powerpc: Use do_kernel_power_off()
>   m68k: Switch to new sys-off handler API
>   sh: Use do_kernel_power_off()
>   x86: Use do_kernel_power_off()
>   ia64: Use do_kernel_power_off()
>   mips: Use do_kernel_power_off()
>   memory: emif: Use kernel_can_power_off()
>   ACPI: power: Switch to sys-off handler API
>   regulator: pfuze100: Use devm_register_sys_off_handler()
>   reboot: Remove pm_power_off_prepare()
>   soc/tegra: pmc: Use sys-off handler API to power off Nexus 7 properly
>   kernel/reboot: Add devm_register_power_off_handler()
>   kernel/reboot: Add devm_register_restart_handler()
>
>  arch/arm/kernel/reboot.c               |   4 +-
>  arch/arm64/kernel/process.c            |   3 +-
>  arch/csky/kernel/power.c               |   6 +-
>  arch/ia64/kernel/process.c             |   4 +-
>  arch/m68k/emu/natfeat.c                |   3 +-
>  arch/m68k/include/asm/machdep.h        |   1 -
>  arch/m68k/kernel/process.c             |   5 +-
>  arch/m68k/kernel/setup_mm.c            |   1 -
>  arch/m68k/kernel/setup_no.c            |   1 -
>  arch/m68k/mac/config.c                 |   4 +-
>  arch/mips/kernel/reset.c               |   3 +-
>  arch/parisc/kernel/process.c           |   4 +-
>  arch/powerpc/kernel/setup-common.c     |   4 +-
>  arch/powerpc/xmon/xmon.c               |   3 +-
>  arch/riscv/kernel/reset.c              |  12 +-
>  arch/sh/kernel/reboot.c                |   3 +-
>  arch/x86/kernel/reboot.c               |   4 +-
>  arch/x86/xen/enlighten_pv.c            |   4 +-
>  drivers/acpi/sleep.c                   |  16 +-
>  drivers/memory/emif.c                  |   2 +-
>  drivers/regulator/pfuze100-regulator.c |  42 ++-
>  drivers/soc/tegra/pmc.c                |  87 +++++--
>  include/linux/notifier.h               |   7 +
>  include/linux/pm.h                     |   1 -
>  include/linux/reboot.h                 |  91 +++++++
>  kernel/notifier.c                      | 101 +++++--
>  kernel/reboot.c                        | 347 ++++++++++++++++++++++++-
>  27 files changed, 639 insertions(+), 124 deletions(-)
>
> --
> 2.35.1
>
