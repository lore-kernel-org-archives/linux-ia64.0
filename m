From: Keith Owens <kaos@sgi.com>
Date: Thu, 30 Oct 2003 08:28:31 +0000
Subject: [patch 0/4] kernel salinfo changes
Message-Id: <marc-linux-ia64-106750258117748@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

patch 1 - Print the header from INIT records, correct typo in sal.h.
patch 2 - Clean up kernel salinfo state checking.
patch 3 - Add the ability for user space salinfo to ask kernel salinfo
          and/or the prom to decode the oem data sections of SAL records.

All patches are against 2.4.23-pre8 cset-1.1069.1.143-to-1.1108.
