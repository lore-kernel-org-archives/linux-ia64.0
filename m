From: "Hall, Jenna S" <jenna.s.hall@intel.com>
Date: Tue, 12 Nov 2002 20:36:07 +0000
Subject: [Linux-ia64] RE: [PATCH] Polling for Corrected Platform Errors
Message-Id: <marc-linux-ia64-105590709805406@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Excellent, thank you.  We had planned to add such functionality for
platforms that do not support the CPE interrupt, but had pushed it off.

For future reference, Tony Luck tony.luck@intel.com now owns the Linux MCA
work on the Intel side.

Thanks,
Jenna

 -----Original Message-----
From: 	Alex Williamson [mailto:alex_williamson@hp.com] 
Sent:	Tuesday, November 12, 2002 1:27 PM
To:	linux-ia64@linuxia64.org
Cc:	jenna.s.hall@intel.com
Subject:	[PATCH] Polling for Corrected Platform Errors

 << File: cpe_polling.diff >> 
  Attached is a patch that adds a fallback polling mechanism for
retrieving CPE logs from firmware.  The code makes an attempt to
determine if CPEs are happening and adjust the polling interval
accordingly.  On a system that's not getting CPEs, it should
poll every 15 minutes, so should have no performance impact.

   HP zx1 systems do not support an interrupt driven CPE notifier,
so polling is required to get these logs.  Comments?  Thanks,

	Alex

--
Alex Williamson                                  Linux Development Lab
alex_williamson@hp.com                                 Hewlett Packard
970-898-9173                                          Fort Collins, CO

