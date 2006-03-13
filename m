From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Mon, 13 Mar 2006 09:13:46 +0000
Subject: Re: Fix race in the accessed/dirty bit handlers
Message-Id: <441537CA.3030405@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote:

> If another processor has a purge floating out there on the
> bus at this time, it would be because that other processor
> was making some change to this mapping.  In which case it
> would have executed:
> 
>  *pte = new_value
>  ptc
> 
> Are you saying that these events may become visible to the
> processor that is executing the dirty_bit handler in either
> order, so that you are worried we'll see the old *pte value
> when we do the load, but miss the purge because we didn't
> wait for the itc.d to complete before we did the load?

Yes, I should have said in this way.

Thanks,

Zoltan
