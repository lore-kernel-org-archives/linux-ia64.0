From: Gerrit.Huizenga@us.ibm.com
Date: Wed, 09 Aug 2000 10:53:49 +0000
Subject: Re: [Linux-ia64] Processor Rev.
Message-Id: <marc-linux-ia64-105590678205295@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In addition to /proc/cpuinfo, there's a bunch of interesting stuff
in /proc/palinfo/*, for instance:

[gerrit@elm3a86 palinfo]$ cat /proc/palinfo/version_info
PAL_vendor     : 0xff (min=0xff)
PAL_A revision : 0x9 (min=0x9)
PAL_A model    : 0x22 (min=0x22)
PAL_B mode     : 0x9 (min=0x0)
PAL_B revision : 0x22 (min=0x0)

There is other stuff of interest in /proc/palinfo.

Chris pointed out that the minor numbers of the version aren't included here.

Also, reading one of the files here caused a panic with the B1 CPU steppings.

gerrit

> What is a good way to check the processor revision on the lion machines. I
> see people on the list refering to A1 or A2 stepping machines, but /proc/cpuinfo on
> our machines only shows this:
> 
> processor  : 3
> vendor     : GenuineIntel
> family     : IA-64
> model      : Itanium
> revision   : 0
> archrev    : 0
> 
> plus the serial numbers and MHz and such. Does this just mean we have old
> CPUs, or is there a different way to check?
> 
> -- 
> John V. Baboval (baboval@missioncriticallinux.com)
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 

