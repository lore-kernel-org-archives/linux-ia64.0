From: n0ano@n0ano.com
Date: Wed, 10 Mar 2004 03:58:01 +0000
Subject: Re: Virtual memory leaking through IA32 emulation layer for mmap and munmap
Message-Id: <20040310035801.GC23596@tlaloc.n0ano.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0403091028060.22838@sutekh.progsoc.uts.edu.au>
In-Reply-To: <Pine.LNX.4.58.0403091028060.22838@sutekh.progsoc.uts.edu.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

What Dave said.  I only see 2 solutions to this problem:

1)  Find the preliminary patch I wrote (it's in the email archives,
let me know if you can't find it) and finish it.  It should be
fairly functional but it needs to be made optional, either as a
config option or something at run time.  Most `well behaved' IA32
programs don't need the overhead required to implement that patch.

2)  The easiest solution is to just configure your kernel to use
4K pages.  This might cause some performance degradation for IA64
programs but it should be minor and will definitely solve this
problem.

PS: You can read through the email archives to follow the detailed
discussion of this issue but, trust me, there is no easy solution.
Trying to modify the IA32 `mmap' calls to align all requests onto
the kerenl's page size, the obvious solution, will break the way
shared libraries are loaded and then no IA32 programs will run.

On Mon, Mar 08, 2004 at 05:04:47PM -0800, David Mosberger wrote:
> >>>>> On Tue, 9 Mar 2004 11:57:47 +1100, Peter Chubb <peter@chubb.wattle.id.au> said:
> 
> >>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:
>   David> Rounded up to the _page-size_ which is 4KB for x86.  In
>   David> general, you can't just round up to 16KB for munmap() or all
>   David> hell will break lose.
> 
>   Peter> As munmap()'s behaviour is undefined on memory that wasn't
>   Peter> allocated with mmap(), rounding to the underlaying true page
>   Peter> size should work for well-behaved programs.
> 
>   Peter>      x = mmap(... 4k ....)  maps a 16k chunk
> 
>   Peter>      munmap(x, 4k) deallocates a 16k chunk, if page_size is
>   Peter> 16k
> 
>   Peter> Of course at present, mmap32 tries to be clever and pretend
>   Peter> PAGE_SIZE is 4k, so it doesn't work...
> 
> All of this is old news and has come up at least twice in the past.
> Don Dugger started to work on a patch to track partial page
> allocations but I believe the patch was never finished.  Please check
> the mail archives for details.
> 
> 	--david
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@n0ano.com
Ph: 303/447-2201
