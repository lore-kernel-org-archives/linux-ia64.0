From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 11 Jul 2002 21:50:47 +0000
Subject: [Linux-ia64] Re: switch_mm race condition with Ingo's scheduler
Message-Id: <marc-linux-ia64-105590701905767@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805973@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805973@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 10 Jul 2002 19:27:20 +0200, Erich Focht <efocht@ess.nec.de> said:

  Erich> Hi David, the attached patch fixes the switch_mm ->
  Erich> wrap_mmu_context deadlock which can occur in 2.5.18+ia64. We
  Erich> discussed this in January/February...

The patch basically looks fine to me and I put it in my 2.5 tree with
a few small changes to take advantage of the new per-CPU scheme
(avoids clutter in asm/processor.h).  Also, I think it's sufficient to
call delayed_flush_tlb() in get_new_mmu_context(), as we just need to
make sure that the TLB does get flushed before.  Or did this not work
for some reason?

	--david

