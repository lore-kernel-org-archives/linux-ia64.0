From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 09 Mar 2004 00:23:49 +0000
Subject: Re: Virtual memory leaking through IA32 emulation layer for mmap and munmap
Message-Id: <16461.3733.809634.212327@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0403091028060.22838@sutekh.progsoc.uts.edu.au>
In-Reply-To: <Pine.LNX.4.58.0403091028060.22838@sutekh.progsoc.uts.edu.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 9 Mar 2004 11:11:04 +1100, Peter Chubb <peter@chubb.wattle.id.au> said:

>>>>> "Shaun" = Shaun  <delius@progsoc.uts.edu.au> writes:
  Shaun> Hi,

  Shaun> Given that getpagesize() is hardcoded in glibc it returns
  Shaun> 4096, the mmap succeeds and the compatibility layers actually
  Shaun> allocate a full page (the kernel in question has PAGE_SHIFT
  Shaun> set to 14 for a page size of 16K).  However the munmap hits
  Shaun> the following bit of code in sys_ia32.c:

  Shaun> asmlinkage long sys32_munmap (unsigned int start, unsigned
  Shaun> int len) { unsigned int end = start + len; long ret; ...
  Shaun> start = PAGE_ALIGN(start); end = PAGE_START(end);

  Shaun> if (start >= end) return 0;

  Peter>  I think thius may be a bug.  From the man page for munmap:

  Peter>    The address start must be a multiple of the page size. All
  Peter> pages con- taining a part of the indicated range are
  Peter> unmapped, and subsequent ref- erences to these pages will
  Peter> generate SIGSEGV. It is not an error if the indicated range
  Peter> does not contain any mapped pages.

  Peter> This follows the SUS, which means that end should be rounded
  Peter> up not down.

Rounded up to the _page-size_ which is 4KB for x86.  In general, you
can't just round up to 16KB for munmap() or all hell will break lose.

	--david
