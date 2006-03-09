From: Andi Kleen <ak@suse.de>
Date: Thu, 09 Mar 2006 04:56:04 +0000
Subject: Re: [PATCH: 010/017](RFC) Memory hotplug for new nodes v.3. (allocate wait table)
Message-Id: <200603090556.06226.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060308213301.0036.Y-GOTO@jp.fujitsu.com> <20060309040055.21f3ec2d.akpm@osdl.org>
In-Reply-To: <20060309040055.21f3ec2d.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, tony.luck@intel.com, jschopp@austin.ibm.com, haveblue@us.ibm.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thursday 09 March 2006 13:00, Andrew Morton wrote:
> Yasunori Goto <y-goto@jp.fujitsu.com> wrote:
> >
> >  +		/* we can use kmalloc() in run time */
> >  +		do {
> >  +			table_size = zone->wait_table_size
> >  +					* sizeof(wait_queue_head_t);
> >  +			zone->wait_table = kmalloc(table_size, GFP_ATOMIC);
> 
> Again, GFP_KERNEL would be better is possible.
> 
> Won't this place the node's wait_table into a different node's memory?

Yes, kmalloc_node would be better.

-Andi


