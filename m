From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 19 Sep 2003 18:43:16 +0000
Subject: RE: QLogic drivers in 2.4
Message-Id: <marc-linux-ia64-106399712320834@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106399415917430@msgid-missing>
In-Reply-To: <marc-linux-ia64-106399415917430@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On a second thought, the qla2x00 driver in ia64 tree is so old that it
doesn't add much value for the effort that people put in. Dropping it
isn't going to doom the earth or something.


-----Original Message-----
From: Chen, Kenneth W 
Sent: Friday, September 19, 2003 11:24 AM
To: 'Bjorn Helgaas'; linux-ia64@vger.kernel.org
Subject: RE: QLogic drivers in 2.4


> > Redhat AS2.1 and EL3 have at least qla2xxx and qla1280.
> 
> $ l
redhat/rhel3-b2/usr/src/linux-2.4.21-1.1931.2.399.ent/drivers/scsi/qla*
>
redhat/rhel3-b2/usr/src/linux-2.4.21-1.1931.2.399.ent/drivers/scsi/qla12
80.c
>
redhat/rhel3-b2/usr/src/linux-2.4.21-1.1931.2.399.ent/drivers/scsi/qla12
80.h
> $ l redhat/2.4.18-e.37/src/drivers/scsi/qla*
> redhat/2.4.18-e.37/src/drivers/scsi/qla1280.c
> redhat/2.4.18-e.37/src/drivers/scsi/qla1280.h
> 
> I see they have qla1280, but I don't see qla2xxx.  Am I looking in the
> wrong place?

Redhat stuff the qla2xxx under drivers/addon/qla2200


> Do you care enough to help get these changes upstream?
> I'm tired of carrying them in the ia64 patch.

Probably not that far.
