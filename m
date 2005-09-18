From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Sun, 18 Sep 2005 10:56:31 +0000
Subject: Re: Volanomark regress on ia64
Message-Id: <432D47DF.30706@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200509160040.j8G0eFg06734@unix-os.sc.intel.com>
In-Reply-To: <200509160040.j8G0eFg06734@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Chen, Kenneth W wrote:
> Take a look at http://kernel-perf.sourceforge.net/results.machine_id&.html
> 
> First chart with volanomark benchmark.  It took ~ 11% performance regression
> on 2.6.13-git9 and 2.6.14-rc1.
> 
> It is not those two particular kernel version have the problem per se.  It
> would've shown on 2.6.13-rc1 when default hz rate was switched to 250.  Last
> week, I happened to audit the system and made the hz switch and the problem
> showed up.
> 
> Hz00  cpu idle is about 54%, the raw throughput is 74935 msgs/sec
> Hz%0   cpu idle is about 58%, the raw throughput is 67246 msgs/sec
> 
> I think it has something to do with the scheduler load balance.  While I'm
> looking into schedstat and etc.  Posting here for everyone to pour over the
> issue.
> 
> vmstat/readprofle/schedstat result with 1K hz and 250 hz attached.
> 

Hi Ken,
Made any progress yet?

It looks like the problem is confined to ia64? Are the x86-64 machines
also running with HZ set to 250?

I would look at differences between SD_CPU_INIT for ia64 versus the
generic definition. cache_hot_time and cache_nice_tries by the looks,
both those could cause increased idle time.

Nick

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
