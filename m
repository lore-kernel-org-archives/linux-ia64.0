From: Yasunori Goto <y-goto@jp.fujitsu.com>
Date: Fri, 27 May 2005 05:14:12 +0000
Subject: Re: [patch 0/4] ia64 SPARSEMEM
Message-Id: <20050527110405.6745.Y-GOTO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050523175031.GC2783@localhost.localdomain>
In-Reply-To: <20050523175031.GC2783@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello. Jack-san.

> > > a smaller number ... his banks of memory all start on 4G boundaries,
> 
> All banks (currently) start on 16GB boundaries. I don't think it
> matters, but directory memory occupies the last 1/32 of each DIMM. This
> means that memory blocks are slightly smaller than you might expect. The
> bios marks the directory memory as "unavailable".

Then, I don't think section size must be same with
its directory memory size. When pages are registered by __free_pages(),
kernel distinguish RAM from the areas for firmware
(ex, page_is_ram()) before free, firmware page become reserved page, 
and kernel doesn't use it.
If you make a code that kernel asks its BIOS, the status of directory
memory pages will be reserved. I think section size can be 16GB
for your case.

Thanks.
-- 
Yasunori Goto 

