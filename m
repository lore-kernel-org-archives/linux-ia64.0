From: Jack Steiner <steiner@sgi.com>
Date: Thu, 20 Nov 2003 15:23:35 +0000
Subject: Re: [PATCH] - sched_clock() broken for ia64 SN platform
Message-Id: <marc-linux-ia64-106934268811134@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106928980122896@msgid-missing>
In-Reply-To: <marc-linux-ia64-106928980122896@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Nov 19, 2003 at 05:24:08PM -0800, David Mosberger wrote:
> >>>>> On Wed, 19 Nov 2003 16:56:23 -0800 (PST), John Hawkes <hawkes@babylon.engr.sgi.com> said:
> 
>   John> We might instead want to implement a more general scheme,
>   John> along the lines of what is done by (struct time_interpolator),
>   John> to provide a framework to solve this for other architectures
>   John> that have "drifty" non-default timebases.
> 
> My sense is that with a bit of thinking, it would be possible to come
> up with a solution that allows even drifty platforms to use ITC for
> sched_clock()---it serves very a specific purpose in the scheduler and
> scalability is key and perfect accuracy is not (unlike for
> gettimeofday).  I don't think anything that goes out to read a single
> (shared) platform counter will be sufficiently scalable to the number
> of CPUs you guys are talking about.  But yes, it would be much more

This is slightly off-topic, but the shared platform counter on the SGI 
platform isnt a single counter. The counter is replicated in each chipset
It is synchronized thruout the system so that all cpus will see
the same value - ie., no drift. Reading the counter does not required any 
off-node references. There shouldnt be any scaling issues. However,
reading the ITC is faster & preferred if intercpu drift is not an issue.


> effort than just adding Yet Another Callback.  The rewards would be
> bigger, though, too...
> 
> 	--david
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


