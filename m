From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 13 Oct 2021 11:34:33 +0000
Subject: Re: [PATCH v1 06/10] asm-generic: Refactor dereference_[kernel]_function_descriptor()
Message-Id: <CAK8P3a0G8zOD-DJVOxWWwHgGUWQC2yxgMMKYrBQTgVLAicC7pw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1633964380.git.christophe.leroy@csgroup.eu>
 <c215b244a19a07327ec81bf99f3c5f89c68af7b4.1633964380.git.christophe.leroy@csgroup.eu>
 <202110130002.A7C0A86@keescook> <c2904a2e-c112-f2bc-04a0-52b08b46c1ce@csgroup.eu>
In-Reply-To: <c2904a2e-c112-f2bc-04a0-52b08b46c1ce@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Christophe Leroy <christophe.leroy@csgroup.eu>
Cc: Kees Cook <keescook@chromium.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-ia64@vger.kernel.org, Parisc List <linux-parisc@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Wed, Oct 13, 2021 at 1:20 PM Christophe Leroy
<christophe.leroy@csgroup.eu> wrote:
> Le 13/10/2021 à 09:02, Kees Cook a écrit :
> > On Mon, Oct 11, 2021 at 05:25:33PM +0200, Christophe Leroy wrote:
> >> dereference_function_descriptor() and
> >> dereference_kernel_function_descriptor() are identical on the
> >> three architectures implementing them.
> >>
> >> Make it common.
> >>
> >> Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>
> >> ---
> >>   arch/ia64/include/asm/sections.h    | 19 -------------------
> >>   arch/parisc/include/asm/sections.h  |  9 ---------
> >>   arch/parisc/kernel/process.c        | 21 ---------------------
> >>   arch/powerpc/include/asm/sections.h | 23 -----------------------
> >>   include/asm-generic/sections.h      | 18 ++++++++++++++++++
> >>   5 files changed, 18 insertions(+), 72 deletions(-)
> >
> > A diffstat to love. :)
> >
> > Reviewed-by: Kees Cook <keescook@chromium.org>

Reviewed-by: Arnd Bergmann <arnd@arndb.de>

> Unless somebody minds, I will make them out of line as
> suggested by Helge in he's comment to patch 4.
>
> Allthough there is no spectacular size reduction, the functions
> are not worth being inlined as they are not used in critical pathes.

Sounds good to me.

      Arnd
