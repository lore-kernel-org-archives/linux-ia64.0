From: Arvind Kandhare <arvind.kan@wipro.com>
Date: Sun, 23 Nov 2003 12:38:10 +0000
Subject: PFN to virtual address for identity mapped segment
Message-Id: <marc-linux-ia64-106958992125849@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
We are working on porting LKCD (Linux Kernel Crash Dump) to the ia64 platform.
The normal dumping procedure goes through all the Physical Page Frame Numbers,
finds out the corresponding virtual addresses for all of them and dumps the data.

We are facing difficulty in finding out corresponding virtual address if
it is in the identity mapped region (region 7). The macro pfn_to_page does not seem to return
proper page structure for this region although region 7 does seem to have corresponding page
table entries (in the PTE table).
But it does not have entries for memory for the pages which are allocated by the alloc_pages call.

Please let us know whether our understanding is correct. Any more light on this matter will be really helpful.

Thanks and regards,
Arvind

