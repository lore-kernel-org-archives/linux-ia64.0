From: Christoph Hellwig <hch@lst.de>
Date: Tue, 18 Jan 2022 07:48:36 +0000
Subject: architectures that still need to remove set_fs()
Message-Id: <20220118074836.GA20994@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@kernel.org>, Guo Ren <guoren@kernel.org>, Brian Cain <bcain@codeaurora.org>, Michal Simek <monstr@monstr.eu>, Nick Hu <nickhu@andestech.com>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Dinh Nguyen <dinguyen@kernel.org>, Jonas Bonn <jonas@southpole.se>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Stafford Horne <shorne@gmail.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>
Cc: linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, openrisc@lists.librecores.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@linux-xtensa.org, linux-kernel@linux-xtensa.org

Hi all,

you are in this list because your architecture still implements and
uses address space overrides using set_fs(), which are deprecated and
have been removed from all mainstream architecture ports.  To help
cleanup the core kernel it would be great to make progress on removing
set_fs entirely.

The following steps are required:

 (1) implement the __get_kernel_nofault and __put_kernel_nofault
     helper to access kernel memory without page faults, replacing
     the get/put_user under set_fs(KERNEL_DS) abuse.  Mips has a good
     example for a trivial implementation for architectures that use
     a common address space in commit 04324f44cb69
 (2) remove any architecture specific use of such constructs.  This
     only affects ia64 and sh.
 (3) stop selecting the SET_FS and remove all the set_fs-related
     infrastructure.  The above mips commit is a good guide once again.

Thanks!
