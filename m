From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 29 Jul 2005 23:23:33 +0000
Subject: RE: __copy_user exception handling
Message-Id: <200507292323.j6TNNZg19721@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050729221044.GA23144@kirby.fc.hp.com>
In-Reply-To: <20050729221044.GA23144@kirby.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Matt Chapman wrote on Friday, July 29, 2005 3:11 PM
> The main __copy_user loop looks like this:
> 
> 2:
>         EX(.failure_in3,(p16) ld8 val1[0]=[src1],16)
> (p16)   ld8 val2[0]=[src2],16
> 
>         EX(.failure_out, (EPI)  st8 [dst1]=val1[PIPE_DEPTH-1],16)
> (EPI)   st8 [dst2]=val2[PIPE_DEPTH-1],16
>         br.ctop.dptk 2b
> 
> What I'm trying to understand is why there is no EX necessary on the
> second store.  As far as I understand the implementation, src is 16-byte
> aligned here, so there is no need for EX on the second load, since it
> necessarily hits the same page.  But dst is only 8-byte aligned, so I
> would think that the second store could fault.

Because exception handler use to work at instruction bundle granularity.
The first EX would automatically catch the 2nd ld8 or st8, with a caveat
that this code is assuming gcc 2.x tool chain.  With moving to gcc 3.x
assembler where it understand local tag support, the exception handler
works at instruction granularity and then all the sudden, it falls flat
on its face.


> I've done some testing and for some reason it doesn't seem to be a
> problem in Linux; I haven't been able to produce an oops.  But I've hit
> oopses in Xen (we use the same code), and so I'm trying to understand
> *why* it's not a problem in Linux.

Are you sure you want to use this code?  It's for first incarnation of
Itanium.  The kernel has an optimized version of copy_user for Itanium2.
See memcpy_mck.S

- Ken
 

