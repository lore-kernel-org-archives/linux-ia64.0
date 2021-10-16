From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Sat, 16 Oct 2021 06:28:09 +0000
Subject: Re: [PATCH v2 13/13] lkdtm: Add a test for function descriptors protection
Message-Id: <b11bab54-04bd-4244-a043-b3d8df34967b@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1634190022.git.christophe.leroy@csgroup.eu>
 <08a3dfbc55e1c7a0a1917b22f0ca6cabd9895ab2.1634190022.git.christophe.leroy@csgroup.eu>
 <202110151433.6270D717@keescook>
In-Reply-To: <202110151433.6270D717@keescook>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Kees Cook <keescook@chromium.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org



Le 15/10/2021 à 23:35, Kees Cook a écrit :
> On Thu, Oct 14, 2021 at 07:50:02AM +0200, Christophe Leroy wrote:
>> Add WRITE_OPD to check that you can't modify function
>> descriptors.
>>
>> Gives the following result when function descriptors are
>> not protected:
>>
>> 	lkdtm: Performing direct entry WRITE_OPD
>> 	lkdtm: attempting bad 16 bytes write at c00000000269b358
>> 	lkdtm: FAIL: survived bad write
>> 	lkdtm: do_nothing was hijacked!
>>
>> Looks like a standard compiler barrier(); is not enough to force
>> GCC to use the modified function descriptor. Add to add a fake empty
>> inline assembly to force GCC to reload the function descriptor.
>>
>> Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>
>> ---
>>   drivers/misc/lkdtm/core.c  |  1 +
>>   drivers/misc/lkdtm/lkdtm.h |  1 +
>>   drivers/misc/lkdtm/perms.c | 22 ++++++++++++++++++++++
>>   3 files changed, 24 insertions(+)
>>
>> diff --git a/drivers/misc/lkdtm/core.c b/drivers/misc/lkdtm/core.c
>> index fe6fd34b8caf..de092aa03b5d 100644
>> --- a/drivers/misc/lkdtm/core.c
>> +++ b/drivers/misc/lkdtm/core.c
>> @@ -148,6 +148,7 @@ static const struct crashtype crashtypes[] = {
>>   	CRASHTYPE(WRITE_RO),
>>   	CRASHTYPE(WRITE_RO_AFTER_INIT),
>>   	CRASHTYPE(WRITE_KERN),
>> +	CRASHTYPE(WRITE_OPD),
>>   	CRASHTYPE(REFCOUNT_INC_OVERFLOW),
>>   	CRASHTYPE(REFCOUNT_ADD_OVERFLOW),
>>   	CRASHTYPE(REFCOUNT_INC_NOT_ZERO_OVERFLOW),
>> diff --git a/drivers/misc/lkdtm/lkdtm.h b/drivers/misc/lkdtm/lkdtm.h
>> index c212a253edde..188bd0fd6575 100644
>> --- a/drivers/misc/lkdtm/lkdtm.h
>> +++ b/drivers/misc/lkdtm/lkdtm.h
>> @@ -105,6 +105,7 @@ void __init lkdtm_perms_init(void);
>>   void lkdtm_WRITE_RO(void);
>>   void lkdtm_WRITE_RO_AFTER_INIT(void);
>>   void lkdtm_WRITE_KERN(void);
>> +void lkdtm_WRITE_OPD(void);
>>   void lkdtm_EXEC_DATA(void);
>>   void lkdtm_EXEC_STACK(void);
>>   void lkdtm_EXEC_KMALLOC(void);
>> diff --git a/drivers/misc/lkdtm/perms.c b/drivers/misc/lkdtm/perms.c
>> index 96b3ebfcb8ed..3870bc82d40d 100644
>> --- a/drivers/misc/lkdtm/perms.c
>> +++ b/drivers/misc/lkdtm/perms.c
>> @@ -44,6 +44,11 @@ static noinline void do_overwritten(void)
>>   	return;
>>   }
>>   
>> +static noinline void do_almost_nothing(void)
>> +{
>> +	pr_info("do_nothing was hijacked!\n");
>> +}
>> +
>>   static void *setup_function_descriptor(func_desc_t *fdesc, void *dst)
>>   {
>>   	memcpy(fdesc, do_nothing, sizeof(*fdesc));
>> @@ -143,6 +148,23 @@ void lkdtm_WRITE_KERN(void)
>>   	do_overwritten();
>>   }
>>   
>> +void lkdtm_WRITE_OPD(void)
>> +{
>> +	size_t size = sizeof(func_desc_t);
>> +	void (*func)(void) = do_nothing;
>> +
>> +	if (!have_function_descriptors()) {
>> +		pr_info("Platform doesn't have function descriptors.\n");
> 
> This should be more explicit ('xfail'):
> 
> 	pr_info("XFAIL: platform doesn't use function descriptors.\n");

Ok


> 
>> +		return;
>> +	}
>> +	pr_info("attempting bad %zu bytes write at %px\n", size, do_nothing);
>> +	memcpy(do_nothing, do_almost_nothing, size);
>> +	pr_err("FAIL: survived bad write\n");
>> +
>> +	asm("" : "=m"(func));
> 
> Since this is a descriptor, I assume no icache flush is needed. Are
> function descriptors strictly dcache? (Is anything besides just a
> barrier needed?)

No flush is needed, the code just loads the function address from memory 
into CTR, loads R2 and branch to CTR:

	 19c:	e9 21 00 70 	ld      r9,112(r1)
	 1a0:	e9 49 00 00 	ld      r10,0(r9)
	 1a4:	7d 49 03 a6 	mtctr   r10
	 1a8:	e8 49 00 08 	ld      r2,8(r9)
	 1ac:	4e 80 04 21 	bctrl


> 
>> +	func();
>> +}
>> +
>>   void lkdtm_EXEC_DATA(void)
>>   {
>>   	execute_location(data_area, CODE_WRITE);
>> -- 
>> 2.31.1
>>
> 
