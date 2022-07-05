From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 05 Jul 2022 15:44:06 +0000
Subject: Re: [PATCH v4 12/12] sched,signal,ptrace: Rework TASK_TRACED, TASK_STOPPED state
Message-Id: <YsRcRgfZFl0K4L9h@worktop.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <87a6bv6dl6.fsf_-_@email.froward.int.ebiederm.org>
 <20220505182645.497868-12-ebiederm@xmission.com>
 <YrHA5UkJLornOdCz@li-4a3a4a4c-28e5-11b2-a85c-a8d192c6f089.ibm.com>
 <877d5ajesi.fsf@email.froward.int.ebiederm.org>
 <YrHgo8GKFPWwoBoJ@li-4a3a4a4c-28e5-11b2-a85c-a8d192c6f089.ibm.com>
 <87y1xk8zx5.fsf@email.froward.int.ebiederm.org>
 <YrtKReO2vIiX8VVU@tuxmaker.boeblingen.de.ibm.com>
 <87czess94h.fsf@email.froward.int.ebiederm.org>
 <20220628184850.05f60d1e@gandalf.local.home>
 <87pmisqgs0.fsf@email.froward.int.ebiederm.org>
In-Reply-To: <87pmisqgs0.fsf@email.froward.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Alexander Gordeev <agordeev@linux.ibm.com>, linux-kernel@vger.kernel.org, rjw@rjwysocki.net, Oleg Nesterov <oleg@redhat.com>, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, mgorman@suse.de, bigeasy@linutronix.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org, svens@linux.ibm.com

On Tue, Jun 28, 2022 at 10:39:59PM -0500, Eric W. Biederman wrote:

> > That is, the two paths should already be synchronized, and the memory
> > barriers will not help anything inside the locks. The locking should (and
> > must) handle all that.
> 
> I would presume so to.  However the READ_ONCE that is going astray
> does not look like it is honoring that.
> 
> So perhaps there is a bug in the s390 spin_lock barriers?  Perhaps there
> is a subtle detail in the barriers that spin locks provide that we are
> overlooking?

So the thing is, s390 is, like x86, a TSO architecture with SC atomics.
Or at least it used to be; I'm not entirely solid on the Z196 features.

I've been looking at this and I can't find anything obviously wrong.
arch_spin_trylock_once() has what seems a spurious barrier() but that's
not going to cause this.

Specifically, s390 is using a simple test-and-set spinlock based on
their Compare-and-Swap (CS) instruction (so no Z196 funnies around).

Except perhaps arch_spin_unlock(), I can't grok the magic there. It does
something weird before the presumably regular TSO store of 0 into the
lock word.

Ooohh.. /me finds arch_spin_lock_queued().. *urfh* because obviously a
copy of queued spinlocks is what we need.

rwlock_t OTOH is using __atomic_add_*() and that's all Z196 magic.

Sven, does all this still reproduce if you take out
CONFIG_HAVE_MARCH_Z196_FEATURES ? Also, could you please explain the
Z196 bits or point me to the relevant section in the PoO. Additionally,
what's that _niai[48] stuff?

And I'm assuming s390 has hardware fairness on competing CS ?
