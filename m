From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 20 Nov 2003 02:39:40 +0000
Subject: Re: Problems using psr.dd
Message-Id: <marc-linux-ia64-106929606629827@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106879020623297@msgid-missing>
In-Reply-To: <marc-linux-ia64-106879020623297@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 14 Nov 2003 17:09:15 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> I am unable to successfully use psr.dd on 2.4 and 2.6
  Keith> kernels.  The patches below plus the debug.c module
  Keith> demonstrate the problem.  do_trap29() sets regs->cr_ipsr.dd
  Keith> and returns.  The kernel drops through ia64_leave_kernel,
  Keith> loads the modified ipsr and does rfi.  However the same debug
  Keith> fault occurs again, as if psr.dd were being ignored.

  Keith> What am I missing?

Did you find the answer already?

I'm wondering if the problem would still occurr if the
debug-fault-triggering memory access was in a function with an empty
register frame.

	--david
