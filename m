From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 15 Jun 2004 04:17:34 +0000
Subject: RE: [PATCH] Kernel panic on IA-64 Linux with SELinux
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F01727AD3@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <013f01c44ddb$636d4aa0$f97d220a@linux.bs1.fc.nec.co.jp>
In-Reply-To: <013f01c44ddb$636d4aa0$f97d220a@linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>> We _could_ do something like this in init_task.c:
>> 
>> void
>> initialize_init_task (void)
>> {
>> *current = (task_t) INIT_TASK((*current));
>> }
>> 
>> and then call this function from setup_arch().
>> 
>> The code does compile but doesn't seem to work.  I suspect there are
>> other lists that are inconsistent now.  Anybody want to track this
>> down?
>
>I have applied this patch to 2.6.6 kernel, and system stall occurred
>while booting up. The problem is in init_mount_tree().
>The init_mount_tree() function uses do_each_thread() macro
>defined as follows:
>
>#define do_each_thread(g, t) \
>        for (g = t = &init_task ; (g = t = next_task(g)) != 
>&init_task ; ) do
>
>The termination condition of this loop is g->tasks.next equals 
>&init_task.
>But g->tasks.next will not refer to &init_task forever,
>because the init_task.task list_head was initialized as the 
>data structure
>in region 7 in spite of &init_task was in region 5.

I managed to take a look at what David's code actually did this
afternoon.  It does manage to fix up all the list_head structures,
but as noted above it messes up the list of all tasks since we
converted to region 7, and now we'll never find a link with the
region 5 address "&init_task".

I also found that the "lock_depth" entry is messed up (because
INIT_TASK resets it to "-1", undoing the "lock_kernel()" call
that start_kernel() did before it called setup_arch().

We could go for a slightly uglier version of initialize_init_task()
that just fixes the list_head elements ... there are only
six of them ... so in one respect this isn't too ugly, but it
would require maintenance every time someone added/removed
a new list from the task structure.

-Tony
