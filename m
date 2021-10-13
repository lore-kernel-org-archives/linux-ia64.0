From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Wed, 13 Oct 2021 07:29:53 +0000
Subject: Re: [PATCH v1 08/10] lkdtm: Really write into kernel text in WRITE_KERN
Message-Id: <336f314c-2db3-0899-b012-18c493ae0e3a@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1633964380.git.christophe.leroy@csgroup.eu>
 <624940395e5d81967246f911a65740b9a15b5a70.1633964380.git.christophe.leroy@csgroup.eu>
 <202110130004.880A6C841@keescook>
In-Reply-To: <202110130004.880A6C841@keescook>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Kees Cook <keescook@chromium.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org



Le 13/10/2021 à 09:05, Kees Cook a écrit :
> On Mon, Oct 11, 2021 at 05:25:35PM +0200, Christophe Leroy wrote:
>> WRITE_KERN is supposed to overwrite some kernel text, namely
>> do_overwritten() function.
>>
>> But at the time being it overwrites do_overwritten() function
>> descriptor, not function text.
>>
>> Fix it by dereferencing the function descriptor to obtain
>> function text pointer.
>>
>> And make do_overwritten() noinline so that it is really
>> do_overwritten() which is called by lkdtm_WRITE_KERN().
>>
>> Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>
>> ---
>>   drivers/misc/lkdtm/perms.c | 8 +++++---
>>   1 file changed, 5 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/misc/lkdtm/perms.c b/drivers/misc/lkdtm/perms.c
>> index 60b3b2fe929d..442d60ed25ef 100644
>> --- a/drivers/misc/lkdtm/perms.c
>> +++ b/drivers/misc/lkdtm/perms.c
>> @@ -5,6 +5,7 @@
>>    * even non-readable regions.
>>    */
>>   #include "lkdtm.h"
>> +#include <linux/kallsyms.h>
> 
> Why not #include <asm/sections.h> instead here?

dereference_symbol_descriptor() is defined in linux/kallsyms.h

> 
>>   #include <linux/slab.h>
>>   #include <linux/vmalloc.h>
>>   #include <linux/mman.h>
>> @@ -37,7 +38,7 @@ static noinline void do_nothing(void)
>>   }
>>   
>>   /* Must immediately follow do_nothing for size calculuations to work out. */
>> -static void do_overwritten(void)
>> +static noinline void do_overwritten(void)
>>   {
>>   	pr_info("do_overwritten wasn't overwritten!\n");
>>   	return;
>> @@ -113,8 +114,9 @@ void lkdtm_WRITE_KERN(void)
>>   	size_t size;
>>   	volatile unsigned char *ptr;
>>   
>> -	size = (unsigned long)do_overwritten - (unsigned long)do_nothing;
>> -	ptr = (unsigned char *)do_overwritten;
>> +	size = (unsigned long)dereference_symbol_descriptor(do_overwritten) -
>> +	       (unsigned long)dereference_symbol_descriptor(do_nothing);
>> +	ptr = dereference_symbol_descriptor(do_overwritten);
> 
> But otherwise, yup, I expect there will be a bunch of things like this
> to clean up in LKDTM. :| Sorry about that!
> 
> Acked-by: Kees Cook <keescook@chromium.org>
> 
>>   
>>   	pr_info("attempting bad %zu byte write at %px\n", size, ptr);
>>   	memcpy((void *)ptr, (unsigned char *)do_nothing, size);
>> -- 
>> 2.31.1
>>
> 
