From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 25 Jan 2005 21:52:09 +0000
Subject: RE: [patch] ia64: Align rse_clear_invalid to double-bundle boundary.
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02CA9FAC@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16877.59631.914927.689418@napali.hpl.hp.com>
In-Reply-To: <16877.59631.914927.689418@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>David Mosberger wrote on Tuesday, January 25, 2005 12:42 PM
>> Oh, I should have used TEXT_ALIGN(32) instead of .align 32, since
>> .align inside a function was broken for a long time.
>>
>> Bjorn, Ken, does that fix your problem?
>
>
>Yes, that fixes my problem.

So I switched over to TEXT_ALIGN(32) instead of ".align", but the
speedup seems to have gone away (using TEXT_ALIGN is 6 cycles slower
than ".align").

-Tony
