From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 19 Nov 2003 20:20:42 +0000
Subject: RE: [PATCH] remove unimplemented syscalls noise
Message-Id: <marc-linux-ia64-106927330102939@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106926030617023@msgid-missing>
In-Reply-To: <marc-linux-ia64-106926030617023@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 19 Nov 2003 12:15:23 -0800, "Seth, Rohit" <rohit.seth@intel.com> said:

  Rohit> Well, in the case of unaligned faults, there is no other way
  Rohit> for an application to know that there were unaligned faults.
  Rohit> Whereas for unsupported system calls, the kernel will return
  Rohit> ENOSYS and thus the application gets the required
  Rohit> notification (so that it can take any action it wants).  It
  Rohit> does not need to depend on dmesg stuff to find that
  Rohit> information out.

True in principle, but in practice, you can't always run strace to
find out what's going on, either because the problem starts in early
boot or because the problem is triggered indirectly through daemons
etc.

  Rohit> So, it does make sense to remove this printk (even though it
  Rohit> is _debug_) in this path.

I really much favor for distro's to make dmesg -n4 the default.  There
is no reason to bother average users with KERN_{NOTICE,INFO,DEBUG}
stuff unless they ask for it.

	--david
