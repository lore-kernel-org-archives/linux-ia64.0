From: Dave Hansen <haveblue@us.ibm.com>
Date: Fri, 17 Feb 2006 15:39:52 +0000
Subject: Re: [PATCH: 001/012] Memory hotplug for new nodes v.2. (pgdat
Message-Id: <1140190792.21383.64.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060217210749.406A.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20060217210749.406A.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andrew Morton <akpm@osdl.org>, "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>, Joel Schopp <jschopp@austin.ibm.com>, linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, x86-64 Discuss <discuss@x86-64.org>

On Fri, 2006-02-17 at 22:28 +0900, Yasunori Goto wrote:
> 
> +extern int kswapd(void *);

In a header, please.  

> +int new_pgdat_init(int nid, unsigned long start_pfn, unsigned long
> nr_pages)
> +{
> +       unsigned long zones_size[MAX_NR_ZONES] = {0};
> +       unsigned long zholes_size[MAX_NR_ZONES] = {0};
> +       unsigned long pernode_size = arch_pernode_size(nid);
> +       pg_data_t *pgdat;
> +       struct task_struct *p;
> +
> +       pgdat = kmalloc(pernode_size, GFP_KERNEL);
> +       if (!pgdat){
> +               printk(KERN_ERR "%s node_data allocation failed\n",
> +                       __FUNCTION__);
> +               return -ENODEV;
> +       }
> +
> +       memset(pgdat, 0, pernode_size);

kzalloc() instead of explicit kmalloc/memset, please.

I'm a teensy bit concerned that this doesn't share enough code with the
boot-time initialization.  For instance, the kthread_create() seems to
be a pretty darn generic piece.  I'd feel a lot more at ease if this
patch did something with _existing_ code instead of just adding.

Also, can the regular boot code use your set_node_data_array() function?
Can you take out the "_array" part of the name? 

-- Dave

