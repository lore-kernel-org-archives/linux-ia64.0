From: Jesse Barnes <jbarnes@sgi.com>
Date: Wed, 23 Oct 2002 03:21:00 +0000
Subject: [Linux-ia64] ia64 compressed makefile target
Message-Id: <marc-linux-ia64-105590709805211@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David and Bjorn,

I noticed that the arch/ia64/Makefile 'compressed' target there's a
'--strip-all' arg getting passed to objcopy.  This has the effect of
removing relocation info from the vmlinux binary that we need for
systems w/o memory at the default link address, if I understand
correctly.  Would it be possible to change this option to
'--strip-debug' instead?  I can provide one-line patches for this
against your bitkeeper trees if that's easiest for you...

Thanks,
Jesse

