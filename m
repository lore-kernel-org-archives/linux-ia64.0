From: Bill Nottingham <notting@redhat.com>
Date: Fri, 19 Sep 2003 18:20:10 +0000
Subject: Re: QLogic drivers in 2.4
Message-Id: <marc-linux-ia64-106399585719304@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106399415917430@msgid-missing>
In-Reply-To: <marc-linux-ia64-106399415917430@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bill Nottingham (notting@redhat.com) said: 
> > $ l redhat/rhel3-b2/usr/src/linux-2.4.21-1.1931.2.399.ent/drivers/scsi/qla*
> > redhat/rhel3-b2/usr/src/linux-2.4.21-1.1931.2.399.ent/drivers/scsi/qla1280.c
> > redhat/rhel3-b2/usr/src/linux-2.4.21-1.1931.2.399.ent/drivers/scsi/qla1280.h
> > $ l redhat/2.4.18-e.37/src/drivers/scsi/qla*
> > redhat/2.4.18-e.37/src/drivers/scsi/qla1280.c
> > redhat/2.4.18-e.37/src/drivers/scsi/qla1280.h
> > 
> > I see they have qla1280, but I don't see qla2xxx.  Am I looking in the
> > wrong place?
> 
> drivers/addon

Note that for RHEL3 (and probably RHEL2.1, I'll need to check) we aren't
using the qla2xxx out of the ia64 patch, but a separate driver from qlogic.

Bill
