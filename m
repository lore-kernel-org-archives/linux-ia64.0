From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 09 Mar 2004 01:04:47 +0000
Subject: Re: Virtual memory leaking through IA32 emulation layer for mmap and munmap
Message-Id: <16461.6191.949155.778550@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0403091028060.22838@sutekh.progsoc.uts.edu.au>
In-Reply-To: <Pine.LNX.4.58.0403091028060.22838@sutekh.progsoc.uts.edu.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 9 Mar 2004 11:57:47 +1100, Peter Chubb <peter@chubb.wattle.id.au> said:

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:
  David> Rounded up to the _page-size_ which is 4KB for x86.  In
  David> general, you can't just round up to 16KB for munmap() or all
  David> hell will break lose.

  Peter> As munmap()'s behaviour is undefined on memory that wasn't
  Peter> allocated with mmap(), rounding to the underlaying true page
  Peter> size should work for well-behaved programs.

  Peter>      x = mmap(... 4k ....)  maps a 16k chunk

  Peter>      munmap(x, 4k) deallocates a 16k chunk, if page_size is
  Peter> 16k

  Peter> Of course at present, mmap32 tries to be clever and pretend
  Peter> PAGE_SIZE is 4k, so it doesn't work...

All of this is old news and has come up at least twice in the past.
Don Dugger started to work on a patch to track partial page
allocations but I believe the patch was never finished.  Please check
the mail archives for details.

	--david
