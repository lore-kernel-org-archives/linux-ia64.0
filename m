From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 18 May 2007 23:01:21 +0000
Subject: RE: [PATCH] get_wchan on running task sometimes MCAs the machine.
Message-Id: <617E1C2C70743745A92448908E030B2A017BCB36@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070517111651.GA760@lnx-holt.americas.sgi.com>
In-Reply-To: <20070517111651.GA760@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

If the problem *only* occurs when trying to get_wchan on the
current task (a futile endevour) then the original patch
should be fine all by itself ... there are no races involved
the current task is going to remain in TASK_RUNNING state at
any point that it happens to look at itself.

A quick scan of my e-mail archives shows an updated libunwind
patch from you dated August 2005 ... which is a lot more than
a couple of months ago :-) I assume that I've missed some more
recent posting. 

-Tony
