From: Don Dugger <n0ano@valinux.com>
Date: Wed, 14 Feb 2001 20:39:32 +0000
Subject: Re: [Linux-ia64] 2.4.1 network problems
Message-Id: <marc-linux-ia64-105590693005151@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005146@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005146@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Mike-

Just as a data point I downloaded you file and copied over NFS to
my BigSur multiple times, both to and from the BigSur.  No problems
with any of the copies.

On Wed, Feb 14, 2001 at 12:10:24PM -0800, Michael Madore wrote:
> 
> On Wed, Feb 14, 2001 at 10:49:12AM -0800, David Mosberger wrote:
> > Can't say I have the problem you're describing.  I did have one
> > strange NFS related hang yesterday, after 13 days of uptime on a 2-way
> > Big Sur.  I did an "rpm -Uvh" while the current working directory was
> > on an NFS mounted filesystem and the "rpm" hung (even though the RPM
> > file itself was on a local filesystem).  It appeared that the
> > __rpc_execute() was waiting for an event that never happened and there
> > didn't seem to be a timeout either.  Of course, when doing the same
> > thing again after rebooting the system, it worked just fine.  Also,
> > note that it was only that one "rpm" process that got stuck (so it's
> > not like the kernel's timer facility was hosed all together).
> > 
> > So, for now, we should probably focus on trying to find a test case
> > that reproduces the problem reliably (or at least with decent
> > frequency).
> > 
> > Actually, IIRC, there are some eepro100 patches in the pipe for 2.4.2,
> > but I haven't played with it.  Also, given that Mike says the problems
> > happen both with e100 and eepro100, I suspect those won't help.
> 
> In addition to the >1024MB problem, I am also experiencing a reproducible
> nfs hang on Lions.  If I copy this file
> 
>    ftp://frontier.turbolinux.com/pub/ia64/nfshang.bin 
> 
> from an nfs server to the local file system, the copy hangs after
> transferring 294912 bytes.  If I copy the file from the local filesystem to the 
> server, the copy completes successfully.  The hang only occurs with certain files.
> 
> The following messages are logged:
> 
> nfs: server plateau not responding, still trying
> nfs: task 294 can't get a request slot
> eth0: 0 multicast blocks dropped.
> eepro100: wait_for_cmd_done timeout!
> eepro100: wait_for_cmd_done timeout!
> eepro100: wait_for_cmd_done timeout!
> nfs: task 295 can't get a request slot
> eepro100: wait_for_cmd_dont timeout!
> 
> Only nfs seems to be affected.  I am able to ssh into and out of the box.
> 
> Also, the hang does not happen if I switch to a 3COM 3C905B network card.
> 
> I have tried the same experiment with the Intel driver module.  Although the
> problem is harder to reproduce,  when nfs does hang, it is in the same
> offset in the same file.
> 
> 
> -- 
> Mike Madore
> Software Engineer
> TurboLinux, Inc.
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@valinux.com
Ph: 303/938-9838

