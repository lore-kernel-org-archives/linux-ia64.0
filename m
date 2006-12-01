From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 01 Dec 2006 17:15:05 +0000
Subject: RE: [PATCH] fix uninitialized string in get_model_name()
Message-Id: <617E1C2C70743745A92448908E030B2ADC4DFB@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061201163035.GE31914@frankl.hpl.hp.com>
In-Reply-To: <20061201163035.GE31914@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> If ia64_pal_get_brand_info() fails in get_model_name() we may be copying
> an invalid string.

I'm not sure I see how.  If ia64_pal_get_brand_info() succeeds, it returns
0, and must have copied a brand string to brand[].  If it fails (returns non-zero)
we look family and model and fill in brand[] with something.

I suppose that techincally there is a gap in the switch statement for
model 0x1f as there is no default: case ... but I'm sure that 0, 1, 2
cover all the models that were released with family 0x1f.

> +	memset(brand, 0, sizeof(brand));

But if I missed something, this is overkill, there is no need to
fill the entire brand[] array with NUL ... just:

	brand[0] = '\0';

should be enough.  Or you could use memcpy(brand, "Unknown", 8) and
delete it from the "else" clause just below.

-Tony

Ahh ... do you have a Montecito with some pre-production PAL that
doesn't implement PAL_GET_BRAND_INFO?  That could mess up as we
don't cover family = 0x20 inside the 'if' statement (as I thought
that this PAL call was implemented early enough in Montecito that
everyone would have it).
