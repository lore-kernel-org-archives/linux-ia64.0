From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 14 Sep 2006 16:47:51 +0000
Subject: Re: [patch] show_mem() printk levels
Message-Id: <Pine.LNX.4.64.0609140946560.23909@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq04pvcey2p.fsf@jaguar.mkp.net>
In-Reply-To: <yq04pvcey2p.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 14 Sep 2006, Jes Sorensen wrote:

> 
> Actually it's far worse than that if I got the math right, it will
> print in the order of 2 * NR_CPUS * NR_NODES * nr_zones, which for a
> machine with 1024 cpus and 1024 nodes will result in 2 million lines
> plus a bit of other noise.
> 
> This is a problem on all architectures, not just ia64, so I have a
> patch to try and trim that down too, so it gets done right. But we may
> also want to consider dropping the call altogether for ia64 or maybe
> if the number of nodes is larger than a certain amount (but I don't
> like inconsistent behavior depending on the size of a system).

Please lets just drop the call for ia64. For systems with a few cpus 
(typical for Linux use) the diagnostics are very useful.

