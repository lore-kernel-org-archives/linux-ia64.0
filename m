From: James Bottomley <James.Bottomley@SteelEye.com>
Date: Tue, 14 Sep 2004 19:00:37 +0000
Subject: Re: Oops in free_page_and_swap_cache on 2.6.9-rc2
Message-Id: <1095188442.1762.35.camel@mulgrave>
List-Id: <linux-ia64.vger.kernel.org>
References: <1095176571.1762.14.camel@mulgrave>
In-Reply-To: <1095176571.1762.14.camel@mulgrave>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2004-09-14 at 13:21, James Bottomley wrote:
> It could be.  Jesse Barnes suggested that the problem might be because
> CONFIG_DISCONTIGMEM isn't set in the zx1_defconfig, so I'm going to try
> to reproduce with generic_defconfig instead.

OK, with the CONFIG_DISCONTIGMEM=y I can't reproduce this.  It looks
like pfn_to_page() is only broken when CONFIG_DISCONTIGMEM isn't set.

James


