From: "John Hawkes" <hawkes@sgi.com>
Date: Sun, 28 Mar 2004 02:37:39 +0000
Subject: Re: should ia64_spinlock_contention do backoff?
Message-Id: <00c101c4146d$bf3f1630$6400a8c0@PCJohn>
List-Id: <linux-ia64.vger.kernel.org>
References: <200403251941.i2PJfrTH026392@napali.hpl.hp.com>
In-Reply-To: <200403251941.i2PJfrTH026392@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



> >>>>> Chris Wedgwood wrote on Fri, March 26, 2004 3:41 PM
> > Does anyone have any idea what locks are most heavily contented for
> > ia64 right now?
>
> This question is a bit too broad, lock contention highly depends on
workload.

I totally agree.

On one AIM7-like workload that I'm using, at 64p the dominant contention is
doing pte_chain_lock() in page_remove_rmap() (11% of the cycles) and
page_add_rmap() (5%).  That's not spinlock contention -- it's cacheline
contention.  That same workload at 96p shows about 47% of the kernel cycles in
find_get_page() doing the spin_lock(mapping->page_lock), and the
pte_chain_lock() bottleneck has faded into insignificance.

John Hawkes

