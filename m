From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 19 Dec 2014 22:29:54 +0000
Subject: [GIT PULL] ia64: last piece of __get_cpu_var removal
Message-Id: <5494a6e2110585b801@agluck-desk.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit 009d0431c3914de64666bec0d350e54fdd59df6a:

  Linux 3.18-rc7 (2014-11-30 16:42:27 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-misc-3.19

for you to fetch changes up to 87b4bf6d0aeca53f3663d7815059284a014d400d:

  [IA64] Update comment that references __get_cpu_var (2014-12-02 11:22:07 -0800)

----------------------------------------------------------------
__get_cpu_var removed from rest of tree, drop reference from comments in arch/ia64

----------------------------------------------------------------
Christoph Lameter (1):
      [IA64] Update comment that references __get_cpu_var

 arch/ia64/include/asm/percpu.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)
