From: zhong jiang <zhongjiang@huawei.com>
Date: Tue, 14 Aug 2018 02:46:52 +0000
Subject: [PATCH 0/2] Use ARRAY_SIZE to replace its implementation
Message-Id: <1534214814-9043-1-git-send-email-zhongjiang@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, fenghua.yu@intel.com, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, oleg@redhat.com, rppt@linux.vnet.ibm.com, dhowells@redhat.com, akpm@linux-foundation.org, viro@zeniv.linux.org.uk
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

The issue is detected with the help of Coccinelle.

zhong jiang (2):
  ia64: Use ARRAY_SIZE to replace its implementation
  powerpc: Use ARRAY_SIZE to replace its implementation

 arch/ia64/kernel/perfmon.c  |  2 +-
 arch/powerpc/xmon/ppc-opc.c | 12 ++++--------
 2 files changed, 5 insertions(+), 9 deletions(-)

-- 
1.7.12.4
