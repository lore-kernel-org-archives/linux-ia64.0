From: Richard Hirst <rhirst@linuxcare.com>
Date: Thu, 20 Sep 2001 22:56:25 +0000
Subject: Re: [Linux-ia64] AT Keyboard not present?
Message-Id: <marc-linux-ia64-105590698805233@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805137@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805137@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Sep 19, 2001 at 02:49:28PM -0700, David Mosberger wrote:
> Glad to see you're making progress on this, but the patch looks
> suspicious to me.  There shouldn't be anything ia64 specific in this
> code.  It would be good to understand why the keyboard interrupt gets
> lost.

Turns out the interrupt isn't lost, it is just held off until the
previous one has been completely serviced...

  User hits CapsLock
  
  CPU enters arch/ia64/kernel/irq_ia64.c:ia64_handle_irq()
  
  which calls arch/ia64/kernel/irq.c:do_IRQ()
  
  which calls the kb interrupt handler
  
  and then do_IRQ() sees local_softirq_pending() and calls do_softirq()
  
  that will run the keyboard tasklet, which calls
  drivers/char/pc_keyb.c:pckbd_leds()
  
  pckbd_leds() calls send_data() which expects the kb to generate interrupts
  
  those interrupts can't happen because we havn't yet returned to
  ia64_handle_irq() and called ia64_eoi() for the last one

eventually send_data() gives up and returns, we unwind and call ia64_eio()
and the keyboard interrupts.

I'm guessing that ia64_eoi() is needed before the next k/b int can
happen, but it sounds logical.

The answer _might_ be to move the call to do_softirq() from the end of
do_IRQ() to the end of ia64_handle_irq().  I've tried that, and it works,
but I don't claim to know the ia64 interrupt h/w or s/w, so there may
be nasty side-effects.  Calling do_softirq() only once all pending ints
have been completely serviced sounds more correct to me anyway.

Richard


