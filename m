From: "Martin J. Bligh" <mbligh@aracnet.com>
Date: Wed, 06 Oct 2004 15:14:08 +0000
Subject: Re: [RFC/PATCH]  pfn_valid() more generic : arch independent part[0/2]
Message-Id: <1209350000.1097075647@[10.10.2.4]>
List-Id: <linux-ia64.vger.kernel.org>
References: <416392BF.1020708@jp.fujitsu.com>
In-Reply-To: <416392BF.1020708@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>, LinuxIA64 <linux-ia64@vger.kernel.org>
Cc: linux-mm <linux-mm@kvack.org>

> This is generic parts.
> 
> Boot-time routine:
> At first, information of valid pages is gathered into a list.
> After gathering all information, 2 level table are created.
> Why I create table instead of using a list is only for good cache hit.
> 
> pfn_valid_init()  <- initilize some structures
> validate_pages(start,size) <- gather valid pfn information
> pfn_valid_setup() <- create 1st and 2nd table.


Boggle. what on earth are you trying to do?

pfn_valid does exactly one thing - it checks whether there is a struct
page for that pfn. Nothing else. Surely that can't possibly take a tenth
of this amount of code?

M.

