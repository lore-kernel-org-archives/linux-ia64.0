From: Stephane Eranian <eranian@hpl.hp.com>
Date: Fri, 01 Dec 2006 20:45:32 +0000
Subject: Re: [PATCH] fix uninitialized string in get_model_name()
Message-Id: <20061201204532.GA709@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061201163035.GE31914@frankl.hpl.hp.com>
In-Reply-To: <20061201163035.GE31914@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Dec 01, 2006 at 09:15:05AM -0800, Luck, Tony wrote:
> > If ia64_pal_get_brand_info() fails in get_model_name() we may be copying
> > an invalid string.
> 
> I'm not sure I see how.  If ia64_pal_get_brand_info() succeeds, it returns
> 0, and must have copied a brand string to brand[].  If it fails (returns non-zero)
> we look family and model and fill in brand[] with something.
> 
Ah, yes, now I see that my logic was wrong on the return value of
ia64_pal_get_brand_info(), so I think the code is fine.

> 
> Ahh ... do you have a Montecito with some pre-production PAL that
> doesn't implement PAL_GET_BRAND_INFO?  That could mess up as we
> don't cover family = 0x20 inside the 'if' statement (as I thought
> that this PAL call was implemented early enough in Montecito that
> everyone would have it).

This can be a problem.

-- 
-Stephane
