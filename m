From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Sun, 12 Mar 2006 16:47:06 +0000
Subject: [patch 0/6] init declaration cleanup
Message-Id: <200603121647.k2CGl4g09972@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I started off at mca.c, surfing around the source tree, made 
some changes, then made more changes.  And I end up with 37
instances with the following diffstat.


 arch/ia64/kernel/mca.c         |   12 ++++-----
 arch/ia64/kernel/patch.c       |    8 +++---
 arch/ia64/kernel/setup.c       |   24 +++++++++----------
 arch/ia64/kernel/vmlinux.lds.S |   51 ++++++++++++++++++++---------------------
 arch/ia64/mm/contig.c          |    8 +++---
 arch/ia64/mm/discontig.c       |    2 -
 arch/ia64/mm/init.c            |   16 ++++++------
 include/asm-ia64/processor.h   |    1
 8 files changed, 61 insertions(+), 61 deletions(-)


The end result?  Moved 15,176 byte worth of text and data into
init section, which netted a "whooping" one extra free page. Do
I care about that extra page?  Probably not.  Nevertheless, post
them so that next poor soul won't waste his time trying to
duplicate the effort.

- Ken

