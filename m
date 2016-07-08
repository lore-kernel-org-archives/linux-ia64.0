From: Kees Cook <keescook@chromium.org>
Date: Fri, 08 Jul 2016 16:07:54 +0000
Subject: Re: [kernel-hardening] Re: [PATCH 9/9] mm: SLUB hardened usercopy support
Message-Id: <CAGXu5jKE=h32tHVLsDeaPN1GfC+BB3YbFvC+5TE5TK1oR-xU3A@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <577f7e55.4668420a.84f17.5cb9SMTPIN_ADDED_MISSING@mx.google.com> <alpine.DEB.2.20.1607080844370.3379@east.gentwo.org>
In-Reply-To: <alpine.DEB.2.20.1607080844370.3379@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <cl@linux.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Jan Kara <jack@suse.cz>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Linux-MM <linux-mm@kvack.org>, sparclinux <sparclinux@vger.kernel.org>, linux-ia64@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, linux-arch <linux-arch@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, Russell King <linux@armlinux.org.uk>, PaX Team <pageexec@freemail.hu>, Borislav Petkov <bp@suse.de>, lin <ux-arm-kernel@lists.infradead.org>, Mathias Krause <minipli@googlemail.com>, Fenghua Yu <fenghua.yu@intel.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Tony Luck <tony.luck@intel.com>, Andy Lutomirski <luto@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, Brad Spengler <spender@grsecurity.net>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, LKML <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, Case y Schauf ler <casey@schaufler-ca.com>, Andrew Morton <akpm@linux-foundation.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "David S. Miller" <davem@davemloft.net>

On Fri, Jul 8, 2016 at 9:45 AM, Christoph Lameter <cl@linux.com> wrote:
> On Fri, 8 Jul 2016, Michael Ellerman wrote:
>
>> > I wonder if this code should be using size_from_object() instead of s->size?

BTW, I can't reproduce this on x86 yet...

>>
>> Hmm, not sure. Who's SLUB maintainer? :)
>
> Me.
>
> s->size is the size of the whole object including debugging info etc.
> ksize() gives you the actual usable size of an object.

Is check_valid_pointer() making sure the pointer is within the usable
size? It seemed like it was checking that it was within the slub
object (checks against s->size, wants it above base after moving
pointer to include redzone, etc).

I think a potential problem with Michael's fix is that the ptr in
__check_heap_object() may not point at the _start_ of the usable
object, so doing the red zone shift isn't quite right.

This finds the ptr's offset within the slub object (since s->size is
the slub object size):

        offset = (ptr - page_address(page)) % s->size;

But this looks at object_size and doesn't take into account actual size:

        if (offset <= s->object_size && n <= s->object_size - offset)
                return NULL;

I think offset needs to be adjusted by the size of padding, which the
restore_red_left() call had the same effect, but may not cover all
padding conditions? I'm not sure.

Should it be:

        /* Find offset within slab object. */
        offset = (ptr - page_address(page)) % s->size;

        /* Adjust offset for meta data and padding. */
        offset -= s->size - s->object_size;

        /* Make sure offset and size are within bounds of the
allocation size. */
        if (offset <= s->object_size && n <= s->object_size - offset)
                return NULL;

?

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security
