From: Christoph Lameter <clameter@engr.sgi.com>
Date: Mon, 06 Jun 2005 08:40:46 +0000
Subject: fsys_rt_sigprocmask fastcall not taking lock to read current->blocked
Message-Id: <Pine.LNX.4.62.0506060115470.15260@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

rt_sigprocmask can be called like

sigprocmask(how, NULL, &oset)

in this case oset is set to the current mask. The C code does:

 spin_lock_irq(&current->sighand->siglock);
 old_set = current->blocked;
 spin_unlock_irq(&current->sighand->siglock);

asm does:

..
 add r31=IA64_TASK_SIGHAND_OFFSET,r16
..
 ld8 r31=[r31]                           // r31 <- current->sighand
..

 cmp.eq p6,p0=r0,r33                     // set = NULL?
(p6)    br.dpnt.many .store_mask                // -> short-circuit to just reading the signal mask

...
.store_mask:
 EX(.fail_efault, (p15) probe.w.fault r34, 3)    // verify user has 
 write-access to *oset
 EX(.fail_efault, (p15) st8 [r34]=r3)
...
        FSYS_RETURN

No lock! However it seems that a side effect of siglock is also to 
guarantee that current->blocked is always in sync with TIF_SIGPENDING. 

Typical locking for current->blocked is like this (sys_rt_sigtimedwait):

			/* None ready -- temporarily unblock those we're
                         * interested while we are sleeping in so that we'll
                         * be awakened when they arrive.  */
                        current->real_blocked = current->blocked;
                        sigandsets(&current->blocked, &current->blocked, &these);
                        recalc_sigpending();
                        spin_unlock_irq(&current->sighand->siglock);

Without the lock an app calling rt_sicprocmask may see a blocked 
signal state that is not in sync with TIF_SIGPENDING.

Is that permissible? TIF_SIGPENDING seems to be important for the end of 
syscall handling and also be used without a lock. 

Then there is some code that generates intermediate current->blocked 
values while holding the siglock that may also be cause for concern. F.e. 
in handle_signal:

		spin_lock_irq(&current->sighand->siglock);
                {
                        sigorsets(&current->blocked, &current->blocked, &ka->sa.sa_mask);
                        sigaddset(&current->blocked, sig);
                        recalc_sigpending();
                }
                spin_unlock_irq(&current->sighand->siglock);


The current structure is thread specific so one would think that this will 
guarantee some protection. But is this always the case?


