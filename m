From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 21 Mar 2003 19:45:22 +0000
Subject: Re: [Linux-ia64] show_trace_task portability
Message-Id: <marc-linux-ia64-105590723705285@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705283@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705283@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Vladimir,

>>>>> On Fri, 21 Mar 2003 12:36:23 +0300, Vladimir Simonov <sv@sw.com.sg> said:

  Vladimir> Hi!  Trying to port some patches from i386 to ia64 I've
  Vladimir> found that show_trace_task is the only portable way to
  Vladimir> show tasks' call traces(perhaps because it is called from
  Vladimir> ./kernel/sched.c:)).  But its ia64 implementation can't
  Vladimir> work with running task.

  Vladimir> Attached patch fixes this issue.

  Vladimir> As I understand show_trace and show_stack are platform
  Vladimir> dependent or have different sense/args.

  Vladimir> Any opinion?

The patch looks fine to me.  I applied it in the 2.5 tree.

Thanks,

	--david

