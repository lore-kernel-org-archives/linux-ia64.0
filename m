From: "Summers, Dow" <dsummers@verisign.com>
Date: Fri, 05 Apr 2002 19:37:01 +0000
Subject: RE: [Linux-ia64] ia64_log_get error while booting
Message-Id: <marc-linux-ia64-105590701905394@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905330@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905330@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I've been tracking this problem on my machine. I've worked out
that if I have a CD in the drive with the drive door closed when
the machine is powered on it will boot and run.  If there isn't
a CD in the drive and the drive door is closed when I boot the
machine the kerenl hangs in the MCA code.

I'm running Redhat 7.2 with a bios 109.

---
Dow Summers


-----Original Message-----
From: Daniel Yeisley [mailto:dpy102@alumni.psu.edu]
Sent: Friday, March 22, 2002 4:51 PM
To: Hall, Jenna S
Cc: linux-ia64@linuxia64.org
Subject: RE: [Linux-ia64] ia64_log_get error while booting


Well, it works now.  All I did was power cycle the machine.  I have no idea 
what could have been wrong.  I'll have to take a look at the BIOS level next

week.

Thanks for the help.
Dan



Quoting "Hall, Jenna S" <jenna.s.hall@intel.com>:

> Daniel,
> 
> What BIOS are you running on your Lion?  Older BIOSes did not have the
> correct firmware support for machine checks, so if you boot a kernel with
> CONFIG_IA64_MCA enabled in the kernel config, this behavior could result.
> 
> You have two options:
> 
> 1. Upgrade your BIOS - this is only an option if you have an OEM Lion (it
> is
> not recommended or supported by Intel to upgrade the BIOS past build 83 on
> SDV Lions).  You can determine if you have an OEM Lion by looking at the
> back of the legacy I/O card inside the machine - OEM machines will have
> "OEM
> Legacy" silkscreened on the back of the card.
> 2. Disable CONFIG_IA64_MCA in your .config file, rebuild the kernel, then
> reboot with that new kernel.
> 
> Jenna
> 
> -----Original Message-----
> From: Daniel Yeisley [mailto:dpy102@alumni.psu.edu]
> Sent: Friday, March 22, 2002 12:57 PM
> To: linux-ia64@linuxia64.org
> Subject: [Linux-ia64] ia64_log_get error while booting
> 
> I'm new to Linux on the IA64.  I installed Redhat 7.2 for the Itanium on a
> Lion
> system this morning.  It seemed to work fine.  I changed my screen
> resolution
> and rebooted.  I get a warning saying that my event log is full.  Linux
> starts
> to boot, but then it goes into what seems to be an infinite loop of
> alternating
> error messages.  They go by very quickly, but I believe that they are:
> ia64_log_get: Failed to retrieve SAL error record type ...
> ia64_mca_cpe_int_handler: received interrupt. vector > I've looked in the kernel source and both messages come from mca.c.  I'm
> not
> sure what the problem is.  I can't boot the machine, not even from the
> Redhat
> CDs.
> 
> 
> 
> 
> --------------------------------------------------
> Get Your FREE E-Mail Account Today at AcmeMail.net
> http://www.acmemail.net
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 




--------------------------------------------------
Get Your FREE E-Mail Account Today at AcmeMail.net
http://www.acmemail.net

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

