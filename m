From: Roland McGrath <roland@redhat.com>
Date: Thu, 28 Feb 2008 08:33:24 +0000
Subject: Re: [PATCH 1/4] IA64 regset: 64-bit support - takes 2
Message-Id: <20080228083324.278AE2700FD@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1204186169.11494.16.camel@sli10-desk.sh.intel.com>
In-Reply-To: <1204186169.11494.16.camel@sli10-desk.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> +static int
> +gpregs_writeback(struct task_struct *target,
> +		 const struct user_regset *regset,
> +		 int now)
> +{
> +	if (test_and_set_tsk_thread_flag(current, TIF_RESTORE_RSE))
> +		return 0;
> +	tsk_set_notify_resume(current);

target, not current.


Thanks,
Roland
