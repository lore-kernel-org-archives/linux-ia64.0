From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 21 Sep 2001 15:44:18 +0000
Subject: Re: [Linux-ia64] AT Keyboard not present?
Message-Id: <marc-linux-ia64-105590698805237@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805137@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805137@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Richard,

Some good hunting!

>>>>> On Thu, 20 Sep 2001 23:56:25 +0100, Richard Hirst <rhirst@linuxcare.com> said:

  Richard> Turns out the interrupt isn't lost, it is just held off
  Richard> until the previous one has been completely serviced...

  Richard>   User hits CapsLock
  Richard>   CPU enters arch/ia64/kernel/irq_ia64.c:ia64_handle_irq()
  Richard>   which calls arch/ia64/kernel/irq.c:do_IRQ()
  Richard>   which calls the kb interrupt handler
  Richard>   and then do_IRQ() sees local_softirq_pending() and calls
  Richard> do_softirq()
  Richard>   that will run the keyboard tasklet, which calls
  Richard> drivers/char/pc_keyb.c:pckbd_leds()
  Richard>   pckbd_leds() calls send_data() which expects the kb to
  Richard> generate interrupts
  Richard>   those interrupts can't happen because we havn't yet
  Richard> returned to ia64_handle_irq() and called ia64_eoi() for the
  Richard> last one
  Richard> eventually send_data() gives up and returns, we unwind and
  Richard> call ia64_eio() and the keyboard interrupts.

Ah, yes, this makes tons of sense.

  Richard> I'm guessing that ia64_eoi() is needed before the next k/b
  Richard> int can happen, but it sounds logical.

Yes, that's what we used to do until the softirq-rewrite happened in
2.4.7.

  Richard> The answer _might_ be to move the call to do_softirq() from
  Richard> the end of do_IRQ() to the end of ia64_handle_irq().  I've
  Richard> tried that, and it works, but I don't claim to know the
  Richard> ia64 interrupt h/w or s/w, so there may be nasty
  Richard> side-effects.  Calling do_softirq() only once all pending
  Richard> ints have been completely serviced sounds more correct to
  Richard> me anyway.

That's probably the best thing to do for now.  For 2.5, the idea is to
have a single, platform-independent irq.c and for this reason, I'm
trying to keep the ia64 version as close to the x86 version as
possible.  But this obviously is something that needs to be changed.

Thanks,

	--david

