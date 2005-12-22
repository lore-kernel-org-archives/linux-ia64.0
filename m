From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 22 Dec 2005 12:05:58 +0000
Subject: Re: quick overview of the perfmon2 interface
Message-Id: <20051222120558.GA31303@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051219113140.GC2690@frankl.hpl.hp.com> <20051220025156.a86b418f.akpm@osdl.org> <20051222115632.GA8773@frankl.hpl.hp.com>
In-Reply-To: <20051222115632.GA8773@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Stephane Eranian <eranian@hpl.hp.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, perfmon@napali.hpl.hp.com, linux-ia64@vger.kernel.org, perfctr-devel@lists.sourceforge.net

On Thu, Dec 22, 2005 at 03:56:32AM -0800, Stephane Eranian wrote:
> reason:
> 	- allow support of existing kernel profiling infratructures such as
> 	  Oprofile or VTUNE (the VTUNE driver is open-source)

last time I checked it was available in source, but not under an open-source
license.  has this changed?  In either case intel should contribute to the
kernel profiling infrastructure instead of doing their own thing.  Supporting
people to do their own private variant is always a bad thing.

> Let's take an example on Itanium. Take a user running a commercial distro
> based on 2.6. This user is given early access to a Montecito machine.

That scenario is totally uninteresting for kernel development.  we want
to encourage people to use upstream kernels, and not the bastardized vendor
crap.

I think you're adding totally pointless complexity everywhere for such
scenarious because HP apparently cares for such vendor mess.  Maybe you
should concentrate on what's best for upstream kernel development.  And
the most important thing is to reduce complexity by at least one magnitude.

