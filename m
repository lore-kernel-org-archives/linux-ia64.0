From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 09 Mar 2005 23:32:28 +0000
Subject: Re: Page Fault Scalability patch V19 [4/4]: Drop use of page_table_lock
Message-Id: <Pine.LNX.4.58.0503091526000.30604@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050309201324.29721.28956.sendpatchset@schroedinger.engr.sgi.com>
 <20050309201344.29721.26698.sendpatchset@schroedinger.engr.sgi.com>
 <m13bv4whrl.fsf@muc.de> <Pine.LNX.4.58.0503091500040.30604@schroedinger.engr.sgi.com>
 <20050309231440.GB63395@muc.de> <Pine.LNX.4.58.0503091515440.30604@schroedinger.engr.sgi.com>
 <20050309232141.GD63395@muc.de>
In-Reply-To: <20050309232141.GD63395@muc.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@muc.de>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 10 Mar 2005, Andi Kleen wrote:

> > Changing the type for the countedrs is possible by only changing the
> > definition of MM_COUNTER_T in include/sched.h. I would prefer to wait
> > until atomic64_t is available on all 64 bit platforms before making that
> > part of this patch.
>
> Well, they will not move until someone uses it (especially parisc
> and sh64 which always are quite out of sync in mainline). ppc64
> usually moves quickly.

Hmm. I could add that with

#ifdef ATOMIC64_INIT

atomic64

#else

atomic_t

#endif

> But adding arbitary limits like this even temporarily is imho
> a bad idea.

Hmmm yes this could actually develop to be an issue for us. Columbia has
20 Terabytes of memory (some rumors have it that it get up to 500TB but
maybe that was just a journalist). But Columbia has only 1TB per 512
CPU cluster addressable directly. So even the biggest box in existence
right now will be fine with V19.

But V20 will definitely support atomic64.

