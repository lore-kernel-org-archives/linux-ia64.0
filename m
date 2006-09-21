From: Jes Sorensen <jes@sgi.com>
Date: Thu, 21 Sep 2006 12:40:37 +0000
Subject: Re: [patch] show_mem() printk levels
Message-Id: <45128845.4050201@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq04pvcey2p.fsf@jaguar.mkp.net>
In-Reply-To: <yq04pvcey2p.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Lameter wrote:
> On Thu, 14 Sep 2006, Jes Sorensen wrote:
> 
>> Actually it's far worse than that if I got the math right, it will
>> print in the order of 2 * NR_CPUS * NR_NODES * nr_zones, which for a
>> machine with 1024 cpus and 1024 nodes will result in 2 million lines
>> plus a bit of other noise.
>>
>> This is a problem on all architectures, not just ia64, so I have a
>> patch to try and trim that down too, so it gets done right. But we may
>> also want to consider dropping the call altogether for ia64 or maybe
>> if the number of nodes is larger than a certain amount (but I don't
>> like inconsistent behavior depending on the size of a system).
> 
> Please lets just drop the call for ia64. For systems with a few cpus 
> (typical for Linux use) the diagnostics are very useful.

I'm fine with this - anybody objecting to this call being dropped for
ia64? We could do something where we only call it if the number of nodes
is lower than a certain threshold, but IMHO it's better to be
consistent?

Comments,
Jes

