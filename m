From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Sun, 17 Oct 2021 07:50:10 +0000
Subject: Re: [PATCH v2 11/13] lkdtm: Fix lkdtm_EXEC_RODATA()
Message-Id: <87927aa3-6414-adaa-44f7-b3bf1f664317@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1634190022.git.christophe.leroy@csgroup.eu>
 <44946ed0340013a52f8acdee7d6d0781f145cd6b.1634190022.git.christophe.leroy@csgroup.eu>
 <202110151432.D8203C19@keescook>
 <61a3d2c4-4997-c221-3eef-d74aef5ba584@csgroup.eu>
In-Reply-To: <61a3d2c4-4997-c221-3eef-d74aef5ba584@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Kees Cook <keescook@chromium.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org



Le 16/10/2021 à 08:41, Christophe Leroy a écrit :
> 
> 
> Le 15/10/2021 à 23:32, Kees Cook a écrit :
>> On Thu, Oct 14, 2021 at 07:50:00AM +0200, Christophe Leroy wrote:
>>> Behind its location, lkdtm_EXEC_RODATA() executes
>>> lkdtm_rodata_do_nothing() which is a real function,
>>> not a copy of do_nothing().
>>>
>>> So executes it directly instead of using execute_location().
>>>
>>> This is necessary because following patch will fix execute_location()
>>> to use a copy of the function descriptor of do_nothing() and
>>> function descriptor of lkdtm_rodata_do_nothing() might be different.
>>>
>>> And fix displayed addresses by dereferencing the function descriptors.
>>>
>>> Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>
>>
>> I still don't understand this -- it doesn't look needed at all given the
>> changes in patch 12. (i.e. everything is using
>> dereference_function_descriptor() now)
> 
> dereference_function_descriptor() only deals with the function address, 
> not the function TOC.
> 
> do_nothing() is a function. It has a function descriptor with a given 
> address (address of .do_nothing) and a given TOC, say TOC1.
> 
> lkdtm_rodata_do_nothing() is another function. It has its own function 
> descriptor with a given address (address of .lkdtm_rodata_do_nothing) 
> and a given TOC, say TOC2.
> 
> If we use execute_location(), it will copy do_nothing() function 
> descriptor and change the function address to the address of 
> lkdtm_rodata_do_nothing(). So it will call lkdtm_rodata_do_nothing() 
> with TOC1 instead of calling it with TOC2.
> 
>>
>> Can't this patch be dropped?
> 
> It is likely that the TOC will be the same for both functions, and 
> anyway those functions are so simple that they don't use the TOC at all, 
> so yes it would likely work without this patch but from my point of view 
> it is incorrect to call one function with the TOC from the descriptor of 
> another function.
> 
> If you thing we can take the risk, then I'm happy to drop the patch and 
> replace it by
> 
>      execute_location(dereference_function_descriptor(lkdtm_rodata_do_nothing), CODE_AS_IS)
> 

Once we have patch 12 EXEC_RODATA works well on powerpc without this 
patch so I will drop this patch for now and will propose something else 
as a follow-up to my series.

Christophe
