From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 15 Oct 2007 22:21:56 +0000
Subject: RE: git pull on ia64 linux tree
Message-Id: <617E1C2C70743745A92448908E030B2A02B1D52F@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

Another quick pull to fix the ia64 build problem introduced by some
header file re-arrangements elsewhere in the tree.

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

Or since git is updating slowly right now, from:

	ssh://master.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the file shown below.

Thanks!

-Tony

 include/asm-ia64/dma-mapping.h |    1 +
 1 file changed, 1 insertion(+)

Tony Luck (1):
      [IA64] build fix for scatterlist
