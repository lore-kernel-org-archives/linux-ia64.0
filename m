From: Gerrit.Huizenga@us.ibm.com
Date: Wed, 23 Aug 2000 01:01:52 +0000
Subject: Re: [Linux-ia64] Memory clearing at reboot
Message-Id: <marc-linux-ia64-105590678205384@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205378@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205378@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Having an ability to dump system memory to disk from an application
other than the kernel that just crashed is a major serviceability
feature for larger systems.  I don't see it as being as useful on
a one or two proc system, but post-mortem analysis is typically
considered a major feature for people running departmental or
large servers (e.g. Lion sized).

Being only able to dump memory from inside of a dying kernel (a la
NT) seems like a bad idea on a big box.

Of course, if this is BIOS specific, people building larger machines
(e.g. 4 proc or larger) can hopefully avoid this problem (e.g. here
at IBM ;-).  It would be more useful though if this were a feature
of the standard Lion BIOS as well.

gerrit

> Hi John,
> 
> Big Sur initializes it's memory only on power on; it does not do so on a
> soft reboot.  The behavior you are seeing should continue on all build of
> our BIOS.
> 
> I am waiting for the answer on the Lion machine and do not know if Lion team
> can also enable this functionality.  I will respond again once I have the
> answer.  (By the way, my gut feelings says that they will not be able to
> enable this functionality.)
> 
> Thanks
> Sunil 
> 
> -----Original Message-----
> From: John Baboval [mailto:baboval@mclinux.com]
> Sent: Tuesday, August 22, 2000 11:50 AM
> To: linux-ia64@linuxia64.org
> Subject: [Linux-ia64] Memory clearing at reboot
> 
> 
> I have a small test program that I run at the EFI shell prompt to set an
> area of memory and then perform a warm reboot. After the reboot our BigSur
> still contains the values written, but the Lion is cleared to zero. (We
> check the contents with the mem command, and the ResetSystem() is called
> with the EfiResetWarm parameter.)
> 
> Does anyone know if there is a way to cause the Lion *not* to clear memory?
> Also, our Lion has newer firmware then the BigSur. Perhaps the newer
> firmware causes the reset? 
> 
> If someone out there has a BigSur with the latest firmware/CPU rev., could
> you run my program and tell me if your machine resets it's memory? The
> source code is attached, and you can build it with gnu-efi-0.9.
> 
> Basically, you run the program and write down the address, and then when the
> machine comes back up type 'mem <Address>' and see if the memory is zero or
> not.
> 
> Not reseting memory makes taking kernel core dumps with our in-memory core
> dump patches MUCH easier! Thanks for any help,
> 
> -- 
> --John
> jbaboval@missioncriticallinux.com
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 

