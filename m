From: Robin Holt <holt@sgi.com>
Date: Sat, 19 May 2007 02:08:32 +0000
Subject: Re: [PATCH] get_wchan on running task sometimes MCAs the machine.
Message-Id: <20070519020832.GA26643@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070517111651.GA760@lnx-holt.americas.sgi.com>
In-Reply-To: <20070517111651.GA760@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, May 18, 2007 at 04:01:21PM -0700, Luck, Tony wrote:
> If the problem *only* occurs when trying to get_wchan on the
> current task (a futile endevour) then the original patch
> should be fine all by itself ... there are no races involved
> the current task is going to remain in TASK_RUNNING state at
> any point that it happens to look at itself.

The problem I was seeing was only on the current task, but we could
have two seperate threads creating that situation.  I could certain see
the argument for adding the sanity checks to the current unwind code or
verifying that libunwind does not suffer the same race conditions.

I will leave it to your discretion.

Thanks,
Robin
