From: Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com>
Date: Mon, 27 Mar 2006 08:09:20 +0000
Subject: Re: [PATCH 0/2] cleanup iosapic.c
Message-Id: <87fyl4fgwf.wl%takeuchi_satoru@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <87pskcfily.wl%takeuchi_satoru@jp.fujitsu.com>
In-Reply-To: <87pskcfily.wl%takeuchi_satoru@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Jes,

At 24 Mar 2006 05:26:02 -0500,
Jes Sorensen wrote:
> 
> >>>>> "Satoru" = Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com> writes:
> 
> Satoru> Hi, These patches clean up arch/ia64/kernel/iosapic.c.  The
> Satoru> changes are as follows:
> 
> Satoru> - [PATCH 1/2] correct some messages and fixes some some minor
> Satoru> typos.
> 
> Hi Satoru,
> 
> When you are in there fixing those types of issues, it would be nice
> if you also fixed the parts you are touching to comply with
> codingstyle at the same time (80 columns and tab indentation). Not a
> big thing, just seemed a good time to resolve it.
> 
> Cheers,
> Jes

OK, I fixed as you said. New patch is here.

These patches clean up arch/ia64/kernel/iosapic.c.
The changes are as follows:

- [PATCH 1/2] correct some messages and fixes some minor things.

- [PATCH 2/2] simplify some condition checks.

For more specifc information, please refer to the header of each patch.
These patches are against 2.6.16. I tested them on Tiger4.

Thanks,
Satoru Takeuchi
