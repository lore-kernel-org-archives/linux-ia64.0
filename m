From: Benjamin LaHaise <bcrl@kvack.org>
Date: Tue, 23 Sep 2003 19:04:59 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106434479411312@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Sep 23, 2003 at 11:51:04AM -0700, Grant Grundler wrote:
> On Tue, Sep 23, 2003 at 02:29:25PM -0400, Benjamin LaHaise wrote:
> ...
> > (yet another hardware issue pushed off on software for no significant gain).
> 
> Even x86 pays at least a one cycle penalty for every misaligned access.
> In general, open source code has no excuse for using misaligned fields.
> It's (mostly) avoidable.  TCP/IP headers are the historical exception.

The other point to keep in mind is that apparently the .09u rev of the P4 
includes additional hardware for handling unaligned accesses because they 
are so common (gzip is a good example of an app where it is faster to do 
an unaligned access for the benefit of fetching the data in one instruction 
instead of 3+, and there is no way to improve on it).

> One could make the same arguement that a modern NIC should not require
> 16 byte alignment for DMA. It's a tradeoff one way or the other.
> Just a matter of perspective.

I consider the 83820 buggy in this regard, too.  That said, the fix does 
not belong in the driver layer, as having it duplicated in a dozen drivers 
is more stupid than fixing up the arch code which is required anyways.

		-ben
-- 
"The software industry today survives only through an unstated agreement 
not to stir things up too much.  We must hope this lawsuit [by SCO] isn't 
the big stirring spoon." -- Ian Lance Taylor, Linux Journal, June 2003
