From: "Tian, Kevin" <kevin.tian@intel.com>
Date: Thu, 13 Apr 2006 09:23:21 +0000
Subject: Two questions about iosapic code
Message-Id: <571ACEFD467F7749BC50E0A98C17CDD8094E7B15@pdsmsx403>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm looking at 2.6.16 code, and not sure whether anyone else 
already addressed following questions:

- iosapic_end_level_irq:
list_for_each_entry(rte, &iosapic_intr_info[vec].rtes, rte_list)
                iosapic_eoi(rte->addr, vec);

If two RTEs are from two different IOSAPIC, above code is 
meaningful to send two EOI to both IOSAPIC. However if two 
RTEs are in same IOSAPIC, then EOI are sent to same IOSAPIC 
twice. Will the 2nd EOI trigger duplicated notifications to CPU if 
some device has assertion on that irq line once after 1st EOI?

- iosapic_reassign_vector:
	It's only called by iosapic_register_platform_intr for PMI by
far. 
When designated vector is already occupied, the rte list of that 
vector will be copied to a new vector. However there's no updates 
to physical RTEs within IOSAPIC to reflect this change.

Correct me if my understanding is incorrect, and seems these two 
corner cases are seldom to be seen...

Thanks,
Kevin
