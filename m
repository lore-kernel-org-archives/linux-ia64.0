From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Tue, 16 Nov 2021 15:07:47 +0000
Subject: Re: [PATCH v2 12/13] lkdtm: Fix execute_[user]_location()
Message-Id: <8ba77500-cb40-0662-f571-6a6f391374b9@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1634190022.git.christophe.leroy@csgroup.eu>
 <cbee30c66890994e116a8eae8094fa8c5336f90a.1634190022.git.christophe.leroy@csgroup.eu>
 <202110151428.187B1CF@keescook>
 <9b4c39d4-1322-89af-585c-679a574576a2@csgroup.eu>
In-Reply-To: <9b4c39d4-1322-89af-585c-679a574576a2@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Kees Cook <keescook@chromium.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

Hi Kees,

Le 16/10/2021 à 08:42, Christophe Leroy a écrit :
> 
> 
> Le 15/10/2021 à 23:31, Kees Cook a écrit :
>> On Thu, Oct 14, 2021 at 07:50:01AM +0200, Christophe Leroy wrote:
>>> execute_location() and execute_user_location() intent
>>> to copy do_nothing() text and execute it at a new location.
>>> However, at the time being it doesn't copy do_nothing() function
>>> but do_nothing() function descriptor which still points to the
>>> original text. So at the end it still executes do_nothing() at
>>> its original location allthough using a copied function descriptor.
>>>
>>> So, fix that by really copying do_nothing() text and build a new
>>> function descriptor by copying do_nothing() function descriptor and
>>> updating the target address with the new location.
>>>
>>> Also fix the displayed addresses by dereferencing do_nothing()
>>> function descriptor.
>>>
>>> Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>
>>> ---
>>>   drivers/misc/lkdtm/perms.c     | 25 +++++++++++++++++++++----
>>>   include/asm-generic/sections.h |  5 +++++
>>>   2 files changed, 26 insertions(+), 4 deletions(-)
>>>
>>> diff --git a/drivers/misc/lkdtm/perms.c b/drivers/misc/lkdtm/perms.c
>>> index 5266dc28df6e..96b3ebfcb8ed 100644
>>> --- a/drivers/misc/lkdtm/perms.c
>>> +++ b/drivers/misc/lkdtm/perms.c
>>> @@ -44,19 +44,32 @@ static noinline void do_overwritten(void)
>>>       return;
>>>   }
>>> +static void *setup_function_descriptor(func_desc_t *fdesc, void *dst)
>>> +{
>>> +    memcpy(fdesc, do_nothing, sizeof(*fdesc));
>>> +    fdesc->addr = (unsigned long)dst;
>>> +    barrier();
>>> +
>>> +    return fdesc;
>>> +}
>>
>> How about collapsing the "have_function_descriptors()" check into
>> setup_function_descriptor()?
>>
>> static void *setup_function_descriptor(func_desc_t *fdesc, void *dst)
>> {
>>     if (__is_defined(HAVE_FUNCTION_DESCRIPTORS)) {
>>         memcpy(fdesc, do_nothing, sizeof(*fdesc));
>>         fdesc->addr = (unsigned long)dst;
>>         barrier();
>>         return fdesc;
>>     } else {
>>         return dst;
>>     }
>> }
> 
> Ok
> 

...

>>
>>> diff --git a/include/asm-generic/sections.h 
>>> b/include/asm-generic/sections.h
>>> index 76163883c6ff..d225318538bd 100644
>>> --- a/include/asm-generic/sections.h
>>> +++ b/include/asm-generic/sections.h
>>> @@ -70,6 +70,11 @@ typedef struct {
>>>   } func_desc_t;
>>>   #endif
>>> +static inline bool have_function_descriptors(void)
>>> +{
>>> +    return __is_defined(HAVE_FUNCTION_DESCRIPTORS);
>>> +}
>>> +
>>>   /* random extra sections (if any).  Override
>>>    * in asm/sections.h */
>>>   #ifndef arch_is_kernel_text
>>
>> This hunk seems like it should live in a separate patch.
>>
> 
> Ok I move it in a previous patch.


Do you have any additional feedback or comment on series v3 ?

What's the way forward, should it go via LKDTM tree or via powerpc tree 
or another tree ? I see there are neither Ack-by nor Reviewed-by for the 
last 2 patches.

Thanks
Christophe
