From: Grant Grundler <iod00d@hp.com>
Date: Mon, 06 Dec 2004 21:03:10 +0000
Subject: Re: [PATCH] - Cacheline align jiffies_64
Message-Id: <20041206210310.GI26198@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041206193232.GA14994@sgi.com>
In-Reply-To: <20041206193232.GA14994@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Dec 06, 2004 at 01:32:32PM -0600, Jack Steiner wrote:
> On large systems, system overhead on cpu 0 is higher than on other
> cpus. On a completely idle 512p system, the average amount of system time 
> on cpu 0 is 2.4%  and .15% on cpu 1-511.

Jack,
Not to trivialize the problem, but I found it amusing that someone
has time to "optimize" the idle loop. :^)

I realize the symptom is an effect that is only easily measured
on an idle system...but it's amusing, none the less. :^)

I'd hope there is a better way to measure temporal locality
of what's in a cacheline with q-tools. But I only know how
to determine cacheline utilization. ie look up the cache line
aligned address in System.map and then use Data EAR to get hard data
as described (briefly) here:
   http://iou.parisc-linux.org/ols2004/www/4_Measuring_Cache_line_Miss.html

probably need a few more bits to isolate per CPU behaviors but I'm
pretty sure pfmon/q-tools can do that.  The "temporal locality"
is the bit I haven't seen any solution for. (Well, maybe a simulator
is the right tool to do that; I don't know).

thanks,
grant
