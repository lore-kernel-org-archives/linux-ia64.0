From: dann frazier <dannf@hp.com>
Date: Mon, 28 Nov 2005 06:23:46 +0000
Subject: initrd_size inflation breaks initramfs
Message-Id: <1133159027.6062.98.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

hey,
  I've been trying to track down why initramfs seems to be broken on
ia64 when passed using the initrd= flag.  This appears to be due to an
inflated ia64_boot_param->initrd_size.  In my case, initrd_size got set
to 1957888 (which happens to be a multiple of 4K), when my initramfs
file is actually 1957415 bytes.

unpack_to_rootfs() expects gunzip() to succeed until it has reached the
initrd_size.  Since it thinks the image is larger than it actually is,
it runs off the end of the initrd and the initramfs footprinting fails.
I can get unpack_to_rootfs to succeed by hardcoding my initrd_size.

My guess is that this is a bug in elilo.

initrd.c has:
        /* round up to get required number of pages (4KB) */
        initrd->pgcnt = pgcnt = EFI_SIZE_TO_PAGES(size);

initrd->pgcnt is later used to calculate the initrd_size boot param, but
it is now (size % 4096) bytes too big.
-- 
dann frazier <dannf@hp.com>

