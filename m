From: Dave Hansen <haveblue@us.ibm.com>
Date: Fri, 17 Feb 2006 15:52:37 +0000
Subject: Re: [PATCH: 004/012] Memory hotplug for new nodes v.2. (pgdat
Message-Id: <1140191557.21383.79.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060217211436.4070.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20060217211436.4070.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andrew Morton <akpm@osdl.org>, "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>, Joel Schopp <jschopp@austin.ibm.com>, linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, x86-64 Discuss <discuss@x86-64.org>

On Fri, 2006-02-17 at 22:28 +0900, Yasunori Goto wrote:
> 
> +       if (node < 0)
> +               node = 0; /* pxm is undefined in DSDT.
> +                            This might be non NUMA case */
> +
> +       if (!node_online(node)){
> +               ret = new_pgdat_init(node, start_pfn, nr_pages);
> +               if (ret)
> +                       return ret;
> +
> +               new_pgdat = 1;
> +       }
> +       pgdat = NODE_DATA(node); 

Now that I've seen this exact code copy-and-pasted into two different
architectures, it begs the question: do we need a common function here?

-- Dave

