From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Tue, 17 Oct 2000 01:12:24 +0000
Subject: [Linux-ia64] kdb-2.4-test9 is available
Message-Id: <marc-linux-ia64-105590678205571@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Just  a quick note to let you know that I uploaded the
KDB patch relative to linux-v2.4.0-test9 + David's 1014 patch.

You can download it from:

	ftp://ftp.hpl.hp.com/pub/linux-ia64/kdb-2.4-test9.patch.gz

No new feature added. 

An important remark:
	The latest firmware now supports USB keyboard and mouse. The Linux
	kernel works fine with pure USB keyboard and mouse. However it is not
	currently possible to use KDB with ONLY a USB keyboard attached. To
	use KDB on the (VGA) console you need a PS/2 keyboard. 

+--------------------------------------------------------------------+
| Ste'phane ERANIAN                       | Email eranian@hpl.hp.com |
| Hewlett-Packard Laboratories            |                          |
| 1501, Page Mill Road MS 1U-15           |                          |
| Palo  Alto, CA 94303-096                |                          |
| USA                                     |                          |
| Tel : (650) 857-7174                    |                          |
| Fax : (650) 857-5548                    |                          |
+--------------------------------------------------------------------+

