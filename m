From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 08 May 2003 00:24:13 +0000
Subject: Re: [Linux-ia64] Re: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705669@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 7 May 2003 17:07:42 -0700, 
"Luck, Tony" <tony.luck@intel.com> wrote:
>David wrote
>> How many tools are out there that depend on System.map or similar?  I
>> suppose you could just generate a fresh System.map at boot time (or
>> have something like /proc/System.map).
>
>Apparently a few, but not a vast number ... on RedHat AS2.1:
>
> # grep -rl 'System.map' /bin /usr/bin /usr/sbin /etc /sbin
>   /bin/ps
>   /usr/bin/ksymoops
>   /usr/bin/kpm
>   /usr/sbin/readprofile
>   /etc/rc.d/rc.sysinit
>   /etc/rc.sysinit
>   /sbin/depmod
>   /sbin/insmod.static
>   /sbin/insmod
>   /sbin/modprobe
>   /sbin/ksyms
>   /sbin/kallsyms
>   /sbin/lsmod
>   /sbin/modinfo
>   /sbin/rmmod
>   /sbin/klogd
>   /sbin/installkernel
>   /sbin/new-kernel-pkg

Out of the modutils programs, only depmod actually reads System.map and
only when doing make modules_install.  It does not care about the
addresses, only if a symbol is exported or not.  insmod, modprobe,
ksyms, lsmod, modinfo, rmmod contain a reference to System.map because
of a table that lists files that might appear in /lib/modules/`uname -r`,
they only care about the file name, not its contents.

kallsyms will require run time relocation, its table uses absolute
kernel addresses.

rc.sysinit only looks for the file System.map so it can set up a
symlink, it does not read the contents.

installkernel and new-kernel-pkg just copy System.map so other tools
can find it.

klogd, ps, readprofile and lkcd (not on that list) will need a clean
copy of System.map.  IOW it has to be regenerated for those programs.

Don't know about kpm.


