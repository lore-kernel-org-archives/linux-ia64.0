From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 07 May 2004 01:04:17 +0000
Subject: GAS warning fixes checked into bk repository
Message-Id: <16538.57489.874565.843185@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Since Jim Wilson kindly checked in the GAS changes to support the
.serialize.{data,instruction} directives, I went ahead and checked in
the companion patch [1] for the kernel.

No more excuses for ignoring warning messages! ;-)

	--david

[1]: http://lia64.bkbits.net:8080/linux-ia64-2.5/cset@davidm@tiger.hpl.hp.com|ChangeSet|20040507004653|56552
