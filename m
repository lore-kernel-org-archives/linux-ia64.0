From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 12 Jul 2002 17:02:43 +0000
Subject: [Linux-ia64] Re: switch_mm race condition with Ingo's scheduler
Message-Id: <marc-linux-ia64-105590701905770@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805973@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805973@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 12 Jul 2002 18:47:58 +0200, Erich Focht <efocht@ess.nec.de> said:

  Erich> But then other processors would continue using the old TLBs
  Erich> maybe of tasks which died. The problem is that we need to do
  Erich> a TLB flush on all CPUs when wrapping around the
  Erich> context. Otherwise we might reuse the context number of a
  Erich> recently exited process and on other CPUs some of its TLB
  Erich> entries may survive until the new task switches CPUs. Hard to
  Erich> debug, probably...

But the only time you might reuse an old context number is when you
allocate one.  Yes, you will have old entries hanging around in the
TLB for a while, but you _know_ that the corresponding tasks already
died and you also know that you'll flush the TLB before re-using one
of those context numbers.

	--david

