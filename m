From: Dave Hansen <haveblue@us.ibm.com>
Date: Fri, 17 Mar 2006 17:58:17 +0000
Subject: Re: [PATCH: 012/017]Memory hotplug for new nodes v.4.(rebuild
Message-Id: <1142618297.10906.97.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060317163612.C64F.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20060317163612.C64F.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andrew Morton <akpm@osdl.org>, "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Fri, 2006-03-17 at 17:22 +0900, Yasunori Goto wrote:
> +++ pgdat8/mm/memory_hotplug.c  2006-03-17 13:53:40.712581399 +0900
> @@ -123,6 +123,7 @@ int online_pages(unsigned long pfn, unsi
>         unsigned long flags;
>         unsigned long onlined_pages = 0;
>         struct zone *zone;
> +       int need_refresh_zonelist = 0; 

I'd make this "need_to_rebuild_zonelists" or "need_zonelists_rebuild".
I think those sound a little bit better.

Plus, it makes even more sense when you see:

       if (need_to_rebuild_zonelists)
               build_all_zonelists();

if the names all match up.

-- Dave

