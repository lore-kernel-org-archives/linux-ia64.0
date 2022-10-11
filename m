From: Valentin Schneider <vschneid@redhat.com>
Date: Tue, 11 Oct 2022 16:40:26 +0000
Subject: Re: [RFC PATCH 0/5] Generic IPI sending tracepoint
Message-Id: <xhsmhfsfufh51.mognet@vschneid.remote.csb>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221007154145.1877054-1-vschneid@redhat.com>
 <Y0CFnWDpMNGajIRD@fuller.cnet> <xhsmhilkqfi7z.mognet@vschneid.remote.csb>
 <3e680bb9-9896-3665-dd59-4f2e6f8205bb@redhat.com>
In-Reply-To: <3e680bb9-9896-3665-dd59-4f2e6f8205bb@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Daniel Bristot de Oliveira <bristot@redhat.com>
Cc: linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, x86@kernel.org, "Paul E. McKenney" <paulmck@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Juri Lelli <juri.lelli@redhat.com>, Frederic Weisbecker <frederic@kernel.org>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Marc Zyngier <maz@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Russell King <linux@armlinux.org.uk>, Nicholas Piggin <npiggin@gmail.com>, Marcelo Tosatti <mtosatti@redhat.com>, Guo Ren <guoren@kernel.org>, "David S.
 Miller" <davem@davemloft.net>, Douglas RAILLARD <douglas.raillard@arm.com>

On 11/10/22 18:22, Daniel Bristot de Oliveira wrote:
> On 10/11/22 18:17, Valentin Schneider wrote:
>> Thinking out loud, it makes way more sense to record a cpumask in the
>> tracepoint, but perhaps we could have a postprocessing step to transform
>> those into N events each targeting a single CPU?
>
> My approach on the tracers/rtla is to make the simple things in kernel, and beautify
> things in user-space.
>
> You could keep the tracepoint as a mask, and then make it pretty, like cpus=3-5,8
> in user-space. For example with a trace-cmd/perf loadable plugin, libtracefs helper.
>

That's a nice idea, the one downside I see is that means registering an
event handler for all events with cpumasks rather than directly targeting
cpumask fields, but that doesn't look too horrible. I'll dig a bit in that
direction.

> For rtla I was thinking to make a new tool to parse them. and make it pretty there.
>
> -- Daniel
