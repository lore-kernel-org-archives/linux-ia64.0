From: Allen Pais <allen.lkml@gmail.com>
Date: Fri, 22 Sep 2017 11:37:59 +0000
Subject: [PATCH 0/3] use setup_timer() helper function.
Message-Id: <1506079562-5068-1-git-send-email-allen.lkml@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This series uses setup_timer() helper function. The series
addresses the files under drivers/block/*.


Allen Pais (3):
  ia64: bte: use setup_timer() helper.
  ia64: mca: use setup_timer() helper.
  ia64: salinfo: use setup_timer() helper.

 arch/ia64/kernel/salinfo.c | 3 +--
 arch/ia64/sn/kernel/bte.c  | 5 ++---
 arch/ia64/sn/kernel/mca.c  | 3 +--
 3 files changed, 4 insertions(+), 7 deletions(-)

-- 
2.7.4

