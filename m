From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Fri, 25 Feb 2005 23:41:41 +0000
Subject: Re: [PATCH] random ia64 sched-domains values
Message-Id: <421FB7B5.6080101@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <421EDE70.3010501@yahoo.com.au>
In-Reply-To: <421EDE70.3010501@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Chen, Kenneth W wrote:
> Nick Piggin wrote on Friday, February 25, 2005 12:15 AM
> 
>>These are some values I just found from thin-air that should
>>hopefully make ia64 work after the latest sched patches.
>>
>>+	.cache_hot_time		= (10*1000000),		\
> 
> 
> In 2.6.9, cache_hot_time gets the value from cache_decay_tick, since
> when this become a constant again?
> 

Not sure. cache_decay_ticks isn't set to anything meaningful on
ia64 anyway. Nor i386 for that matter.

Nick

