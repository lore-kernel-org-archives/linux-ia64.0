From: Matt_Domsch@Dell.com
Date: Tue, 22 May 2001 21:06:30 +0000
Subject: RE: [Linux-ia64] 2.4.4 stability on Lions
Message-Id: <marc-linux-ia64-105590693005644@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005642@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005642@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Has anyone seem any instability with the 2.4.4 kernel + 
> David's patch on
> Lions?  I have been running it successfully on a 2P C0 Big 
> Sur with BIOS
> 103.  On a 4P C0 Lion with BIOS 73, however, I consistantly 
> get lockups
> after a short time.  Usually I get a totally black screen.  
> I'm going to try
> 2.4.3 and see if I still see the same problem.  2.4.2 seem to 
> work fine.

I had one lockup after about 18 hours of heavy stress copy-and-compare and
NIC traffic last night.
4P C0, Lion B2 board set, BIOS 80.  Black screen, no magic sysrq.  I'm
trying to reproduce it now.

Under normal light loads I haven't seen any issues.

Thanks,
Matt

--
Matt Domsch
Sr. Software Engineer
Dell Linux Solutions
www.dell.com/linux

