From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Thu, 07 Apr 2022 18:32:16 +0000
Subject: Re: [RFC PATCH] lkdtm: Replace lkdtm_rodata_do_nothing() by do_nothing()
Message-Id: <9b1b475c-f3de-02a4-b863-c00345d3364b@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <fe36bf23fb14e7eff92a95a1092ed38edb01d5f5.1634491011.git.christophe.leroy@csgroup.eu>
 <26d37781-9824-3306-240d-6ce6044c2412@csgroup.eu>
In-Reply-To: <26d37781-9824-3306-240d-6ce6044c2412@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Kees Cook <keescook@chromium.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

Hi Kees,

Le 23/02/2022 à 18:17, Christophe Leroy a écrit :
> Hi Kees,
> 
> Le 17/10/2021 à 19:19, Christophe Leroy a écrit :
>> All EXEC tests are based on running a copy of do_nothing()
>> except lkdtm_EXEC_RODATA which uses a different function
>> called lkdtm_rodata_do_nothing().
>>
>> On architectures using function descriptors, EXEC tests are
>> performed using execute_location() which is a function
>> that most of the time copies do_nothing() at the tested
>> location then duplicates do_nothing() function descriptor
>> and updates it with the address of the copy of do_nothing().
>>
>> But for EXEC_RODATA test, execute_location() uses
>> lkdtm_rodata_do_nothing() which is already in rodata section
>> at build time instead of using a copy of do_nothing(). However
>> it still uses the function descriptor of do_nothing(). There
>> is a risk that running lkdtm_rodata_do_nothing() with the
>> function descriptor of do_thing() is wrong.
>>
>> To remove the above risk, change the approach and do the same
>> as for other EXEC tests: use a copy of do_nothing(). The copy
>> cannot be done during the test because RODATA area is write
>> protected. Do the copy during init, before RODATA becomes
>> write protected.
>>
>> Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>
> 
> Any opinion on this patch ?

Any opinion ?

Thanks
Christophe

> 
> Thanks
> Christophe
> 
>> ---
>> This applies on top of series v3 "Fix LKDTM for PPC64/IA64/PARISC"
>>
>>   drivers/misc/lkdtm/Makefile | 11 -----------
>>   drivers/misc/lkdtm/lkdtm.h  |  3 ---
>>   drivers/misc/lkdtm/perms.c  |  9 +++++++--
>>   drivers/misc/lkdtm/rodata.c | 11 -----------
>>   4 files changed, 7 insertions(+), 27 deletions(-)
>>   delete mode 100644 drivers/misc/lkdtm/rodata.c
>>
>> diff --git a/drivers/misc/lkdtm/Makefile b/drivers/misc/lkdtm/Makefile
>> index e2984ce51fe4..3d45a2b3007d 100644
>> --- a/drivers/misc/lkdtm/Makefile
>> +++ b/drivers/misc/lkdtm/Makefile
>> @@ -6,21 +6,10 @@ lkdtm-$(CONFIG_LKDTM)        += bugs.o
>>   lkdtm-$(CONFIG_LKDTM)        += heap.o
>>   lkdtm-$(CONFIG_LKDTM)        += perms.o
>>   lkdtm-$(CONFIG_LKDTM)        += refcount.o
>> -lkdtm-$(CONFIG_LKDTM)        += rodata_objcopy.o
>>   lkdtm-$(CONFIG_LKDTM)        += usercopy.o
>>   lkdtm-$(CONFIG_LKDTM)        += stackleak.o
>>   lkdtm-$(CONFIG_LKDTM)        += cfi.o
>>   lkdtm-$(CONFIG_LKDTM)        += fortify.o
>>   lkdtm-$(CONFIG_PPC_BOOK3S_64)    += powerpc.o
>> -KASAN_SANITIZE_rodata.o        := n
>>   KASAN_SANITIZE_stackleak.o    := n
>> -KCOV_INSTRUMENT_rodata.o    := n
>> -CFLAGS_REMOVE_rodata.o        += $(CC_FLAGS_LTO)
>> -
>> -OBJCOPYFLAGS :>> -OBJCOPYFLAGS_rodata_objcopy.o    := \
>> -            --rename-section 
>> .noinstr.text=.rodata,alloc,readonly,load,contents
>> -targets += rodata.o rodata_objcopy.o
>> -$(obj)/rodata_objcopy.o: $(obj)/rodata.o FORCE
>> -    $(call if_changed,objcopy)
>> diff --git a/drivers/misc/lkdtm/lkdtm.h b/drivers/misc/lkdtm/lkdtm.h
>> index 188bd0fd6575..905555d4c2cf 100644
>> --- a/drivers/misc/lkdtm/lkdtm.h
>> +++ b/drivers/misc/lkdtm/lkdtm.h
>> @@ -137,9 +137,6 @@ void lkdtm_REFCOUNT_SUB_AND_TEST_SATURATED(void);
>>   void lkdtm_REFCOUNT_TIMING(void);
>>   void lkdtm_ATOMIC_TIMING(void);
>> -/* rodata.c */
>> -void lkdtm_rodata_do_nothing(void);
>> -
>>   /* usercopy.c */
>>   void __init lkdtm_usercopy_init(void);
>>   void __exit lkdtm_usercopy_exit(void);
>> diff --git a/drivers/misc/lkdtm/perms.c b/drivers/misc/lkdtm/perms.c
>> index 2c6aba3ff32b..9b951ca48363 100644
>> --- a/drivers/misc/lkdtm/perms.c
>> +++ b/drivers/misc/lkdtm/perms.c
>> @@ -27,6 +27,7 @@ static const unsigned long rodata = 0xAA55AA55;
>>   /* This is marked __ro_after_init, so it should ultimately be 
>> .rodata. */
>>   static unsigned long ro_after_init __ro_after_init = 0x55AA5500;
>> +static u8 rodata_area[EXEC_SIZE] __ro_after_init;
>>   /*
>>    * This just returns to the caller. It is designed to be copied into
>> @@ -193,8 +194,7 @@ void lkdtm_EXEC_VMALLOC(void)
>>   void lkdtm_EXEC_RODATA(void)
>>   {
>> -    
>> execute_location(dereference_function_descriptor(lkdtm_rodata_do_nothing), 
>>
>> -             CODE_AS_IS);
>> +    execute_location(rodata_area, CODE_AS_IS);
>>   }
>>   void lkdtm_EXEC_USERSPACE(void)
>> @@ -269,4 +269,9 @@ void __init lkdtm_perms_init(void)
>>   {
>>       /* Make sure we can write to __ro_after_init values during 
>> __init */
>>       ro_after_init |= 0xAA;
>> +
>> +    memcpy(rodata_area, dereference_function_descriptor(do_nothing),
>> +           EXEC_SIZE);
>> +    flush_icache_range((unsigned long)rodata_area,
>> +               (unsigned long)rodata_area + EXEC_SIZE);
>>   }
>> diff --git a/drivers/misc/lkdtm/rodata.c b/drivers/misc/lkdtm/rodata.c
>> deleted file mode 100644
>> index baacb876d1d9..000000000000
>> --- a/drivers/misc/lkdtm/rodata.c
>> +++ /dev/null
>> @@ -1,11 +0,0 @@
>> -// SPDX-License-Identifier: GPL-2.0
>> -/*
>> - * This includes functions that are meant to live entirely in .rodata
>> - * (via objcopy tricks), to validate the non-executability of .rodata.
>> - */
>> -#include "lkdtm.h"
>> -
>> -void noinstr lkdtm_rodata_do_nothing(void)
>> -{
>> -    /* Does nothing. We just want an architecture agnostic "return". */
>> -}
