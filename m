From: Matt_Domsch@Dell.com
Date: Mon, 11 Jun 2001 17:29:40 +0000
Subject: RE: [Linux-ia64] Linux 2.4.5 boot hangs at "SCSI(0): Verifying ch
Message-Id: <marc-linux-ia64-105590693005708@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Booting Linux 2.4.5 on a Lion, it sometimes hangs at 
> "SCSI(0): Verifying
> chip..."  When it hangs there, you can't break in with ITP, 
> it gets a bus
> timeout. Other times, it boots.  Has anyone else seen this?  
> If so, is it a
> known problem with Linux, firmware, or what?  Is there a workaround?

I've only seen this rarely, but twice this weekend with qla1280 v4.28.  A
powercycle (or perhaps a reset) clears it up.  It happened after 9
successful reboots, then again after about 27 successful reboots.
-Matt

--
Matt Domsch
Sr. Software Engineer
Dell Linux Solutions
www.dell.com/linux



