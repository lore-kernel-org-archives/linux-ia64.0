From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 10 Mar 2016 22:07:02 +0000
Subject: Re: [PATCH v3 0/4] generic relative extable support
Message-Id: <20160310140702.0c1fd6129a62d10dadd5f3c3@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1457620996-462-1-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1457620996-462-1-git-send-email-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 10 Mar 2016 21:43:12 +0700 Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:

> This is basically a resend of the remaining relative extable rework patches
> that were queued for v4.6 in Andrew's tree for a couple of weeks, and then
> subsequently dropped due to conflicts with the arm64 and x86 subtrees in -next.
> 
> Since the core patch that these remaining patches depend on is now queued in
> the arm64 tree for inclusion in v4.6, I have rebased this series onto
> next-20160310 so that they may be requeued and hopefully merged late during the
> next merge window. Alternatively, they could be picked up by each maintainer
> separately since they are all independent. Queueing them for v4.7 is likely
> to result in conflicts again, so I think that would be the least preferable
> option.

Yup, these all look good to merge.

> ---- v2 blurb ----
> There are currently four architectures (x86, ia64, alpha and s390) whose
> user-access exception tables are relative to the table entry address rather
> than absolute. Each of these architectures has its own search_extable() and
> sort_extable() implementation, which are not only mostly identical to each
> other, but also deviate very little from the generic absolute implementations
> in lib/extable.c that they override.
> 
> So before making arm64 the fifth architecture that reimplements this, let's
> refactor the existing code so that all of these architectures use common code
> for searching and sorting the relative extables. Archs may set
> ARCH_HAS_RELATIVE_EXTABLE to indicate that the table consists of a pair of
> relative ints, and may define swap_ex_entry_fixup() if the fixup member needs
> special treatment in the swapping step of the sorting routine (such as alpha).
> 

I'll want to manually verify that the required patches are upstreamed. 
I assume we're referring to a272858a3c1ecd4a ("extable: add support for
relative extables to search and sort routines") and related patches?

