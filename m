From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 14 Feb 2001 18:49:12 +0000
Subject: Re: [Linux-ia64] 2.4.1 network problems
Message-Id: <marc-linux-ia64-105590693005147@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005146@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005146@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Can't say I have the problem you're describing.  I did have one
strange NFS related hang yesterday, after 13 days of uptime on a 2-way
Big Sur.  I did an "rpm -Uvh" while the current working directory was
on an NFS mounted filesystem and the "rpm" hung (even though the RPM
file itself was on a local filesystem).  It appeared that the
__rpc_execute() was waiting for an event that never happened and there
didn't seem to be a timeout either.  Of course, when doing the same
thing again after rebooting the system, it worked just fine.  Also,
note that it was only that one "rpm" process that got stuck (so it's
not like the kernel's timer facility was hosed all together).

So, for now, we should probably focus on trying to find a test case
that reproduces the problem reliably (or at least with decent
frequency).

Actually, IIRC, there are some eepro100 patches in the pipe for 2.4.2,
but I haven't played with it.  Also, given that Mike says the problems
happen both with e100 and eepro100, I suspect those won't help.

	--david

>>>>> On Tue, 13 Feb 2001 15:43:37 -0800, Michael Madore <mmadore@turbolinux.com> said:

  Mike> Hi, I am experiencing a lot of problems with 2.4.1 + David's
  Mike> patch on Lions.  If I try to scp a file from another machine
  Mike> the network connection dies almost immediately.  If I restrict
  Mike> the memory available to the kernel at boot time to 1024MB,
  Mike> then the problem seems to go away.  I've tried this on 4
  Mike> Lions, all with the eepro100 card.

  Mike> Has anyone else seen this?  I've had problems with the
  Mike> eepro100 before, but things are much worse now.

  Mike> -- Mike Madore Software Engineer TurboLinux, Inc.

  Mike> _______________________________________________ Linux-IA64
  Mike> mailing list Linux-IA64@linuxia64.org
  Mike> http://lists.linuxia64.org/lists/listinfo/linux-ia64

