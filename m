From: Matt_Domsch@Dell.com
Date: Thu, 28 Jun 2001 15:52:52 +0000
Subject: RE: [Linux-ia64] Linux 2.4.4 boot hangs at "SCSI(0): Verifying ch
Message-Id: <marc-linux-ia64-105590693005800@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005797@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005797@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > Booting my Lion Qual with SuSE 7.2a RC1 (2.4.4-SMP) 
> sporadically hangs at
> > scsi(0): verifying chip ...
> > 
> I wonder if you have the 64bit support enabled for the QLA in 
> the setup. 
> You must make sure that it is enabled. Press F2 and check it out.

Shouldn't need that anymore (the qla1280 driver sets up 64-bit addressing
when on a 64-bit system).  I've seen this occasionally.  Easiest to
reproduce it if you do repeated reboots until it fails.  In my case, it
would repeat the Red Hat installer between 9 and 30 times before failing,
but haven't been able to track it down yet.

Thanks,
Matt

--
Matt Domsch
Sr. Software Engineer
Dell Linux Solutions
www.dell.com/linux
#2 Linux Server provider with 17% in the US and 14% Worldwide (IDC)!
#3 Unix provider with 18% in the US (Dataquest)!

