From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 20 Nov 2003 18:32:29 +0000
Subject: Re: [PATCH] - sched_clock() broken for ia64 SN platform
Message-Id: <marc-linux-ia64-106935347926743@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106928980122896@msgid-missing>
In-Reply-To: <marc-linux-ia64-106928980122896@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 20 Nov 2003 09:23:35 -0600, Jack Steiner <steiner@sgi.com> said:

  Jack> This is slightly off-topic, but the shared platform counter on
  Jack> the SGI platform isnt a single counter. The counter is
  Jack> replicated in each chipset It is synchronized thruout the
  Jack> system so that all cpus will see the same value - ie., no
  Jack> drift. Reading the counter does not required any off-node
  Jack> references. There shouldnt be any scaling issues.

Ah, that's good.  Just for future reference, what's the approximate
latency of reading this counter?

  Jack> However, reading the ITC is faster & preferred if intercpu
  Jack> drift is not an issue.

Yes.  Plus we could solve the problem once and for all, not once for
each drifty platform.

As I remember it, sched_clock() was originally invented to measure
fine-grained "how long have I run" times.  This can be done with ITC
without synchronization, since the start and stop "times" will be
measured on the same CPU.  Howver, as John points out, at the moment
sched_clock() is also used for migration-decisions.  My guess is that
this part is just due to someone trying to be overly clever.  At least
on drifty platforms, you can just as easily make this decision based
on jiffies.  All it would do is add one word to the task_struct and
reading both sched_clock() and jiffies when updating the timestamp(s).

	--david
