From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 17 Nov 2004 23:44:39 +0000
Subject: Re: [PATCH] Fix for kexec reboot failing after multiple continued kexec reboots
Message-Id: <200411171544.39448.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1100633878.21234.15.camel@lyra.fc.hp.com>
In-Reply-To: <1100633878.21234.15.camel@lyra.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday, November 17, 2004 2:45 pm, Jesse Barnes wrote:
> This is really neat!  It patched pretty cleanly against the latest bk (this
> stuff should get into -mm asap to help prevent it from getting stale) and
> my new boot got this far:
>
> [root@flatearth ~]# kexec -e
> Starting new kernel
> Linux version 2.6.10-rc2 (jbarnes@tomahawk.engr.sgi.com) (gcc version
> 3.4.1) #1SMP Wed Nov 17 14:34:56 PST 2004
> EFI v1.02 by SGI: SALsystab=0x3002514a60 ACPI 2.0=0x3002514b60
> kexec'd kernel: Not virtualizing EFI
> Number of logical nodes in system = 1
> Number of memory chunks in system = 1
>
> This may be due to the lack of args though, I'll fix it up so that the
> console= stuff is passed in correctly and then debug it further.

It's dying in find_pernode_space.  The efi memmap, though trimmed, should be 
ok at this point, so I'm still trying to figure out what's going on in that 
routine.

Jesse
