From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 16 Dec 2002 21:04:03 +0000
Subject: [Linux-ia64] Re: Use of __ia64_syscall() - syscall interface
Message-Id: <marc-linux-ia64-105590709805572@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 16 Dec 2002 17:07:18 +0100 (NFT), Joel GUILLET <Joel.Guillet@bull.net> said:

  Joel> This doesn't compile on a Itanium.  I got a "undefined
  Joel> reference to __ia64_syscall()"

Please use the syscall() routine instead.  The stuff in unistd.h is
for kernel-use only.

	--david

