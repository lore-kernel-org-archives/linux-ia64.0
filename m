From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 12 Jul 2002 17:37:47 +0000
Subject: [Linux-ia64] Re: switch_mm race condition with Ingo's scheduler
Message-Id: <marc-linux-ia64-105590701905772@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805973@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805973@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 12 Jul 2002 19:26:07 +0200, Erich Focht <efocht@ess.nec.de> said:

  Erich> get_new_mmu_context is called on the CPU where task 123 is
  Erich> scheduled first.  We can flush TLB there. But on the other
  Erich> CPUs the stale entries of task 100 survive. If no new context
  Erich> is needed before task 123 gets migrated to another CPU, it
  Erich> might reuse TLB entries of task 100, which are wrong.  I'm
  Erich> not worried about taking an old context number but of using
  Erich> old TLB entries when my newly created task with reused
  Erich> context number switches CPUs. flush_tlb_all() was flushing
  Erich> all TLB entries by sending an IPI but this can lead to a
  Erich> deadlock... Do I misunderstand something?

Ah, I see now what you mean.  Yes, you're right it could happen that
we allocate a context number for a task on one CPU, task gets
rescheduled, and then we have to flush the TLB when activating the
context number.

	--david

