From: Jack Steiner <steiner@sgi.com>
Date: Mon, 06 Dec 2004 22:01:08 +0000
Subject: Re: [PATCH] - Cacheline align jiffies_64
Message-Id: <20041206220108.GA18431@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041206193232.GA14994@sgi.com>
In-Reply-To: <20041206193232.GA14994@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Dec 06, 2004 at 01:03:10PM -0800, Grant Grundler wrote:
> On Mon, Dec 06, 2004 at 01:32:32PM -0600, Jack Steiner wrote:
> > On large systems, system overhead on cpu 0 is higher than on other
> > cpus. On a completely idle 512p system, the average amount of system time 
> > on cpu 0 is 2.4%  and .15% on cpu 1-511.
> 
> Jack,
> Not to trivialize the problem, but I found it amusing that someone
> has time to "optimize" the idle loop. :^)

I wasn't clear. 

The problem is that idle cpus interfere with cpu 0 (timekeeper) doing
real work. It doesn't matter what is running on cpu 0 (idle or busy), When
a timer tick occurs on cpu 0, it takes a long time to obtain exclusive 
ownership of the line that contains jiffies. 

The problem is real. The investigation was triggered by a user app
that ran ~2.5% faster on cpu 1 than on cpu 0. 


Although the specific case that I ran into could be solved by moving pal_halt, 
I don't think that is a good solution. Jiffies can be a
fairly hot variable. If it is falsely shared with another variable that
is frequently written, it could significantly impact performance.

Moving jiffies to a private cacheline seems like a better solution.


> 
> I realize the symptom is an effect that is only easily measured
> on an idle system...but it's amusing, none the less. :^)
> 
> I'd hope there is a better way to measure temporal locality
> of what's in a cacheline with q-tools. But I only know how
> to determine cacheline utilization. ie look up the cache line
> aligned address in System.map and then use Data EAR to get hard data
> as described (briefly) here:
>    http://iou.parisc-linux.org/ols2004/www/4_Measuring_Cache_line_Miss.html

I'll experiment with this tool. I wonder if there are other hot
cache lines caused by false sharing.


-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


