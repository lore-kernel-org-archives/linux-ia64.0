From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 19 Sep 2003 18:08:50 +0000
Subject: Re: QLogic drivers in 2.4
Message-Id: <marc-linux-ia64-106399496118337@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106399415917430@msgid-missing>
In-Reply-To: <marc-linux-ia64-106399415917430@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday 19 September 2003 12:01 pm, Chen, Kenneth W wrote:
> > It looks like at least the ql2xxx stuff is (a) not in the 2.5
> > tree, and (b) not in Red Hat kernels.
> 
> Redhat AS2.1 and EL3 have at least qla2xxx and qla1280.

$ l redhat/rhel3-b2/usr/src/linux-2.4.21-1.1931.2.399.ent/drivers/scsi/qla*
redhat/rhel3-b2/usr/src/linux-2.4.21-1.1931.2.399.ent/drivers/scsi/qla1280.c
redhat/rhel3-b2/usr/src/linux-2.4.21-1.1931.2.399.ent/drivers/scsi/qla1280.h
$ l redhat/2.4.18-e.37/src/drivers/scsi/qla*
redhat/2.4.18-e.37/src/drivers/scsi/qla1280.c
redhat/2.4.18-e.37/src/drivers/scsi/qla1280.h

I see they have qla1280, but I don't see qla2xxx.  Am I looking in the
wrong place?

> > So who cares about this stuff?
> 
> I do, :-)

Do you care enough to help get these changes upstream?
I'm tired of carrying them in the ia64 patch.

Bjorn

