From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 15 Jun 2004 04:23:38 +0000
Subject: Re: [PATCH] Kernel panic on IA-64 Linux with SELinux
Message-Id: <16590.31178.360206.284780@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <013f01c44ddb$636d4aa0$f97d220a@linux.bs1.fc.nec.co.jp>
In-Reply-To: <013f01c44ddb$636d4aa0$f97d220a@linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Kaigai,

Thanks for looking into this issue.

>>>>> On Tue, 15 Jun 2004 11:28:14 +0900, "Kaigai Kohei" <kaigai@ak.jp.nec.com> said:

  Kaigai> I have applied this patch to 2.6.6 kernel, and system stall
  Kaigai> occurred while booting up. The problem is in
  Kaigai> init_mount_tree().  The init_mount_tree() function uses
  Kaigai> do_each_thread() macro defined as follows:

  Kaigai> #define do_each_thread(g, t) \
  Kaigai>   for (g = t = &init_task ; (g = t = next_task(g)) != &init_task ; ) do

Yeah, that'd do it.

  Kaigai> There are several solutions against this problem.

  Kaigai> (1) Initializing only wait_chldexit as my first patch.

  Kaigai> (2) Moving current of swapper from region 7 to region 5 as
  Kaigai> Miyoshi's second patch.

  Kaigai> (3) Replacing &init_task with task_t *p_init_task which
  Kaigai> refers to init_task in region 7, and refers to init_task
  Kaigai> directly on other archtectures.

  Kaigai> (1) is easy but ad hoc. (3) needs to correct generic code.
  Kaigai> (2) is consistent on &init_task is in region 5 and
  Kaigai> current(r13) for cpu_idle refers to region 5. But the number
  Kaigai> of steps in switch_to() macro will increase.  This overhead
  Kaigai> is not a big problem, I guess.

  Kaigai> For reasons already stated I prefer (2). What do you think?

I agree, (2) seems to best solution so far.  It maintains the
invariant that static data will be in region 5.  The extra
instructions should be pretty much free since it should be possible to
schedule them into existing stalls.

Can you resend the tested patch with proper changelog and "Signed-off-by"
trailer?

Thanks,

	--david
