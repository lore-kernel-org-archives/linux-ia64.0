From: Yasunori Goto <y-goto@jp.fujitsu.com>
Date: Fri, 19 Aug 2005 01:26:50 +0000
Subject: Re: [PATCH] gurantee DMA area for alloc_bootmem_low() ver. 2.
Message-Id: <20050819101023.62C5.Y-GOTO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050810145550.740D.Y-GOTO@jp.fujitsu.com> <20050818125236.4ffe1053.akpm@osdl.org>
In-Reply-To: <20050818125236.4ffe1053.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: peterc@gelato.unsw.edu.au, linux-mm@kvack.org, mbligh@mbligh.org, linux-ia64@vger.kernel.org, kravetz@us.ibm.com, tony.luck@intel.com

> >  To avoid this panic, following patch confirm allocated area, and retry
> >  if it is not in DMA.
> >  I tested this patch on my Tiger 4 and our new server.
> 
> It kills my x86_64 box:
> 
>  PID hash table entries: 4096 (order: 12, 131072 bytes)
>  time.c: Using 14.318180 MHz HPET timer.               
>  time.c: Detected 3400.236 MHz processor.
>  Console: colour VGA+ 80x25              
>  Dentry cache hash table entries: 1048576 (order: 11, 8388608 bytes)
>  Inode-cache hash table entries: 524288 (order: 10, 4194304 bytes)  
>  bootmem alloc of 67108864 bytes failed!                          
>  Kernel panic - not syncing: Out of memory

Thank you for your notification.

Unfortunately, I don't have x86_64 box. So, I can't trace its cause now.
I guess 67Mbyte allocation size might be trigger of its panic.
Hmm... :-(

Thanks.
-- 
Yasunori Goto 

