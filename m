From: Jiang Liu <jiang.liu@linux.intel.com>
Date: Tue, 02 Jun 2015 05:46:36 +0000
Subject: Re: [v3,33/36] genirq: Use helper function to access irq_data->msi_desc
Message-Id: <556D433C.4040508@linux.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20150602034507.1BBCB1412F1@ozlabs.org>
In-Reply-To: <20150602034507.1BBCB1412F1@ozlabs.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michael Ellerman <mpe@ellerman.id.au>, Thomas Gleixner <tglx@linutronix.de>, Bjorn Helgaas <bhelgaas@google.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Randy Dunlap <rdunlap@infradead.org>, Yinghai Lu <yinghai@kernel.org>, Borislav Petkov <bp@alien8.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Paul Mackerras <paulus@samba.org>, Chris Metcalf <cmetcalf@ezchip.com>, Rusty Russell <rusty@rustcorp.com.au>, Tejun Heo <tj@kernel.org>, Joe Perches <joe@perches.com>
Cc: linux-ia64@vger.kernel.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-pci@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On 2015/6/2 11:45, Michael Ellerman wrote:
> On Mon, 2015-01-06 at 08:05:42 UTC, Jiang Liu wrote:
>> Use irq_data access helper to access irq_data->msi_desc, so we could
>> move msi_desc from struct irq_data into struct irq_common_data later.
>>
>> Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
>> ---
>>  arch/powerpc/sysdev/xics/ics-opal.c |    2 +-
>>  arch/powerpc/sysdev/xics/ics-rtas.c |    2 +-
>>
>> diff --git a/arch/powerpc/sysdev/xics/ics-opal.c b/arch/powerpc/sysdev/xics/ics-opal.c
>> index 3996393c254d..27c936c080a6 100644
>> --- a/arch/powerpc/sysdev/xics/ics-opal.c
>> +++ b/arch/powerpc/sysdev/xics/ics-opal.c
>> @@ -72,7 +72,7 @@ static unsigned int ics_opal_startup(struct irq_data *d)
>>  	 * card, using the MSI mask bits. Firmware doesn't appear to unmask
>>  	 * at that level, so we do it here by hand.
>>  	 */
>> -	if (d->msi_desc)
>> +	if (irq_data_get_msi_desc(d))
>>  		pci_msi_unmask_irq(d);
>>  #endif
>>  
>> diff --git a/arch/powerpc/sysdev/xics/ics-rtas.c b/arch/powerpc/sysdev/xics/ics-rtas.c
>> index e2665a9dfc0f..3854dd41558d 100644
>> --- a/arch/powerpc/sysdev/xics/ics-rtas.c
>> +++ b/arch/powerpc/sysdev/xics/ics-rtas.c
>> @@ -75,7 +75,7 @@ static unsigned int ics_rtas_startup(struct irq_data *d)
>>  	 * card, using the MSI mask bits. Firmware doesn't appear to unmask
>>  	 * at that level, so we do it here by hand.
>>  	 */
>> -	if (d->msi_desc)
>> +	if (irq_data_get_msi_desc(d))
>>  		pci_msi_unmask_irq(d);
>>  #endif
>>  	/* unmask it */
> 
> These look OK.
> 
> Though I would point out we already have 16 irq_foo_get_bar() accessors?!
Hi Michael,
	Thanks for review. We are trying to solve some issues introduced
by hierarchy irqdomain/irqchip by splitting irq_data into a common part
(irq_common_data) and per-chip part(irq_data). These accessors are used
to ease the transition and hide implementation details.
Thanks!
Gerry

> 
> Acked-by: Michael Ellerman <mpe@ellerman.id.au>
> 
> cheers
> 
