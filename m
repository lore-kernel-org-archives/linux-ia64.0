From: Michael Schmitz <schmitzmic@gmail.com>
Date: Tue, 28 Feb 2023 19:18:59 +0000
Subject: Re: [PATCH 08/10] parisc: fix livelock in uaccess
Message-Id: <f619e8ce-1fce-ace9-3685-e0b50646e8fb@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Y9lz6yk113LmC9SI@ZenIV> <Y9l0w4M91DwYLO3N@ZenIV>
 <20230228152236.GA4088022@roeck-us.net>
In-Reply-To: <20230228152236.GA4088022@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Guenter Roeck <linux@roeck-us.net>, Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-m68k@lists.linux-m68k.org, Michal Simek <monstr@monstr.eu>, Dinh Nguyen <dinguyen@kernel.org>, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org, sparclinux@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

Guenter,

On 1/03/23 04:22, Guenter Roeck wrote:
> On Tue, Jan 31, 2023 at 08:06:27PM +0000, Al Viro wrote:
>> parisc equivalent of 26178ec11ef3 "x86: mm: consolidate VM_FAULT_RETRY handling"
>> If e.g. get_user() triggers a page fault and a fatal signal is caught, we might
>> end up with handle_mm_fault() returning VM_FAULT_RETRY and not doing anything
>> to page tables.  In such case we must *not* return to the faulting insn -
>> that would repeat the entire thing without making any progress; what we need
>> instead is to treat that as failed (user) memory access.
>>
>> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
>> ---
>>   arch/parisc/mm/fault.c | 5 ++++-
>>   1 file changed, 4 insertions(+), 1 deletion(-)
>>
>> diff --git a/arch/parisc/mm/fault.c b/arch/parisc/mm/fault.c
>> index 869204e97ec9..bb30ff6a3e19 100644
>> --- a/arch/parisc/mm/fault.c
>> +++ b/arch/parisc/mm/fault.c
>> @@ -308,8 +308,11 @@ void do_page_fault(struct pt_regs *regs, unsigned long code,
>>   
>>   	fault = handle_mm_fault(vma, address, flags, regs);
>>   
>> -	if (fault_signal_pending(fault, regs))
>> +	if (fault_signal_pending(fault, regs)) {
>> +		if (!user_mode(regs))
>> +			goto no_context;
> 0-day rightfully complains that this leaves 'msg' uninitialized.
>
> arch/parisc/mm/fault.c:427 do_page_fault() error: uninitialized symbol 'msg'
>
> Guenter

What happens if you initialize msg to "Page fault: no context" right at 
the start of do_page_fault (and drop the assignment a few lines down as 
that's now redundant)?

(Wondering if the zero page access on parisc could cause a trip right 
back into do_page_fault, ad infinitum...)

Cheers,

     Michael


>>   		return;
>> +	}
>>   
>>   	/* The fault is fully completed (including releasing mmap lock) */
>>   	if (fault & VM_FAULT_COMPLETED)
