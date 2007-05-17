From: Keith Owens <kaos@sgi.com>
Date: Thu, 17 May 2007 11:38:59 +0000
Subject: Re: [PATCH] get_wchan on running task sometimes MCAs the machine.
Message-Id: <8976.1179401939@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070517111651.GA760@lnx-holt.americas.sgi.com>
In-Reply-To: <20070517111651.GA760@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Robin Holt (on Thu, 17 May 2007 06:16:52 -0500) wrote:
>Make ia64's get_wchan safer by not unwinding a running tasks stack.
>...
>All that said, I have put together the following simple patch stolen
>directly from i386's get_wchan.  If the task is running, why even try.
>
>
>Index: linux-tot-20070517/arch/ia64/kernel/process.c
>=================================>--- linux-tot-20070517.orig/arch/ia64/kernel/process.c	2007-05-17 05:39:54.000000000 -0500
>+++ linux-tot-20070517/arch/ia64/kernel/process.c	2007-05-17 05:44:26.820535382 -0500
>@@ -763,6 +763,9 @@ get_wchan (struct task_struct *p)
> 	unsigned long ip;
> 	int count = 0;
> 
>+	if (!p || p = current || p->state = TASK_RUNNING)
>+		return 0;
>+
> 	/*
> 	 * Note: p may not be a blocked task (it could be current or
> 	 * another process running on some other CPU.  Rather than

AFAICT there is no lock on struct task_struct p that stops it being
scheduled to run after you test if it is running.  proc_task_lookup()
only does get_task_struct() which prevents the task from being deleted,
it does not prevent the task from being scheduled while you are looking
at it.

So even with that check, it can race between not running and running
while you do the unwind, and still get the MCA.

