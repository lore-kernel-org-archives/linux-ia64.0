From: David Mosberger <davidm@hpl.hp.com>
Date: Sun, 22 Jul 2001 00:24:57 +0000
Subject: [Linux-ia64] SANE on ia64 linux
Message-Id: <marc-linux-ia64-105590693005857@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

A while ago someone asked about SANE on IA-64 Linux.  I now had a
chance to test it and as far as I can see, it works fine.  This was
with an HP ScanJet 6200C connected via USB.  The syslog file shows
some extraneous "usb_control/bulk_msg: timeout" messages but they do
not affect the operation of the scanner (other than slowing it down
unnecessarily) and I suspect they are not ia64 specific.

	--david

