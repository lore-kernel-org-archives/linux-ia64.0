From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 08 Sep 2004 04:28:34 +0000
Subject: Re: [PATCH] ia64: fix show_mem() for discontig machines
Message-Id: <200409072128.34693.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200409060132.03951.amgta@yacht.ocn.ne.jp>
In-Reply-To: <200409060132.03951.amgta@yacht.ocn.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mita akinobu <amgta@yacht.ocn.ne.jp>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, tony.luck@intel.com

On Sunday, September 5, 2004 9:32 am, mita akinobu wrote:
> Hello,
>
> On multi-node ia64 system, SysRq-M seems to dump wrong memory info.
> (Since I don't have such a large machine, I don't confirm it)
> It should reset counters every iteration each node in show_mem().

This looks good, though the bug sounds familiar.  Tony, care to apply?

Thanks,
Jesse
