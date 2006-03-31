From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 31 Mar 2006 03:02:00 +0000
Subject: RE: Synchronizing Bit operations V2
Message-Id: <200603310301.k2V31Gg28423@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0603301855280.3045@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Christoph Lameter' <clameter@sgi.com>
Cc: 'Nick Piggin' <nickpiggin@yahoo.com.au>, 'Zoltan Menyhart' <Zoltan.Menyhart@bull.net>, "'Boehm, Hans'" <hans.boehm@hp.com>, "'Grundler, Grant G'" <grant.grundler@hp.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Christoph Lameter wrote on Thursday, March 30, 2006 6:56 PM
> > By the way, this is the same thing on x86: look at include/asm-i386/bitops.h:
> > 
> > #define smp_mb__before_clear_bit()      barrier()
> > #define smp_mb__after_clear_bit()       barrier()
> > 
> > A simple compiler barrier, nothing but
> > #define barrier() __asm__ __volatile__("": : :"memory")
> > 
> > See, no memory ordering there, because clear_bit already has a LOCK prefix.
> 
> And that implies barrier behavior right?

No, not the memory ordering semantics you are thinking about.  It just tell
compiler not to be over smart and schedule a load operation above that point
Intel compiler is good at schedule memory load way ahead of its use to hide
memory latency. gcc probably does that too, I'm not 100% sure. This prevents
the compiler to schedule load before that line.

- Ken
