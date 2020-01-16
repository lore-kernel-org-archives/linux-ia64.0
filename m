From: Thomas Gleixner <tglx@linutronix.de>
Date: Thu, 16 Jan 2020 00:30:33 +0000
Subject: Re: [PATCH v5] reboot: support offline CPUs before reboot
Message-Id: <8736cgxmxi.fsf@nanos.tec.linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200115063410.131692-1-hsinyi@chromium.org>
In-Reply-To: <20200115063410.131692-1-hsinyi@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hsin-Yi Wang <hsinyi@chromium.org>
Cc: Mark Rutland <mark.rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, Guenter Roeck <groeck@chromium.org>, Will Deacon <will@kernel.org>, Ingo Molnar <mingo@kernel.org>, linux-s390@vger.kernel.org, linux-csky@vger.kernel.org, Aaro Koskinen <aaro.koskinen@nokia.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-pm@vger.kernel.org, linux-xtensa@linux-xtensa.org, Stephen Boyd <swboyd@chromium.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Pavankumar Kondeti <pkondeti@codeaurora.org>, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mips@vger.kernel.org, James Morse <james.morse@arm.com>, Jiri Kosina <jkosina@suse.cz>, Vitaly Kuznetsov <vkuznets@redhat.com>, linuxppc-dev@lists.ozlabs.org

Hsin-Yi Wang <hsinyi@chromium.org> writes:

> Currently system reboots uses architecture specific codes (smp_send_stop)
> to offline non reboot CPUs. Most architecture's implementation is looping
> through all non reboot online CPUs and call ipi function to each of them. Some
> architecture like arm64, arm, and x86... would set offline masks to cpu without
> really offline them. This causes some race condition and kernel warning comes
> out sometimes when system reboots.

'some race condition and kernel warning' is pretty useless information.
Please describe exactly which kind of issues are caused by the current
mechanism. Especially the race conditions are the interesting part (the
warnings are just a consequence).

> This patch adds a config ARCH_OFFLINE_CPUS_ON_REBOOT, which would
> offline cpus in

Please read Documentation/process/submitting-patches.rst and search for
'This patch'.

> migrate_to_reboot_cpu(). If non reboot cpus are all offlined here, the loop for
> checking online cpus would be an empty loop.

This does not make any sense. The issues which you are trying to solve
are going to be still there when CONFIG_HOTPLUG_CPU is disabled.

> If architecture don't enable this config, or some cpus somehow fails
> to offline, it would fallback to ipi function.

This is really a half baken solution which keeps the various pointlessly
different pseudo reboot/kexec offlining implementations around. So with
this we have yet more code which only works depending on kernel
configuration and has the issue of potentially not being able to offline
a CPU. IOW this is going to fail completely in cases where a system is
in a state which prevents regular hotplug.

The existing pseudo-offline functions have timeouts and eventually a
fallback, e.g. the NMI fallback on x86. With this proposed regular
offline solution this will just get stuck w/o a chance to force
recovery.

While I like the idea and surely agree that the ideal solution is to
properly shutdown the CPUs on reboot, we need to take a step back and
look at the minimum requirements for a regular shutdown/reboot and at
the same time have a look at the requirements for emergency shutdown and
kexec/kcrash. Having proper information about the race conditions and
warnings you mentioned would be a good starting point.

> Opt in this config for architectures that support CONFIG_HOTPLUG_CPU.

This is not opt-in. You force that on all architectures which support
CONFIG_HOTPLUG_CPU. The way we do this normally is to provide the
infrastructure first and then have separate patches (one per
architecture) enabling this, which allows the architecture maintainers
to decide individually.

Thanks,

        tglx
