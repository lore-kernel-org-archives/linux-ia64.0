From: Stephane Eranian <eranian@hpl.hp.com>
Date: Tue, 30 May 2006 14:24:20 +0000
Subject: 2.6.17-rc5 new perfmon code base available
Message-Id: <20060530142420.GH25544@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: perfmon@napali.hpl.hp.com
Cc: linux-ia64@vger.kernel.org, oprofile-list@lists.sourceforge.net, perfctr-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org

Hello,

I have released another version of the perfmon new code base package.

The patch includes:
	- update to 2.6.17-rc5
	- re-enable debugging
	- fix broken pfm_read(). Sampling was not functional.
	 (broken by the perfmon_kapi.c code)

This patch works with existing libpfm-3.2-060522 release.

You can grab the new package at our web site:

	 http://perfmon2.sf.net

-- 
-Stephane
-- 

-Stephane
