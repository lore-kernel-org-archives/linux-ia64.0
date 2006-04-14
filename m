From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Fri, 14 Apr 2006 04:37:42 +0000
Subject: Re: Two questions about iosapic code
Message-Id: <443F2716.4040108@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <571ACEFD467F7749BC50E0A98C17CDD8094E7B15@pdsmsx403>
In-Reply-To: <571ACEFD467F7749BC50E0A98C17CDD8094E7B15@pdsmsx403>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Kevin,

Tian, Kevin wrote:
> I'm looking at 2.6.16 code, and not sure whether anyone else 
> already addressed following questions:
> 
> - iosapic_end_level_irq:
> list_for_each_entry(rte, &iosapic_intr_info[vec].rtes, rte_list)
>                 iosapic_eoi(rte->addr, vec);
> 
> If two RTEs are from two different IOSAPIC, above code is 
> meaningful to send two EOI to both IOSAPIC. However if two 
> RTEs are in same IOSAPIC, then EOI are sent to same IOSAPIC 
> twice. Will the 2nd EOI trigger duplicated notifications to CPU if 
> some device has assertion on that irq line once after 1st EOI?
> 

I think it will, though I guess the 1st notification and 2nd
notification might be handled as one interrupt, if 2nd notification
was sent before reading IVR for 1st notification. On the other hand,
2nd interrupt would be handled like spurious interrupt, when 1st one
and 2nd one were handled separately. Anyway, 2nd EOI looks needless
and I think it should be fixed.


> - iosapic_reassign_vector:
> 	It's only called by iosapic_register_platform_intr for PMI by
> far. 
> When designated vector is already occupied, the rte list of that 
> vector will be copied to a new vector. However there's no updates 
> to physical RTEs within IOSAPIC to reflect this change.

IIRC, vectors for PMI are 0 to 15 and any other external interrupts
don't use those vectors. So this code path is executed only if
multiple PMIs use the same vector number. Vector numbers for PMIs
are assigned by firmware, so OS cannot re-assign other vector. I
guess this is why there's no updates to physical RTES. But, I don't
know why we need iosapic_reassing_vector()...

Thanks,
Kenji Kaneshige



> 
> Correct me if my understanding is incorrect, and seems these two 
> corner cases are seldom to be seen...
> 
> Thanks,
> Kevin
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

