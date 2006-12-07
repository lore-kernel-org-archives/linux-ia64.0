From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 07 Dec 2006 00:10:53 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200612070010.kB70ArLG005600@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

Mirroring at kernel.org is slow today ... perhaps better to use:
	master.kernel.org:/home/ftp/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

Just one build breakage patch here ... rest of 2.6.20 patches coming soon.

Thanks!

-Tony

 arch/ia64/pci/pci.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

Peter Chubb:
      [IA64] Fix pci.c kernel compilation breakage.
