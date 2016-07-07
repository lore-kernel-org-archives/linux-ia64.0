From: Kees Cook <keescook@chromium.org>
Date: Thu, 07 Jul 2016 17:19:26 +0000
Subject: Re: [PATCH 4/9] arm64/uaccess: Enable hardened usercopy
Message-Id: <CAGXu5jLeH2KL+FVi7mxBF5oH2-zMfwSY=2ReJOL4JYsQuJKy6Q@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1467843928-29351-1-git-send-email-keescook@chromium.org>
 <1467843928-29351-5-git-send-email-keescook@chromium.org> <20160707100717.GB8306@leverpostej>
In-Reply-To: <20160707100717.GB8306@leverpostej>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mark Rutland <mark.rutland@arm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Linux-MM <linux-mm@kvack.org>, sparclinux <sparclinux@vger.kernel.org>, linux-ia64@vger.kernel.org, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-arch <linux-arch@vger.kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, "x86@kernel.org" <x86@kernel.org>, Russell King <linux@armlinux.org.uk>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, PaX Team <pageexec@freemail.hu>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Fenghua Yu <fenghua.yu@intel.com>, Rik van Riel <riel@redhat.com>, Vitaly Wool <vitalywool@gmail.com>, David Rientjes <rientjes@google.com>, Tony Luck <tony.luck@intel.com>, Andy Lutomirski <luto@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, Brad Spengler <spender@grsecurity.net>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Pekka Enberg <penberg@kernel.org>, Casey Schaufler <casey@schaufler-ca.com>, Andrew Morton <akpm@linux-foundation.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "David S. Miller" <davem@davemloft.net>

On Thu, Jul 7, 2016 at 6:07 AM, Mark Rutland <mark.rutland@arm.com> wrote:
> Hi,
>
> On Wed, Jul 06, 2016 at 03:25:23PM -0700, Kees Cook wrote:
>> Enables CONFIG_HARDENED_USERCOPY checks on arm64. As done by KASAN in -next,
>> renames the low-level functions to __arch_copy_*_user() so a static inline
>> can do additional work before the copy.
>
> The checks themselves look fine, but as with the KASAN checks, it seems
> a shame that this logic is duplicated per arch, integrated in subtly
> different ways.
>
> Can we not __arch prefix all the arch uaccess helpers, and place
> kasan_check_*() and check_object_size() calls in generic wrappers?
>
> If we're going to update all the arch uaccess helpers anyway, doing that
> would make it easier to fix things up, or to add new checks in future.

Yeah, I totally agree, and my work on the next step of this hardening
will require something like this to separate the "check" logic from
the "copy" logic, as I want to introduce a set of constant-sized
copy_*_user helpers.

Though currently x86 poses a weird problem in this regard (they have
separate code paths for copy_* and __copy*, but I think it's actually
a harmless(?) mistake.

For now, I'd like to leave this as-is, and then do the copy_* cleanup,
then do step 2 (slab whitelisting).

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security
