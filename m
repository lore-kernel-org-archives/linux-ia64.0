From: Petr Tesarik <ptesarik@suse.cz>
Date: Mon, 28 Apr 2008 10:01:35 +0000
Subject: Re: ptrace problem with 2.6.25 on Itanium
Message-Id: <1209376895.4027.29.camel@elijah.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <7c86c4470804240339p77639b4ejee73baec305d74c5@mail.gmail.com>
In-Reply-To: <7c86c4470804240339p77639b4ejee73baec305d74c5@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, 2008-04-27 at 19:30 -0700, Roland McGrath wrote:
> Sorry to complicate your life, but this one is officially Your Problem.
> There is no kernel bug here.  The semantics have not changed, only the
> timing.  (You are not the first to assume some ordering constraint was
> provided in the ptrace interface that in fact has never been guaranteed
> at all.)

I was just wondering why the timing was changed in such a way that the
signals *consistently* arrive in wrong order, and why only on IA64. I
think I know the answer:

do_fork() calls ptrace_notify() from the parent before the parent
process is rescheduled. This usually happens before the child process is
scheduled - BTW it happens always if both processes run on the same CPU
and the kernel is not preemptive.

Now, what happens after applying the RSE patch is that sending the
notification from the parent involves synchronizing the parent's RSE to
user space. Because this takes some time (and may sleep), the child
process is selected by the scheduler and runs first (note that the
notification is sent _after_ waking the child).

On other architectures, the overhead with enqueueing the notification
signal is much smaller, so the parent usually finishes sending the
signal before the child even gets to sending its own notification. But
this is racy, as pointed out by Roland, and any program which relies on
it will fail one day. In a way, we should be glad that ia64 now tends to
send the signals in a non-deterministic order, as more people will hit
the race and (hopefully) fix their programs. ;)

Kind regards,
Petr Tesarik
