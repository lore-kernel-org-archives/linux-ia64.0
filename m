From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 24 May 2007 16:18:21 +0000
Subject: RE: Question about output for PAL_VM_TR_READ call
Message-Id: <617E1C2C70743745A92448908E030B2A018835D5@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200705241644.03732.christian.kandeler@hob.de>
In-Reply-To: <200705241644.03732.christian.kandeler@hob.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I'd like to know why in the tr_info function in arch/ia64/kernel/palinfo.c the 
> ppn and vpn values are left-shifted by 12 bits in the sprintf call. They are 
> supposed to be page numbers, but this shift turns them into byte addresses, 
> doesn't it?

Looks like a mistake ... 'ppn' and 'vpn' sound like they stand for physical and
virtual page number, but we are printing addresses.

Printing "page numbers" here might be confusing (in what pagesize units should
we compute the page number?  Current complied in PAGE_SIZE for the kernel?  Or
the "ps" for this entry?

It would be better to just change the tags to "phys" and "virt" and keep the
numeric field the same.

Any change raises a user-space API change issue though ... does anyone know
of any applications that look at the tr_info file?  It seems highly improbable
(if someone had written code to parse this, perhaps they might have noticed
that this has been wrong since the dawn of time ... well at least since 2.4.0).

-Tony
