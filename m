From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 23 Oct 2002 17:46:32 +0000
Subject: RE: [Linux-ia64] ia64 compressed makefile target
Message-Id: <marc-linux-ia64-105590709805214@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805211@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805211@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Or perhaps David will take the CONFIG_IA64_VMAP_KERNEL
patch that I posted a week ago which also allows the
kernel to run on systems without memory at the default
link address.  Admittedly it's more than one line, but
it contains much of the same infrastructure that is
needed to support kernel text replication.

-Tony

-----Original Message-----
From: Jesse Barnes [mailto:jbarnes@sgi.com]
Sent: Tuesday, October 22, 2002 8:21 PM
To: linux-ia64@linuxia64.org; davidm@hpl.hp.com; bjorn_helgaas@hp.com
Subject: [Linux-ia64] ia64 compressed makefile target


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

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

