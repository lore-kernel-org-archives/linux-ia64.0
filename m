From: Michael Madore <mmadore@turbolinux.com>
Date: Tue, 22 May 2001 22:43:45 +0000
Subject: Re: [Linux-ia64] 2.4.4 stability on Lions
Message-Id: <marc-linux-ia64-105590693005648@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005642@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005642@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hmmm,  I'll check that out.  I know that the adapter settings were
originally set to > 4GB.  Not sure how they would have been altered.

On Tue, May 22, 2001 at 03:33:48PM -0700, Wiegrefe, Don J wrote:
> While it is true you should always use the latest BIOS that matches your
> processor stepping ( in this case 76 ). The solution to your problem is to
> alter your SCSI host adapter settings to operate > 4GB. If you can use the
> SCSI FastUtil the setting to change is found under host adapter settings.
>  Hope this helps. 
>  
>  Don Wiegrefe
>  Soft Sur/ Lion Hardware/BIOS Support
> 
> -----Original Message-----
> From: Michael Madore [mailto:mmadore@turbolinux.com]
> Sent: Tuesday, May 22, 2001 2:58 PM
> To: Matt_Domsch@Dell.com
> Cc: linux-ia64@linuxia64.org
> Subject: Re: [Linux-ia64] 2.4.4 stability on Lions
> 
> 
> I just noticed that the machine locked up on me while sitting at the EFI
> shell prompt.  I've downloaded BIOS 76 (latest available on Quad) and I'll
> see if that makes any difference.
> 
> On Tue, May 22, 2001 at 04:06:30PM -0500, Matt_Domsch@Dell.com wrote:
> > > Has anyone seem any instability with the 2.4.4 kernel + 
> > > David's patch on
> > > Lions?  I have been running it successfully on a 2P C0 Big 
> > > Sur with BIOS
> > > 103.  On a 4P C0 Lion with BIOS 73, however, I consistantly 
> > > get lockups
> > > after a short time.  Usually I get a totally black screen.  
> > > I'm going to try
> > > 2.4.3 and see if I still see the same problem.  2.4.2 seem to 
> > > work fine.
> > 
> > I had one lockup after about 18 hours of heavy stress copy-and-compare and
> > NIC traffic last night.
> > 4P C0, Lion B2 board set, BIOS 80.  Black screen, no magic sysrq.  I'm
> > trying to reproduce it now.
> > 
> > Under normal light loads I haven't seen any issues.
> > 
> > Thanks,
> > Matt
> > 
> > --
> > Matt Domsch
> > Sr. Software Engineer
> > Dell Linux Solutions
> > www.dell.com/linux
> 
> -- 
> Mike Madore
> Senior Software Engineer
> TurboLinux, Inc.
> (650)228-5203
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Mike Madore
Senior Software Engineer
TurboLinux, Inc.
(650)228-5203

