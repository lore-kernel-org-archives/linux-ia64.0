From: Robin Holt <holt@sgi.com>
Date: Thu, 12 Feb 2004 21:53:57 +0000
Subject: How do I raise a thread to realtime priority?
Message-Id: <20040212215357.GA15214@lnx-holt>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


In the 2.4 kernel headers, unistd.h had a _syscall3 that I could
use to make an extern of the sys_sched_setscheduler raise a tasks
priority to realtime.  With 2.6, the _syscall3 has been replaced
with static inlines.  This all seems well.

Since sys_sched_setscheduler is not in the unistd.h, should I add
it to unistd.h?  Is there a prefered method for exporting/inlining
syscall entry points?

Thanks,
Robin Holt
