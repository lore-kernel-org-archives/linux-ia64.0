From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 09 Mar 2005 23:02:54 +0000
Subject: Re: Page Fault Scalability patch V19 [4/4]: Drop use of page_table_lock
Message-Id: <Pine.LNX.4.58.0503091500040.30604@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050309201324.29721.28956.sendpatchset@schroedinger.engr.sgi.com>
 <20050309201344.29721.26698.sendpatchset@schroedinger.engr.sgi.com>
 <m13bv4whrl.fsf@muc.de>
In-Reply-To: <m13bv4whrl.fsf@muc.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@muc.de>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 9 Mar 2005, Andi Kleen wrote:

> I still think it's a bad idea to add arbitary process size limits like this:

The limit is pretty high: 2^31*PAGE_SIZE bytes. For the standard 4k
pagesize this will be >8TB.

> >
> > +#ifdef CONFIG_ATOMIC_TABLE_OPS
> > +/*
> > + * Atomic page table operations require that the counters are also
> > + * incremented atomically
> > +*/
> > +#define set_mm_counter(mm, member, value) atomic_set(&(mm)->member, value)
> > +#define get_mm_counter(mm, member) ((unsigned long)atomic_read(&(mm)->member))
> > +#define update_mm_counter(mm, member, value) atomic_add(value, &(mm)->member)
> > +#define MM_COUNTER_T atomic_t
>
> Can you use atomic64_t on 64bit systems at least?

If atomic64_t is available on all 64 bit systems then its no problem.
