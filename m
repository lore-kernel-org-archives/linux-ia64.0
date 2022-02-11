From: Kees Cook <keescook@chromium.org>
Date: Fri, 11 Feb 2022 00:51:59 +0000
Subject: Re: [PATCH v3 01/12] powerpc: Move and rename func_descr_t
Message-Id: <202202101651.E6AACB3D4F@keescook>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1634457599.git.christophe.leroy@csgroup.eu>
 <637a9a11263afa216fdfa7fb470a54479c67c61c.1634457599.git.christophe.leroy@csgroup.eu>
In-Reply-To: <637a9a11263afa216fdfa7fb470a54479c67c61c.1634457599.git.christophe.leroy@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christophe Leroy <christophe.leroy@csgroup.eu>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Sun, Oct 17, 2021 at 02:38:14PM +0200, Christophe Leroy wrote:
> There are three architectures with function descriptors, try to
> have common names for the address they contain in order to
> refactor some functions into generic functions later.
> 
> powerpc has 'entry'
> ia64 has 'ip'
> parisc has 'addr'
> 
> Vote for 'addr' and update 'func_descr_t' accordingly.
> 
> Move it in asm/elf.h to have it at the same place on all
> three architectures, remove the typedef which hides its real
> type, and change it to a smoother name 'struct func_desc'.
> 
> Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>

I like the name. :)

Reviewed-by: Kees Cook <keescook@chromium.org>

-- 
Kees Cook
