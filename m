From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 20 Jan 2005 06:07:30 +0000
Subject: glibc-2.3.2 NPTL caveat
Message-Id: <16879.19106.549352.469688@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We just discovered a nasty bug in glibc-2.3.2 which can lead to
"random" memory corruption in multi-threaded applications using NPTL.
This definitely affects Debian/{testing,unstable}, but it may affect
other distros as well.  I also believe that the CVS glibc still has
this bug, so I suspect it's not just glibc-2.3.2 that's affected.

For details, see:

  http://sources.redhat.com/bugzilla/show_bug.cgi?idh5

	--david
