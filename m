From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 12 Mar 2003 06:55:12 +0000
Subject: Re: [Linux-ia64] Memory leak in 2.5.64
Message-Id: <marc-linux-ia64-105590709806052@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806020@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806020@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 10 Mar 2003 19:59:39 -0800, William Lee Irwin III <wli@holomorphy.com> said:

  William> On Tue, Mar 11, 2003 at 02:44:14PM +1100, Peter Chubb
  William> wrote:
  >> The way that tasks need to be freed has changed since 2.5.61 ---
  >> I think we need to do something like the attached patch (keep
  >> __put_task_struct() in kernel/fork.c; have ia64-specific
  >> free_task_struct() in arch/ia64/kernel/process.c) otherwise the
  >> user_struct will never have its reference count deleted and so
  >> will not be freed.

  William> I think you might be in trouble. From entry.S:

  William>         /* * Invoke schedule_tail(task) while preserving
  William> in0-in7, which may be nee ded * in case a system call gets
  William> restarted.  */ GLOBAL_ENTRY(ia64_invoke_schedule_tail)

  William> Well, you're going to need to pass a parameter to
  William> schedule_tail() namely, the previous task, and find some
  William> other way to save in0-in7.  schedule_tail() now relies on
  William> the task getting passed to it to free it.

That's why ia64_invoke_schedule_tail() exists in the first place: the
previously running task is passed in r8.  In other words: no problem.

	--david

