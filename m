From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 17 Nov 2004 22:45:27 +0000
Subject: Re: [PATCH] Fix for kexec reboot failing after multiple continued kexec reboots
Message-Id: <200411171445.27850.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1100633878.21234.15.camel@lyra.fc.hp.com>
In-Reply-To: <1100633878.21234.15.camel@lyra.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday, November 16, 2004 11:37 am, Khalid Aziz wrote:
> kexec patch I had sent out earlier has bug where it appends
> "kexec_reboot" to kernel parameters blindly. After several kexec reboots
> from kexec'd kernel, kernel parameters line becomes too long and kernel
> fails to boot. Attached patch  will cure this. Patch
> kexec-ia64-reboot.diff can be applied on top of the previous patch I had
> sent. Patch 2.6.8.1-kexec3-ia64-2.diff includes this fix and is
> repalcement for my previous patch.
>
> My current kexec patches for ia64 can also be found at
> <http://free.linux.hp.com/~khalid/kexec-ia64/>.

This is really neat!  It patched pretty cleanly against the latest bk (this 
stuff should get into -mm asap to help prevent it from getting stale) and my 
new boot got this far:

[root@flatearth ~]# kexec -e
Starting new kernel
Linux version 2.6.10-rc2 (jbarnes@tomahawk.engr.sgi.com) (gcc version 3.4.1) 
#1SMP Wed Nov 17 14:34:56 PST 2004
EFI v1.02 by SGI: SALsystab=0x3002514a60 ACPI 2.0=0x3002514b60
kexec'd kernel: Not virtualizing EFI
Number of logical nodes in system = 1
Number of memory chunks in system = 1

This may be due to the lack of args though, I'll fix it up so that the 
console= stuff is passed in correctly and then debug it further.

Thanks,
Jesse
