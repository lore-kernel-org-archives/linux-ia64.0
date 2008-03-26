From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Wed, 26 Mar 2008 00:25:58 +0000
Subject: Re: larger default page sizes...
Message-Id: <87od925o15.wl%peter@chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0803251045510.16206@schroedinger.engr.sgi.com>
	<20080325.162244.61337214.davem@davemloft.net>
	<87tziu5q37.wl%peter@chubb.wattle.id.au>
	<20080325.164927.249210766.davem@davemloft.net>
In-Reply-To: <20080325.164927.249210766.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: peterc@gelato.unsw.edu.au, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, torvalds@linux-foundation.org, ianw@gelato.unsw.edu.au

>>>>> "David" = David Miller <davem@davemloft.net> writes:

David> From: Peter Chubb <peterc@gelato.unsw.edu.au> Date: Wed, 26 Mar
David> 2008 10:41:32 +1100

>> It's actually harder than it looks.  Ian Wienand just finished his
>> Master's project in this area, so we have *lots* of data.  The main
>> issue is that, at least on Itanium, you have to turn off the
>> hardware page table walker for hugepages if you want to mix
>> superpages and standard pages in the same region. (The long format
>> VHPT isn't the panacea we'd like it to be because the hash function
>> it uses depends on the page size).  This means that although you
>> have fewer TLB misses with larger pages, the cost of those TLB
>> misses is three to four times higher than with the standard pages.

David> If the hugepage is more than 3 to 4 times larger than the base
David> page size, which it almost certainly is, it's still an enormous
David> win.

That depends on the access pattern.  We measured a small win for some
workloads, and a small loss for others, using 4k base pages, and
allowing up to 4G superpages (the actual sizes used depended on the
size of the objects being allocated, and the amount of contiguous
memory available).

--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
http://www.ertos.nicta.com.au           ERTOS within National ICT Australia
