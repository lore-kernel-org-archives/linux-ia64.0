From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 04 May 2004 22:36:13 +0000
Subject: Re: [RFC] I/O MCA recovery
Message-Id: <200405041536.13104.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405040954.09524.jbarnes@engr.sgi.com>
In-Reply-To: <200405040954.09524.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday, May 4, 2004 11:20 am, David Mosberger wrote:
>   Jesse> This is I/O initiated by userspace loads/stores, so unless I
>   Jesse> wrap every in/out with some sort of ioctl or something, those
>   Jesse> won't help me.
>
> User-level accesses are mapped via the MMU so you could always
> intercept the page-faults.

Wouldn't that mean that on every I/O access we'd have to page fault, do the 
I/O, and then invalidate the mapping?  That seems like a lot of overhead.

>   Jesse> Also, with this scheme, we could potentially recover from
>   Jesse> regular read/writes too.
>
> _If_ there is an infrastructure what you can hook into, fine.  But I'm
> highly suspicious of using broken platforms as a justification for new
> infrastructure.

Are you describing ia64 as a broken platform here?  The problem I'm trying to 
solve isn't sn2 specific (though part of the X stuff I have to do will be 
driven by sn2 requirements), it's a generic way to deal with hard fails on 
PIO reads, which afaik, affects all ia64 platforms.  Correct me if I'm wrong 
here...

Thanks,
Jesse
