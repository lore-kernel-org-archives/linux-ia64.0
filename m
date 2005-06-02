From: "Jim Hull" <jim.hull@hp.com>
Date: Thu, 02 Jun 2005 03:00:30 +0000
Subject: RE: flush_icache_range
Message-Id: <200506020300.UAA12118@lucy.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4236D7B5.8050408@bull.net>
In-Reply-To: <4236D7B5.8050408@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David: 

> If a CPU advertises an optimal stride-size of 128 bytes, that better
> work for all CPUs in the system, even if the optimal stride for
> another CPU is smaller, say 64 bytes.

Unfortunately, that's not how the ia64 architecture works.  Although the flushes
are broadcast throughout the cache coherence domain, the parameters returned by
PAL are for that specific processor only.  This is because each PAL knows
nothing about the other (potentially heterogeneous) processors - that depends on
system knowledge.

Because there is no SAL interface to query all the PALs and compute the minimum
for you, this task falls on the OS to do.

> If you want to do a global min and store that in a global variable,
> sure, that's fine too.  I _think_ the per-CPU approach would come out
> as simpler code, but I could be wrong.

A single global is sufficient, so long as you don't aspire to optimally run a
single OS image across multiple cache coherence domains.  If you did, then you'd
need one value per coherence domain.  If you did want to (someday) allow for
this, then a per-CPU value, computed initially as the system-wide min, would be
easier to extend.

>   Zoltan> I prefer not to support mixed configurations as there is not
>   Zoltan> such a real machine, => no need to calculate the min. stride
>   Zoltan> size.
> 
> We should write software that fits the architecture, not just today's
> machines.  Doing the latter just calls for trouble when new machines
> are being introduced.  Never underestimate the cleverness of future hw
> designers...

It's not as farfetched as you might think.  As I understand Intel's official
public position, they don't test, and therefore don't support such mixed
configurations.  However, they also don't expect it not to work, and any OEM who
wishes to do the testing and assume the support costs is free to do so.  (Note:
This same position applies to other types of mixing as well, such as multiple
frequencies.)

 -- Jim


