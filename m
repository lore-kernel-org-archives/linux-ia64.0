From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 02 Sep 2004 15:33:41 +0000
Subject: Re: Problem with no mem_map arg to init functions change?
Message-Id: <200409020833.41165.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040902053659.GG21873@cse.unsw.EDU.AU>
In-Reply-To: <20040902053659.GG21873@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday, September 2, 2004 8:05 am, Matthew Wilcox wrote:
> On Wed, Sep 01, 2004 at 11:10:30PM -0700, William Lee Irwin III wrote:
> > You don't thave CONFIG_DISCONTIGMEM set? Why are you bothering with
> > virtual mem_map if not? If the core helpers are insufficiently
> > lightweight in the CONFIG_DISCONTIGMEM=n case we are very well going
> > to have whatever sanction we need to repair it, as this is the common
> > case among end users of the most predominant hardware and architectures.
>
> Ah, basic lack of understanding of what VIRTUAL_MEM_MAP is used for
> and why it exists.  It should be exclusive with DISCONTIGMEM as they
> both solve the same problem, but in wildly different ways.

Well, on ia64 it's used *by* DISCONTIGMEM to deal with nodes that have sparse 
memory layouts.

> If DISCONTIGMEM now works properly, I think VIRTUAL_MEM_MAP can disappear.

Except that the former uses the latter, and that won't change without a bit 
more work.  Even then, CONFIG_NUMA and CONFIG_DISCONTIGMEM are somewhat 
intertwined at this point, so using the discontig code to deal with a zx1 
memory layout isn't a good match.

Jesse
