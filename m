From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 04 Feb 2003 01:03:37 +0000
Subject: [Linux-ia64] Re: Preemption patch
Message-Id: <marc-linux-ia64-105590709805807@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 31 Jan 2003 11:42:51 +1100, Peter Chubb <peter@chubb.wattle.id.au> said:

  Peter> The main changes are in entry.S to check the RESCHEDULE flag
  Peter> for kernel threads if preempt_count() is zero, and call
  Peter> schedule() if so.  As my IA64 assembly language skills are
  Peter> shaky, I'd appreciate someone reviewing that bit of code (as
  Peter> it's also performance critical).

I looked over your changes to entry.S and they look fine to me.  The
code probably could be scheduled better, but I assume you're aware of
that and you are focusing on correctness for now.

	--david

