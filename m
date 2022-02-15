From: Kees Cook <keescook@chromium.org>
Date: Tue, 15 Feb 2022 16:06:59 +0000
Subject: Re: [PATCH v4 01/13] powerpc: Fix 'sparse' checking on PPC64le
Message-Id: <202202150806.66CC906@keescook>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1644928018.git.christophe.leroy@csgroup.eu>
 <ac1312f2451aa558bb2a8806b4d0aa2020f0c176.1644928018.git.christophe.leroy@csgroup.eu>
In-Reply-To: <ac1312f2451aa558bb2a8806b4d0aa2020f0c176.1644928018.git.christophe.leroy@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christophe Leroy <christophe.leroy@csgroup.eu>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Tue, Feb 15, 2022 at 01:40:56PM +0100, Christophe Leroy wrote:
> 'sparse' is architecture agnostic and knows nothing about ELF ABI
> version.
> 
> Just like it gets arch and powerpc type and endian from Makefile,
> it also need to get _CALL_ELF from there, otherwise it won't set
> PPC64_ELF_ABI_v2 macro for PPC64le and won't check the correct code.
> 
> Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>

Reviewed-by: Kees Cook <keescook@chromium.org>

-- 
Kees Cook
