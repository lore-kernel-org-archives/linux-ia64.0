From: Jes Sorensen <jes@sgi.com>
Date: Thu, 14 Sep 2006 08:27:21 +0000
Subject: Re: [patch] show_mem() printk levels
Message-Id: <yq0venqetue.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq04pvcey2p.fsf@jaguar.mkp.net>
In-Reply-To: <yq04pvcey2p.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Christoph" = Christoph Lameter <clameter@sgi.com> writes:

Christoph> On Wed, 13 Sep 2006, Jes Sorensen wrote:
>> Index: linux-2.6/arch/ia64/mm/contig.c
>> =================================>> --- linux-2.6.orig/arch/ia64/mm/contig.c +++
>> linux-2.6/arch/ia64/mm/contig.c
>> 
>> - printk("Mem-info:\n"); + printk(KERN_INFO "Mem-info:\n");
>> show_free_areas();

Christoph> ^^^ This will print 1 mio cpuset descriptions on a 1k cpu /
Christoph> 1k node system to the console. Could we just drop calling
Christoph> show_free_areas()?

Actually it's far worse than that if I got the math right, it will
print in the order of 2 * NR_CPUS * NR_NODES * nr_zones, which for a
machine with 1024 cpus and 1024 nodes will result in 2 million lines
plus a bit of other noise.

This is a problem on all architectures, not just ia64, so I have a
patch to try and trim that down too, so it gets done right. But we may
also want to consider dropping the call altogether for ia64 or maybe
if the number of nodes is larger than a certain amount (but I don't
like inconsistent behavior depending on the size of a system).

Anyway, I am not done sending out patches :)

Cheers,
Jes
