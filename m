From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 24 Mar 2005 20:15:12 +0000
Subject: Re: [PATCH] pte prefetching
Message-Id: <16963.8144.379547.857976@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <424269B9.9020306@yahoo.com.au>
In-Reply-To: <424269B9.9020306@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 24 Mar 2005 18:18:17 +1100, Nick Piggin <nickpiggin@yahoo.com.au> said:

  Nick> After applying the recent freepgt patchset from Hugh (on
  Nick> lkml), the time to fork+exit a process mapping 64GB of address
  Nick> (32MB of page tables) is 0.471s. With the prefetch patch, this
  Nick> drops to 0.357s.

Looks like a nice improvement to me.

Does prefetching 1 line ahead give the best results?  That's only
128/8 PTEs.  Assuming a 200 cycle latency, this would allow
for only 12.5 cycles/iteration.  Especially for large (NUMA) machines,
prefetching further out might help more.

	--david

