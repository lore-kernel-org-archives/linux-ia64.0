From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 19 Jun 2003 17:36:34 +0000
Subject: SCSI ERRORS triggered by BIO_VMERGE_BOUNDARY
Message-Id: <marc-linux-ia64-105604433402604@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Since we enabled block-layer-level merging of buffers via
BIO_VMERGE_BOUNDARY (in asm-ia64/io.h), I started to notice SCSI
errors on one of our machines (an rx5670 with 16GB of memory).  If I
set BIO_VMERGE_BOUNDARY to 0, the errors disappear.  My suspicion is
that something is wrong in the sba_iommu.c code with respect to block
merging.  Unfortunately, I won't be able to investigate this further
at the moment, since I'm trying to get out a 2.5.72 patch and will be
on vacation on and off over the next 2 weeks.  One thing that would be
interesting to know is whether similar SCSI errors show up on SN2
machines (assuming the SGI guys can get the latest 2.5 bits to boot,
of course).  This should tell us whether the bug is really in the I/O
MMU or somewhere else.

For reference, I attached a couple of sample error message below.

Can someone look into this?

	--david

Jun 19 06:31:15 magma kernel: SCSI error : <3 0 0 0> return code = 0x70000
Jun 19 06:31:15 magma kernel: end_request: I/O error, dev sda, sector 2573060
Jun 19 06:31:15 magma kernel: SCSI error : <3 0 0 0> return code = 0x70000
Jun 19 06:31:15 magma kernel: end_request: I/O error, dev sda, sector 2573068
Jun 19 06:31:15 magma kernel: SCSI error : <3 0 0 0> return code = 0x70000
Jun 19 06:31:15 magma kernel: end_request: I/O error, dev sda, sector 2573076
