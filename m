From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Thu, 14 Oct 2021 07:20:32 +0000
Subject: Re: [PATCH v1 04/10] asm-generic: Use HAVE_DEREFERENCE_FUNCTION_DESCRIPTOR to define associated stub
Message-Id: <dbce3a00-2f1a-bb6d-98b5-5f73c14dad9d@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1633964380.git.christophe.leroy@csgroup.eu>
 <8db2a3ca2b26a8325c671baa3e0492914597f079.1633964380.git.christophe.leroy@csgroup.eu>
 <202110122359.E59B90A@keescook>
In-Reply-To: <202110122359.E59B90A@keescook>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Kees Cook <keescook@chromium.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org



Le 13/10/2021 à 09:00, Kees Cook a écrit :
> On Mon, Oct 11, 2021 at 05:25:31PM +0200, Christophe Leroy wrote:
>> Use HAVE_DEREFERENCE_FUNCTION_DESCRIPTOR instead of 'dereference_function_descriptor'
>> to know whether arch has function descriptors.
>>
>> Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>
> 
> I'd mention the intentionally-empty #if/#else in the commit log, as I,
> like Helge, mentally tripped over it in the review. :)
> 
> Reviewed-by: Kees Cook <keescook@chromium.org>
> 

Ok, I did it in v2.

I also renamed it HAVE_FUNCTION_DESCRIPTORS because behind the fact that 
it has some functions to dereference function descriptor, the main fact 
is that they have and use function descriptors.

Christophe
