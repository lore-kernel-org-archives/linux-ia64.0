From: n0ano@n0ano.com
Date: Wed, 12 Nov 2003 19:45:55 +0000
Subject: Re: Odd IA32 mmap calls - Is this fixed
Message-Id: <marc-linux-ia64-106866658823794@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106862063402317@msgid-missing>
In-Reply-To: <marc-linux-ia64-106862063402317@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Arun-

I'm pretty sure your patch with cause things to break.  You
will wind up freeing memory that the IA32 process is still
using, causing `bad` things to happen.

Actually, there is a solution but it's kind of icky.  The
idea is you have to maintain knowledge of which 4K area of
the IA32 prcesses's IA64 page is truly in use.  When all
4K areas of the IA64 page are freed you can free the IA64 page.

This not as bad as it could be because you only have to keep
track of the first & last IA64 pages that are used for each
IA32 mmap request so the overhead isn't that outrageous.  I
submitted a patch to do this ages ago but I guess it got lost
somehow.

On Wed, Nov 12, 2003 at 11:17:32AM -0800, Arun Sharma wrote:
> 
> There is no "safe" solution that I know of. The attached patch will fix 
> this particular problem, but might create new ones. Try it at your own risk.
> 
> 	-Arun
> 
> On 11/11/2003 11:03 PM, Shiju A Mathew wrote:
> >Hi,
> >The mummap is failing to unmap the pages allocated by
> >mmap when a ia32 application ( 4k Pagesize) is run on
> >ia64 system( 16k pagesize). This happens when the
> >offset  in mmap does not fall on 16k boundary. The
> >problem seems to be similar to the problem " Odd IA32
> >mmap calls" (Calls to mmap/munmap where the length is
> >a fraction of the page size cause a memory leak,
> >eventually running out of VM for the IA32 process)
> >listed in the ToDo list of ia64 homepage.I am doing
> >the test on sles-8 running 2.4.19 kernel. Is this
> >problem fixed in the 2.6 test kernel ? If it is not
> >fixed are there anyone working on it to fix the
> >problem?

> --- linux-2.4.9/arch/ia64/ia32/sys_ia32.c	Tue Feb  5 22:08:20 2002
> +++ linux-nk/arch/ia64/ia32/sys_ia32.c	Tue Feb  5 22:18:24 2002
> @@ -549,8 +559,8 @@
>  	if (start > end)
>  		return -EINVAL;
>  
> -	start = PAGE_ALIGN(start);
> -	end = PAGE_START(end);
> +	start = PAGE_START(start);
> +	end = PAGE_ALIGN(end);
>  
>  	if (start >= end)
>  		return 0;


-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@n0ano.com
Ph: 303/447-2201
