From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 23 Aug 2005 07:05:04 +0000
Subject: RE: [PATCH] Remove rwsem limitation of 32k waiters
Message-Id: <B05667366EE6204181EABE9C1B1C0EB507E8AF0D@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0508221215370.7633@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0508221215370.7633@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Lameter wrote on Monday, August 22, 2005 1:34 PM
> On Mon, 22 Aug 2005, Matthew Wilcox wrote:
> > On Mon, Aug 22, 2005 at 01:26:17PM -0700, Christoph Lameter wrote:
> > > The adjustment is RWSEM_WAITING_BIAS - RWSEM_ACTIVE bias. This
eliminates
> > > the RWSEM_ACTIVE_BIAS but adds RWSEM_WAITING_BIAS for each waiter.
> > 
> > You're looking at rwsem_down_read_failed() instead of
rwsem_down_write_failed()
> 
> down_write already adds RWSEM_WAITING_BIAS + RWSEM_ACTIVE_BIAS in 
> include/asm-ia64/rwsem.h. It only removes RW_SEM_WAITING_BIAS when it 
> fails. So the net outcome is that a writer also adds
RWSEM_WAITING_BIAS to 
> count.

The upper bits are used to count number of waiter, and the lower bits
are
used to count number of active locks.  I don't see anything wrong with
Matthew's
earlier suggestion, except the bits were wrong in his original post.
How about:

#define RWSEM_ACTIVE_MASK               0x00000fff
#define RWSEM_WAITING_BIAS              (-0x00001000)

which gives you roughly 20 bits for number of waiter, at the expense of
reducing
number of uncontended reader to 12 bits. Or you can do 18/14 bits
breakdown. Will
that work?

By the way, you must have an app of the devil to trigger the overflow,
at ~64K
rwsem waiter?

- Ken
