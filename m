From: "John Ik Lee \(WA\)" <jlee@platsolns.com>
Date: Mon, 12 Sep 2005 23:36:29 +0000
Subject: RE: [RFC] SAL_MC_RENDEZ logic
Message-Id: <AEBB9AF2F7713A4FAB1397435451162E0197CFEC@spock.invent.psi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <43252738.8030303@jp.fujitsu.com>
In-Reply-To: <43252738.8030303@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

MCA experts,

Itanium 2 processor datasheet mentions about ETM generated CMCI but none
of the PAL/SAL spec/Itanium error handling guide has that info.
PAL_MC_ERROR_INFO/SAL_GET_STATE_INFO for processor errors do not have
any entries related to thermal event.

When CMCI is sent, I presume there's an error record of it.
Where can I find the info of ETM-CMC related error record format/doc?

Itanium 2 processor datasheet reads:
#5.1.2 Enhanced Thermal Management
...Once the thermal sensing device observes the temperature rise above
the thermal entry point, the processor will enter a low power mode of
execution and notify the system by sending a Correctable Machine Check
Interrupt (CMCI). ...

Thanks,
John Ik Lee (J.I.)
Sr. Staff Engineer
Platform Solutions, Inc

-----Original Message-----
From: linux-ia64-owner@vger.kernel.org
[mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Hidetoshi Seto
Sent: Monday, September 12, 2005 1:28 AM
To: Keith Owens
Cc: linux-ia64@vger.kernel.org
Subject: Re: [RFC] SAL_MC_RENDEZ logic

Thank you for your reply, Keith.

Keith Owens wrote:
> The IRR bits are read only.  The OS clears them by reading cr.ivr, in
> the external interrupt vector.  The only reason that mca.c tests IRR
> directly is because at that point interrupts are disabled.

I forgot to mention, the SAL actually reads cr.ivr and writes cr.eoi.

>>I'm not sure but it seems "if any" means that SAL can clear
>>the IRR bits on behalf of OS.  So OS shouldn't expect the IRR
>>always be set on returning from SAL_MC_RENDEZ, is this right?
> 
> The phrase "if any" is quite ambiguous, it is not clear what it means
> here.

I agree.  It should be written in full sentence.

>>I don't know whether there is any old SAL never spins in
>>SAL_MC_RENDEZ or not.  Or is this the beginning of nightmare,
>>having different MCA codes depend on the SAL version?
> 
> I hope not.  In any case my MCA/INIT rewrite removes the spin in mca.c
> waiting for IRR to be set.  Instead the slave comes out of SAL due to
a
> wake up call, waits for the monarch to exit then the slaves all exit.
> 
> Once a slave resumes to its normal context and interrupts are enabled
> again, then the external interrupt vector clears the wake up bit and
> calls ia64_mca_wakeup_int_handler() which is a no-op.  The rendezvous
> IRR bit is cleared when we read cr.ivr prior to calling
> ia64_mca_rendez_int_handler(), i.e. this bit is already clear when we
> rendezvous.
> 
> In your case I would say that SAL is wrong.  I would argue that SAL
> should not be reading cr.ivr at all, it should leave that to the OS.
> The existing (2.6.13) code will not work with that SAL.  My rewrite
> (hopefully in 2.6.14-rc1) will work with that SAL.

I appreciate your work very well.
I'll argue off this problem with developers of the SAL instead of you.

Thanks,
H.Seto

-
To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
