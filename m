From: "Kaigai Kohei" <kaigai@ak.jp.nec.com>
Date: Tue, 15 Jun 2004 02:28:14 +0000
Subject: Re: [PATCH] Kernel panic on IA-64 Linux with SELinux
Message-Id: <006f01c45280$69c3aee0$f97d220a@linux.bs1.fc.nec.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <013f01c44ddb$636d4aa0$f97d220a@linux.bs1.fc.nec.co.jp>
In-Reply-To: <013f01c44ddb$636d4aa0$f97d220a@linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello, everyone.

David Mosbeger wrote:

> You're probably right.
> 
> We _could_ do something like this in init_task.c:
> 
> void
> initialize_init_task (void)
> {
> *current = (task_t) INIT_TASK((*current));
> }
> 
> and then call this function from setup_arch().
> 
> The code does compile but doesn't seem to work.  I suspect there are
> other lists that are inconsistent now.  Anybody want to track this
> down?

I have applied this patch to 2.6.6 kernel, and system stall occurred
while booting up. The problem is in init_mount_tree().
The init_mount_tree() function uses do_each_thread() macro
defined as follows:

#define do_each_thread(g, t) \
        for (g = t = &init_task ; (g = t = next_task(g)) != &init_task ; ) do

The termination condition of this loop is g->tasks.next equals &init_task.
But g->tasks.next will not refer to &init_task forever,
because the init_task.task list_head was initialized as the data structure
in region 7 in spite of &init_task was in region 5.

There are similer problems
(The condition of the loop termination depends on &init_task).
- do_each_process() macro       ... in include/linux/sched.h
- is_devfsd_or_child() function ... in fs/devfs/base.c
- get_tgid_list() function      ... in fs/proc/base.c

There are several solutions against this problem.
(1) Initializing only wait_chldexit as my first patch.
(2) Moving current of swapper from region 7 to region 5 as
    Miyoshi's second patch.
(3) Replacing &init_task with task_t *p_init_task which refers to
    init_task in region 7, and refers to init_task directly on other archtectures.

(1) is easy but ad hoc. (3) needs to correct generic code.
(2) is consistent on &init_task is in region 5 and current(r13) for cpu_idle
 refers to region 5. But the number of steps in switch_to() macro will increase. 
 This overhead is not a big problem, I guess.

For reasons already stated I prefer (2). What do you think?

Best Regards, 
--------
Kaigai Kohei, Linux Promotion Center, NEC
E-mail: kaigai@ak.jp.nec.com
