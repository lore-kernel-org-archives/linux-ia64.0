From: Andi Kleen <ak@suse.de>
Date: Sat, 27 Aug 2005 00:24:25 +0000
Subject: Re: [PATCH] Only process_die notifier in ia64_do_page_fault if KPROBES is configured.
Message-Id: <200508270224.26423.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <200508262246.j7QMkEoT013490@linux.jf.intel.com> <Pine.LNX.4.62.0508261559450.17433@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0508261559450.17433@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Rusty Lynch <rusty.lynch@intel.com>, linux-mm@kvack.org, prasanna@in.ibm.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, anil.s.keshavamurthy@intel.com

On Saturday 27 August 2005 01:05, Christoph Lameter wrote:
> On Fri, 26 Aug 2005, Rusty Lynch wrote:
> > Just to be sure everyone understands the overhead involved, kprobes only
> > registers a single notifier.  If kprobes is disabled (CONFIG_KPROBES is
> > off) then the overhead on a page fault is the overhead to execute an
> > empty notifier chain.
>
> Its the overhead of using registers to pass parameters, performing a
> function call that does nothing etc. A waste of computing resources. All
> of that unconditionally in a performance critical execution path that
> is executed a gazillion times for an optional feature that I frankly
> find not useful at all and that is disabled by default.

In the old days notifier_call_chain used to be inline. Then someone looking
at code size out of lined it. Perhaps it should be inlined again or notifier.h
could supply a special faster inline version for time critical code.

Then it would be simple if (global_var != NULL) { ... } in the fast path.
In addition the call chain could be declared __read_mostly.

I suspect with these changes Christoph's concerns would go away, right?

-Andi
