From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 06 Aug 2003 07:01:40 +0000
Subject: Re: [patch] fix "struct irq_desc"
Message-Id: <marc-linux-ia64-106015430302971@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 6 Aug 2003 16:52:45 +1000, Martin Pool <mbp@samba.org> said:

  Martin> In linux-2.6.0-test2-ia64-030729 configured for generic ia64,
  Martin> asm-ia64/machvec.h returns a 'struct irq_desc'.  There is a forward
  Martin> declaration for the struct, but it is never actually defined under
  Martin> that name, only as irq_desc_t.

  Martin> This means that the type of ia64_mv_irq_desc is wrong, which causes
  Martin> the build to break in some files that are built with -Werror.  Really
  Martin> this is incorrect even for non-generic builds although it does not
  Martin> actually fail.

  Martin> This patch puts in both the struct name and _t name:

  Martin> --- linux-2.6.0test2-ia64/include/linux/irq.h.~1~	2003-07-29 12:05:34.000000000 +1000
  Martin> +++ linux-2.6.0test2-ia64/include/linux/irq.h	2003-08-06 16:33:30.000000000 +1000
  Martin> @@ -56,7 +56,7 @@ typedef struct hw_interrupt_type  hw_irq
  Martin> *
  Martin> * Pad this out to 32 bytes for cache and indexing reasons.
  Martin> */
  Martin> -typedef struct {
  Martin> +typedef struct irq_desc {
  Martin> unsigned int status;		/* IRQ status */
  Martin> hw_irq_controller *handler;
  Martin> struct irqaction *action;	/* IRQ action list */

  Martin> Perhaps it would be better to make everything use the
  Martin> irq_desc_t name?  That would require a somewhat larger
  Martin> rearrangement of the headers to make it visible at that
  Martin> point, but I can do that if desired.

Can you run it past Andrew Morton and see if he accepts this patch?  I
think it makes tons of sense on the grounds that in Linux typedef's
are usually frowned upon (exactly because they can't be
forward-declared).  I dropped that patch a while ago because I thought
it wasn't needed anymore (and I was trying to get sync'd up with
Linus' tree).

	--david
