From: Oscar Salvador <osalvador@suse.de>
Date: Mon, 14 Sep 2020 08:19:26 +0000
Subject: Re: [PATCH 2/3] mm: don't rely on system state to detect hot-plug operations
Message-Id: <20200914081921.GA15113@linux>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200911134831.53258-1-ldufour@linux.ibm.com>
 <20200911134831.53258-3-ldufour@linux.ibm.com>
 <f50fe4ae-faf0-6e03-b87e-45ca8c53960d@redhat.com>
In-Reply-To: <f50fe4ae-faf0-6e03-b87e-45ca8c53960d@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>
Cc: Laurent Dufour <ldufour@linux.ibm.com>, akpm@linux-foundation.org, mhocko@kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, "Rafael J . Wysocki" <rafael@kernel.org>, nathanl@linux.ibm.com, cheloha@linux.ibm.com, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Michal Hocko <mhocko@suse.com>

On Mon, Sep 14, 2020 at 09:57:46AM +0200, David Hildenbrand wrote:
> >  /* register memory section under specified node if it spans that node */
> > +struct rmsun_args {
> > +	int nid;
> > +	enum memplug_context context;
> > +};

Uhmf, that is a not so descriptive name.

> Instead of handling this in register_mem_sect_under_node(), I
> think it would be better two have two separate
> register_mem_sect_under_node() implementations.
> 
> static int register_mem_sect_under_node_hotplug(struct memory_block *mem_blk,
> 						void *arg)
> {
> 	const int nid = *(int *)arg;
> 	int ret;
> 
> 	/* Hotplugged memory has no holes and belongs to a single node. */
> 	mem_blk->nid = nid;
> 	ret = sysfs_create_link_nowarn(&node_devices[nid]->dev.kobj,
> 				       &mem_blk->dev.kobj,
> 				       kobject_name(&mem_blk->dev.kobj));
> 	if (ret)
> 		returnr et;
> 	return sysfs_create_link_nowarn(&mem_blk->dev.kobj,
> 					&node_devices[nid]->dev.kobj,
> 					kobject_name(&node_devices[nid]->dev.kobj));
> 
> }
> 
> Cleaner, right? :) No unnecessary checks.

I tend to agree here, I like more a simplistic version for hotplug.

> One could argue if link_mem_section_hotplug() would be better than passing around the context.

I am not sure if I would duplicate the code there.
We could just pass the pointer of the function we want to call to
link_mem_sections? either register_mem_sect_under_node_hotplug or
register_mem_sect_under_node_early?
Would not that be clean and clear enough?

-- 
Oscar Salvador
SUSE L3
