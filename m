From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Tue, 09 Mar 2004 00:11:04 +0000
Subject: Re: Virtual memory leaking through IA32 emulation layer for mmap and munmap
Message-Id: <16461.2968.682582.139300@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0403091028060.22838@sutekh.progsoc.uts.edu.au>
In-Reply-To: <Pine.LNX.4.58.0403091028060.22838@sutekh.progsoc.uts.edu.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Shaun" = Shaun  <delius@progsoc.uts.edu.au> writes:

Shaun> Hi,

Shaun> Given that getpagesize() is hardcoded in glibc it returns 4096,
Shaun> the mmap succeeds and the compatibility layers actually
Shaun> allocate a full page (the kernel in question has PAGE_SHIFT set
Shaun> to 14 for a page size of 16K).  However the munmap hits the
Shaun> following bit of code in sys_ia32.c:

Shaun> asmlinkage long sys32_munmap (unsigned int start, unsigned int
Shaun> len) { unsigned int end = start + len; long ret; ...  start Shaun> PAGE_ALIGN(start); end = PAGE_START(end);

Shaun>    if (start >= end) return 0;

 I think thius may be a bug.  From the man page for munmap:

   The  address  start must be a multiple of the page size. All pages con-
   taining a part of the indicated range are unmapped, and subsequent ref-
   erences to these pages will generate SIGSEGV. It is not an error if the
   indicated range does not contain any mapped pages.

This follows the SUS, which means that end should be rounded up not
down.

--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*


