From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 17 Oct 2007 22:06:54 +0000
Subject: RE: git pull on ia64 linux tree
Message-Id: <617E1C2C70743745A92448908E030B2A02B58049@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

Another day, another buildfix, another git pull ...

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/kernel/machine_kexec.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

Andrew Morton (1):
      [IA64] fix non-numa build
