From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 15 Jan 2003 06:40:03 +0000
Subject: [Linux-ia64] Re: fsyscall-support
Message-Id: <marc-linux-ia64-105590709805678@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Of course I had to forgot one thing:

	Note that the fsyscall-support also changes the meaning of
	ar.k6: it used to contain the physical address of the
	"current" task pointer.  Now, it contains the (kernel) virtual
	address instead.  This is a small performance optimization, we
	we run in virtual mode almost all the time, nowadays.

  --david

