From: Matt_Domsch@Dell.com
Date: Fri, 13 Oct 2000 17:32:02 +0000
Subject: RE: [Linux-ia64] qla1280 SCSI controller problems?
Message-Id: <marc-linux-ia64-105590678205570@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205569@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205569@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Yes, under SMP.  Under UP it works great.  I don't know if it's a driver
problem or elsewhere.

Thanks,
Matt Domsch
Dell Enterprise Systems Group
Linux Development Team

-----Original Message-----
From: Broadfoot, KenX [mailto:kenx.broadfoot@intel.com]
Sent: Friday, October 13, 2000 12:09 PM
To: linux-ia64@linuxia64.org
Subject: [Linux-ia64] qla1280 SCSI controller problems?



Hello folks,

Has anyone on this list seen the Lion lockup ( but not "crash" ) were
seemingly the SCSI hard drive becomes unaccessable?
The machine then requires a hard restart.

I have ONLY seen this in kernel 2.4.0-test8 and 2.4.0-test9.

I see typically when trying to insert a module or running a command like: du
-a *

--ken


_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

