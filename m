From: jbarnes@sgi.com (Jesse Barnes)
Date: Mon, 24 Nov 2003 22:21:54 +0000
Subject: Re: udelay() & preemption & drifty ITCs
Message-Id: <marc-linux-ia64-106971276704138@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106955914311295@msgid-missing>
In-Reply-To: <marc-linux-ia64-106955914311295@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Nov 24, 2003 at 04:01:31PM -0600, Jack Steiner wrote:
> I dislike disabling preemption in udelay(). Although most delays are
> short, there are some delays that are 100s or 1000s of usec long. Users running
> soft-realtime really dont want preemption disabled unnecessarily.
>
> On platforms with synchronized clocks, disabling preemption is not required. 

Yeah, I thought about this too, but unless we have a global flag telling
us if itcs drift or not, it seems lik we have to unconditionally disable
preemption.

> Even on platforms with drifty ITCs, preemption in udelay() is ok as long 
> as migration is disabled. AFAIK, there is no standard API for disabling 
> migration aside from saving/changing/restoring the cpus_allowed mask.

Then we'd have to check if drifty itcs were present and also check to
see if the process was pinned...

If we found enough code that depended on having preemption disabled
because of itc drift, it might be worthwhile to add another inline to
deal with it.  As for CPU pinning, maybe we could check in
preempt_disable() whether the cpus_allowed mask only had one bit
set--that would prevent us from disabling preemption at all for pinned
processes, right?

Jesse
