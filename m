From: Jack Steiner <steiner@sgi.com>
Date: Fri, 16 Mar 2001 21:07:53 +0000
Subject: [Linux-ia64] Status of 64K pagesize support
Message-Id: <marc-linux-ia64-105590693005288@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

What is the status of support for 64K pagesizes in IA64. Is anyone
actively working this??

I built a 2.4.2 kernel with 64K pages & immediately hit 2
problems:

	- gcc doesnt support 64K alignment (perhaps I am using
	  an old gcc??)

	- drivers/scsi/scsi_dma.c has a bitmap 
	  that overflows with 64K pages.


I dont mind working on these issues but first wanted to check if
anyone else is working on them.

What other issues are people aware of that are lurking.....



-- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com


