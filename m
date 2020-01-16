From: Thomas Gleixner <tglx@linutronix.de>
Date: Thu, 16 Jan 2020 11:10:56 +0000
Subject: Re: [PATCH v5] reboot: support offline CPUs before reboot
Message-Id: <87h80vwta7.fsf@nanos.tec.linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200115063410.131692-1-hsinyi@chromium.org>
 <8736cgxmxi.fsf@nanos.tec.linutronix.de>
 <CAJMQK-jDi+AACE1Cv_hKSMq8VhGTBeh+kyHO2U4sx9w=9bO2mA@mail.gmail.com>
In-Reply-To: <CAJMQK-jDi+AACE1Cv_hKSMq8VhGTBeh+kyHO2U4sx9w=9bO2mA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hsin-Yi Wang <hsinyi@chromium.org>
Cc: Mark Rutland <mark.rutland@arm.com>, linux-ia64@vger.kernel.org, Linux-sh list <linux-sh@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, lkml <linux-kernel@vger.kernel.org>, sparclinux@vger.kernel.org, Guenter Roeck <groeck@chromium.org>, Will Deacon <will@kernel.org>, Ingo Molnar <mingo@kernel.org>, linux-s390@vger.kernel.org, linux-csky@vger.kernel.org, Aaro Koskinen <aaro.koskinen@nokia.com>, Fenghua Yu <fenghua.yu@intel.com>, Linux PM <linux-pm@vger.kernel.org>, linux-xtensa@linux-xtensa.org, Stephen Boyd <swboyd@chromium.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Pavankumar Kondeti <pkondeti@codeaurora.org>, "moderated list:ARM/FREESCALE IMX / MXC ARM ARCHITECTURE" <linux-arm-kernel@lists.infradead.org>, linux-parisc@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mips@vger.kernel.org, James Morse <james.morse@arm.com>, Jiri Kosina <jkosina@suse.cz>, Vitaly Kuznetsov <vkuznets@redhat.com>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>

Hsin-Yi Wang <hsinyi@chromium.org> writes:
> On Thu, Jan 16, 2020 at 8:30 AM Thomas Gleixner <tglx@linutronix.de> wrote:
> We saw this issue on regular reboot (not panic) on arm64: If tick
> broadcast and smp_send_stop() happen together and the first broadcast
> arrives to some idled CPU that hasn't already executed reboot ipi to
> run in spinloop, it would try to broadcast to another CPU, but that
> target CPU is already marked as offline by set_cpu_online() in reboot
> ipi, and a warning comes out since tick_handle_oneshot_broadcast()
> would check if it tries to broadcast to offline cpus. Most of the time
> the CPU getting the broadcast interrupt is already in the spinloop and
> thus isn't going to receive interrupts from the broadcast timer.

The timer broadcasting is obviously broken by the existing reboot unplug
mechanism as the outgoing CPU should remove itself from the broadcast.

Just addressing the broadcast issue is not sufficient as there are tons
of other places which rely on consistency of the various cpu masks.

> If system supports hotplug, _cpu_down() would properly handle tasks
> termination such as remove CPU from timer broadcasting by
> tick_offline_cpu()...etc, as well as some interrupt handling.

Well, emphasis on 'if system supports hotplug'. If not, then you are
back to square one. On ARM64 hotplug is selectable by a config option.

So either we mandate HOTPLUG_CPU for SMP and get rid of all the
ifdeffery or we need to have a mechanism which works on !HOTPLUG_CPU as
well.

That whole reboot/shutdown stuff is an unpenetrable mess of notifiers
and architecture hackery, so something generic and understandable is
really required.

Thanks,

        tglx
