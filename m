From: "John Hawkes" <hawkes@sgi.com>
Date: Thu, 20 Nov 2003 22:14:36 +0000
Subject: Re: [PATCH] - sched_clock() broken for ia64 SN platform
Message-Id: <marc-linux-ia64-106936655210703@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106928980122896@msgid-missing>
In-Reply-To: <marc-linux-ia64-106928980122896@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: "john stultz" <johnstul@us.ibm.com>
> I too was confused why per-cpu start and stop times were not just used
> for this high-res accounting. I'm not sure I can look into it now, but
> I'd be interested to hear why we'd compare timestamps across cpus
> (rather then just use time deltas calculated on a single cpu).

sched_clock() and task->timestamp are used in two different ways.  One is for
supposedly high-res accounting.  The other is for can_migrate_task(), called
during load-balancing, to determine if the process has slept long enough to
consider it to no longer be cache-hot.  It's this latter use that suffers from
a drifty timebase.

John Hawkes


