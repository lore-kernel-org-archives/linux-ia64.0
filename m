From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Thu, 17 Aug 2000 07:55:26 +0000
Subject: [Linux-ia64] [Correction] KDB patch for 2.4.0-test6
Message-Id: <marc-linux-ia64-105590678205346@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

The patch I announced a few minutes ago had some problems 
when compiling for the HP simulator. Also this new patch
fixes some header files in the disassembler.  Both fixes
patches are courtesy of David Mosberger (thanks).

Please download the new file:
	 size  date   time  name
	 13445 Aug 17 00:47 kdb-2.4-test6.patch.gz

from the same location at

	ftp://ftp.hpl.hp.com/pub/linux-ia64/kdb-2.4-test6.patch.gz

+--------------------------------------------------------------------+
| Ste'phane ERANIAN                       | Email eranian@hpl.hp.com |
| Hewlett-Packard Laboratories            |                          |
| 1501, Page Mill Road MS 1U-15           |                          |
| Palo  Alto, CA 94303-096                |                          |
| USA                                     |                          |
| Tel : (650) 857-7174                    |                          |
| Fax : (650) 857-5548                    |                          |
+--------------------------------------------------------------------+

