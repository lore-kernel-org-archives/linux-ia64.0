From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Thu, 21 Oct 2004 14:34:22 +0000
Subject: Re: [PATCH] top level scheduler domain for ia64
Message-Id: <4177C8EE.6020400@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200410191427.27336.jbarnes@engr.sgi.com>
In-Reply-To: <200410191427.27336.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Xavier Bru wrote:
> Hello Nick & all,
> 
> Nick Piggin wrote:
> 
>> Luck, Tony wrote:
>>
>>
>>> +    .min_interval        = 80,            \
>>> +    .max_interval        = 320,            \
>>> +    .busy_factor        = 320,            \
>>> +    .imbalance_pct        = 125,            \
>>> +    .cache_hot_time        = (10*1000000),        \
>>> +    .balance_interval    = 100*(63+num_online_cpus())/64,   \
>>>
>>> That's a lot of magic numbers and formulae ... are they right?
>>> How would a user know if they are right.
>>>
>>
>> To be honest you really wouldn't. It would take a lot of careful
>> testing on numerous workloads and systems. I believe SGI is
>> starting to do a bit of testing... I don't have the resources to
>> do many "real world" tests.
>>
>> At this stage I wouldn't let them worry you too much :P
>> Hopefully they'll gradually improve.
> 
> 
> Why should'nt we use the node_distance() function to build in an 
> independant way the Numa hierarchy and compute the right parameters for 
> each level ?
> 
> 

Hi Xavier,
That would probably be a good idea where possible, although for many
architectures this sort of information won't be available. It may be
that we ultimately will want to represent the NUMA topology with
node_distance being the first class function/measure (I personally
think sched-domains should be extended into the memory topology). At
the present time though, it would be a backward step to force everyone
to build a node_distance table.

Two things to note - first, even if node_distance does return something
meaningful, it still has to be input into a larger field of parameters,
so there will still be some heuristics/fudging/tuning going on.

Second, we can do runtime probing to gain more information. For example,
Ingo has a patch in the works that will compute real cache transfer
times between any two CPUs, which looks promising. We can query the
number of online CPUs when deciding on balancing rates, etc etc.

So in short, we basically want as much info as we can possibly gather...
and that is the easy part :( People need to do tests on their real life
workloads with real systems to convert this information into useful
parameters.

Anyway, the scheduler isn't _quite_ at the point where you want to be
doing serious fine tuning with it yet; we've got to get a few more
things to go in (eg. Ingo's patch, improvements from John Hawkes, some
performance patches from me, etc).
