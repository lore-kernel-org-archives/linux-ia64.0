From: Andrew Morton <akpm@osdl.org>
Date: Thu, 15 Dec 2005 02:56:58 +0000
Subject: Re: 2.6.15-rc5-mm2 can't boot on ia64 due to changing
Message-Id: <20051214185658.7a60aa07.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051215103344.241C.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20051215103344.241C.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mm@kvack.org, bcrl@kvack.org, tony.luck@intel.com

Yasunori Goto <y-goto@jp.fujitsu.com> wrote:
>
> When I removed following patch which is in 2.6.15-rc5-mm2,
>  which changes on_each_cpu() from static inline function to macro,
>  then there was no warning, and kernel could boot up.
>  So, I guess that gcc was not able to solve a bit messy cast
>  for calling function "local_flush_tlb_all()" due to its change.

Thanks.  I'll drop it.

I built and booted that kernel on my Tiger.  Odd.  I suspect there's
something very non-aggressive about my .config - this sort of thing has
happened before.
