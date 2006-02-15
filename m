From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 15 Feb 2006 01:06:39 +0000
Subject: Re: [Lhms-devel] [RFC/PATCH: 002/010] Memory hotplug for new nodes
Message-Id: <43F27E9F.9030005@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060211125941.D35C.Y-GOTO@jp.fujitsu.com> <43EDC35B.5060106@jp.fujitsu.com> <20060214221413.ECF3.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20060214221413.ECF3.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>, linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, x86-64 Discuss <discuss@x86-64.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>

Yasunori Goto wrote:
> +	if (system_state = SYSTEM_RUNNING){
> +		unsigned long queue_head_size = 1;
> +		while (queue_head_size < sizeof(wait_queue_head_t))
> +		       queue_head_size <<= 1;
> +
> +		pages = (1 << (PAGE_SHIFT + 3)) / queue_head_size;
> +	}
> +
we have to kmalloc() wait_table after this.
I don't think we always succeed to alloc multiple contiguous pages by kmalloc().
How about allocating wait_table like this ?
=
size = 4096; /* 4096 is maximum size */
while(size) {
	waittable = kmalloc(size * sizeof(wait_queue_head_t), GFP_KERNEL):
	if (wait_table)
		break;
	size = size >> 1;
}
zone->wait_table_size = size;
zone->wait_table_bits = wait_table_bits(zone->wait_table_size);
zone->wait_table = wait_table;
=


-- Kame



