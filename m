From: Christian Hildner <christian.hildner@hob.de>
Date: Thu, 16 Sep 2004 06:49:29 +0000
Subject: Re: INIT dumps broken?
Message-Id: <41493779.8060202@hob.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <200409141450.i8EEotfk029379@napali.hpl.hp.com>
In-Reply-To: <200409141450.i8EEotfk029379@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Russ Anderson schrieb:

>Correctly understanding the proper way to translate addresses for
>the various regions would be the first step.
>
>The top 3 bits of the virtual address is the virtual region number.  
>
>If it is a region 7 (0xe) address, then masking off the top 3 bits 
>yields the correct physical address.
>
>If it is a region 5 (0xa) address, then a "tpa" instruction (using 
>the TLB) should yield the correct physical address (assuming there is
>a valid TLB entry for that virtual address).
>
>Would that be the correct way to translate the addresses?
>
If you can rely on a working ivt and uncorrupted page tables, yes.

>Are there exceptions, such as region 7 addresses where masking off 
>the top 3 bits would not yield the correct physical address?
>
No. Region 7 is per definition one to one mapped. Because of that the 
kernel went from region 7 (2.4.x) to region 5 (2.6.x) to allow having a 
relocatable kernel at a fixed virtual address.

>How should region 5 addresses without a valid TLB mapping be handled?
>
If you don't accept tlb misses thrown by tpa then you have to first make 
sure that the address is in the page table mapped segment and second 
walk the page tables in physical mode (see ivt.S nested TLB handler).

>Are there any other regions that need handling, and if so, how?
>
There shouldn't be other regions needed. Nevertheless you could also 
walk the page tables for them.

Christian

