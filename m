From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 12 Oct 2021 08:02:03 +0000
Subject: Re: [PATCH v1 01/10] powerpc: Move 'struct ppc64_opd_entry' back into asm/elf.h
Message-Id: <CAK8P3a09azJ0fshthGeOqK92uaYJ+m39Yg1=YQav=n9n_PNt5w@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1633964380.git.christophe.leroy@csgroup.eu>
 <8ff3ec195d695033b652e9971fba2dc5528f7151.1633964380.git.christophe.leroy@csgroup.eu>
 <878ryy7m6v.fsf@mpe.ellerman.id.au>
In-Reply-To: <878ryy7m6v.fsf@mpe.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Christophe Leroy <christophe.leroy@csgroup.eu>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Kees Cook <keescook@chromium.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-ia64@vger.kernel.org, Parisc List <linux-parisc@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Tue, Oct 12, 2021 at 9:10 AM Michael Ellerman <mpe@ellerman.id.au> wrote:
> Christophe Leroy <christophe.leroy@csgroup.eu> writes:
> > 'struct ppc64_opd_entry' doesn't belong to uapi/asm/elf.h
> > But it was by mistake added outside of __KERNEL__ section,
> > therefore commit c3617f72036c ("UAPI: (Scripted) Disintegrate
> > arch/powerpc/include/asm") moved it to uapi/asm/elf.h
>
> ... it's been visible to userspace since the first commit moved it, ~13
> years ago in 2008, v2.6.27.
>
> > Move it back into asm/elf.h, this brings it back in line with
> > IA64 and PARISC architectures.
>
> Removing it from the uapi header risks breaking userspace, I doubt
> anything uses it, but who knows.
>
> Given how long it's been there I think it's a bit risky to remove it :/

I would not be too worried about it. While we should absolutely
never break existing binaries, changing the visibility of internal
structures in header files only breaks compiling applications
that do rely on these entries, and they really should not be using
this in the first place.

        Arnd
