From: "Zhu, Yi" <yi.zhu@intel.com>
Date: Tue, 22 Jul 2003 01:00:43 +0000
Subject: RE: elilo option to disable perfmon
Message-Id: <marc-linux-ia64-105883569332687@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105876853727712@msgid-missing>
In-Reply-To: <marc-linux-ia64-105876853727712@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Get it! Thanks for all of your help!

-yi

> -----Original Message-----
> From: Luck, Tony 
> Sent: Monday, July 21, 2003 11:37 PM
> To: Alex Williamson; Zhu, Yi
> Cc: linux-ia64@vger.kernel.org
> Subject: RE: elilo option to disable perfmon
> 
> 
> >    I remember seeing this kind of error when playing with using
> > PAL_HALT_LIGHT in the cpu_idle loop.  Newer PAL solved the
> > problem.  If you have CONFIG_IA64_PAL_IDLE turned on in your
> > config file, you either need to upgrade to new firmware (not
> > sure what rev to recommend on a tiger box) or disable the config
> > option and rebuild a kernel.  Try for PAL 7.40 or better.
> 
> Latest BIOS for Tiger is S870BN4A.86B.0898.P07.0305300848 which
> includes PAL 7.59
> 
> -Tony
> 
