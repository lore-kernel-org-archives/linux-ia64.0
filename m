From: Guangyu Fang <gfang@mylex.com>
Date: Tue, 16 May 2000 21:12:32 +0000
Subject: [Linux-ia64] block_device_operations
Message-Id: <marc-linux-ia64-105590678205087@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I'm using TurboLinux 2.3.99-pre6-000501-18. Since <linux/fs.h> has the
following definition:

struct block_device_operations {
	int (*open) (struct inode *, struct file *);
	int (*release) (struct inode *, struct file *);
	int (*ioctl) (struct inode *, struct file *, unsigned, unsigned
long);
	int (*check_media_change) (kdev_t);
	int (*revalidate) (kdev_t);
};


Does it mean that block device can not do read/write operations? Is there
any work around?

Thanks.


Gary


