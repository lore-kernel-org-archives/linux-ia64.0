From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 09 Mar 2005 00:02:06 +0000
Subject: Re: PCI Express
Message-Id: <200503081602.07221.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4228F250.7C5E2E3C@sgi.com>
In-Reply-To: <4228F250.7C5E2E3C@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday, March 8, 2005 3:48 pm, Colin Ngam wrote:
> Well, unfortunately, we do not send IPI by using the Processor Interrupt
> Block. We actually
> target a Special Altix Chipset "IPI Interrupt" register that ends up
> generating an IPI.  That is why, we
> have Platform Specific "send ipi" calls on ia64:
>
> platform_send_ipi()
>   File          Line
> 0 machvec.h     113 #define platform_send_ipi ia64_mv.send_ipi
> 1 machvec.h     282 #define platform_send_ipi ia64_send_ipi
> 2 machvec_sn2.h  86 #define platform_send_ipi sn2_send_IPI
> 3 machvec.h      95 #define platform_send_ipi ia64_mv.send_ipi
> 4 machvec.h     255 #define platform_send_ipi ia64_send_ipi
> 5 machvec_sn2.h  83 #define platform_send_ipi sn2_send_IPI
>
> I do not know why we do not use the Processor Interrupt Block, but I will
> find out.  But this does
> not mean that we cannot use the PIB for MSI.  Ofcourse, it may not be
> relocated at
> 0x0000 0000 FEE0 0000.

That's beside the point though--MSIs don't use IPIs, they just use the 
processor interrupt block, which is also used by IPIs (on non-sn2 platforms).  
If the processor interrupt block works for us (pretty sure it does) MSIs 
targetted there should also work.  The problem for us is if a processor tries 
to IPI a processor on a different node with the processor interrupt block, 
which I don't think MSIs will try to do.

Jesse
