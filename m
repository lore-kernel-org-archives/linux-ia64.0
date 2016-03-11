From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Fri, 11 Mar 2016 00:41:17 +0000
Subject: Re: [PATCH v3 0/4] generic relative extable support
Message-Id: <CAKv+Gu-WR3ssyaA+cXCgATJeq=1SgRr-dtqYdfDu3-pBoeXUBQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160310140702.0c1fd6129a62d10dadd5f3c3@linux-foundation.org>
In-Reply-To: <20160310140702.0c1fd6129a62d10dadd5f3c3@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-s390@vger.kernel.org, linux-ia64@vger.kernel.org, linux-alpha@vger.kernel.org

On 11 March 2016 at 05:07, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Thu, 10 Mar 2016 21:43:12 +0700 Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:
[...]
>> ---- v2 blurb ----
>> There are currently four architectures (x86, ia64, alpha and s390) whose
>> user-access exception tables are relative to the table entry address rather
>> than absolute. Each of these architectures has its own search_extable() and
>> sort_extable() implementation, which are not only mostly identical to each
>> other, but also deviate very little from the generic absolute implementations
>> in lib/extable.c that they override.
>>
>> So before making arm64 the fifth architecture that reimplements this, let's
>> refactor the existing code so that all of these architectures use common code
>> for searching and sorting the relative extables. Archs may set
>> ARCH_HAS_RELATIVE_EXTABLE to indicate that the table consists of a pair of
>> relative ints, and may define swap_ex_entry_fixup() if the fixup member needs
>> special treatment in the swapping step of the sorting routine (such as alpha).
>>
>
> I'll want to manually verify that the required patches are upstreamed.
> I assume we're referring to a272858a3c1ecd4a ("extable: add support for
> relative extables to search and sort routines") and related patches?
>

Correct. As long as that single patch is in, these are good to go.

Thanks,
Ard.
