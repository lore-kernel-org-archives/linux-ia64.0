From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Sat, 26 Feb 2005 00:48:40 +0000
Subject: Re: [PATCH] random ia64 sched-domains values
Message-Id: <421FC768.3000905@yahoo.com.au>
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
>>+#define SD_CPU_INIT (struct sched_domain) {		\
>>...
>>+	.max_interval		= 4,			\
>>+	.busy_factor		= 64,			\
>>+	.imbalance_pct		= 125,			\
> 
> 
> For one db workload, performance increases with the following
> values compare to the values proposed above.
> 

Sorry if I wasn't clear earlier - this patch is not meant to
go into 2.6. It is for Andrew to get ia64 working after my
last round of scheduler patches.

There are pretty significant changes, so the optimal values
for various things will have changed quite a bit.

> .max_interval = 100
> .busy_factor = 32
> .imbalance_pct = 100
> 

I can imagine max_interval could probably be increased.

Setting imbalance_pct to 100 is interesting, I wonder why this
helps performance... It would be good to get schedstats output.

Nick

