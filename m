From: Yasunori Goto <y-goto@jp.fujitsu.com>
Date: Wed, 13 Jul 2005 05:09:19 +0000
Subject: Re: [PATCH] gurantee DMA area for alloc_bootmem_low()
Message-Id: <20050713110109.F796.Y-GOTO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050712152715.44CD.Y-GOTO@jp.fujitsu.com> <9320000.1121179193@[10.10.2.4]>
In-Reply-To: <9320000.1121179193@[10.10.2.4]>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: linux-mm <linux-mm@kvack.org>, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org


> > To avoid this panic, following patch skips no DMA'ble node when 
> > lower address is required.
> > I tested this patch on my Tiger 4 and our new server.
> 
> Seems reasonable ... but do you not want to check that the returned
> ptr is actually less than MAX_DMA_ADDRESS as well? 

Well... If there isn't enough DMA area in a node by too much
lower memory request or by something strange memory map in the node,
its case might occur.
I don't know it will really happen. But, the after check might be better
than nothing.

To tell the truth, I did the after check at first
"instead of" previous check like this patch. 
In its patch, if its DMA check failed, 
allocated area are should be freed by free_bootmem_core(). 
But hung up occurred by it, and I changed my patch to previous check
instead of deep investigation of its hung up.

Ok. I'll investigate more.

Thanks.
-- 
Yasunori Goto 

