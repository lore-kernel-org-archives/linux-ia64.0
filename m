From: Christoph Lameter <clameter@engr.sgi.com>
Date: Fri, 24 Jun 2005 17:53:08 +0000
Subject: Re: [RFC] Hierarchical BackOff Locks
Message-Id: <Pine.LNX.4.62.0506241048050.24991@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0506151550440.6431@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0506151550440.6431@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 22 Jun 2005, Zoltan Menyhart wrote:

> Can we consider instead of "cpu_to_node_map[(ia64_getreg(_IA64_REG_TP)->cpu)]"
> perhaps some "per_cpu__my_slock_idx" ?
> 
> > +	ia64_spinlock_val = ia64_cmpxchg4_acq(ia64_spinlock_ptr,
> > numa_node_id()+ 1, 0);	\
> 
> Instead of "numa_node_id()+ 1" perhaps some "per_cpu__my_slock_id" ?

I just tried to implement your proposed method but we will run into issues 
with preemption. I would have preempt disable/enables or irq 
disable/enables inline as well as in the contention handlers.

