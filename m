From: Dave Hansen <haveblue@us.ibm.com>
Date: Fri, 10 Feb 2006 16:26:47 +0000
Subject: Re: [Lhms-devel] [RFC/PATCH: 001/010] Memory hotplug for new nodes
Message-Id: <1139588807.9209.71.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060210223757.C530.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20060210223757.C530.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>, linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>, x86-64 Discuss <discuss@x86-64.org>

On Fri, 2006-02-10 at 23:20 +0900, Yasunori Goto wrote:
> 
> -extern unsigned long __initdata nr_kernel_pages;
> -extern unsigned long __initdata nr_all_pages;
> +extern unsigned long __meminitdata nr_kernel_pages;
> +extern unsigned long __meminitdata nr_all_pages; 

Can you separate out these trivial changes into separate patches?

> +extern int kswapd(void *);
> +int new_pgdat_init(int nid, unsigned long start_pfn, unsigned long
> nr_pages)
> +{
> +       unsigned long zones_size[MAX_NR_ZONES] = {0};
> +       unsigned long zholes_size[MAX_NR_ZONES] = {0};
> +        unsigned long size = arch_pernode_size(nid);
> +       pg_data_t *pgdat;

Whitespace borkage?

-- Dave

