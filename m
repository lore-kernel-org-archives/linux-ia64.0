From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Fri, 23 Jul 2004 04:29:05 +0000
Subject: Re: [RFC] Patch for isolated scheduler domains
Message-Id: <41009411.1080401@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040722164126.GB13189@sgi.com> <20040722175459.GA30059@elte.hu> <4100859C.9060409@yahoo.com.au> <20040723041349.GB15188@sgi.com>
In-Reply-To: <20040723041349.GB15188@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dimitri Sivanich <sivanich@sgi.com>
Cc: Ingo Molnar <mingo@elte.hu>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Dimitri Sivanich wrote:
> On Fri, Jul 23, 2004 at 01:27:24PM +1000, Nick Piggin wrote:
> 
>>Cool. Have you actually tried running it? With Ingo's correction, it
>>should work fine but I don't think anyone has tested this.
>>
> 
> Yup, I've been running it on an Altix.
> 

Great.

> I've created a version for sched.c (all platform) which I'll be posting
> soon.  That will include code for both CONFIG_NUMA_SCHED and non
> CONFIG_NUMA_SCHED configurations.

Sorry to throw a spanner in the works, but could you have a look
at the "[PATCH] consolidate sched domains" I just sent in, and
see if you can work on top of that.

I really should have done that patch earlier :\
