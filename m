From: Colin Ngam <cngam@sgi.com>
Date: Wed, 09 Mar 2005 01:29:06 +0000
Subject: Re: PCI Express
Message-Id: <422E5162.18491A4E@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4228F250.7C5E2E3C@sgi.com>
In-Reply-To: <4228F250.7C5E2E3C@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Colin Ngam wrote:

> Jesse Barnes wrote:
>
> > On Tuesday, March 8, 2005 3:48 pm, Colin Ngam wrote:
> > > Well, unfortunately, we do not send IPI by using the Processor Interrupt
> > > Block. We actually
> > > target a Special Altix Chipset "IPI Interrupt" register that ends up
> > > generating an IPI.  That is why, we
> > > have Platform Specific "send ipi" calls on ia64:
> > >
> > > platform_send_ipi()
> > >   File          Line
> > > 0 machvec.h     113 #define platform_send_ipi ia64_mv.send_ipi
> > > 1 machvec.h     282 #define platform_send_ipi ia64_send_ipi
> > > 2 machvec_sn2.h  86 #define platform_send_ipi sn2_send_IPI
> > > 3 machvec.h      95 #define platform_send_ipi ia64_mv.send_ipi
> > > 4 machvec.h     255 #define platform_send_ipi ia64_send_ipi
> > > 5 machvec_sn2.h  83 #define platform_send_ipi sn2_send_IPI
> > >
> > > I do not know why we do not use the Processor Interrupt Block, but I will
> > > find out.  But this does
> > > not mean that we cannot use the PIB for MSI.  Ofcourse, it may not be
> > > relocated at
> > > 0x0000 0000 FEE0 0000.
>
> Hi Jesse,
>
> >
> >
> > That's beside the point though--MSIs don't use IPIs, they just use the
> > processor interrupt block, which is also used by IPIs (on non-sn2 platforms).
> > If the processor interrupt block works for us (pretty sure it does) MSIs
>
> That's what I will find out before deciding to use it.  It is not used for IPIs
> on our platform, probably for very good reasons.  If we can and the address is
> the same than it is a no brainer.
>
> >
> > targetted there should also work.  The problem for us is if a processor tries
> > to IPI a processor on a different node with the processor interrupt block,
> > which I don't think MSIs will try to do.
>
> Perhaps you can elaborate.  I am not sure what you are trying to say here.
>
> Thanks.
>
> colin
>
> >
> >
> > Jesse

Hi Jesse,

I beleive the reason why we do not use the Processor Interrupt Block for
generating interrupts is because it does not have the range to reach all the nodes
that we can have in the system.

Thanks.

colin

>
>
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

