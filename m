From: "Robert K Gjertsen" <gjertsen@us.ibm.com>
Date: Thu, 07 Feb 2002 16:51:26 +0000
Subject: [Linux-ia64] anyone maintaining lkcd for ia64?
Message-Id: <marc-linux-ia64-105590698806015@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I've used kdb in the past for ia64, but was
taking a look at getting lkcd working on RH 7.2
(2.4.9-18/21) for ia64.
I grabbed the latest stuff from sourceforge.net
and I'm working through the patched build now
and see that dump_base.c is ia64 unfriendly
with its use of irq_stat (using a hacked patch
originally from lkcd-2.4.15-1.diff).
I'm slogging through this, but I hate to reinvent
the wheel if someone else has a working
copy/patch (newer kernel version is fine).
Anyone actually using this for newer kernels
on ia64 (and has SGI totally dumped working
on this)?

Thanks,

--Rob


