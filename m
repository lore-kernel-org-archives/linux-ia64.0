From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Mon, 18 Oct 2021 07:08:54 +0000
Subject: Re: [PATCH v3 04/12] powerpc: Prepare func_desc_t for refactorisation
Message-Id: <1f66d234-3624-7ba2-7b03-5d0e1bea087f@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1634457599.git.christophe.leroy@csgroup.eu>
 <86c393ce0a6f603f94e6d2ceca08d535f654bb23.1634457599.git.christophe.leroy@csgroup.eu>
 <1634536863.oq0s171f8c.astroid@bobo.none>
In-Reply-To: <1634536863.oq0s171f8c.astroid@bobo.none>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Nicholas Piggin <npiggin@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Helge Deller <deller@gmx.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Kees Cook <keescook@chromium.org>, Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>
Cc: linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org



Le 18/10/2021 à 08:27, Nicholas Piggin a écrit :
> Excerpts from Christophe Leroy's message of October 17, 2021 10:38 pm:
>> In preparation of making func_desc_t generic, change the ELFv2
>> version to a struct containing 'addr' element.
>>
>> This allows using single helpers common to ELFv1 and ELFv2.
>>
>> Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>
> 
>> ---
>>   arch/powerpc/kernel/module_64.c | 32 ++++++++++++++------------------
>>   1 file changed, 14 insertions(+), 18 deletions(-)
>>
>> diff --git a/arch/powerpc/kernel/module_64.c b/arch/powerpc/kernel/module_64.c
>> index a89da0ee25e2..b687ef88c4c4 100644
>> --- a/arch/powerpc/kernel/module_64.c
>> +++ b/arch/powerpc/kernel/module_64.c
>> @@ -33,19 +33,13 @@
>>   #ifdef PPC64_ELF_ABI_v2
>>   
>>   /* An address is simply the address of the function. */
>> -typedef unsigned long func_desc_t;
>> +typedef struct {
>> +	unsigned long addr;
>> +} func_desc_t;
> 
> I'm not quite following why this change is done. I guess it is so you
> can move this func_desc_t type into core code, but why do that? Is it
> just to avoid using the preprocessor?

I explained it in patch 7 but yes it probably also deserves some more 
explanation here as well.

That's right, it's to avoid having to spread #ifdefs everywhere.

> 
> On its own this patch looks okay.
> 
> Acked-by: Nicholas Piggin <npiggin@gmail.com>
> 
