From: Matt_Domsch@Dell.com
Date: Mon, 11 Aug 2003 20:38:30 +0000
Subject: efibootmgr 0.4.2-test2
Message-Id: <marc-linux-ia64-106063434227835@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Announcing efibootmgr 0.4.2-test2.  If you have systems you can test
this on, please do so.  It appears to work fine on my BigSur.  The big
change here is I think I fixed the unaligned access errors.  If you're
still getting them with this, please look at the ip=... address reported
by the kernel, and tell me what function the code is in at that time
(objdump -D is very helpful here).

* Mon Aug 11 2003 Matt Domsch <Matt_Domsch@dell.com>
- fixed unaligned access errors
- removed extraneous printing of mac addr when creating netboot entries
- sync docbook to README
- whitespace cleanups


Tarballs at:
http://domsch.com/linux/ia64/efibootmgr/efibootmgr-0.4.2-test2.tar.gz
http://domsch.com/linux/ia64/efibootmgr/efibootmgr-0.4.2-test2.tar.gz.asc


Feedback welcome!

Thanks,
Matt

-- 
Matt Domsch
Sr. Software Engineer, Lead Engineer
Dell Linux Solutions www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com

