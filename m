From: Jonathan_Kwahk@Dell.com
Date: Wed, 07 Mar 2001 19:32:49 +0000
Subject: RE: [Linux-ia64] Two questions
Message-Id: <marc-linux-ia64-105590693005260@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005254@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005254@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Obviouslly, W460GXBS2 is the chipset notation (Workstation 460GX chipset,
Big Sur).
89B is the build number for the BIOS.
P03 is production build.  In this case, it's build 3.

If I recall correctly (it's been a very long time), the last string includes
the date of build.  I'm not sure what the other digits mean.

J

-----Original Message-----
From: Hall, Jenna S [mailto:jenna.s.hall@intel.com]
Sent: Wednesday, March 07, 2001 12:01 PM
To: linux-ia64@linuxia64.org
Subject: RE: [Linux-ia64] Two questions


As far as the 30+ digit BIOS revision, the only significant part would be
the "0089B" in the number below:

W460GXBS2.86E.0089B.P03.200012151745

So that's all you really have to record or report to Intel when clarifying
BIOS revision.

Jenna

-----Original Message-----
From: Stephane Eranian [mailto:eranian@frankl.hpl.hp.com]
Sent: Wednesday, March 07, 2001 9:35 AM
To: linux-ia64@linuxia64.org
Subject: Re: [Linux-ia64] Two questions


On Wed, Mar 07, 2001 at 12:19:05PM +0100, Francis Galiegue wrote:
> 1. Where can I get precise info about firmware revisions, etc etc? I only
know
> about what a 'ver' displays at the EFI prompt and what the files in /proc
> display... As to noting the 30+ digit BIOS revision, I do it by hand for
now...

Could you explain exactly what do you mean by precise ? version numbers ?
If so, you can get the pal version in  /proc/pal/cpu0/version_info. As for
EFI and SAL, at this point, there is no /proc interface to them. So your
only chance is by dmesg because the kernel prints the versions when it
boots.
The rest is probably coming from ACPI, I guess.

--
-Stephane

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64


_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

