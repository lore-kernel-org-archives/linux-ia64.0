From: Andi Kleen <ak@muc.de>
Date: Wed, 09 Mar 2005 22:56:14 +0000
Subject: Re: Page Fault Scalability patch V19 [4/4]: Drop use of
Message-Id: <m13bv4whrl.fsf@muc.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050309201324.29721.28956.sendpatchset@schroedinger.engr.sgi.com>
	<20050309201344.29721.26698.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20050309201344.29721.26698.sendpatchset@schroedinger.engr.sgi.com> (Christoph
 Lameter's message of "Wed, 9 Mar 2005 12:13:44 -0800 (PST)")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Christoph Lameter <clameter@sgi.com> writes:

> Do not use the page_table_lock in do_anonymous_page. This will significantly
> increase the parallelism in the page fault handler in SMP systems. The patch
> also modifies the definitions of _mm_counter functions so that rss and anon_rss
> become atomic.

I still think it's a bad idea to add arbitary process size limits like this:

>  
> +#ifdef CONFIG_ATOMIC_TABLE_OPS
> +/*
> + * Atomic page table operations require that the counters are also
> + * incremented atomically
> +*/
> +#define set_mm_counter(mm, member, value) atomic_set(&(mm)->member, value)
> +#define get_mm_counter(mm, member) ((unsigned long)atomic_read(&(mm)->member))
> +#define update_mm_counter(mm, member, value) atomic_add(value, &(mm)->member)
> +#define MM_COUNTER_T atomic_t

Can you use atomic64_t on 64bit systems at least? 

-Andi
