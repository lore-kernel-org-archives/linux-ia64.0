From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 16 Oct 2003 23:57:53 +0000
Subject: Re: load-store emulation with SIGSEGV
Message-Id: <marc-linux-ia64-106634869106973@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106634457403703@msgid-missing>
In-Reply-To: <marc-linux-ia64-106634457403703@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 16 Oct 2003 23:49:20 +0100, "R. Lake" <rich@lakes.plus.com> said:

  Rich> I'm investigating a means of emulating causes of SEGV where
  Rich> they can be isolated from genuine failure. For example, a rule
  Rich> stating a load from address 0x100 "loads" the value 42 into
  Rich> the target register.

  Rich> A simple test to decode the instruction, locate and modify the
  Rich> operand register in the sigcontext or backing store, then
  Rich> increment sc_ip shows the expected behaviour. But, for
  Rich> practical usage I'm not entirely confident I've taken all the
  Rich> necessary steps to return to the kernel in a robust manner.
  Rich> I've thus far taken insight from the unaligned handler albeit
  Rich> without altering the psr.ri field. So, my question is... am I
  Rich> missing a vital stage to this process, some piece of
  Rich> information the kernel expects to receive when avoiding the
  Rich> faulting instruction?

I'm not entirely sure I understand what you're trying to do and
whether you're doing it in the kernel or user (signal-handler).  If
the latter, adjusting the sc_ip should be sufficient (the slot number
is encoded in bits 0 and 1 of sc_ip).

	--david
