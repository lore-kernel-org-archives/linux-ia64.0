From: Oleg Verych <olecom@flower.upol.cz>
Date: Wed, 30 May 2007 21:57:49 +0000
Subject: Re: [KJ][PATCH 02/03]ROUND_UP|DOWN macro cleanup in arch/ia64,x86_64
Message-Id: <E1HtWAv-00028d-9l@flower>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070413043140.GA9431@arun.site> <617E1C2C70743745A92448908E030B2A015B4E12@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A015B4E12@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Milind Arun Choudhary <milindchoudhary@gmail.com>, kernel-janitors@lists.osdl.org, linux-ia64@vger.kernel.org, discuss@x86-64.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, ak@suse.de

* From: "Luck, Tony"
* Date: Fri, 13 Apr 2007 09:45:49 -0700

>> So as ALIGN macro does the same work as ROUNDUP,
>
> Although it is mathematically the same operation, the
> semantic associations of the name are important too.
[]
> Maybe this is because I started out in mathematics before
> discovering that computers were so much fun, or maybe it
> is a British-English bias ... I can't tell, but it makes
> sense to me to use ROUNDUP in some places, and ALIGN in
> others.

I agree. I came from neither one (still coming); first look and vague
semantics of ALIGN macro, English confusion, a bit of laziness, led me to
stupid messages about aligning, Linus being so kind to reply, a couple of
months ago. Anyway i did that after some patching and re-patching that
macro by gurus :).

> If ROUNDUP isn't available everywhere, then it should be. To
> avoid code duplication perhaps we should add:
>
>     #define ROUNDUP(size, len) ALIGN((size), (len))
>
> and delete the previous ROUNDUP definition?

And i would vote for "align" via "round".
____
