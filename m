From: Matt_Domsch@Dell.com
Date: Wed, 11 Feb 2004 23:13:57 +0000
Subject: efibootmgr 0.5.0-test2
Message-Id: <16E52145F803EF44BE0CAB504CEF34E7056DB7A4@ausx2kmpc106.aus.amer.dell.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

efibootmgr 0.5.0-test2 is now available.  Feedback welcome.

Changes:
- removed -t short option for --test
- added -t <timeout> and -T delete timeout options
- updated man page and README about the timeout options
This allows you to frob the EFI Boot Manager timeout value, which generally
defaults to 30 seconds before choosing the BootNext or BootOrder values
automatically.  This allows for users to choose a different value from the
boot manager list when sitting at the console, else the default is chosen
after the timeout expires.

Download from:
http://linux.dell.com/efibootmgr/testing/efibootmgr-0.5.0-test2.tar.gz
http://linux.dell.com/efibootmgr/testing/efibootmgr-0.5.0-test2.tar.gz.sign


Also, please note that efibootmgr has a new official download location:
http://linux.dell.com/efibootmgr/.  Requests to the domsch.com location
should automatically redirect you to this new site.


Thanks,
Matt

--
Matt Domsch
Sr. Software Engineer, Lead Engineer
Dell Linux Solutions linux.dell.com & www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com

