From: Nicholas Piggin <npiggin@gmail.com>
Date: Mon, 18 Oct 2021 09:16:25 +0000
Subject: Re: [PATCH v3 07/12] asm-generic: Define 'func_desc_t' to commonly describe function descriptors
Message-Id: <1634546857.xamu59z8sr.astroid@bobo.none>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1634457599.git.christophe.leroy@csgroup.eu>
        <a33107c5b82580862510cc20af0d61e33a2b841d.1634457599.git.christophe.leroy@csgroup.eu>
        <1634538449.eah9b31bbz.astroid@bobo.none>
        <802b3ff9-8ada-b45b-2b69-b6a23f0c3664@csgroup.eu>
In-Reply-To: <802b3ff9-8ada-b45b-2b69-b6a23f0c3664@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Christophe Leroy <christophe.leroy@csgroup.eu>, Helge Deller <deller@gmx.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Kees Cook <keescook@chromium.org>, Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>
Cc: linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

Excerpts from Christophe Leroy's message of October 18, 2021 5:07 pm:
> 
> 
> Le 18/10/2021 à 08:29, Nicholas Piggin a écrit :
>> Excerpts from Christophe Leroy's message of October 17, 2021 10:38 pm:
>>> We have three architectures using function descriptors, each with its
>>> own type and name.
>>>
>>> Add a common typedef that can be used in generic code.
>>>
>>> Also add a stub typedef for architecture without function descriptors,
>>> to avoid a forest of #ifdefs.
>>>
>>> It replaces the similar 'func_desc_t' previously defined in
>>> arch/powerpc/kernel/module_64.c
>>>
>>> Reviewed-by: Kees Cook <keescook@chromium.org>
>>> Acked-by: Arnd Bergmann <arnd@arndb.de>
>>> Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>
>>> ---
>> 
>> [...]
>> 
>>> diff --git a/include/asm-generic/sections.h b/include/asm-generic/sections.h
>>> index a918388d9bf6..33b51efe3a24 100644
>>> --- a/include/asm-generic/sections.h
>>> +++ b/include/asm-generic/sections.h
>>> @@ -63,6 +63,9 @@ extern __visible const void __nosave_begin, __nosave_end;
>>>   #else
>>>   #define dereference_function_descriptor(p) ((void *)(p))
>>>   #define dereference_kernel_function_descriptor(p) ((void *)(p))
>>> +typedef struct {
>>> +	unsigned long addr;
>>> +} func_desc_t;
>>>   #endif
>>>   
>> 
>> I think that deserves a comment. If it's just to allow ifdef to be
>> avoided, I guess that's okay with a comment. Would be nice if you could
>> cause it to generate a link time error if it was ever used like
>> undefined functions, but I guess you can't. It's not a necessity though.
>> 
> 
> I tried to explain it in the commit message, but I can add a comment 
> here in addition for sure.

Thanks.

> 
> By the way, it IS used in powerpc's module_64.c:

Ah yes of course. I guess the point is function descriptors don't exist 
so it should not be used (in general). powerpc module code knows what it
is doing, I guess it's okay for it to use it.

Thanks,
Nick
