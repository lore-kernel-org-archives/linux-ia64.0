From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 19 Sep 2003 17:47:46 +0000
Subject: QLogic drivers in 2.4
Message-Id: <marc-linux-ia64-106399415917430@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

These drivers, and the ql2xxx stuff in particular, comprise
one of the big pieces of the 2.4 ia64 patch that hasn't gone
upstream yet:

 drivers/scsi/ql12160_fw.h                    | 3125 +++---
 drivers/scsi/ql1280_fw.h                     | 3774 ++++---
 drivers/scsi/ql2100_fw.h                     | 4740 +++++++++
 drivers/scsi/ql2200_fw.h                     | 5179 ++++++++++
 drivers/scsi/ql2300_fw.h                     | 5486 +++++++++++
 drivers/scsi/qla1280.c                       | 1399 +-
 drivers/scsi/qla1280.h                       |  297 
 drivers/scsi/qla2x00.c                       |12823 +++++++++++++++++++++++++++
 drivers/scsi/qla2x00.h                       | 2492 +++++
 drivers/scsi/qla2x00exioct.h                 |  823 +
 drivers/scsi/qla2x00exioctln.h               |  131 
 drivers/scsi/qla2x00ioctl.c                  | 1179 ++
 drivers/scsi/qlavendor.c                     |  325 

It looks like at least the ql2xxx stuff is (a) not in the 2.5
tree, and (b) not in Red Hat kernels.

So who cares about this stuff?  If I dropped it out of the
ia64 patch, would anybody be upset enough to help sort
this out?

Bjorn

