From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 27 Mar 2001 03:22:41 +0000
Subject: [Linux-ia64] kernel update (third patch relative to 2.4.2)
Message-Id: <marc-linux-ia64-105590693005356@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The latest IA-64 patch is now available at:

 ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/

in file linux-2.4.2-ia64-010326.diff*

The only two changes are:

	o fix do_csum_partial_copy_from_user() to work properly
	o fix ia64_ksyms.c so it compiles for UP as well

Enjoy,

	--david

