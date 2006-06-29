From: "David Mosberger-Tang" <David.Mosberger@acm.org>
Date: Thu, 29 Jun 2006 18:42:27 +0000
Subject: Re: ia64 breakage in current -git
Message-Id: <ed5aea430606291142o4e2aea99s70e7db0348306725@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060627010646.21ff5687.akpm@osdl.org>
In-Reply-To: <20060627010646.21ff5687.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The problem seems to come from the use of $(*F) in Makefile.lib:

  _a_flags       = $(AFLAGS) $(EXTRA_AFLAGS) $(AFLAGS_$(*F).o)

If I use $(@F) instead of $(*F).o, the build works fine.

Using $(*F) seems wrong to me, since it expands to the stem, which in
the case of an explicit rule is the target-name minus any recognized
suffixes or the empty string if the target doesn't have a recognized
suffix.  I assume with -r, the old-fashioned suffix-rules are disabled
and hence $(*F) always yields the empty string for explicit rules.

Does this make sense?

  --david

On 6/27/06, Andrew Morton <akpm@osdl.org> wrote:
>
>
> fyi, Linus's current tree is bust on ia64 - you get a lot of link-time
> warnings about missing __udivdi3 and things.
>
> The below will get things going again.
>
> diff -puN Makefile~revert-ignore-makes-built-in-rules-variables Makefile
> --- a/Makefile~revert-ignore-makes-built-in-rules-variables
> +++ a/Makefile
> @@ -276,9 +276,9 @@ MAKEFLAGS += --include-dir=$(srctree)
>  # We need some generic definitions
>  include  $(srctree)/scripts/Kbuild.include
>
> -# Do not use make's built-in rules and variables
> -# This increases performance and avoid hard-to-debug behavour
> -MAKEFLAGS += -rR
> +# For maximum performance (+ possibly random breakage, uncomment
> +# the following)
> +#MAKEFLAGS += -rR
>
>  # Make variables (CC, etc...)
>
> _
>
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
Mosberger Consulting LLC, http://www.mosberger-consulting.com/
