From: Keith Owens <kaos@sgi.com>
Date: Fri, 07 Mar 2003 13:57:04 +0000
Subject: [Linux-ia64] ia64_spinlock_contention and NEW_LOCK
Message-Id: <marc-linux-ia64-105590709806001@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

2.4.0-test6-ia64-000811 introduced ia64_spinlock_contention and
NEW_LOCK.  AFAICT they have been disabled ever since they were
introduced.  Are there any plans to use this NEW_LOCK code?  I have two
reasons for asking.

(1) If ia64_spinlock_contention is going to be used then it needs
    unwind data, otherwise an interrupt in this code will not get a
    decent backtrace.

(2) To enable kdb and lkcd diagnosis of hung spinlocks, I want the
    contention path to check for a 'enter debugger now!' flag[*].
    Obviously such a test would be better handled in a single
    contention routine instead of being expanded as part of every
    spinlock usage.

[*] I tried DavidM's suggestion of using INIT interrupts to break into
disabled spinlocks.  It works, and with kdb v4.0 you get a decent
backtrace.  However INIT is far too destructive, once INIT has been
sent the cpu is dead.  Barely acceptable for a completely hung machine,
no good if you are just trying to diagnose a problem.


