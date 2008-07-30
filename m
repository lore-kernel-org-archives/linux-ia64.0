From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Wed, 30 Jul 2008 08:42:38 +0000
Subject: Re: Anyone tested 2.6.27-rc1?
Message-Id: <87od4f69vl.wl%peter@chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080730063731.GA31304@parisc-linux.org>
In-Reply-To: <20080730063731.GA31304@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Matthew" = Matthew Wilcox <matthew@wil.cx> writes:

Matthew> With zx1_defconfig on a dual-processor rx2600 prototype, I
Matthew> get:

Matthew> VFS: Mounted root (ext3 filesystem) readonly.  Freeing unused
Matthew> kernel memory: 336kB freed Mount failed for selinuxfs on
Matthew> /selinux: No such file or directory INIT: version 2.86
Matthew> booting

Matthew> ... and that's it.  I'm trying to do something else, so I'll
Matthew> probably just revert back to 2.6.26.

I get the same on a zx2000 with 2.6.26  plus a few patches ... I was
planning to debug it today, only the disk in my zx2000 died, and I
need to get that fixed first.
--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
http://www.ertos.nicta.com.au           ERTOS within National ICT Australia
