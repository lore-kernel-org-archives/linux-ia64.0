From: William Cohen <wcohen@redhat.com>
Date: Thu, 22 Dec 2005 15:37:56 +0000
Subject: Re: [Perfctr-devel] Re: quick overview of the perfmon2 interface
Message-Id: <43AAC854.6020608@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051219113140.GC2690@frankl.hpl.hp.com> <20051220025156.a86b418f.akpm@osdl.org> <20051222115632.GA8773@frankl.hpl.hp.com> <20051222120558.GA31303@infradead.org>
In-Reply-To: <20051222120558.GA31303@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>
Cc: Stephane Eranian <eranian@hpl.hp.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, perfmon@napali.hpl.hp.com, linux-ia64@vger.kernel.org, perfctr-devel@lists.sourceforge.net

Christoph Hellwig wrote:
> On Thu, Dec 22, 2005 at 03:56:32AM -0800, Stephane Eranian wrote:
> 
>>reason:
>>	- allow support of existing kernel profiling infratructures such as
>>	  Oprofile or VTUNE (the VTUNE driver is open-source)
> 
> 
> last time I checked it was available in source, but not under an open-source
> license.  has this changed?  In either case intel should contribute to the
> kernel profiling infrastructure instead of doing their own thing.  Supporting
> people to do their own private variant is always a bad thing.

Both OProfile and PAPI are open source and could use such an performance 
monitoring interface.

One of the problems right now is there is a patchwork of performance 
monitoring support. Each instrumentation system has its own set of 
drivers/patches. Few have support integrated into the kernel, e.g. 
OProfile. However, the OProfile driver provides only a subset of the 
performance monitoring support, system-wide sampling. The OProfile 
driver doesn't allow per-thread monitoring or stopwatch style 
measurement, which can be very useful for some performance monitoring 
applications.

Having specific drivers for each performance monitoring program is not 
the way to go. That is one of the reasons that people have problems 
doing performance monitoring on Linux. Each performance monitoring 
program has its own driver and/or set of patches to the kernel. Many 
application programers are not in a position to patch the kernel and to 
install the custom kernel on the machine so they can use performance 
monitoring hardware. Not everyone has root access to the machine they 
use, so they can  install and reboot a kernel of their choosing.

>>Let's take an example on Itanium. Take a user running a commercial distro
>>based on 2.6. This user is given early access to a Montecito machine.
> 
> 
> That scenario is totally uninteresting for kernel development.  we want
> to encourage people to use upstream kernels, and not the bastardized vendor
> crap.

Vendors don't want to provide "bastardized vendor crap" either. The 
fewer patches in the vendor distributed kernels the better.

> I think you're adding totally pointless complexity everywhere for such
> scenarious because HP apparently cares for such vendor mess.  Maybe you
> should concentrate on what's best for upstream kernel development.  And
> the most important thing is to reduce complexity by at least one magnitude.

Specifically what are the things that are "best for upstream kernel 
development?" What are the things that should be eliminated "to reduce 
complexity by at least one magnitude?"

-Will
