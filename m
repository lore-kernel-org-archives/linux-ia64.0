From: Andi Kleen <ak@muc.de>
Date: Wed, 09 Mar 2005 23:21:41 +0000
Subject: Re: Page Fault Scalability patch V19 [4/4]: Drop use of page_table_lock in do_anonymous_page
Message-Id: <20050309232141.GD63395@muc.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050309201324.29721.28956.sendpatchset@schroedinger.engr.sgi.com> <20050309201344.29721.26698.sendpatchset@schroedinger.engr.sgi.com> <m13bv4whrl.fsf@muc.de> <Pine.LNX.4.58.0503091500040.30604@schroedinger.engr.sgi.com> <20050309231440.GB63395@muc.de> <Pine.LNX.4.58.0503091515440.30604@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0503091515440.30604@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Mar 09, 2005 at 03:17:10PM -0800, Christoph Lameter wrote:
> On Wed, 10 Mar 2005, Andi Kleen wrote:
> 
> > > If atomic64_t is available on all 64 bit systems then its no problem.
> >
> > Most of them have it already. parisc64/ppc64/sh64 are missing it,
> > but I assume they will catch up quickly.
> 
> Changing the type for the countedrs is possible by only changing the
> definition of MM_COUNTER_T in include/sched.h. I would prefer to wait
> until atomic64_t is available on all 64 bit platforms before making that
> part of this patch.

Well, they will not move until someone uses it (especially parisc
and sh64 which always are quite out of sync in mainline). ppc64 
usually moves quickly.

But adding arbitary limits like this even temporarily is imho
a bad idea.

-Andi
