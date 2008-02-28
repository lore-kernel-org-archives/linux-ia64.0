From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 28 Feb 2008 11:50:41 +0000
Subject: Re: 2.6.25-rc2-mm1 - boot hangs on ia64
Message-Id: <20080228115041.GA22082@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080227103831.423F.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080227071118.GA4638@elte.hu> <20080228192509.BDCF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080228192509.BDCF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Steven Rostedt <srostedt@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-ia64 <linux-ia64@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Ingo Molnar <mingo@redhat.com>, Bob Picco <bob.picco@hp.com>, Eric Whitney <eric.whitney@hp.com>


* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Hi Ingo,
> CC'ed Steven Rostedt 
> 
> I found the following patch cause regression by bisect.
> 
> 2.6.25-rc2-mm1:                            doesn't boot
> 2.6.25-rc2-mm1 + revert following patch:   works well
> 
> but I think it is very strange. runqueue_is_locked() seems simple and 
> have not bug. ;)
> 
> What do you think this problem?

thanks for bisecting it down! Could ia64 have trouble accessing the 
percpu data structures of the scheduler?

does the patch below resolve the hang?

	Ingo

------------------------->
Subject: sched: fix wake_up_klogd()
From: Ingo Molnar <mingo@elte.hu>
Date: Thu Feb 28 12:42:45 CET 2008

on some platforms if we printk too early it might not be safe to call
into the scheduler data structures.

Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 kernel/printk.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

Index: linux/kernel/printk.c
=================================--- linux.orig/kernel/printk.c
+++ linux/kernel/printk.c
@@ -948,7 +948,8 @@ int is_console_locked(void)
 
 void wake_up_klogd(void)
 {
-	if (!oops_in_progress && waitqueue_active(&log_wait))
+	if (!oops_in_progress && waitqueue_active(&log_wait) &&
+						!runqueue_is_locked())
 		wake_up_interruptible(&log_wait);
 }
 
@@ -1000,7 +1001,7 @@ void release_console_sem(void)
 	 * If we try to wake up klogd while printing with the runqueue lock
 	 * held, this will deadlock.
 	 */
-	if (wake_klogd && !runqueue_is_locked())
+	if (wake_klogd)
 		wake_up_klogd();
 }
 EXPORT_SYMBOL(release_console_sem);
