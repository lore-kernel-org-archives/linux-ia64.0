From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 07 Sep 2000 18:35:39 +0000
Subject: Re: [Linux-ia64] [PATCH] Hundred percent system time
Message-Id: <marc-linux-ia64-105590678205463@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205462@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205462@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 07 Sep 2000 14:12:28 -0400, "Pat O'Rourke" <orourke@mclinux.com> said:

  Pat> vmstat(8) was showing 100% system time on an "idle" system.
  Pat> The problem is that irq_enter() was being called twice for each
  Pat> clock interrupt; once in handle_IRQ_event() and a second time
  Pat> in smp_do_timer():

Yes, you are right.  This bug was introduced with test7 and, on the
x86 side, has been fixed with test8-preXX.  The patch looks fine.

	--david

