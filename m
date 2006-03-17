From: Dave Hansen <haveblue@us.ibm.com>
Date: Fri, 17 Mar 2006 17:55:47 +0000
Subject: Re: [PATCH: 011/017]Memory hotplug for new nodes v.4.(start kswapd)
Message-Id: <1142618147.10906.93.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060317163538.C64D.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20060317163538.C64D.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andrew Morton <akpm@osdl.org>, "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Fri, 2006-03-17 at 17:22 +0900, Yasunori Goto wrote
> +#ifdef CONFIG_MEMORY_HOTPLUG
> +/* start new kswapd for new node */
> +extern int kswapd_run(int nid);
> +#endif

I'd move this code down to where you actually use the extern.  I'd also
take the #ifdef out.  It won't hurt anything to have the extern there
all the time.

-- Dave

