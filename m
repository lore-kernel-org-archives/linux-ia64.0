From: Matt_Domsch@Dell.com
Date: Sat, 19 May 2001 00:03:24 +0000
Subject: [Linux-ia64] Announcing efibootmgr-0.3.1
Message-Id: <marc-linux-ia64-105590693005626@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I really shouldn't try to get stuff out late Friday nights...

Announcing efibootmgr-0.3.1, a Linux user-space application which
interacts with the EFI Boot Manager.  It may be downloaded from
http://domsch.com/linux/ia64/efibootmgr-0.3.1.tar.gz.
 
Fixes usage() to not let you think you can pass args to the OS loader.  It
can't.  It's on the TODO list, but isn't strictly required, so that feature
will have to come later.

Thanks,
Matt


-- 
Matt Domsch
Sr. Software Engineer
Dell Linux Solutions
www.dell.com/linux

