From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 08 May 2003 00:07:42 +0000
Subject: RE: [Linux-ia64] Re: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705664@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> How many tools are out there that depend on System.map or similar?  I
> suppose you could just generate a fresh System.map at boot time (or
> have something like /proc/System.map).

Apparently a few, but not a vast number ... on RedHat AS2.1:

 # grep -rl 'System.map' /bin /usr/bin /usr/sbin /etc /sbin
   /bin/ps
   /usr/bin/ksymoops
   /usr/bin/kpm
   /usr/sbin/readprofile
   /etc/rc.d/rc.sysinit
   /etc/rc.sysinit
   /sbin/depmod
   /sbin/insmod.static
   /sbin/insmod
   /sbin/modprobe
   /sbin/ksyms
   /sbin/kallsyms
   /sbin/lsmod
   /sbin/modinfo
   /sbin/rmmod
   /sbin/klogd
   /sbin/installkernel
   /sbin/new-kernel-pkg

