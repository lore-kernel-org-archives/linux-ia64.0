From: Arun Sharma <arun.sharma@intel.com>
Date: Tue, 09 Mar 2004 20:26:38 +0000
Subject: Re: Virtual memory leaking through IA32 emulation layer for mmap
Message-Id: <404E287E.30501@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0403091028060.22838@sutekh.progsoc.uts.edu.au>
In-Reply-To: <Pine.LNX.4.58.0403091028060.22838@sutekh.progsoc.uts.edu.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Peter Chubb wrote:
> 
> As munmap()'s behaviour is undefined on memory that wasn't allocated
> with mmap(), rounding to the underlaying true page size should work
> for well-behaved programs.
> 
>      x = mmap(... 4k ....)
> maps a 16k chunk
> 
>      munmap(x, 4k)
> deallocates a 16k chunk, if page_size is 16k

As David said, this has been discussed before. Basically if there were 
other 4k mappings with a different permission in the same 16k chunk, you 
can't deallocate the 16k chunk safely. Tracking the sub pages without 
changes to machine independent code (struct page) is possible, but may 
be expensive.

	-Arun
