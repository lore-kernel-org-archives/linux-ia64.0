From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Wed, 13 Oct 2021 11:20:34 +0000
Subject: Re: [PATCH v1 06/10] asm-generic: Refactor dereference_[kernel]_function_descriptor()
Message-Id: <c2904a2e-c112-f2bc-04a0-52b08b46c1ce@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1633964380.git.christophe.leroy@csgroup.eu>
 <c215b244a19a07327ec81bf99f3c5f89c68af7b4.1633964380.git.christophe.leroy@csgroup.eu>
 <202110130002.A7C0A86@keescook>
In-Reply-To: <202110130002.A7C0A86@keescook>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Kees Cook <keescook@chromium.org>, Helge Deller <deller@gmx.de>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org



Le 13/10/2021 à 09:02, Kees Cook a écrit :
> On Mon, Oct 11, 2021 at 05:25:33PM +0200, Christophe Leroy wrote:
>> dereference_function_descriptor() and
>> dereference_kernel_function_descriptor() are identical on the
>> three architectures implementing them.
>>
>> Make it common.
>>
>> Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>
>> ---
>>   arch/ia64/include/asm/sections.h    | 19 -------------------
>>   arch/parisc/include/asm/sections.h  |  9 ---------
>>   arch/parisc/kernel/process.c        | 21 ---------------------
>>   arch/powerpc/include/asm/sections.h | 23 -----------------------
>>   include/asm-generic/sections.h      | 18 ++++++++++++++++++
>>   5 files changed, 18 insertions(+), 72 deletions(-)
> 
> A diffstat to love. :)
> 
> Reviewed-by: Kees Cook <keescook@chromium.org>

Unless somebody minds, I will make them out of line as
suggested by Helge in he's comment to patch 4.

Allthough there is no spectacular size reduction, the functions
are not worth being inlined as they are not used in critical pathes.
