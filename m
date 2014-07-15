From: Michael Ellerman <mpe@ellerman.id.au>
Date: Tue, 15 Jul 2014 03:16:36 +0000
Subject: Re: Re: [PATCH v5 2/2] [BUGFIX] kprobes: Fix "Failed to find blacklist" error on ia64 and ppc64
Message-Id: <1405394196.17767.6.camel@concordia>
List-Id: <linux-ia64.vger.kernel.org>
References: <1404276081.7254.1.camel@concordia>
	  <20140702070029.14689.18485.stgit@kbuild-fedora.novalocal>
	  <53BBDEE6.1080800@hitachi.com>
	  <CA+8MBbJH3EfiGctxLpXScGEtvBNXkNVYEnyahihnCie1FgO+9Q@mail.gmail.com>
	 <1405390262.17767.5.camel@concordia> <53C490F1.4020402@hitachi.com>
In-Reply-To: <53C490F1.4020402@hitachi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Tony Luck <tony.luck@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Jeremy Fitzhardinge <jeremy@goop.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, sparse@chrisli.org, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, linux-tip-commits@vger.kernel.org, akataria@vmware.com, anil.s.keshavamurthy@intel.com, "Suzuki K. Poulose" <suzuki@in.ibm.com>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, Rusty Russell <rusty@rustcorp.com.au>, Chris Wright <chrisw@sous-sol.org>, yrl.pp-manager.tt@hitachi.com, Thomas Gleixner <tglx@linutronix.de>, Kevin Hao <haokexin@gmail.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, linuxppc-dev@lists.ozlabs.org, rdunlap@infradead.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, dl9pf@gmx.de, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>

On Tue, 2014-07-15 at 11:24 +0900, Masami Hiramatsu wrote:
> (2014/07/15 11:11), Michael Ellerman wrote:
> > On Mon, 2014-07-14 at 10:17 -0700, Tony Luck wrote:
> >> On Tue, Jul 8, 2014 at 5:07 AM, Masami Hiramatsu
> >> <masami.hiramatsu.pt@hitachi.com> wrote:
> >>> Ping?
> >>>
> >>> This patch can be applied without 1/2, and will fix ia64/ppc64 problem.
> >>
> >> Is somebody going to push this upstream? Another week has gone by,
> >> we are at -rc5, and I'm still seeing the
> >>
> >>   Failed to find blacklist a00000010133b150
> >>
> >> messages on ia64.
> > 
> > I don't see those messages on ppc64, I don't know where the original report
> > that it was broken on ppc64 came from. So I'm a bit lukewarm on the patch.
> 
> Right, on ppc64(ABIv1) it may be silently failed. Because each function
> descriptor has another entry on kallsyms, original code can't detect
> that. 

OK, that would have been good to know :)

It's actually much worse than you describe. On ppc64 (ABIv1) we are
successfully blacklisting the function descriptors. But that doesn't prevent
you from probing the text address. So basically NOKPROBE_SYMBOL() does nothing
useful for us.

$ head -2 ../kprobes/blacklist 
0xc000000000d4cff8-0xc000000000d4d010	notify_die
0xc000000000d4cf80-0xc000000000d4cf98	atomic_notifier_call_chain
$ echo "p:atomic_notifier_call_chain .atomic_notifier_call_chain" > kprobe_events
$ echo 1 > events/kprobes/enable 
$ ls
available_events      instances       saved_cmdlines       trace_options
available_tracers     kprobe_events   saved_cmdlines_size  trace_pipe
buffer_size_kb        kprobe_profile  set_event            tracing_cpumask
buffer_total_size_kb  options         snapshot             tracing_max_latency
current_tracer        per_cpu         trace                tracing_on
events                printk_formats  trace_clock          tracing_thresh
free_buffer           README          trace_marker
$ Dumping ftrace buffer:
cpu 0x2: Vector: 400 (Instruction Access) at [c0000001defaf830]
    pc: 0000000000000000
    lr: 0000000000000001
    sp: c0000001defafab0
   msr: 8000000140009032
  current = 0xc0000001def57e40
  paca    = 0xc00000000fe00800	 softe: 0	 irq_happened: 0x01
    pid   = 1, comm = swapper/2
cpu 0x3: Vector: 400 (Instruction Access) at [c0000001ddbcc640]
    pc: 0000000000000000
    lr: 0000000000000000
    sp: c0000001ddbcc8c0
   msr: 8000000040001032
  current = 0xc0000001def5a100
  paca    = 0xc00000000fe00c00	 softe: 0	 irq_happened: 0x01
    pid   = -554326528, comm = 

Dead machine.


With your patch:

$ head -2 kprobes/blacklist 
0xc0000000000bf860-0xc0000000000bf8b0	.notify_die
0xc0000000000bf750-0xc0000000000bf780	.atomic_notifier_call_chain

$ echo "p:notify_die .notify_die" > tracing/kprobe_events
-bash: echo: write error: Invalid argument

So that is much better.

cheers


