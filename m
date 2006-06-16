From: Andi Kleen <ak@suse.de>
Date: Fri, 16 Jun 2006 10:09:25 +0000
Subject: Re: FOR REVIEW: New x86-64 vsyscall vgetcpu()
Message-Id: <200606161209.25266.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <200606140942.31150.ak@suse.de> <200606160822.23898.ak@suse.de> <yq0ejxp2zzg.fsf@jaguar.mkp.net>
In-Reply-To: <yq0ejxp2zzg.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@sgi.com>
Cc: Tony Luck <tony.luck@intel.com>, discuss@x86-64.org, linux-kernel@vger.kernel.org, libc-alpha@sourceware.org, vojtech@suse.cz, linux-ia64@vger.kernel.org


> It all depends on your application and the type of system you are
> running on. What you say applies to smaller cpu counts. However once
> we see the upcoming larger count multi-core cpus become commonly
> available, this is likely to change and become more like what is seen
> today on larger NUMA systems.

Maybe. Maybe not. 

> 
> In the scientific application space, there are two very common
> groupings of jobs.

The scientific users just use pinned CPUs and seem to be happy with that.
They also have cheap slav^wgrade students to spend lots of time on
manual tuning.  I'm not concerned about them. 

If you already use CPU affinity you should already know where you are and don't 
need this call at all.

So this clearly isn't targetted for them. 

Interesting is getting the best performance from general purpose applications 
without any special tuning. For them I'm trying to improve things.

Number one applications currently are databases and JVMs. I hope with 
Wolfam's malloc work it will be useful for more applications too. 

> Andi> So by default filling the CPUs must be the highest priority and
> Andi> memory policy cannot interfere with that.
> 
> I really don't think this approach is going to solve the problem. As
> Tony also points out, tasks will eventually migrate.

Currently we don't solve this problem with the standard heuristics.
It can be solved with manual tuning (mempolicy, explicit CPU affinity)
but if you're doing that you're already out side the primary use 
case of vgetcpu().

vgetcpu() is only trying to be a incremental improvement of the current
simple default local policy.

> The user needs to 

Scientific users do that, but other users normally not. I doubt that
is going to change.

-Andi
