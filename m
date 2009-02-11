From: Ingo Molnar <mingo@elte.hu>
Date: Wed, 11 Feb 2009 12:32:49 +0000
Subject: Re: [PATCH] SGI IA64 UV: fix ia64 build error in the linux-next
Message-Id: <20090211123249.GE16535@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090209162520.GA4882@sgi.com>
In-Reply-To: <20090209162520.GA4882@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dean Nelson <dcn@sgi.com>
Cc: Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-ia64 <linux-ia64@vger.kernel.org>, linux-next <linux-next@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>


* Dean Nelson <dcn@sgi.com> wrote:

> Fix the ia64 build error that occurs in the linux-next tree by introducing
> an ia64 version of uv.h.  Additionally, clean up the usage of is_uv_system().
> 
> Signed-off-by: Dean Nelson <dcn@sgi.com>
> Signed-off-by: Jack Steiner <steiner@sgi.com>

Applied, thanks Dean!

Tony, since this breakage is an accidental side-effect of the x86 tree (that
has to be fixed there), mind if we carry it there?

	Ingo
