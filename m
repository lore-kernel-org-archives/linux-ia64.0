From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Wed, 20 Mar 2002 00:08:49 +0000
Subject: RE: [Linux-ia64] mkswap fails to create large swap partitions on
Message-Id: <marc-linux-ia64-105590701905305@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905268@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905268@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Kevin" = Van Maren <Van> writes:


Kevin> So we're okay until about a couple terrabytes is all, until we
Kevin> change all the index variables to "long". :-) But even one
Kevin> terrabyte is 16x 64GB.

I'm currently looking at some other problems which would also limit
the size of a single swap file/device to 1TB --- the genhd code limits
the size of a partition to 2^31-1 blocks, where a block is *known* to
be 512 bytes. (The 512 number is so embedded that's it's going to be a
major effort to remove, not only from the code, but from the brains of
the programmers... so the only thing we can do is change the size of
the index variables, and all the interfaces that use them).

So even if swap could be specified bigger than 1TB, you couldn't
create a volume that big to put it on (even with LVM).


Kevin> Also, the kernel should probably try to use "some" of the swap
Kevin> space if it can't vmalloc storage for the whole thing -- maybe
Kevin> cut p->max in half until the vmalloc succeeds?  I see the case
Kevin> where you are low on memory and can't add more swap because you
Kevin> can't allocate enough memory and the only swapfile you have is
Kevin> 100GB...

Interesting idea... I'll think about it.

Peter C
--
Working on the Gelato project 
http://www.gelato.org/ 
http://www.gelato.unsw.edu.au/  (coming soon!)

