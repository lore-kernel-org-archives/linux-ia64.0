From: Nicholas Piggin <npiggin@gmail.com>
Date: Fri, 15 Oct 2021 11:52:44 +0000
Subject: Re: [PATCH v2 06/13] asm-generic: Use HAVE_FUNCTION_DESCRIPTORS to define associated stubs
Message-Id: <1634298613.bp91trt1cz.astroid@bobo.none>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1634190022.git.christophe.leroy@csgroup.eu>
        <4fda65cda906e56aa87806b658e0828c64792403.1634190022.git.christophe.leroy@csgroup.eu>
        <1634278340.5yp7xtm7um.astroid@bobo.none>
        <7523a005-ea69-7c4c-64ad-bc2537921975@csgroup.eu>
        <1634284464.kd8scm0ckz.astroid@bobo.none>
In-Reply-To: <1634284464.kd8scm0ckz.astroid@bobo.none>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Christophe Leroy <christophe.leroy@csgroup.eu>, Helge Deller <deller@gmx.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Kees Cook <keescook@chromium.org>, Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>
Cc: linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

Excerpts from Nicholas Piggin's message of October 15, 2021 6:02 pm:
> Excerpts from Christophe Leroy's message of October 15, 2021 4:24 pm:
>> 
>> 
>> Le 15/10/2021 à 08:16, Nicholas Piggin a écrit :
>>> Excerpts from Christophe Leroy's message of October 14, 2021 3:49 pm:
>>>> Replace HAVE_DEREFERENCE_FUNCTION_DESCRIPTOR by
>>>> HAVE_FUNCTION_DESCRIPTORS and use it instead of
>>>> 'dereference_function_descriptor' macro to know
>>>> whether an arch has function descriptors.
>>>>
>>>> To limit churn in one of the following patches, use
>>>> an #ifdef/#else construct with empty first part
>>>> instead of an #ifndef in asm-generic/sections.h
>>> 
>>> Is it worth putting this into Kconfig if you're going to
>>> change it? In any case
>> 
>> That was what I wanted to do in the begining but how can I do that in 
>> Kconfig ?
>> 
>> #ifdef __powerpc64__
>> #if defined(_CALL_ELF) && _CALL_ELF == 2
>> #define PPC64_ELF_ABI_v2
>> #else
>> #define PPC64_ELF_ABI_v1
>> #endif
>> #endif /* __powerpc64__ */
>> 
>> #ifdef PPC64_ELF_ABI_v1
>> #define HAVE_DEREFERENCE_FUNCTION_DESCRIPTOR 1
> 
> We have ELFv2 ABI / function descriptors iff big-endian so you could 
> just select based on that.

Of course that should read ELFv1. To be clearer: BE is ELFv1 ABI and
LE is ELFv2 ABI.

Thanks,
Nick
