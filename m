From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 16 Apr 2003 19:28:46 +0000
Subject: [Linux-ia64] ia32 subsystem in 2.5.67
Message-Id: <marc-linux-ia64-105590723705513@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It looks like dynamic x86 binaries have a problem once again (or
still).  If I try to run any shared x86 binaries, I get:

	$ ls.x86
	ls.x86: error while loading shared libraries: librt.so.1: cannot map zero-fill pages: Error 14

Would someone take a look?

	--david

