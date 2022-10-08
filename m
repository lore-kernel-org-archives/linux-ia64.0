From: Steven Rostedt <rostedt@goodmis.org>
Date: Sat, 08 Oct 2022 19:40:16 +0000
Subject: Re: [RFC PATCH 0/5] Generic IPI sending tracepoint
Message-Id: <20221008154016.0f7ecd8f@rorschach.local.home>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221007154145.1877054-1-vschneid@redhat.com>
	<Y0CFnWDpMNGajIRD@fuller.cnet>
In-Reply-To: <Y0CFnWDpMNGajIRD@fuller.cnet>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Marcelo Tosatti <mtosatti@redhat.com>
Cc: Valentin Schneider <vschneid@redhat.com>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, x86@kernel.org, "Paul E. McKenney" <paulmck@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Juri Lelli <juri.lelli@redhat.com>, Daniel Bristot de Oliveira <bristot@redhat.com>, Frederic Weisbecker <frederic@kernel.org>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Marc Zyngier <maz@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Russell King <linux@armlinux.org.uk>, Nicholas Piggin <npiggin@gmail.com>, Guo Ren <guoren@kernel.org>, "David S.
 Miller" <davem@davemloft.net>

On Fri, 7 Oct 2022 17:01:33 -0300
Marcelo Tosatti <mtosatti@redhat.com> wrote:

> > As for the targeted CPUs, the existing tracepoint does export them, albeit in
> > cpumask form, which is quite inconvenient from a tooling perspective. For
> > instance, as far as I'm aware, it's not possible to do event filtering on a
> > cpumask via trace-cmd.  
> 
> https://man7.org/linux/man-pages/man1/trace-cmd-set.1.html
> 
>        -f filter
>            Specify a filter for the previous event. This must come after
>            a -e. This will filter what events get recorded based on the
>            content of the event. Filtering is passed to the kernel
>            directly so what filtering is allowed may depend on what
>            version of the kernel you have. Basically, it will let you
>            use C notation to check if an event should be processed or
>            not.
> 
>                =, >=, <=, >, <, &, |, && and ||
> 
>            The above are usually safe to use to compare fields.

We could always add an "isset(x)" filter ;-)

-- Steve
