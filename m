From: Waiman Long <Waiman.Long@hpe.com>
Date: Tue, 14 Jun 2016 18:12:39 +0000
Subject: [RFC PATCH-tip 6/6] xfs: Enable reader optimistic spinning for DAX inodes
Message-Id: <1465927959-39719-7-git-send-email-Waiman.Long@hpe.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1465927959-39719-1-git-send-email-Waiman.Long@hpe.com>
In-Reply-To: <1465927959-39719-1-git-send-email-Waiman.Long@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, xfs@oss.sgi.com, Davidlohr Bueso <dave@stgolabs.net>, Jason Low <jason.low2@hp.com>, Dave Chinner <david@fromorbit.com>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>, Waiman Long <Waiman.Long@hpe.com>

This patch enables reader optimistic spinning for inodes that are
under a DAX-based mount point.

On a 4-socket Haswell machine running on a 4.7-rc1 tip-based kernel,
the fio test with multithreaded randrw and randwrite tests on the
same file on a XFS partition on top of a NVDIMM with DAX were run,
the aggregated bandwidths before and after the patch were as follows:

  Test      BW before patch     BW after patch  % change
  ----      ---------------     --------------  --------
  randrw        1352 MB/s          2164 MB/s      +60%
  randwrite     1710 MB/s          2550 MB/s      +49%

Signed-off-by: Waiman Long <Waiman.Long@hpe.com>
---
 fs/xfs/xfs_icache.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/fs/xfs/xfs_icache.c b/fs/xfs/xfs_icache.c
index 99ee6ee..09f284f 100644
--- a/fs/xfs/xfs_icache.c
+++ b/fs/xfs/xfs_icache.c
@@ -71,6 +71,15 @@ xfs_inode_alloc(
 
 	mrlock_init(&ip->i_iolock, MRLOCK_BARRIER, "xfsio", ip->i_ino);
 
+	/*
+	 * Enable reader spinning for DAX nount point
+	 */
+	if (mp->m_flags & XFS_MOUNT_DAX) {
+		rwsem_set_rspin_threshold(&ip->i_iolock.mr_lock);
+		rwsem_set_rspin_threshold(&ip->i_mmaplock.mr_lock);
+		rwsem_set_rspin_threshold(&ip->i_lock.mr_lock);
+	}
+
 	/* initialise the xfs inode */
 	ip->i_ino = ino;
 	ip->i_mount = mp;
-- 
1.7.1

