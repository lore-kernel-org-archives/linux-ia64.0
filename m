From: "Martin K. Petersen" <mkp@mkp.net>
Date: Fri, 19 Sep 2003 18:21:53 +0000
Subject: Re: QLogic drivers in 2.4
Message-Id: <marc-linux-ia64-106399585719307@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106399415917430@msgid-missing>
In-Reply-To: <marc-linux-ia64-106399415917430@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Bjorn" = Bjorn Helgaas <bjorn.helgaas@hp.com> writes:

Jes actively maintains the qla1280 driver.  If he hasn't pushed the
latest bits to Marcelo yet, he should (hint!).


Bjorn> It looks like at least the ql2xxx stuff is (a) not in the 2.5
Bjorn> tree, and (b) not in Red Hat kernels.

The qla2xxx driver hasn't been submitted to Marcelo.  For this reason
Red Hat puts it in drivers/addon and not drivers/scsi.


I think the qla1280 is important enough (core SCSI on several boxes)
that you should keep it around until it's synced with Marcelo.

But in general I agree with the principle of not having generic
drivers in the IA-64 patch.

-- 
Martin K. Petersen	Wild Open Source, Inc.
mkp@wildopensource.com	http://www.wildopensource.com/

