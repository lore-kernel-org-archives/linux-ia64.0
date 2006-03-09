From: Andrew Morton <akpm@osdl.org>
Date: Thu, 09 Mar 2006 12:00:55 +0000
Subject: Re: [PATCH: 010/017](RFC) Memory hotplug for new nodes v.3.
Message-Id: <20060309040055.21f3ec2d.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060308213301.0036.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20060308213301.0036.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: tony.luck@intel.com, ak@suse.de, jschopp@austin.ibm.com, haveblue@us.ibm.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Yasunori Goto <y-goto@jp.fujitsu.com> wrote:
>
>  +		/* we can use kmalloc() in run time */
>  +		do {
>  +			table_size = zone->wait_table_size
>  +					* sizeof(wait_queue_head_t);
>  +			zone->wait_table = kmalloc(table_size, GFP_ATOMIC);

Again, GFP_KERNEL would be better is possible.

Won't this place the node's wait_table into a different node's memory?
