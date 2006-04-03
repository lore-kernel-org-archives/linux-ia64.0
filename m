From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Mon, 03 Apr 2006 16:33:38 +0000
Subject: Re: accessed/dirty bit handler tuning
Message-Id: <44314E62.10108@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <44157CF1.5060902@bull.net>
In-Reply-To: <44157CF1.5060902@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote:
>>It is very much curious having so few dirty and i-access traps...
> 
> 
> Your data collection code has races (ld8, add, st8 on one cpu can
> race with another cpu doing the same).  So you'll undercount whenever
> a race happens.
> 
> Perhaps you should use per-cpu counters to collect the values, and
> then sum for each cpu in the syscall() before reporting to the user?

It was not very important to count the events precisely.

The lesson I learnt is the VHPT miss handler is the most important
(maybe the D-ACCESS trap handler), the others are "neglectable".
(I have not counted yet the handlers not doing a purge.)

The problem is that the most frequently used trap handler contains
the unsafe walk of the

	rx = IA64_KR_PT_BASE -> pgd[i] -> pud[j] -> pmd[k] -> pte[l]

chain...

Zoltan
