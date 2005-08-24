From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Wed, 24 Aug 2005 12:01:02 +0000
Subject: Re: [PATCH 2.6.13-rc6] cpu_exclusive sched domains build fix
Message-Id: <430C617E.8080002@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050824111510.11478.49764.sendpatchset@jackhammer.engr.sgi.com>	<20050824112640.GB5197@in.ibm.com> <20050824044648.66f7e25a.pj@sgi.com>
In-Reply-To: <20050824044648.66f7e25a.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Paul Jackson <pj@sgi.com>
Cc: dino@in.ibm.com, paulus@samba.org, akpm@osdl.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, torvalds@osdl.org, mingo@elte.hu, hawkes@sgi.com

Paul Jackson wrote:
> Dinakar wrote:
> 
>>Can we hold on to this patch for a while, as I reported yesterday,
> 
> 
> Sure - though I guess it's Linus or Andrew who will have to do
> the holding.
> 
> I sent it off contingent on the approval of yourself, Hawkes and Nick.
> 

I get the feeling that the problem would be present in more
than just misaligned nodes.

On the POWER5 for example, Dinakar probably has SMT enabled,
which may cause something similar to pop up.

I get the feeling that exclusive cpusets should just be
completely disabled for 2.6.13, and John & Ingo's complete
fix put in 2.6.14-early

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
