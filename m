From: Matt_Domsch@Dell.com
Date: Fri, 03 Aug 2001 22:21:36 +0000
Subject: [Linux-ia64] efibootmgr-0.3.3 release
Message-Id: <marc-linux-ia64-105590693006000@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> We have noticed (during RH7.1) install that efibootmgr was 
> not checking
> for options with an identical names and it was creating menu options
> with the same name for instance if you reinstall the system a 
> second time.
> 
> Would it be possible to add a warning/error/check that would 
> avoid such a thing ?

Good idea Stephane.  I've added just such a warning.  When creating a new
boot variable, you'll get a warning on stderr if the label conflicts with an
existing label.  It'll let you do it though.

New release efibootmgr 0.3.3 is now available at
http://domsch.com/linux/ia64/efibootmgr-0.3.3.tar.gz.

Thanks,
Matt

--
Matt Domsch
Sr. Software Engineer
Dell Linux Solutions
www.dell.com/linux
#2 Linux Server provider with 17% in the US and 14% Worldwide (IDC)!
#3 Unix provider with 18% in the US (Dataquest)!

