From: Russ Anderson <rja@sgi.com>
Date: Mon, 17 Jan 2005 19:27:10 +0000
Subject: Re: [patch] Remove limit on MCA recoveries
Message-Id: <200501171927.j0HJRAmE3010159@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <200501160901.j0G91h8G001716@mtv-vpn-hw-mfl-1.corp.sgi.com> from "Matthias Fouquet-Lapar" at Jan 16, 2005 10:01:43 AM
References: <200501152249.j0FMn6JH2857539@clink.americas.sgi.com>
In-Reply-To: <200501152249.j0FMn6JH2857539@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthias Fouquet-Lapar <mfl@kernel.paris.sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Matthias Fouquet-Lapar wrote:
> Keith Owens wrote:
> > Russ Anderson <rja@sgi.com> wrote:
> > >The MCA recovery driver saves the addresses of memory errors
> > >in an array.  The array has 32 entries.  The effect is 
> > >that after 32 recoveries, the driver stops recovering.
> > >
> > >This patch removes the page_isolate array.  Since the array
> > >was only used to see if the page is already marked reserved,
> > >check the reserved bit instead of the array.
> > 
> > lkcd dumps kernel pages marked reserved, so lkcd will try to process
> > isolated pages.  We will eventually need to add a new page flag to mark
> > faulty pages.
> 
> Probably any other dump mechanism should be aware of bad HW pages as well,
> so we might be better off to add a flag right away.  While we are at it I
> would propose to have actually two flags :
> 
>   - hard error (which will cause a MCA and should be skipped when taking
>                 a system dump)
>   - soft error (page has encountered SBE, so we might want to avoid future
>                 allocation, but it can be dumped without causing an MCA)

Yes, there should be page->flags to indicate hard and soft memory errors,
such as PG_hard_error and PG_soft_error.  The dump code could look at those 
flags.

include/linux/page-flags.h has PG_error for indicating I/O errors, which 
is close but not quite what we need, given the way it is used.  

CCing linux-kernel since the flags are not ia64 specific.

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
