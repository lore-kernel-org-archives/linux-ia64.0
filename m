From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 29 Jul 2002 21:48:39 +0000
Subject: RE: [Linux-ia64] Linux kernel deadlock caused by spinlock bug
Message-Id: <marc-linux-ia64-105590701905848@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905843@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905843@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 29 Jul 2002 16:29:09 -0500, "Van Maren, Kevin" <kevin.vanmaren@unisys.com> said:

  Van> Yes, but that isn't the point: unless you eliminate all rw
  Van> locks, it is conceptually possible to cause a kernel deadlock
  Van> by forcing contention on the locks you didn't remove, if the
  Van> user can force the kernel to acquire a reader lock and if
  Van> something else needs to acquire the writer lock.  Correctness
  Van> is the issue, not performance.

I agree with Kevin here.  There must be some argument as to why
readers cannot indefinitely lock out a writer.  A probabilistic
argument is fine, but just saying "contention doesn't happen"
certainly isn't good enough.

	--david

