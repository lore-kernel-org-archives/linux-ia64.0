From: John Levon <levon@movementarian.org>
Date: Tue, 07 Oct 2003 23:27:51 +0000
Subject: OProfile vs. Perfmon
Message-Id: <marc-linux-ia64-106556940523002@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


2.6 still lacks proper OProfile support. Will Cohen's older patch was
rejected due to issues over lack of re-use of the perfmon interface.

I've been looking briefly at perfmon just now, and wanted to gather your
thoughts on the best way this needs to be integrated.

First, what OProfile needs :

o some way to set up the counter values
o system-wide statistical profiling
o an in-kernel notification on counter overflow, and reset of the
  counter value at that point
o some way to mark each generated event by a small integer value and the
  IP saved at the time of the overflow interrupt

And that's it, I think.

Previously mentioned was the suggestion that OProfile kernel glue should
hook into perfmon's custom buffer API. Having looked briefly at it, it
seems the perfmon core has a lot of buffer management code, that we
really do not want to use, as it would massively complicate the
arch-independent oprofile core. IOW, the overflow handler would feed
straight into oprofile_add_sample().  In effect, all we need is to be
able to receive the overflow interrupts.

It certainly looks like this is easy enough.

The next issue is setting up the counters. Basically the userspace
should be using pfmlib to program the required events, and using
sys_perfmonctl to set up a system-wide session. From oprofiled's point
of view, it would basically write the pmc's, create a session, and start
the profiling.

I'm a bit baffled by the code concerning ctx_cpu in system-wide mode. Is
user-space supposed to figure out how many CPUs are up and create a
context for each of them ? In particular:

   4229         the_cpu = ctx->ctx_cpu = smp_processor_id();

I cannot make head or tail of why the CPU that happens to be running the
task calling sys_perfmonctl() is relevant at all to system-wide
profiling. Can someone explain ?

Finally, is the above summary roughly accurate, and are there any
pitfalls I might need to watch out for ?

thanks,
john

-- 
Khendon's Law:
If the same point is made twice by the same person, the thread is over.
