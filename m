From: "Van Maren, Kevin" <kevin.vanmaren@unisys.com>
Date: Mon, 11 Nov 2002 20:36:38 +0000
Subject: [Linux-ia64] RE: +AFs-Linux-ia64+AF0- reader-writer livelock proble
Message-Id: <marc-linux-ia64-105590709805391@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The entire kernel going south is only the +ACI-worst+ACI- outcome,
but it has been observed with trivial test cases in a 16-
processor system.

It is also possible that a processor can get stuck +ACI-forever+ACI-
spinning in the kernel with interrupts disabled trying to
acquire a lock, and never succeed, without the rest of the
kernel going south.  If that happens, and application will
be livelocked, but the rest of the system will function.
It really depends on the particular circumstances.

+AD4-   Mario+AD4- I know that on some commercial Unix systems there are ways to
+AD4-   Mario+AD4- cap the CPU utilization by user/group ids are there such
+AD4-   Mario+AD4- features/patches available on Linux?

Commercial Unix systems don't have this problem because they do
not use reader-preference locks.  Linux only uses them because
a) locks are allowed to be acquired recursivly, and b) Linux
doesn't want to disable interrupts while holding read locks
if the interrupt handler doesn't acquire a write lock.

Recursion in the reader locks is the real problem that prevents
a simple solution.  Well, there is a simple solution (make all
reader locks act like +ACI-big reader+ACI- locks), but that is also
painful for different reasons.

The first step to fixing the problem is to separate out the
locks that need-to-be/are acquired recursivly+ADs- once that is done,
David's suggestion of making ONLY the interrupt handlers reader-
preference would eliminate the need to disable interrupts more
frequently, with the read-lock-failed path slightly more complex
(involving a check for interrupt mode).

The problem could then be eliminated entirely by turning recursive
reader locks into recursive spinlocks, which eminiates parallelism,
but also prevents starvation (assuming the spinlock implementation
is +ACI-fair+ACI-, but that can be done without changing the locking semantics).

+AD4- I took a look and it appears pretty encouraging. I guess the final
+AD4- question would be - with CPU caps imposed on non-root users would
+AD4- that prevent a user from livelocking the system? I don't recall how
+AD4- long it took for the system  to livelock (I erased the original email),
+AD4- there may be an oppertunity for livelock to develop before the PRM
+AD4- policies kick in.

I have not looked at this, but I don't believe it is the right
way to solve the problem: users who +AF8-need+AF8- to use all the CPUs
for computation would be punished just to work around a kernel
implementation issue: that's like saying don't allow processes
to allocate virtual memory because if the VM is over-committed
by X amount the kernel deadlocks.

It would be a bad hack to limit the system-call rate just to prevent
livelock.

Kevin Van Maren

