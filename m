From: "David S. Miller" <davem@davemloft.net>
Date: Tue, 30 Aug 2005 23:56:31 +0000
Subject: Re: [PATCH] Only process_die notifier in ia64_do_page_fault if
Message-Id: <20050830.165631.122559296.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F0443A9A1@scsmsx401.amr.corp.intel.com>
	<200508310138.09841.ak@suse.de>
In-Reply-To: <200508310138.09841.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: ak@suse.de
Cc: tony.luck@intel.com, clameter@engr.sgi.com, rusty@linux.intel.com, rusty.lynch@intel.com, linux-mm@kvack.org, prasanna@in.ibm.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, anil.s.keshavamurthy@intel.com

From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Only process_die notifier in ia64_do_page_fault if KPROBES is configured.
Date: Wed, 31 Aug 2005 01:38:08 +0200

> On Wednesday 31 August 2005 01:05, Luck, Tony wrote:
> > >Please do not generate any code if the feature cannot ever be
> > >used (CONFIG_KPROBES off). With this patch we still have lots of
> > >unnecessary code being executed on each page fault.
> >
> > I can (eventually) wrap this call inside the #ifdef CONFIG_KPROBES.
> 
> At least the original die notifiers were designed as a generic debugger
> interface, not a kprobes specific thing. So I don't think it's a good idea.

Me neither, I think a way too big deal is being made about
about this by the ia64 folks.  Just put the dang hook in
there unconditionally already :-)
