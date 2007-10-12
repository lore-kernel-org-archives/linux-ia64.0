From: Fenghua Yu <fenghua.yu@intel.com>
Date: Fri, 12 Oct 2007 22:15:06 +0000
Subject: Re: [RFC patch] use thread.on_ustack to determine if on user stack
Message-Id: <20071012221506.GA7194@linux-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0709290053s7b4e80b6t9e7127b9ccac522b@mail.gmail.com>
In-Reply-To: <3877989d0709290053s7b4e80b6t9e7127b9ccac522b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 9/29/07, Luming Yu <luming.yu@gmail.com> wrote:
>Hello list,

>The PSR.lp bit of kernel thread kondemand sometimes would be set, then
>causes set_pstate PAL call fails with invalid argument. I tracked down
>to the place that the PSR.lp was set in do_notify_resume_user. I don't
>understand why not use task->thread.on_ustack to
>check if on user stack.in the first place. For optimization?

The reason for not using on_ustack is because stack in fsys is a mixture of
kernel states and user states. on_ustack is not a correct way to reflect fsys
stack usage. It's cleared to 0 during fsys which can not be explained as it's
not user stack.

The current implementation of checking user_stack() is correct. Though it would
be better to change user_stack()'s name to something like fsys_stack() to avoid
future confusion.

The patch actually always makes user_stack()=0 and fsys_mode()=0 during fsys
execution. Thus there is no psr.lp=1 during fsys execution. And signal is always
delivered during fsys execution.This masks the "Transition failure" issue
instead of fixing it. The patch might cause issues in some stress tests.

Could you please provide more debug info on the issue?

Thanks.

-Fenghua
