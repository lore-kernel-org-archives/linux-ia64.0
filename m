From: Randy Dunlap <rdunlap@infradead.org>
Date: Sun, 26 Sep 2021 17:10:09 +0000
Subject: Re: [PATCH] ia64: don't do IA64_CMPXCHG_DEBUG without CONFIG_PRINTK
Message-Id: <bf2568fa-86ae-79d5-750b-76d76d233126@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210926063325.13581-1-rdunlap@infradead.org>
 <6ee982ca-6b99-da23-ec60-97ca2c317bd5@physik.fu-berlin.de>
In-Reply-To: <6ee982ca-6b99-da23-ec60-97ca2c317bd5@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, linux-kernel@vger.kernel.org
Cc: linux-ia64@vger.kernel.org, Petr Mladek <pmladek@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Chris Down <chris@chrisdown.name>

On 9/26/21 2:10 AM, John Paul Adrian Glaubitz wrote:
> Hi Randy!
> 
> On 9/26/21 08:33, Randy Dunlap wrote:
>> When CONFIG_PRINTK is not set, the CMPXCHG_BUGCHECK() macro calls
>> _printk(), but _printk() is a static inline function, not available
>> as an extern.
>> Since the purpose of the macro is to print the BUGCHECK info,
>> make this config option depend on PRINTK.
>>
>> Fixes multiple occurrences of this build error:
>>
>> ../include/linux/printk.h:208:5: error: static declaration of '_printk' follows non-static declaration
>>    208 | int _printk(const char *s, ...)
>>        |     ^~~~~~~
>> In file included from ../arch/ia64/include/asm/cmpxchg.h:5,
>> ../arch/ia64/include/uapi/asm/cmpxchg.h:146:28: note: previous declaration of '_printk' with type 'int(const char *, ...)'
>>    146 |                 extern int _printk(const char *fmt, ...);
>>
>> Fixes: 337015573718 ("printk: Userspace format indexing support")
>> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
>> Cc: linux-ia64@vger.kernel.org
>> Cc: Petr Mladek <pmladek@suse.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Tony Luck <tony.luck@intel.com>
>> Cc: Chris Down <chris@chrisdown.name>
>> ---
>>   arch/ia64/Kconfig.debug |    2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> --- linux-next-20210917.orig/arch/ia64/Kconfig.debug
>> +++ linux-next-20210917/arch/ia64/Kconfig.debug
>> @@ -39,7 +39,7 @@ config DISABLE_VHPT
>>   
>>   config IA64_DEBUG_CMPXCHG
>>   	bool "Turn on compare-and-exchange bug checking (slow!)"
>> -	depends on DEBUG_KERNEL
>> +	depends on DEBUG_KERNEL && PRINTK
>>   	help
>>   	  Selecting this option turns on bug checking for the IA-64
>>   	  compare-and-exchange instructions.  This is slow!  Itaniums
> 
> We currently don't have a maintainer for ia64 - although I would be willing to pick
> up the job - so your patch would have to go through someone else's tree.

Yes, I know about no-maintainer. That's why Andrew is cc-ed on this.
(or even Peter could merge it.)

> I can boot test the patch on my RX2660 in the mean time.


and Chris wrote:

> This Fixes tag doesn't make much sense. This was already broken long before that patch, just the error message changed: printk() was already static inline on !CONFIG_PRINTK for eons. 

OK, I corrected that for v2. Thanks.

-- 
~Randy
