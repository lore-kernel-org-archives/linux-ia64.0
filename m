From: Joshua Aas <josha@sgi.com>
Date: Tue, 13 Jul 2004 23:52:19 +0000
Subject: Re: free bootmem feedback patch
Message-Id: <40F475B3.5010205@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40F46962.4090604@sgi.com>
In-Reply-To: <40F46962.4090604@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote:
>>NUMA machines with a lot of memory/nodes appear to hang when 
>>freeing boot memory, as it can take on the order of 4 minutes. 
> 
> 
> Isn't this a feature of the amount of memory being freed, rather
> than the fact that there are many nodes?  I.e. if someone has a
> single node box with a few TB of memory, they'll still have the
> multi-minute delay, but your patch won't give them any progress
> dots.
> 
> -Tony

In the case of a single massive memory region you would still see "Freeing boot memory...", you just wouldn't see progress. That would make me feel better than nothing. It wouldn't be easy to add progress feedback within a single region without making one line of feedback per region - which seems like way too much to me on machines are at and above 128-256 regions. The way I've done it, single region machines get notification, multi-region machines see progress, and either way it only makes one line of feedback. Also, correct me if I'm wrong, but machines with 250GB-4TB or so of memory, where the pause is longest, are more likely to be multi-region machines.

-- 
Josh Aas
Silicon Graphics, Inc. (SGI)
Linux System Software
651-683-3068
