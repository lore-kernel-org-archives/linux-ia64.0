From: Andrew Morton <akpm@osdl.org>
Date: Thu, 28 Apr 2005 08:24:42 +0000
Subject: Re: [RFC] [PATCH] naming reserved pages and remove PG_uncached
Message-Id: <20050428012442.7a72cd08.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <42709BDD.3040805@jp.fujitsu.com>
In-Reply-To: <42709BDD.3040805@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> +#define clr_page_uncahced(page)\

typo there.

Please use "clear_page_uncacheed", not "clr_page_uncached".

Please avoid sending multiple patches under the same Subject:.  See
http://www.zip.com.au/~akpm/linux/patches/stuff/tpp.txt, thanks.

