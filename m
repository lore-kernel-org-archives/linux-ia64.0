From: Christoph Lameter <clameter@engr.sgi.com>
Date: Mon, 22 Aug 2005 20:33:31 +0000
Subject: Re: [PATCH] Remove rwsem limitation of 32k waiters
Message-Id: <Pine.LNX.4.62.0508221331260.8094@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0508221215370.7633@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0508221215370.7633@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 22 Aug 2005, Matthew Wilcox wrote:

> On Mon, Aug 22, 2005 at 01:26:17PM -0700, Christoph Lameter wrote:
> > The adjustment is RWSEM_WAITING_BIAS - RWSEM_ACTIVE bias. This eliminates
> > the RWSEM_ACTIVE_BIAS but adds RWSEM_WAITING_BIAS for each waiter.
> 
> You're looking at rwsem_down_read_failed() instead of rwsem_down_write_failed()

down_write already adds RWSEM_WAITING_BIAS + RWSEM_ACTIVE_BIAS in 
include/asm-ia64/rwsem.h. It only removes RW_SEM_WAITING_BIAS when it 
fails. So the net outcome is that a writer also adds RWSEM_WAITING_BIAS to 
count.

