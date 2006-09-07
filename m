From: Takao Indoh <indou.takao@jp.fujitsu.com>
Date: Thu, 07 Sep 2006 01:18:37 +0000
Subject: Re: [Fastboot] [PATCH]IA64 kexec/kdump patch for INIT
Message-Id: <82C6D21B8B7A9Cindou.takao@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 7 Sep 2006 08:57:13 +0800, "Zou, Nanhai" wrote:

>> On Wed, 06 Sep 2006 18:06:53 +0900, Takao Indoh wrote:
>> 
>> >>>+		/* change region of gp to region5 */
>> >>>+		asm volatile ("movl gp=__gp"::: "memory");
>> >>
>> >>Why?  gp is already pointing at the kernel code before we enter
>> >>ia64_init_handler().
>> >
>> >The purpose of this code is just changing region of gp from region7 to
>> >region5. For example, if gp is e000000004ace170, I want to change gp to
>>                                 ~~~~~~~~~~~~~~~~e000000000ace170
>> Sorry, I mistook address...
>> 
>> 
>> Regards,
>> Takao Indoh
>> 
>  You don't need to set gp here. Control page does not use GP, and 
>purgatory code will set GP to a physical address which was pre-calculated 
>at the time of crash kernel loading.

If gp points region7, panic occurs at kdump_disable_iosapic.

kdump_disable_iosapic(void)
{
	u32 low32;
	struct iosapic_intr_info *info;
	struct iosapic_rte_info *rte;
	for (info = iosapic_intr_info; info <
			iosapic_intr_info + IA64_NUM_VECTORS; ++info) {
		low32 = info->low32 |= IOSAPIC_MASK;
		list_for_each_entry(rte, &info->rtes,
				rte_list) {
(snip)

The panic occurs at list_for_each_entry. When I found this problem,
&info->rtes and rte->rte_list pointed same data but they had different
address.

&info->rtes   => 0xe0000000049231e0
rte->rte_list => 0xa0000001009231e0

info->rtes points region7 because its address is calculated from gp.
This difference of address caused panic.

Regards,
Takao Indoh

