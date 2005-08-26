From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Fri, 26 Aug 2005 01:32:34 +0000
Subject: Re: [PATCH 2.6.13-rc7 2/2] completely disable cpu_exclusive sched
Message-Id: <430E7132.9060800@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050825194750.7341.75723.sendpatchset@jackhammer.engr.sgi.com> <20050825194756.7341.83327.sendpatchset@jackhammer.engr.sgi.com>
In-Reply-To: <20050825194756.7341.83327.sendpatchset@jackhammer.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Paul Jackson <pj@sgi.com>
Cc: torvalds@osdl.org, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, paulus@samba.org, mingo@elte.hu, hawkes@sgi.com, dino@in.ibm.com

Paul Jackson wrote:
> At the suggestion of Nick Piggin and Dinakar, totally disable
> the facility to allow cpu_exclusive cpusets to define dynamic
> sched domains in Linux 2.6.13, in order to avoid problems
> first reported by John Hawkes (corrupt sched data structures
> and kernel oops).
> 
> This has been built for ppc64, i386, ia64, x86_64, sparc, alpha.
> It has been built, booted and tested for cpuset functionality
> on an SN2 (ia64).
> 
> Dinakar or Nick - could you verify that it for sure does avoid
> the problems Hawkes reported.  Hawkes is out of town, and I don't
> have the recipe to reproduce what he found.
> 

Thanks Paul, I was never able to reproduce the problem, but
I'm sure Dinakar should be able to test.

Acked-by: Nick Piggin <npiggin@suse.de>

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
