From: Kees Cook <keescook@chromium.org>
Date: Fri, 08 Jul 2016 17:41:20 +0000
Subject: Re: [kernel-hardening] Re: [PATCH 9/9] mm: SLUB hardened usercopy support
Message-Id: <CAGXu5j+UdkQA+k39GNLe5CwBPVD5ZbRGTCQLqS8VF=kWx+PtsQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <577f7e55.4668420a.84f17.5cb9SMTPIN_ADDED_MISSING@mx.google.com>
 <alpine.DEB.2.20.1607080844370.3379@east.gentwo.org> <CAGXu5jKE=h32tHVLsDeaPN1GfC+BB3YbFvC+5TE5TK1oR-xU3A@mail.gmail.com>
 <alpine.DEB.2.20.1607081119170.6192@east.gentwo.org>
In-Reply-To: <alpine.DEB.2.20.1607081119170.6192@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <cl@linux.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Jan Kara <jack@suse.cz>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Linux-MM <linux-mm@kvack.org>, sparclinux <sparclinux@vger.kernel.org>, linux-ia64@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, linux-arch <linux-arch@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, Russell King <linux@armlinux.org.uk>, PaX Team <pageexec@freemail.hu>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Fenghua Yu <fenghua.yu@intel.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Tony Luck <tony.luck@intel.com>, Andy Lutomirski <luto@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, Brad Spengler <spender@grsecurity.net>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, LKML <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, Case y Schauf ler <casey@schaufler-ca.com>, Andrew Morton <akpm@linux-foundation.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "David S. Miller" <davem@davemloft.net>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Fri, Jul 8, 2016 at 12:20 PM, Christoph Lameter <cl@linux.com> wrote:
> On Fri, 8 Jul 2016, Kees Cook wrote:
>
>> Is check_valid_pointer() making sure the pointer is within the usable
>> size? It seemed like it was checking that it was within the slub
>> object (checks against s->size, wants it above base after moving
>> pointer to include redzone, etc).
>
> check_valid_pointer verifies that a pointer is pointing to the start of an
> object. It is used to verify the internal points that SLUB used and
> should not be modified to do anything different.

Yup, no worries -- I won't touch it. :) I just wanted to verify my
understanding.

And after playing a bit more, I see that the only thing to the left is
padding and redzone. SLUB layout, from what I saw:

offset: what's there
-------
start: padding, redzone
red_left_pad: object itself
inuse: rest of metadata
size: start of next slub object

(and object_size = inuse - red_left_pad)

i.e. a pointer must be between red_left_pad and inuse, which is the
same as pointer - ref_left_pad being less than object_size.

So, as found already, the position in the usercopy check needs to be
bumped down by red_left_pad, which is what Michael's fix does, so I'll
include it in the next version.

Thanks!

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security
