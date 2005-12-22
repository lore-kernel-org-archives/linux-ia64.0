From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 22 Dec 2005 17:23:03 +0000
Subject: Re: [Perfctr-devel] Re: quick overview of the perfmon2 interface
Message-Id: <20051222172303.GC6038@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051219113140.GC2690@frankl.hpl.hp.com> <20051220025156.a86b418f.akpm@osdl.org> <20051222115632.GA8773@frankl.hpl.hp.com> <20051222120558.GA31303@infradead.org> <43AAC854.6020608@redhat.com>
In-Reply-To: <43AAC854.6020608@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: William Cohen <wcohen@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, Stephane Eranian <eranian@hpl.hp.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, perfmon@napali.hpl.hp.com, linux-ia64@vger.kernel.org, perfctr-devel@lists.sourceforge.net

On Thu, Dec 22, 2005 at 10:37:56AM -0500, William Cohen wrote:
> Both OProfile and PAPI are open source and could use such an performance 
> monitoring interface.
> 
> One of the problems right now is there is a patchwork of performance 
> monitoring support. Each instrumentation system has its own set of 
> drivers/patches. Few have support integrated into the kernel, e.g. 
> OProfile. However, the OProfile driver provides only a subset of the 
> performance monitoring support, system-wide sampling. The OProfile 
> driver doesn't allow per-thread monitoring or stopwatch style 
> measurement, which can be very useful for some performance monitoring 
> applications.

What about improving oprofile then?  Unlike the vtune or perfoman people
the oprofile authors have shown they actually are able to design sensible
interfaces, and oprofile has broad plattform support over most support
architectures.

