From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 17 Jan 2002 07:57:47 +0000
Subject: [Linux-ia64] raw 2.5.2 patch
Message-Id: <marc-linux-ia64-105590698805868@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

A raw ia64 patch for sync-up with v2.5.2 is now at the usual place
(ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64) in file:

 v2.5/linux-2.5.2-ia64-020116-dontuse.gz

As the name suggests, I don't recommend using it: 2.5.2 seems
sufficiently unstable that I don't think its worth spending a lot of
time on it.  With this patch, the kernel should work on the HP
simulator (both UP and MP).  Also, it worked reasonably well with an
IDE-based Big Sur.  I suspect SCSI won't work (unless you use a
controller other than the qla1280).

Since I don't expect this patch to be very useful for most folks,
I left the kdb stuff in there.

Is someone from Qlogic planning on updating the qla1280 and qla2100
drivers?  I hacked the qla1280 a bit, but I doubt it's all correct and
I didn't touch the qla2100 at all.

	--david

