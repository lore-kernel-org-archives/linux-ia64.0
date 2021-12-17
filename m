From: Helge Deller <deller@gmx.de>
Date: Fri, 17 Dec 2021 17:12:19 +0000
Subject: Re: [PATCH v3 11/12] lkdtm: Fix execute_[user]_location()
Message-Id: <295e2386-eda8-a9d8-3748-60f48205a815@gmx.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1634457599.git.christophe.leroy@csgroup.eu>
 <d4688c2af08dda706d3b6786ae5ec5a74e6171f1.1634457599.git.christophe.leroy@csgroup.eu>
 <e7793192-6879-490d-1f37-3d6d6908a121@csgroup.eu>
In-Reply-To: <e7793192-6879-490d-1f37-3d6d6908a121@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Christophe Leroy <christophe.leroy@csgroup.eu>, Kees Cook <keescook@chromium.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Paul Mackerras <paulus@samba.org>, Arnd Bergmann <arnd@arndb.de>

On 12/17/21 12:49, Christophe Leroy wrote:
> Hi Kees,
>
> Le 17/10/2021 à 14:38, Christophe Leroy a écrit :
>> execute_location() and execute_user_location() intent
>> to copy do_nothing() text and execute it at a new location.
>> However, at the time being it doesn't copy do_nothing() function
>> but do_nothing() function descriptor which still points to the
>> original text. So at the end it still executes do_nothing() at
>> its original location allthough using a copied function descriptor.
>>
>> So, fix that by really copying do_nothing() text and build a new
>> function descriptor by copying do_nothing() function descriptor and
>> updating the target address with the new location.
>>
>> Also fix the displayed addresses by dereferencing do_nothing()
>> function descriptor.
>>
>> Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>
>
> Do you have any comment to this patch and to patch 12 ?
>
> If not, is it ok to get your acked-by ?


Hi Christophe,

I think this whole series is a nice cleanup and harmonization
of how function descriptors are used.

At least for the PA-RISC parts you may add:
Acked-by: Helge Deller <deller@gmx.de>

Thanks!
Helge

>
>> ---
>>   drivers/misc/lkdtm/perms.c | 37 ++++++++++++++++++++++++++++---------
>>   1 file changed, 28 insertions(+), 9 deletions(-)
>>
>> diff --git a/drivers/misc/lkdtm/perms.c b/drivers/misc/lkdtm/perms.c
>> index 035fcca441f0..1cf24c4a79e9 100644
>> --- a/drivers/misc/lkdtm/perms.c
>> +++ b/drivers/misc/lkdtm/perms.c
>> @@ -44,19 +44,34 @@ static noinline void do_overwritten(void)
>>   	return;
>>   }
>>
>> +static void *setup_function_descriptor(func_desc_t *fdesc, void *dst)
>> +{
>> +	if (!have_function_descriptors())
>> +		return dst;
>> +
>> +	memcpy(fdesc, do_nothing, sizeof(*fdesc));
>> +	fdesc->addr = (unsigned long)dst;
>> +	barrier();
>> +
>> +	return fdesc;
>> +}
>> +
>>   static noinline void execute_location(void *dst, bool write)
>>   {
>> -	void (*func)(void) = dst;
>> +	void (*func)(void);
>> +	func_desc_t fdesc;
>> +	void *do_nothing_text = dereference_function_descriptor(do_nothing);
>>
>> -	pr_info("attempting ok execution at %px\n", do_nothing);
>> +	pr_info("attempting ok execution at %px\n", do_nothing_text);
>>   	do_nothing();
>>
>>   	if (write == CODE_WRITE) {
>> -		memcpy(dst, do_nothing, EXEC_SIZE);
>> +		memcpy(dst, do_nothing_text, EXEC_SIZE);
>>   		flush_icache_range((unsigned long)dst,
>>   				   (unsigned long)dst + EXEC_SIZE);
>>   	}
>> -	pr_info("attempting bad execution at %px\n", func);
>> +	pr_info("attempting bad execution at %px\n", dst);
>> +	func = setup_function_descriptor(&fdesc, dst);
>>   	func();
>>   	pr_err("FAIL: func returned\n");
>>   }
>> @@ -66,16 +81,19 @@ static void execute_user_location(void *dst)
>>   	int copied;
>>
>>   	/* Intentionally crossing kernel/user memory boundary. */
>> -	void (*func)(void) = dst;
>> +	void (*func)(void);
>> +	func_desc_t fdesc;
>> +	void *do_nothing_text = dereference_function_descriptor(do_nothing);
>>
>> -	pr_info("attempting ok execution at %px\n", do_nothing);
>> +	pr_info("attempting ok execution at %px\n", do_nothing_text);
>>   	do_nothing();
>>
>> -	copied = access_process_vm(current, (unsigned long)dst, do_nothing,
>> +	copied = access_process_vm(current, (unsigned long)dst, do_nothing_text,
>>   				   EXEC_SIZE, FOLL_WRITE);
>>   	if (copied < EXEC_SIZE)
>>   		return;
>> -	pr_info("attempting bad execution at %px\n", func);
>> +	pr_info("attempting bad execution at %px\n", dst);
>> +	func = setup_function_descriptor(&fdesc, dst);
>>   	func();
>>   	pr_err("FAIL: func returned\n");
>>   }
>> @@ -153,7 +171,8 @@ void lkdtm_EXEC_VMALLOC(void)
>>
>>   void lkdtm_EXEC_RODATA(void)
>>   {
>> -	execute_location(lkdtm_rodata_do_nothing, CODE_AS_IS);
>> +	execute_location(dereference_function_descriptor(lkdtm_rodata_do_nothing),
>> +			 CODE_AS_IS);
>>   }
>>
>>   void lkdtm_EXEC_USERSPACE(void)
