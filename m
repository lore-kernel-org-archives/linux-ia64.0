From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 04 Nov 2011 16:16:19 +0000
Subject: [git pull] ia64 change (new syscalls for 3.2)
Message-Id: <4eb40fd31453623713@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git process_vm
	HEADU69459cd3a828a998dc305ae4141c1e41f25ecb

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/include/asm/unistd.h |    4 +++-
 arch/ia64/kernel/entry.S       |    2 ++
 2 files changed, 5 insertions(+), 1 deletions(-)

Tony Luck (1):
      [IA64] Wire up cross memory attach syscalls

