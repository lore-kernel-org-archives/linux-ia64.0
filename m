From: Erich Focht <efocht@ess.nec.de>
Date: Tue, 05 Nov 2002 11:35:35 +0000
Subject: [Linux-ia64] Re: O(1) scheduler fix for 2.5-ia64
Message-Id: <marc-linux-ia64-105590709805333@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805332@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805332@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 05 November 2002 01:22, David Mosberger wrote:
> >>>>> On Mon, 4 Nov 2002 19:53:07 +0100, Erich Focht <efocht@ess.nec.de>
> >>>>> said:
>
>   Erich> Hi David, this problem is wellknown and I actually thought
>   Erich> that it was solved. But it looks like the complex
>   Erich> prepare_arch_switch() etc. macros didn't make it into the 2.5
>   Erich> kernels for IA64. They are needed on IA64 because we have to
>   Erich> release the runqueue lock during context switch. This is
>   Erich> similar to sparc64. Thanks to John Hawks for noticing this.
>
> Yes, this seems to have fallen through the cracks.  Can you remind me
> what the deadlock scenario looked like?

This can happen when the runqueue lock is held during a context switch
which requires wrapping around the context numbers:

Example:
CPU#0:
schedule()
   -> spin_lock_irq(&rq->lock)
   -> context_switch()
      -> wrap_mmu_context()
         -> read_lock(&tasklist_lock)


CPU#1:
sys_wait4() or release_task() or forget_original_parent()
   -> write_lock(&tasklist_lock)
   -> do_notify_parent()
      -> wake_up_parent()
         -> try_to_wake_up()
            -> spin_lock_irq(&parent_rq->lock)

If the parent's rq happens to be on CPU#0, we'll wait for the rq->lock
of that CPU which will not be released, because there we wait for the
tasklist_lock to become available.

Regards,
Erich


