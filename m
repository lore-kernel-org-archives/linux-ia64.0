From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Fri, 16 Jul 2004 15:48:21 +0000
Subject: Re: [PATCH] Vector sharing (Large I/O system support)
Message-Id: <40F7F8C5.7030501@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40F5E291.7050803@jp.fujitsu.com>
In-Reply-To: <40F5E291.7050803@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Grant,

> The patch uses "pin" to describe IOSAPIC inputs.
> Doesn't PCI use "pin" to describe PCI device IRQ outputs?
> I'm wondering if it's just me who's confused (likely).

As you mentioned, it might be confused with PCI interrupt pin.
So I'll use "rte" instead of "pin".

> It's not obvious to me why both pin_head and pin are necessary.
> "struct iosapic_pin" includes a list_head definition.
> Would pin.pin_list be sufficient as list head?

If we use pin.pin_list as a list head, iosapic_pin included
in iosapic_intr_info needs to be handled outside of
'list_for_each_entry' loop separately. I don't like it. This
is why both pin_head and pin are in iosapic_intr_info.

> BTW, one could avoid the pin/line confusion by naming the above "irte_list"
> or something like that. This all directly deals with programming the
> IOSAPIC irte.

I think it's a good idea.

>>-} iosapic_intr_info[IA64_NUM_VECTORS];
>>+	unsigned char	type	: 1;	/* Vector type */
>>+} iosapic_intr_info[IA64_NUM_VECTORS] __cacheline_aligned;
> 
> > Do you have any data showing accesses to iosapic_intr_info is
> ping-ponging between CPUs?
> 
> I mostly see read-only access and don't think that will cause
> such ping-pong behaviour.

Actually I don't have any data ;-(.
As you mentioned, almost all access to iosapic_intr_info are
read-only. So this change is not necessary.

Thanks,
Kenji Kaneshige

Grant Grundler wrote:
> On Thu, Jul 15, 2004 at 10:49:05AM +0900, Kenji Kaneshige wrote:
> 
>>Hi,
>>
>>Current ia64 linux cannot handle greater than 184 interrupt
>>sources because of the lack of vectors. The following patch
>>enables ia64 linux to handle greater than 184 interrupt sources
>>by allowing the same vector number to be shared by multiple
>>IOSAPIC's RTEs.
> 
> 
> Kenji,
> Some questions about this patch.
> 
> The patch uses "pin" to describe IOSAPIC inputs.
> Doesn't PCI use "pin" to describe PCI device IRQ outputs?
> I'm wondering if it's just me who's confused (likely).
> 
> ...
> 
>>diff -Naurp linux-2.6.8-rc1/arch/ia64/kernel/iosapic.c linux-2.6.8-rc1-changed/arch/ia64/kernel/iosapic.c
>>--- linux-2.6.8-rc1/arch/ia64/kernel/iosapic.c	2004-07-14 15:07:23.811416574 +0900
>>+++ linux-2.6.8-rc1-changed/arch/ia64/kernel/iosapic.c	2004-07-14 15:08:02.630001886 +0900
>>@@ -103,15 +103,23 @@ static spinlock_t iosapic_lock = SPIN_LO
>> 
>> /* These tables map IA-64 vectors to the IOSAPIC pin that generates this vector. */
>> 
>>-static struct iosapic_intr_info {
>>+struct iosapic_pin {
>>+	struct list_head pin_list;	/* IOSAPIC pins which share the same vector */
>> 	char		*addr;		/* base address of IOSAPIC */
>>-	u32		low32;		/* current value of low word of Redirection table entry */
>> 	unsigned int	gsi_base;	/* first GSI assigned to this IOSAPIC */
>>-	char		rte_index;	/* IOSAPIC RTE index (-1 => not an IOSAPIC interrupt) */
>>+	char		rte_index;	/* IOSAPIC RTE index */
>>+};
>>+
>>+static struct iosapic_intr_info {
>>+	struct list_head pin_head;	/* List head of IOSAPIC pins */
>>+	struct iosapic_pin pin;		/* First entry of IOSAPIC pins list */
> 
> 
> It's not obvious to me why both pin_head and pin are necessary.
> "struct iosapic_pin" includes a list_head definition.
> Would pin.pin_list be sufficient as list head?
> 
> BTW, one could avoid the pin/line confusion by naming the above "irte_list"
> or something like that. This all directly deals with programming the
> IOSAPIC irte.
> 
> 
>>-} iosapic_intr_info[IA64_NUM_VECTORS];
>>+	unsigned char	type	: 1;	/* Vector type */
>>+} iosapic_intr_info[IA64_NUM_VECTORS] __cacheline_aligned;
> 
> 
> Do you have any data showing accesses to iosapic_intr_info is
> ping-ponging between CPUs?
> 
> I mostly see read-only access and don't think that will cause
> such ping-pong behaviour.
> 
> 
> thanks,
> grant
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

