From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Tue, 09 Mar 2004 00:57:47 +0000
Subject: Re: Virtual memory leaking through IA32 emulation layer for mmap and munmap
Message-Id: <16461.5771.740526.489351@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0403091028060.22838@sutekh.progsoc.uts.edu.au>
In-Reply-To: <Pine.LNX.4.58.0403091028060.22838@sutekh.progsoc.uts.edu.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:


David> Rounded up to the _page-size_ which is 4KB for x86.  In
David> general, you can't just round up to 16KB for munmap() or all
David> hell will break lose.

As munmap()'s behaviour is undefined on memory that wasn't allocated
with mmap(), rounding to the underlaying true page size should work
for well-behaved programs.

     x = mmap(... 4k ....)
maps a 16k chunk

     munmap(x, 4k)
deallocates a 16k chunk, if page_size is 16k

Of course at present, mmap32 tries to be clever and pretend PAGE_SIZE
is 4k, so it doesn't work...

--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
