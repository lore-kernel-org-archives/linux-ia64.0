From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Thu, 25 Aug 2005 00:02:29 +0000
Subject: Re: [PATCH 2.6.13-rc6] cpu_exclusive sched domains build fix
Message-Id: <430D0A95.30208@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050824111510.11478.49764.sendpatchset@jackhammer.engr.sgi.com>	<20050824112640.GB5197@in.ibm.com>	<20050824044648.66f7e25a.pj@sgi.com>	<430C617E.8080002@yahoo.com.au> <20050824133107.2ca733c3.pj@sgi.com>
In-Reply-To: <20050824133107.2ca733c3.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Paul Jackson <pj@sgi.com>
Cc: dino@in.ibm.com, paulus@samba.org, akpm@osdl.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, torvalds@osdl.org, mingo@elte.hu, hawkes@sgi.com

Paul Jackson wrote:
> So long as the cpuset code stops making any calls to partition_sched_domains()
> whatsoever, then we should be back where we were in 2.6.12, so far as the
> scheduler is concerned - right?
> 

That's right - sorry I just meant disabling the dynamic sched
domains behaviour of the cpu_exclusive cpusets.

> I hope that the following (untested, unbuilt) patch, that I suggested
> in my "Mon, 22 Aug 2005 13:38:23 -0700" message best meets you
> suggestion above ... and I quote:
> 

I apologise, I missed that patch you sent. I think it looks OK,
and that it looks like what I was thinking about.

We need to revert to a stable behaviour, however we can't risk
major surgery to get there.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
