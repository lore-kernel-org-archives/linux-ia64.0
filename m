From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Thu, 17 Feb 2005 16:33:48 +0000
Subject: Re: Allow to change SD_NODES_PER_DOMAIN at configuration or boot
Message-Id: <4214C76C.2020804@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <42138013.3060909@bull.net>
In-Reply-To: <42138013.3060909@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Xavier Bru wrote:
> Nick Piggin wrote:
> 
>> Right. It may make more sense to have the setup based on some
>> maximum distance between nodes. Eg. all nodes less than distance
>> 10 away from node0 are to be in node0's first level NUMA domain
>> (the next level is always global, IIRC).
>>
>> Then you would still need some configuration option, but it would
>> appear to be a more useful metric to use.
>>
>>  
>>
> Hello Nick & all,
> Do you mean that there should ever be only one NUMA sched-domain level ?

Hi,

No, I just mean that if the metric used to determine the nodes
in the lower level NUMA sched-domain is "node distance of no
greater than N", rather than "closest N nodes", you might have
a system that is easier to manage, and be less likely to have
the weird "artifacts" discussed.

> On a 2x4x4 cpus machine, we could in theory have  SD_NODES_PER_DOMAIN=4, 
> thus providing a 2 level NUMA sched-domain (domain 0 spans 4 cpus, 
> domain 1 spans 16, domain 2 is global and spans 32).
> But it is true that this configuration does not show evident performance 
> gains upon SD_NODES_PER_DOMAIN=8 (domain 0 spans 4 cpus, domain 1 is 
> global and spans 32), at least on parallel compilation of the kernel.

I'd say yeah, such a system may be too small for that to make much
difference. That said, a kernel compile probably isn't too sensitive
to scheduling placement, provided it is not completely broken.

> Providing SD_NODES_PER_DOMAIN as a boot parameter was also intended to 
> choose between a multilevel sched-domains or not.
> 

Oh yes, that's better than nothing at all, definitely.

Nick

