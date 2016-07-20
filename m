From: Balbir Singh <bsingharora@gmail.com>
Date: Wed, 20 Jul 2016 10:24:43 +0000
Subject: Re: [PATCH v3 02/11] mm: Hardened usercopy
Message-Id: <1469010283.2800.5.camel@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1468619065-3222-1-git-send-email-keescook@chromium.org>
	 <1468619065-3222-3-git-send-email-keescook@chromium.org>
	 <fc3c7f68-bd2e-cb06-c47c-d97c520fc08b@redhat.com>
	 <CAGXu5j+nHpHcYT8FyHNe6AFQCdakoSMW=UWDatyxhRK7CB7_=g@mail.gmail.com>
In-Reply-To: <CAGXu5j+nHpHcYT8FyHNe6AFQCdakoSMW=UWDatyxhRK7CB7_=g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Daniel Micay <danielmicay@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, "x86@kernel.org" <x86@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-ia64@vger.kernel.org, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, sparclinux <sparclinux@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Tue, 2016-07-19 at 11:48 -0700, Kees Cook wrote:
> On Mon, Jul 18, 2016 at 6:06 PM, Laura Abbott <labbott@redhat.com> wrote:
> > 
> > On 07/15/2016 02:44 PM, Kees Cook wrote:
> > 
> > This doesn't work when copying CMA allocated memory since CMA purposely
> > allocates larger than a page block size without setting head pages.
> > Given CMA may be used with drivers doing zero copy buffers, I think it
> > should be permitted.
> > 
> > Something like the following lets it pass (I can clean up and submit
> > the is_migrate_cma_page APIs as a separate patch for review)
> Yeah, this would be great. I'd rather use an accessor to check this
> than a direct check for MIGRATE_CMA.
>
> >          */
> >         for (; ptr <= end ; ptr += PAGE_SIZE, page = virt_to_head_page(ptr))
> > {
> > -               if (!PageReserved(page))
> > +               if (!PageReserved(page) && !is_migrate_cma_page(page))
> >                         return "<spans multiple pages>";
> >         }
> Yeah, I'll modify this a bit so that which type it starts as is
> maintained for all pages (rather than allowing to flip back and forth
> -- even though that is likely impossible).
> 
Sorry, I completely missed the MIGRATE_CMA bits. Could you clarify if you
caught this in testing/review?

Balbir Singh.
