From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Wed, 16 Apr 2003 16:09:36 +0000
Subject: Re: [Linux-ia64] show_trace_task portability
Message-Id: <marc-linux-ia64-105590723705511@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705283@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705283@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday 21 March 2003 2:36 am, Vladimir Simonov wrote:
> Hi!
> Trying to port some patches from i386 to ia64 I've found that
> show_trace_task is the only portable way to show tasks' call
> traces(perhaps because it is called from ./kernel/sched.c:)).
> But its ia64 implementation can't work with running task.
> 
> Attached patch fixes this issue.

I applied this for 2.4.

Bjorn


