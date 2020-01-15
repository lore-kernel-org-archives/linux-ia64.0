From: Sudeep Holla <sudeep.holla@arm.com>
Date: Wed, 15 Jan 2020 11:41:12 +0000
Subject: Re: [PATCH v5] reboot: support offline CPUs before reboot
Message-Id: <20200115114112.GA3663@bogus>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200115063410.131692-1-hsinyi@chromium.org>
In-Reply-To: <20200115063410.131692-1-hsinyi@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hsin-Yi Wang <hsinyi@chromium.org>
Cc: Mark Rutland <mark.rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, Guenter Roeck <groeck@chromium.org>, Will Deacon <will@kernel.org>, Ingo Molnar <mingo@kernel.org>, linux-s390@vger.kernel.org, linux-csky@vger.kernel.org, Aaro Koskinen <aaro.koskinen@nokia.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-pm@vger.kernel.org, linux-xtensa@linux-xtensa.org, Sudeep Holla <sudeep.holla@arm.com>, Stephen Boyd <swboyd@chromium.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Pavankumar Kondeti <pkondeti@codeaurora.org>, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mips@vger.kernel.org, James Morse <james.morse@arm.com>, Jiri Kosina <jkosina@suse.cz>, Vitaly Kuznetsov <vkuznets@redhat.com>, linuxppc-dev@lists.ozlabs.org

On Wed, Jan 15, 2020 at 02:34:10PM +0800, Hsin-Yi Wang wrote:
> Currently system reboots uses architecture specific codes (smp_send_stop)
> to offline non reboot CPUs. Most architecture's implementation is looping
> through all non reboot online CPUs and call ipi function to each of them. Some
> architecture like arm64, arm, and x86... would set offline masks to cpu without
> really offline them. This causes some race condition and kernel warning comes
> out sometimes when system reboots.
>
> This patch adds a config ARCH_OFFLINE_CPUS_ON_REBOOT, which would offline cpus in
> migrate_to_reboot_cpu(). If non reboot cpus are all offlined here, the loop for
> checking online cpus would be an empty loop. If architecture don't enable this
> config, or some cpus somehow fails to offline, it would fallback to ipi
> function.
>

What's the timing impact on systems with large number of CPUs(say 256 or
more) ? I remember we added some change to reduce the wait times for
offlining CPUs in system suspend path on arm64, still not negligible.

--
Regards,
Sudeep
