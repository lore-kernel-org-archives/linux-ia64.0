From: Dave Hansen <haveblue@us.ibm.com>
Date: Fri, 10 Feb 2006 16:32:08 +0000
Subject: Re: [Lhms-devel] [RFC/PATCH: 002/010] Memory hotplug for new nodes
Message-Id: <1139589128.9209.80.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060210223841.C532.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20060210223841.C532.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>, linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, x86-64 Discuss <discuss@x86-64.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>

On Fri, 2006-02-10 at 23:20 +0900, Yasunori Goto wrote:
> 
>  static __meminit
>  void zone_wait_table_init(struct zone *zone, unsigned long
> zone_size_pages)
>  {
> -       int i;
> +       int i, hotadd = (system_state = SYSTEM_RUNNING);
>         struct pglist_data *pgdat = zone->zone_pgdat;
> +       unsigned long allocsize;
>  
>         /*
>          * The per-page waitqueue mechanism uses hashed waitqueues
>          * per zone.
>          */
> +       if (hotadd && (zone_size_pages = PAGES_PER_SECTION))
> +               zone_size_pages = PAGES_PER_SECTION << 2; 

I don't think I understand this calculation.  You online only 4 sections
worth of pages?

-- Dave

