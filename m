From: Keith Owens <kaos@ocs.com.au>
Date: Tue, 26 Jun 2001 14:42:16 +0000
Subject: Re: [Linux-ia64] Help - 2.4.5 SMP doesn't boot (any more)
Message-Id: <marc-linux-ia64-105590693005769@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005768@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005768@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 26 Jun 2001 15:59:08 +0200 (CEST), 
Martin Wilck <Martin.Wilck@fujitsu-siemens.com> wrote:
>Yesterday I had 2.4.5 running fine. Since today, I can't boot
>the 2.4.5 SMP kernel any more. I get a kernel panic (invalid page
>request at 0000000000000010) after SMP is enabled
>(actually the last message I see is "trying to unmount old root ...",
>but from kdb messages and the fact that uniprocessor 2.4.5 boots, it
>is clear that it is a SMP error).

That sounds like a known bug in 2.4.5 with undefined data in an inode
during root switch.  Fixed in 2.4.6-pre2.  The symptoms can be weird,
other people have blamed it on compilers, it is just luck if the
undefined field causes a problem or not.

Index: 5.1/fs/block_dev.c
--- 5.1/fs/block_dev.c Wed, 23 May 2001 11:55:33 +1000 kaos (linux-2.4/p/b/16_block_dev. 1.2.2.3 644)
+++ 6-pre5.1/fs/block_dev.c Sat, 09 Jun 2001 11:25:53 +1000 kaos (linux-2.4/p/b/16_block_dev. 1.2.2.4 644)
@@ -595,14 +595,15 @@ int check_disk_change(kdev_t dev)
 
 int ioctl_by_bdev(struct block_device *bdev, unsigned cmd, unsigned long arg)
 {
-	kdev_t rdev = to_kdev_t(bdev->bd_dev);
 	struct inode inode_fake;
 	int res;
 	mm_segment_t old_fs = get_fs();
 
 	if (!bdev->bd_op->ioctl)
 		return -EINVAL;
-	inode_fake.i_rdev=rdev;
+	memset(&inode_fake, 0, sizeof(inode_fake));
+	inode_fake.i_rdev = to_kdev_t(bdev->bd_dev);
+	inode_fake.i_bdev = bdev;
 	init_waitqueue_head(&inode_fake.i_wait);
 	set_fs(KERNEL_DS);
 	res = bdev->bd_op->ioctl(&inode_fake, NULL, cmd, arg);


