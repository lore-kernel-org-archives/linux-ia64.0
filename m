From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 26 Mar 2005 08:38:46 +0000
Subject: Re: Can't unwind through dispatch_illegal_op_fault
Message-Id: <16965.8086.78634.396687@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1111801791.498.151.camel@localhost.localdomain>
In-Reply-To: <1111801791.498.151.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 25 Mar 2005 18:49:51 -0700, Bob Montgomery <bob.montgomery@hp.com> said:

  Bob> I accidentally discovered that another good way for my buncho
  Bob> crash test module to oops the system is to mov from ar.bspstore
  Bob> without zeroing the mode bits on ar.rsc.  The resulting illegal
  Bob> op doesn't unwind past dispatch_illegal_op_fault.

  Bob> I'm testing on a 2.6.10 based system (with other patches), and
  Bob> get the following oops message, stopping at
  Bob> dispatch_illegal_op_fault.  Is this a quick question for the
  Bob> ivt.S folks, or should I prepare a test module for a stock
  Bob> kernel?

Ah, dispatch_illegal_op_fault() is an oddball since after calling
ia64_illegal_op_fault() it does some other work and returns to
ia64_leave_kernel only at that point.  Because of that, it
needs to have unwind info.  Hopefully all that it needs is
a PT_REGS_UNWIND_INFO(0) after SAVE_REST.

	--david
