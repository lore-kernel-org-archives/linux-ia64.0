From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 12 Mar 2003 06:53:02 +0000
Subject: [Linux-ia64] Re: Memory leak in 2.5.64
Message-Id: <marc-linux-ia64-105590709806051@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 11 Mar 2003 14:44:14 +1100, Peter Chubb <peter@chubb.wattle.id.au> said:

  Peter> Hi David, The way that tasks need to be freed has changed
  Peter> since 2.5.61 --- I think we need to do something like the
  Peter> attached patch (keep __put_task_struct() in kernel/fork.c;
  Peter> have ia64-specific free_task_struct() in
  Peter> arch/ia64/kernel/process.c) otherwise the user_struct will
  Peter> never have its reference count deleted and so will not be
  Peter> freed.

Yes, indeed.  The patch basically looks good to me, except it
shouldn't say CONFIG_IA64.  The choice of whether or not thread_info
and task_struct should be allocated in one chunk should be a general
platform-choice.  There really isn't anything ia64-specific about it.

	--david

