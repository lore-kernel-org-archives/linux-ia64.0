From: Grant Grundler <iod00d@hp.com>
Date: Wed, 24 Sep 2003 00:13:33 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106436242031938@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Sep 23, 2003 at 04:35:42PM -0700, David S. Miller wrote:
> On Tue, 23 Sep 2003 15:35:40 -0700
> Grant Grundler <iod00d@hp.com> wrote:
> 
> > And someone at Intel obviously agrees the newer architectures
> > should support misaligned access in SW since ever RISC chip
> > they've built (starting with i860, ~1989) does it that way.
> 
> That's a amusing coincidence since at least some people think ia64
> will end up the same way the i860 did :-)

It might. I be happy to share what I know about i860/i960 over pizza.
I worked on ATT SVR4 port to i860 in 1989/90 and things were quite
different then...

> In the past I did always advocate things the way you are right now,
> but these days I think I've been wrong the whole time and Intel on x86
> is doing the right thing.

I'm not so interested in "right" or "wrong". I'd just like to see other
arches besides x86 work well (ia64, parisc in particular) and that includes
how linux deals with unaligned accesses. If x86 is the gold standard
for "the right way", we'd be using bounce buffers for DMA to highmem
(well, PAE support would get added somehow) and 64-bit kernels wouldn't
have happened...but linux so far seems to accomodate other arches *when
reasonable*.  I'll follow Andrew Morton's comments...

> They do everything in hardware and this makes the software so much
> simpler.  Sure, there's a lot of architectually inherited complexity
> in the x86 family, but their engineering priorities mean there is so
> much other stuff you simply never have to think about as a programmer.

Yes, true.  But I think we are digressing from the original thread here...
(/me works his way around another really big rat hole :^)

thanks,
grant
