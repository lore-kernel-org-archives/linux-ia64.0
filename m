From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 13 Jul 2005 00:33:18 +0000
Subject: Re: [PATCH] enable to read region 5 from /dev/kmem
Message-Id: <42D4614E.7000007@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42C501CD.4010907@jp.fujitsu.com>
In-Reply-To: <42C501CD.4010907@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi, Tony

My idea is "A user needs O_SYNC flag to access uncachable area"
like other archs.
With this, a user can avoid accessing region 6 by mistake, to some extent.

- Kamezawa


Luck, Tony wrote:
>>>It comes down to what the real semantics of /dev/kmem are supposed
>>>to be.
>>
>>That is certainly true.  I thought we had settled that pages with the
>>WB attribute would _only_ be accessible in a cacheable fashion and
>>pages without the WB attribute would _only_ be accessible uncached.
> 
> 
> So what is the right thing to do when a user goes through /dev/kmem
> and tries to violate this rule?  For region 7 addresses we silently
> redirect the access to region 6 for uncacheable pages.  At the time
> this seemed a reasonable thing to do as it might be hard for a kmem
> using program to track down whether a page is marked uncacheable ...
> and the "kernel virtual = physical + PAGE_OFFSET" rule works on many
> architectures, so doing this may magically make some kmem readers
> get the right answers without crashing.
> 
> We could do a similar thing for region 6 and silently remap to region
> 7 for pages that should only be accessed cacheably ... but what if the
> user going through /dev/kmem and seeking into region 6 knows what they
> are doing and wants to perform uncacheable access?  If the user is
> accessing region 6, then they didn't get there by blind chance.
> 
> Which gets back to the semantics of /dev/kmem.
> 
> -Tony
> 


