From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Date: Mon, 11 Jul 2016 06:08:29 +0000
Subject: Re: [kernel-hardening] Re: [PATCH 9/9] mm: SLUB hardened usercopy support
Message-Id: <20160711060829.GB14107@js1304-P5Q-DELUXE>
List-Id: <linux-ia64.vger.kernel.org>
References: <577f7e55.4668420a.84f17.5cb9SMTPIN_ADDED_MISSING@mx.google.com>
 <alpine.DEB.2.20.1607080844370.3379@east.gentwo.org>
 <CAGXu5jKE=h32tHVLsDeaPN1GfC+BB3YbFvC+5TE5TK1oR-xU3A@mail.gmail.com>
 <alpine.DEB.2.20.1607081119170.6192@east.gentwo.org>
 <CAGXu5j+UdkQA+k39GNLe5CwBPVD5ZbRGTCQLqS8VF=kWx+PtsQ@mail.gmail.com>
 <CAGXu5jKxw3RxWNKLX4XVCwJ6x_zA=_RwiU9jLDm2+VRO79G7+w@mail.gmail.com>
In-Reply-To: <CAGXu5jKxw3RxWNKLX4XVCwJ6x_zA=_RwiU9jLDm2+VRO79G7+w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kees Cook <keescook@chromium.org>
Cc: Christoph Lameter <cl@linux.com>, Michael Ellerman <mpe@ellerman.id.au>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Jan Kara <jack@suse.cz>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Linux-MM <linux-mm@kvack.org>, sparclinux <sparclinux@vger.kernel.org>, linux-ia64@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, linux-arch <linux-arch@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, Russell King <linux@armlinux.org.uk>, PaX Team <pageexec@freemail.hu>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Fenghua Yu <fenghua.yu@intel.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Tony Luck <tony.luck@intel.com>, Andy Lutomirski <luto@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, Brad Spengler <spender@grsecurity.net>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, LKML <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, Case y Schauf ler <casey@schaufler-ca.com>, Andrew Morton <akpm@linux-foundation.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "David S. Miller" <davem@davemloft.net>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Fri, Jul 08, 2016 at 04:48:38PM -0400, Kees Cook wrote:
> On Fri, Jul 8, 2016 at 1:41 PM, Kees Cook <keescook@chromium.org> wrote:
> > On Fri, Jul 8, 2016 at 12:20 PM, Christoph Lameter <cl@linux.com> wrote:
> >> On Fri, 8 Jul 2016, Kees Cook wrote:
> >>
> >>> Is check_valid_pointer() making sure the pointer is within the usable
> >>> size? It seemed like it was checking that it was within the slub
> >>> object (checks against s->size, wants it above base after moving
> >>> pointer to include redzone, etc).
> >>
> >> check_valid_pointer verifies that a pointer is pointing to the start of an
> >> object. It is used to verify the internal points that SLUB used and
> >> should not be modified to do anything different.
> >
> > Yup, no worries -- I won't touch it. :) I just wanted to verify my
> > understanding.
> >
> > And after playing a bit more, I see that the only thing to the left is
> > padding and redzone. SLUB layout, from what I saw:
> >
> > offset: what's there
> > -------
> > start: padding, redzone
> > red_left_pad: object itself
> > inuse: rest of metadata
> > size: start of next slub object
> >
> > (and object_size = inuse - red_left_pad)
> >
> > i.e. a pointer must be between red_left_pad and inuse, which is the
> > same as pointer - ref_left_pad being less than object_size.
> >
> > So, as found already, the position in the usercopy check needs to be
> > bumped down by red_left_pad, which is what Michael's fix does, so I'll
> > include it in the next version.
> 
> Actually, after some offline chats, I think this is better, since it
> makes sure the ptr doesn't end up somewhere weird before we start the
> calculations. This leaves the pointer as-is, but explicitly handles
> the redzone on the offset instead, with no wrapping, etc:
> 
>         /* Find offset within object. */
>         offset = (ptr - page_address(page)) % s->size;
> 
> +       /* Adjust for redzone and reject if within the redzone. */
> +       if (s->flags & SLAB_RED_ZONE) {
> +               if (offset < s->red_left_pad)
> +                       return s->name;
> +               offset -= s->red_left_pad;
> +       }
> +
>         /* Allow address range falling entirely within object size. */
>         if (offset <= s->object_size && n <= s->object_size - offset)
>                 return NULL;
> 

As Christoph saids, please use slab_ksize() rather than
s->object_size.

Otherwise, looks good to me.

Thanks.

