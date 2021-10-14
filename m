From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 14 Oct 2021 06:52:37 +0000
Subject: Re: [PATCH v2 07/13] asm-generic: Define 'func_desc_t' to commonly describe function descriptors
Message-Id: <CAK8P3a3yAcU0JAri0f9q6HVrZwX_4i6Y9X4P8MebN_Krt-SLQA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1634190022.git.christophe.leroy@csgroup.eu> <dbc9a149826eaa18f524635e64c207c85560c2aa.1634190022.git.christophe.leroy@csgroup.eu>
In-Reply-To: <dbc9a149826eaa18f524635e64c207c85560c2aa.1634190022.git.christophe.leroy@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christophe Leroy <christophe.leroy@csgroup.eu>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Kees Cook <keescook@chromium.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-ia64@vger.kernel.org, Parisc List <linux-parisc@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Thu, Oct 14, 2021 at 7:49 AM Christophe Leroy
<christophe.leroy@csgroup.eu> wrote:
>
> We have three architectures using function descriptors, each with its
> own name.
>
> Add a common typedef that can be used in generic code.
>
> Also add a stub typedef for architecture without function descriptors,
> to avoid a forest of #ifdefs.
>
> It replaces the similar func_desc_t previously defined in
> arch/powerpc/kernel/module_64.c
>
> Reviewed-by: Kees Cook <keescook@chromium.org>
> Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>

Acked-by: Arnd Bergmann <arnd@arndb.de>
