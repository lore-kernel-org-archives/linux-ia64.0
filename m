From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 13 Dec 2006 21:58:00 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200612132158.kBDLw0gU015248@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

Quick fix for lots of warnings and build errors in infiniband.

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

or more likely to work ... git1.kernel.org seems to have given up tracking
altogether, git2.kernel.org is running way behind master.kernel.org

	master.kernel.org:/home/ftp/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

-Tony

 include/asm-ia64/pci.h         |    3 ---
 include/asm-ia64/scatterlist.h |    3 +++
 2 files changed, 3 insertions(+), 3 deletions(-)

Tony Luck:
      [IA64] Move sg_dma_{len,address} from pci.h to scatterlist.h
