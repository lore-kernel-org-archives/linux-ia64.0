From: Grant Grundler <iod00d@hp.com>
Date: Fri, 19 Sep 2003 18:40:29 +0000
Subject: Re: QLogic drivers in 2.4
Message-Id: <marc-linux-ia64-106399684120561@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106399415917430@msgid-missing>
In-Reply-To: <marc-linux-ia64-106399415917430@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Sep 19, 2003 at 11:47:46AM -0600, Bjorn Helgaas wrote:
> These drivers, and the ql2xxx stuff in particular,

Yeah - they don't belong in the ia64-linux specific patch
and it's probably (partially) my fault they are there.

> comprise one of the big pieces of the 2.4 ia64 patch that hasn't gone
> upstream yet:
> 
>  drivers/scsi/ql12160_fw.h                    | 3125 +++---
>  drivers/scsi/ql1280_fw.h                     | 3774 ++++---
>  drivers/scsi/ql2100_fw.h                     | 4740 +++++++++
>  drivers/scsi/ql2200_fw.h                     | 5179 ++++++++++
>  drivers/scsi/ql2300_fw.h                     | 5486 +++++++++++
>  drivers/scsi/qla1280.c                       | 1399 +-
>  drivers/scsi/qla1280.h                       |  297 

I'd think Jes could(had?) submit(ted) qla1280 bits himself upstream.

>  drivers/scsi/qla2x00.c                       |12823 +++++++++++++++++++++++++++
>  drivers/scsi/qla2x00.h                       | 2492 +++++
>  drivers/scsi/qla2x00exioct.h                 |  823 +
>  drivers/scsi/qla2x00exioctln.h               |  131 
>  drivers/scsi/qla2x00ioctl.c                  | 1179 ++
>  drivers/scsi/qlavendor.c                     |  325 

aren't these the "old" isp2x00 FC drivers?
I see the "new" qla2xxx drivers in their own directory:
	drivers/scsi/qla2xxx

in linux-ia64-2.4 bk tree.

> It looks like at least the ql2xxx stuff is (a) not in the 2.5
> tree,

I thought for 2.5.x someone was maintaining an 8.x qla FC driver which was
in parallel with qla2xxx 6.x FC drivers maintained by qlogic.
I'm not sure what happened here since I don't see it in
David's linux-ia64-2.5 bk tree.

> and (b) not in Red Hat kernels.

Red Hat Advanced Server kernels have qla2xxx FC support someplace.
I'll try to unpack a recent ia64 RHAS kernel and see where it's hiding
if no one else knows off hand.

> So who cares about this stuff?

AFAIK, HP doesn't care about "old" FC qla drivers on ia64.
IIRC, i2000 support has qla1280 and HP should support that.
HP cares more about new qlogic FC drivers. e.g.:
scsi6 : QLogic QLA2312 PCI to Fibre Channel Host Adapter: bus 128 device 1 irq 62
	Firmware version:  3.01.18, Driver version 6.04.00

(HP will actually need a post release of 6.05)

> If I dropped it out of the ia64 patch, would anybody be upset enough
> to help sort this out?

If necessary, I can organize help in-house.

thanks,
grant
