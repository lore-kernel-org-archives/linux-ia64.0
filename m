From: Nathan Straz <nstraz@sgi.com>
Date: Fri, 15 Dec 2000 22:43:41 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.0-test12)
Message-Id: <marc-linux-ia64-105590678205858@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Dec 14, 2000 at 09:00:58PM -0800, David Mosberger wrote:
> in files linux-2.4.0-test12-ia64-001214.diff*
> 
> supposed to.  Thus, I'd like to see everyone giving this kernel a good
> workout and to report any new problems.

The kernel boots on my B1 BigSur, but it locks up as soon as I touch the
root file system after remounting it rw.  Sometimes I have SysRq access
for a few seconds, sometimes not.  No messages, no oops, just a good
solid hang.  Anyone else having trouble?

I booted up with init=/bin/bash and followed along with
/etc/rc.d/rc.sysinit. 

mount -n -o remount,rw /	// Works fine
>/etc/mtab			// locks the system. 

I tried "rm /etc/mtab" for the fun of it (after remounting) and it
locked, but after the system came back up and fscked it found the
unlinked inode and placed it in /lost+found is all data intact.  

Anyone else running into problems?
-- 
Nate Straz                                              nstraz@sgi.com
sgi, inc                                           http://www.sgi.com/
Linux Test Project                    http://oss.sgi.com/projects/ltp/

