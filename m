From: Shaun <delius@progsoc.uts.edu.au>
Date: Tue, 09 Mar 2004 00:26:57 +0000
Subject: Re: Virtual memory leaking through IA32 emulation layer for mmap
Message-Id: <Pine.LNX.4.58.0403091111280.22838@sutekh.progsoc.uts.edu.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0403091028060.22838@sutekh.progsoc.uts.edu.au>
In-Reply-To: <Pine.LNX.4.58.0403091028060.22838@sutekh.progsoc.uts.edu.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Mon, 8 Mar 2004, H. J. Lu wrote:

> On Tue, Mar 09, 2004 at 10:43:45AM +1100, Shaun wrote:
> >
> > Given that getpagesize() is hardcoded in glibc it returns 4096, the mmap
>
> getpagesize () isn't hardcoded to 4K in glibc.

Indeed, it isn't quite hardcoded, but it may as well be, it certainly
doesn't do what the man page states it does:

  The function getpagesize() returns the number of bytes in a page,  where
  a "page" is the thing used where it says in the description of mmap(2)
  that files are mapped in page-sized units.

And without a doubt the page size is hardcoded in the libio
(stdio) routines.

> The problem is the x86 executable is
> aligned at 4K page size, which is specified by the i386 ABI. The dynamic
> linker in glibc won't load the normal x86 executables with a bigger page
> size. I have a glibc patch which allows >4K page size. It may work for
> you.

I guess that makes sense, the dynamic linker would need special code to
handle this case.

However, I can't see how this relates to my problem unless your patch
fixes the libio routines too?

Cheers,
Shaun
