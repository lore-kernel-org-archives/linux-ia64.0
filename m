From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 16 May 2000 22:12:03 +0000
Subject: Re: [Linux-ia64] block_device_operations
Message-Id: <marc-linux-ia64-105590678205088@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205087@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205087@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 16 May 2000 14:12:32 -0700, Guangyu Fang <gfang@mylex.com> said:

  Gary> Hi, I'm using TurboLinux 2.3.99-pre6-000501-18. Since
  Gary> <linux/fs.h> has the following definition:

  Gary> struct block_device_operations { int (*open) (struct inode *,
  Gary> struct file *); int (*release) (struct inode *, struct file
  Gary> *); int (*ioctl) (struct inode *, struct file *, unsigned,
  Gary> unsigned long); int (*check_media_change) (kdev_t); int
  Gary> (*revalidate) (kdev_t); };

  Gary> Does it mean that block device can not do read/write
  Gary> operations? Is there any work around?

Yup, the Linux kernel developers recently discovered that they can get
an infinite speed up in disk read/write bandwidth by not doing the I/O
at all.  With gobs of memory, how needs disks anyhow? ;-)

Seriously though: I/O is done through I/O requests.  There is (at
least) one request queue per major device number.  The request
function is defined in <linux/blk.h>.  For example, drivers/ide/hd.c
does:

	blk_init_queue(BLK_DEFAULT_QUEUE(MAJOR_NR), DEVICE_REQUEST);

and if you look at blk.h, this will expand into:

	blk_init_queue(&blk-dev[MAJOR_NR].request_queue, do_hd_request);

Hope this resolves the mystery.

	--david


