From: "PaX Team" <pageexec@freemail.hu>
Date: Sat, 09 Jul 2016 23:16:36 +0000
Subject: Re: [PATCH 0/9] mm: Hardened usercopy
Message-Id: <578185D4.29090.242668C8@pageexec.freemail.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <1467843928-29351-1-git-send-email-keescook@chromium.org>, <CALCETrU5Emr7jZNH5bh7Z+C8fLOcAah9SzeJbDjqW7N-xWGxHA@mail.gmail.com>
In-Reply-To: <CALCETrU5Emr7jZNH5bh7Z+C8fLOcAah9SzeJbDjqW7N-xWGxHA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kees Cook <keescook@chromium.org>, Andy Lutomirski <luto@amacapital.net>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Brad Spengler <spender@grsecurity.net>, Pekka Enberg <penberg@kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Casey Schaufler <casey@schaufler-ca.com>, Will Deacon <will.deacon@arm.com>, Rik van Riel <riel@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dmitry Vyukov <dvyukov@google.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, X86 ML <x86@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, linux-arch <linux-arch@vger.kernel.org>, David Rientjes <rientjes@google.com>, Mathias Krause <minipli@googlemail.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@fedoraproject.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, Russell King <linux@armlinux.org.uk>, Michael Ellerman <mpe@ellerman.id.au>, Andrea Arcangeli <aarcange@redhat.com>, Fenghua Yu <fenghua.yu@intel.com>, linuxppc-dev@lists.ozlabs.org, Vitaly Wool <vitalywool@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@suse.de>, Tony Luck <tony.luck@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, sparclinux@vger.kernel.org

On 9 Jul 2016 at 14:27, Andy Lutomirski wrote:

> On Jul 6, 2016 6:25 PM, "Kees Cook" <keescook@chromium.org> wrote:
> >
> > Hi,
> >
> > This is a start of the mainline port of PAX_USERCOPY[1]. After I started
> > writing tests (now in lkdtm in -next) for Casey's earlier port[2], I
> > kept tweaking things further and further until I ended up with a whole
> > new patch series. To that end, I took Rik's feedback and made a number
> > of other changes and clean-ups as well.
> >
> 
> I like the series, but I have one minor nit to pick.  The effect of
> this series is to harden usercopy, but most of the code is really
> about infrastructure to validate that a pointed-to object is valid.

actually USERCOPY has never been about validating pointers. its sole purpose
is to validate the *size* argument of copy*user calls, a very specific form
of runtime bounds checking. it's only really relevant for slab objects and the
pointer checks (that one might mistake for being a part of the defense mechanism)
are only there to determine whether the kernel pointer refers to a slab object
or not (the stack part is a small bonus and was never the main goal either).

> Might it make sense to call the infrastructure part something else?

yes, more bikeshedding will surely help, like the renaming of .data..read_only
to .data..ro_after_init which also had nothing to do with init but everything
to do with objects being conceptually read-only...

> After all, this could be extended in the future for memcpy or even for
> some GCC plugin to check pointers passed to ordinary (non-allocator)
> functions.

what kind of checks are you thinking of here? and more fundamentally, against
what kind of threats? as for memcpy, it's the standard mandated memory copying
function, what security related properties can it check on its pointer arguments?

