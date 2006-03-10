From: Yasunori Goto <y-goto@jp.fujitsu.com>
Date: Fri, 10 Mar 2006 07:20:37 +0000
Subject: Re: [PATCH: 010/017](RFC) Memory hotplug for new nodes v.3. (allocate wait table)
Message-Id: <20060310154910.CA79.Y-GOTO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060309040055.21f3ec2d.akpm@osdl.org> <200603090556.06226.ak@suse.de>
In-Reply-To: <200603090556.06226.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>, Andrew Morton <akpm@osdl.org>
Cc: tony.luck@intel.com, jschopp@austin.ibm.com, haveblue@us.ibm.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

> On Thursday 09 March 2006 13:00, Andrew Morton wrote:
> > Yasunori Goto <y-goto@jp.fujitsu.com> wrote:
> > >
> > >  +		/* we can use kmalloc() in run time */
> > >  +		do {
> > >  +			table_size = zone->wait_table_size
> > >  +					* sizeof(wait_queue_head_t);
> > >  +			zone->wait_table = kmalloc(table_size, GFP_ATOMIC);
> > 
> > Again, GFP_KERNEL would be better is possible.

Oops.
This was inside of spin_lock in old my patch.
But, it is moved out from spin_lock as a result of refactoring 
and I didn't notice that.
Yes. GFP_KERNEL is better.

> > 
> > Won't this place the node's wait_table into a different node's memory?
> 
> Yes, kmalloc_node would be better.

Kmalloc_node() will not work well at here, 
because this patch is to initialize structures for new node -itself-.
It will work after that completion of initalize pgdat and wait_table.

To use new node's memory at here, other consideration will be necessary. 
But, I would like to use kmalloc() to simplify my patch at this time.

Thanks.

-- 
Yasunori Goto 


