From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 05 May 2003 18:25:33 +0000
Subject: [Linux-ia64] Re: [PATCH] Increase size of user stack
Message-Id: <marc-linux-ia64-105590723705638@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 5 May 2003 14:18:52 -0400, Martin Hicks <mort@wildopensource.com> said:

  Martin> The current user stack size limit of 2GB is not big enough
  Martin> for large SMP or SSI clusters.  The following patch
  Martin> increases this size from 2GB to 512GB.  The new size is
  Martin> negotiable, but right now SGI has programs that require over
  Martin> 100GB of stack size on a 64 processor machine.  Setting the
  Martin> user stack size to 512GB seems like a reasonable thing to do
  Martin> for future growth.

  Martin> Comments?

Why not make it configurable via setrlimit() and be done with it once
and for all?

	--david

