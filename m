From: David Mosberger-Tang <David.Mosberger@acm.org>
Date: Fri, 09 Sep 2005 22:33:45 +0000
Subject: Re: [RFC] timer_interrupt: Avoid device timeouts by freezing time if system froze
Message-Id: <ed5aea430509091533d55bdbe@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0509091501240.12956@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0509091501240.12956@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I also would be nervous about the proposed patch.

I'm wondering: could the problem be avoided perhaps by running all
other pending (lower-priority) interrupts first when you detect a
large jump in elapsed time?  In other words, when you detect a jump
from time T1 to T2 with (T2-T1) greater than some threshold, you make
sure you run all pending interrupts while still at time T1 and only
after that is done you let time catch up to T2.

  --david

On 9/9/05, Magenheimer, Dan (HP Labs Fort Collins)
<dan.magenheimer@hp.com> wrote:
> I am aware of at least two ia64 virtualization systems
> that rely on the existing behavior to compensate for
> the fact that one guest linux may be inactive while another
> is active.  This isn't to say that another solution
> couldn't be found, but just turning off the existing
> behavior doesn't seem like a good alternative.
> 
> > -----Original Message-----
> > From: linux-ia64-owner@vger.kernel.org
> > [mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of
> > Christoph Lameter
> > Sent: Friday, September 09, 2005 4:02 PM
> > To: linux-ia64@vger.kernel.org
> > Subject: [RFC] timer_interrupt: Avoid device timeouts by
> > freezing time if system froze
> >
> > In extraordinay circumstances (MCA init/ debugger invocation,
> > hardware problems) the
> > system may not be able to process timer ticks for an extended
> > period of time.
> >
> > The timer interrupt will compensate as soon as the system
> > becomes functional again by
> > calling do_timer for each missed tick. This will cause time
> > to race forward in a very
> > fast way. Device drivers that wait for timeouts will find
> > that the system times out
> > on everything and thus device drivers will conclude that the
> > devices are not in
> > a functional state disabling them. The system then cannot
> > continue from the frozen
> > state because the device drivers have given up.
> >
> > This patch fixes that issue by checking if more than half a
> > second has passed
> > since the last tick. If more than half a second has passed
> > then we would need to do
> > around 500 calls to do_timer to compensate. So in order to
> > avoid these timeouts
> > we act as if time has been frozen with the system and do not
> > compensate for lost time.
> > Device drivers may still find that their outstanding requests
> > have failed but they
> > will be able to reinitialize the device and the system can
> > hopefully continue.
> >
> > A consequence of this patch is that the wall clock will stand
> > still if the no ticks
> > can be processed for more than half a second.
> >
> > Signed-off-by: Christoph Lameter <clameter@sgi.com>
> >
> > Index: linux-2.6.13/arch/ia64/kernel/time.c
> > =================================> > --- linux-2.6.13.orig/arch/ia64/kernel/time.c 2005-08-28
> > 16:41:01.000000000 -0700
> > +++ linux-2.6.13/arch/ia64/kernel/time.c      2005-09-09
> > 14:45:37.000000000 -0700
> > @@ -55,6 +55,7 @@ static irqreturn_t
> >  timer_interrupt (int irq, void *dev_id, struct pt_regs *regs)
> >  {
> >       unsigned long new_itm;
> > +     unsigned long itc;
> >
> >       if (unlikely(cpu_is_offline(smp_processor_id()))) {
> >               return IRQ_HANDLED;
> > @@ -64,10 +65,25 @@ timer_interrupt (int irq, void *dev_id,
> >
> >       new_itm = local_cpu_data->itm_next;
> >
> > -     if (!time_after(ia64_get_itc(), new_itm))
> > +     itc = ia64_get_itc();
> > +     if (!time_after(itc, new_itm))
> >               printk(KERN_ERR "Oops: timer tick before it's
> > due (itc=%lx,itm=%lx)\n",
> >                      ia64_get_itc(), new_itm);
> >
> > +     /*
> > +      * If more than half a second has passed since the last
> > timer interrupt then
> > +      * something significant froze the system. Skip the
> > time adjustments
> > +      * otherwise repeated calls to do_timer will trigger
> > timeouts by devices.
> > +      */
> > +     if (unlikely(time_after(itc, new_itm + HZ /2 *
> > local_cpu_data->itm_delta))) {
> > +             new_itm = itc;
> > +             if (smp_processor_id() = TIME_KEEPER_ID) {
> > +                     time_interpolator_reset();
> > +                     printk(KERN_ERR "Oops: more than 0.5
> > seconds since last tick."
> > +                             "Skipping time adjustments in
> > order to avoid timeouts.\n");
> > +             }
> > +     }
> > +
> >       profile_tick(CPU_PROFILING, regs);
> >
> >       while (1) {
> > -
> > To unsubscribe from this list: send the line "unsubscribe
> > linux-ia64" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


-- 
Mosberger Consulting LLC, voice/fax: 510-744-9372,
http://www.mosberger-consulting.com/
35706 Runckel Lane, Fremont, CA 94536
