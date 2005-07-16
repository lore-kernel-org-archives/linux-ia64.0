From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Sat, 16 Jul 2005 01:07:51 +0000
Subject: Re: [RFC][patch 3/10] Multiple vector domain support - introduce
Message-Id: <42D85DE7.3060600@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42D62F3E.2090609@jp.fujitsu.com>
In-Reply-To: <42D62F3E.2090609@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Ashok,

Thank you for comments.

>>+
>>+	/*
>>+	 * Make special mapping between per CPU IRQs and GSVs
>>+	 */
>>+	for (gsv = 0; gsv < NR_GSVS; gsv++) {
>>+		vec = gsv_to_vector(gsv);
>>+		if (vec < IA64_FIRST_DEVICE_VECTOR ||
>>+		    vec > IA64_LAST_DEVICE_VECTOR) {
>>+			ia64_gsv_to_irq_map[gsv] = vec;
>>+			ia64_irq_to_gsv_map[vec] = vec;
> 
> 
> Should the above be = gsv instead of vec?
> 
>>+			ia64_irq_to_gsv_map[vec] = vec;
> 
> ---------------------------------------------------^^^^

I did this by intent, but we can also use "= gsv" instead
of "= vec".
In my patch, all per CPU interrupts are mapped to the same
IRQ regardless of what domain the cpu belongs to. So multiple
gsvs are mappied to one IRQ for per CPU interrupts.


>>+/*
>>+ * Convert global system vector to the corresponding IRQ.
>>+ */
>>+static inline int
>>+gsv_to_irq (unsigned int gsv)
>>+{
>>+	if (gsv > NR_GSVS)
> 
> 
> Should the above be (gsv >= NR_GSVS)?? 
> 

Yes, it's a bug.
Thank you for finding this out.

Thanks,
Kenji Kaneshige

