From: Colin Ngam <cngam@sgi.com>
Date: Tue, 08 Mar 2005 23:48:56 +0000
Subject: Re: PCI Express
Message-Id: <422E39E7.2A0666EA@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4228F250.7C5E2E3C@sgi.com>
In-Reply-To: <4228F250.7C5E2E3C@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"Nguyen, Tom L" wrote:

> On Monday, March 07, 2005 8:41 PM Colin wrote:
> > On Altix systems, we have a set of "Interrupt Registers" in Memory
> Address
> > Space that is initialized to target specific CPUs.  The way we
> > initialize a card's MSI is:
> >
> > 1.  The Target Address is One of these "Interrupt Registers"
> > 2.  The Data Payload is the IRQ plus some special Altix bits.
> >
> > This memory write causes the "Interrupt Chipset" to generate a LINTR
> > message to the configured targeted cpu with the IRQ.  Ofcourse, these
> > registers are Altix Platform specific.  Moreover, we have chunks of
> these
> > registers all over the place.
>
> Your solution is Altix chipset specific. MSI affects other architectures
> too. General solution would almost certainly be a better one.

Hi All,

Yes it is and we are looking for a generic solution.

>
>
> > Is there a more direct mechanism to generate an interrupt(LINTR
> Message)
> > to a Processor?
>
> I agree with Jesse's comment.

Well, unfortunately, we do not send IPI by using the Processor Interrupt Block.
We actually
target a Special Altix Chipset "IPI Interrupt" register that ends up generating
an IPI.  That is why, we
have Platform Specific "send ipi" calls on ia64:

platform_send_ipi()
  File          Line
0 machvec.h     113 #define platform_send_ipi ia64_mv.send_ipi
1 machvec.h     282 #define platform_send_ipi ia64_send_ipi
2 machvec_sn2.h  86 #define platform_send_ipi sn2_send_IPI
3 machvec.h      95 #define platform_send_ipi ia64_mv.send_ipi
4 machvec.h     255 #define platform_send_ipi ia64_send_ipi
5 machvec_sn2.h  83 #define platform_send_ipi sn2_send_IPI

I do not know why we do not use the Processor Interrupt Block, but I will find
out.  But this does
not mean that we cannot use the PIB for MSI.  Ofcourse, it may not be relocated
at
0x0000 0000 FEE0 0000.

>
>
> > With Altix, it's always interesting, with respect to "just work" with
> > typical ia64 code base.  Hopefully, it will work cleaner compared to
> > some of our other efforts.
> >
> > Are you the maintainer for the MSI code?
>
> I suggest you move any discussion or any proposed changes to LKML
> because MSI affects other architectures too. Again, general solution
> would almost certainly be a better one.

We will.  We are looking for a general solution.

We will start looking through the MSI code see how best we can implement
this functionality to support Altix platform.  At that point we will post to
lkml for guidance.

Thanks.

colin

>
>
> Thanks,
> Long
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

