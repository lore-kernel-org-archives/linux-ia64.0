From: jbarnes@sgi.com (Jesse Barnes)
Date: Mon, 04 Aug 2003 18:52:31 +0000
Subject: Re: milstone reached: ia64 linux builds out of Linus' tree
Message-Id: <marc-linux-ia64-106002372207737@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106001867501939@msgid-missing>
In-Reply-To: <marc-linux-ia64-106001867501939@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thanks H.J., this patch works for me!  I had to add one more for xfs
(included), but after that, things seemed to work.

Thanks,
Jesse

On Mon, Aug 04, 2003 at 11:10:33AM -0700, H. J. Lu wrote:
> On Mon, Aug 04, 2003 at 11:00:16AM -0700, Jesse Barnes wrote:
> > On Mon, Aug 04, 2003 at 10:53:08AM -0700, H. J. Lu wrote:
> > > On Mon, Aug 04, 2003 at 10:37:39AM -0700, David Mosberger wrote:
> > > > As of this morning, Linus's current bk tree
> > > > (http://linux.bkbits.net:8080/linux-2.5) builds and works out of the
> > > > box for ia64!
> > > > 
> > > 
> > > Does it work on bigsur? Does it support kernel modules?
> > 
> > I just tried the latest on my big sur, and though I think modules work
> > (at least they build for other machines), big sur is broken because
> > non-ACPI based PCI enumeration has been removed from the tree.
> > 
> 
> Can you try this patch for bigsur?

diff -Nru a/fs/xfs/linux/xfs_vfs.h b/fs/xfs/linux/xfs_vfs.h
--- a/fs/xfs/linux/xfs_vfs.h	Wed Jul 16 12:10:39 2003
+++ b/fs/xfs/linux/xfs_vfs.h	Wed Jul 16 12:10:39 2003
@@ -44,8 +44,8 @@
 
 typedef struct vfs {
 	u_int			vfs_flag;	/* flags */
-	fsid_t			vfs_fsid;	/* file system ID */
-	fsid_t			*vfs_altfsid;	/* An ID fixed for life of FS */
+	__kernel_fsid_t			vfs_fsid;	/* file system ID */
+	__kernel_fsid_t			*vfs_altfsid;	/* An ID fixed for life of FS */
 	bhv_head_t		vfs_bh;		/* head of vfs behavior chain */
 	struct super_block	*vfs_super;	/* Linux superblock structure */
 	struct task_struct	*vfs_sync_task;
diff -Nru a/fs/xfs/xfs_mount.c b/fs/xfs/xfs_mount.c
--- a/fs/xfs/xfs_mount.c	Wed Jul 16 12:10:39 2003
+++ b/fs/xfs/xfs_mount.c	Wed Jul 16 12:10:39 2003
@@ -889,7 +889,7 @@
 	 *  File systems that don't support user level file handles (i.e.
 	 *  all of them except for XFS) will leave vfs_altfsid as NULL.
 	 */
-	vfsp->vfs_altfsid = (fsid_t *)mp->m_fixedfsid;
+	vfsp->vfs_altfsid = (__kernel_fsid_t *)mp->m_fixedfsid;
 	mp->m_dmevmask = 0;	/* not persistent; set after each mount */
 
 	/*
