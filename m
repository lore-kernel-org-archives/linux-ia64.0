From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Wed, 29 May 2002 03:56:22 +0000
Subject: [Linux-ia64] Missing files in to-linus-2.5 BK tree; build problems
Message-Id: <marc-linux-ia64-105590701905608@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi David,
   The files perfmon_itanium.h, perfmon_generic.h and
perfmon_mckinley.h are missing from the bk archive. I believe they
should have been added at:
      ChangeSet@1.552.24.3 2002-05-24 18:45:43-0700 eranian@hp.com


Also, what did you decide to do with the scatter-gather list changes
(member `address' no longer exists)?   The changes to sb_iommu.c are
non-trivial, because it looks as if the address field was
overloaded...

Peter C

