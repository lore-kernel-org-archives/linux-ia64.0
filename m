From: Bill Nottingham <notting@redhat.com>
Date: Fri, 19 Sep 2003 18:17:07 +0000
Subject: Re: QLogic drivers in 2.4
Message-Id: <marc-linux-ia64-106399553718949@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106399415917430@msgid-missing>
In-Reply-To: <marc-linux-ia64-106399415917430@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > Redhat AS2.1 and EL3 have at least qla2xxx and qla1280.
> 
> $ l redhat/rhel3-b2/usr/src/linux-2.4.21-1.1931.2.399.ent/drivers/scsi/qla*
> redhat/rhel3-b2/usr/src/linux-2.4.21-1.1931.2.399.ent/drivers/scsi/qla1280.c
> redhat/rhel3-b2/usr/src/linux-2.4.21-1.1931.2.399.ent/drivers/scsi/qla1280.h
> $ l redhat/2.4.18-e.37/src/drivers/scsi/qla*
> redhat/2.4.18-e.37/src/drivers/scsi/qla1280.c
> redhat/2.4.18-e.37/src/drivers/scsi/qla1280.h
> 
> I see they have qla1280, but I don't see qla2xxx.  Am I looking in the
> wrong place?

drivers/addon

Bill
