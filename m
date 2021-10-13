From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Wed, 13 Oct 2021 07:48:54 +0000
Subject: Re: [PATCH v1 09/10] lkdtm: Fix lkdtm_EXEC_RODATA()
Message-Id: <134b968f-f65f-cd74-3db1-fff60e5ebeb8@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1633964380.git.christophe.leroy@csgroup.eu>
 <7da92e59e148bd23564d63bdd8bcfaba0ba6d1f1.1633964380.git.christophe.leroy@csgroup.eu>
 <202110130018.7B2129375@keescook>
 <be307455-b02b-f382-851f-091ea26040b7@csgroup.eu>
In-Reply-To: <be307455-b02b-f382-851f-091ea26040b7@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Kees Cook <keescook@chromium.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org



Le 13/10/2021 à 09:39, Christophe Leroy a écrit :
> 
> 
> Le 13/10/2021 à 09:23, Kees Cook a écrit :
>> On Mon, Oct 11, 2021 at 05:25:36PM +0200, Christophe Leroy wrote:
>>> Behind a location, lkdtm_EXEC_RODATA() executes a real function,
>>> not a copy of do_nothing().
>>>
>>> So do it directly instead of using execute_location().
>>>
>>> And fix displayed addresses by dereferencing the function descriptors.
>>>
>>> Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>
>>> ---
>>>   drivers/misc/lkdtm/perms.c | 9 ++++++++-
>>>   1 file changed, 8 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/drivers/misc/lkdtm/perms.c b/drivers/misc/lkdtm/perms.c
>>> index 442d60ed25ef..da16564e1ecd 100644
>>> --- a/drivers/misc/lkdtm/perms.c
>>> +++ b/drivers/misc/lkdtm/perms.c
>>> @@ -153,7 +153,14 @@ void lkdtm_EXEC_VMALLOC(void)
>>>
>>>   void lkdtm_EXEC_RODATA(void)
>>>   {
>>> -    execute_location(lkdtm_rodata_do_nothing, CODE_AS_IS);
>>> +    pr_info("attempting ok execution at %px\n",
>>> +        dereference_symbol_descriptor(do_nothing));
>>> +    do_nothing();
>>> +
>>> +    pr_info("attempting bad execution at %px\n",
>>> +        dereference_symbol_descriptor(lkdtm_rodata_do_nothing));
>>> +    lkdtm_rodata_do_nothing();
>>> +    pr_err("FAIL: func returned\n");
>>>   }
>>
>> (In re-reading this more carefully, I see now why kallsyms.h is used
>> earlier: _function_ vs _symbol_ descriptor.)
>>
>> In the next patch:
>>
>> static noinline void execute_location(void *dst, bool write)
>> {
>> ...
>>         func = setup_function_descriptor(&fdesc, dst);
>>         if (IS_ERR(func))
>>                 return;
>>
>>         pr_info("attempting bad execution at %px\n", dst);
>>         func();
>>         pr_err("FAIL: func returned\n");
>> }
>>
>> What are the conditions for which dereference_symbol_descriptor works
>> but dereference _function_descriptor doesn't?
>>
> 
> When LKDTM is built as a module I guess ?
> 

To be more precise, dereference_symbol_descriptor() calls either 
dereference_kernel_function_descriptor() or 
dereference_module_function_descriptor()

Both functions call dereference_function_descriptor() after checking 
that we want to dereference something that is in the OPD section.

If we call dereference_function_descriptor() directly instead of 
dereference_symbol_descriptor() we skip the range verification and may 
dereference something that is not a function descriptor.

Should we do that ?

Christophe
