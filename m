From: "Magenheimer, Dan (HP Labs Fort Collins)" <dan.magenheimer@hp.com>
Date: Wed, 29 Jun 2005 15:03:03 +0000
Subject: RE: Fast Syscalls and Virtualised Linux on Linux
Message-Id: <516F50407E01324991DD6D07B0531AD54FA1C5@cacexc12.americas.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <17090.8605.481641.322881@wombat.chubb.wattle.id.au>
In-Reply-To: <17090.8605.481641.322881@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I gather you are measuring with lmbench?  Is the performance
of a real, non-synthetic benchmark awful?

Also, I'm guessing that your guests are running at PL0?

Dan 

> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org 
> [mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Peter Chubb
> Sent: Tuesday, June 28, 2005 10:21 PM
> To: linux-ia64@vger.kernel.org
> Subject: Fast Syscalls and Virtualised Linux on Linux
> 
> 
> Hi,
> 	I'm working on a user-mode-linux like thing for IA64.  I have
> something working. but performance is awful.  The reason is
> syscall-via-break.
> 
> When a process running in the guest OS calls a system call via break
> (or a system call is restarted, and so falls back to syscall via
> break) the host OS catches it and tries to execute the system call.
> This is obviously undesireable.
> 
> The trick I'm using at present (not my own, Matt Chapman implemented
> it) is to ptrace the Virtual Machine Monitor, catch all system calls,
> and redirect ones that are for the guest OS to the guest.
> 
> Obviously, when a process running under the guest uses the fast system
> call path, the host doesn't see it, and so it can run at full speed.
> But there are enough cases where things fall back to the old via-break
> path that the ptrace hack is still needed.  And because it intercepts
> *every* system call even virtualised operations like read/write to the
> virtual disks cop the overhead.
> 
> One approach might be to redefine __BREAK_SYSCALL for the guest OS.
> That'd require a specially compiled glibc and kernel, and possibly
> other executables.
> 
> Does anyone have a better idea?
> 
> 
> -- 
> Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT 
> gelato.unsw.edu.au
> The technical we do immediately,  the political takes *forever*
> -
> To unsubscribe from this list: send the line "unsubscribe 
> linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
