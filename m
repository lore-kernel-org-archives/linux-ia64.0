From: Christian Hildner <christian.hildner@hob.de>
Date: Fri, 14 Dec 2001 13:21:43 +0000
Subject: [Linux-ia64] Linux page tables and VHPT
Message-Id: <marc-linux-ia64-105590698805693@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi all!

After reading and understanding (that took some time) the VHPT feature I

looked through the sources, but there are some questions left about the
use of the processor's VHPT.

- which of the page tables are used as base address in cr.pta?

- where is the virtual page table located?

- which size has the virtual page table?

- is the VHPT used for both the kernel and the userspace mappings?

If anyone knows answers to my questions you'd be welcome.

Christian


