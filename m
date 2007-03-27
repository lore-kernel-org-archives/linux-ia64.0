From: Jack Steiner <steiner@sgi.com>
Date: Tue, 27 Mar 2007 22:46:43 +0000
Subject: Re: [PATCH] - Optional method to purge the TLB on SN systems
Message-Id: <20070327224643.GA2527@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070327193925.GA8615@sgi.com>
In-Reply-To: <20070327193925.GA8615@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 27, 2007 at 03:32:16PM -0700, Luck, Tony wrote:
> > FWIW, slab.c has a "struct array_cache *new[NR_CPUS]" on the
> > stack.
> 
> I don't think so.  That line is part of the "struct ccupdate_struct"
> definition.  We only declare a pointer to one of those on the stack.

You are correct (of course). I was looking in a tree basd on 
SLES10. That is also true for the other reference in the network
code. 

> Debugging kernel stack overflow is no fun at all, so you might
> want to take the better-safe-than-sorry approach here.

Probably true. I'll repost a modified patch (hopefully) tommorrow.

Does anyone see any other issues?

