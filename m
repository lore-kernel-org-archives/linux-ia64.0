From: Len Brown <len.brown@intel.com>
Date: Sat, 21 Jan 2006 08:20:05 +0000
Subject: ia64: allnoconfig build fails
Message-Id: <200601210320.05771.len.brown@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Volunteers?


mm/mempolicy.c: In function `huge_zonelist':
mm/mempolicy.c:1045: error: `HPAGE_SHIFT' undeclared (first use in this function)
mm/mempolicy.c:1045: error: (Each undeclared identifier is reported only once
mm/mempolicy.c:1045: error: for each function it appears in.)
make[1]: *** [mm/mempolicy.o] Error 1
