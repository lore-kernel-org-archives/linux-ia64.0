From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 18 Mar 2005 23:30:36 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <200503182330.j2INUa102463@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please do a

	bk pull http://lia64.bkbits.net/linux-ia64-release-2.6.12

This will update the files shown below.

Thanks!

-Tony

 include/asm-ia64/pgtable.h |   20 +++++++++++++++-----
 1 files changed, 15 insertions(+), 5 deletions(-)

through these ChangeSets:

<tony.luck@intel.com> (05/03/18 1.2218.1.1)
   [IA64] Another fix for pgd_addr_end (last one was wrong).
   
   I confused the hole in the middle of a region when an implementation of
   the Itanium architecture doesn't implement all the virtual address bits
   with the actual layout in Linux.  Linux doesn't put a hole in the middle
   of the region, it stacks all the address space that the page tables can
   reference at the start of the region.
   
   Thanks to Dave Miller (again) and Peter Chubb.
   
   Signed-off-by: Tony Luck <tony.luck@intel.com>

