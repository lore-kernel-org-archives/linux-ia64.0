From: Jonathan_Kwahk@Dell.com
Date: Wed, 07 Mar 2001 19:38:31 +0000
Subject: RE: [Linux-ia64] ACPI problems in 2.4.2-ia64-010228
Message-Id: <marc-linux-ia64-105590693005261@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005246@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005246@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Yes, for Big Sur there is a more recent BIOS build than 89B (I currently
have 99 PAL 6.6.19).
I believe the EFI version is 12.33 based on the EFI spec. rev. 1.02.
SAL revision is 1.01 based on SAL spec. rev. 2.9.

I would try to get my hands on the 99 build since it supports many missing
SMBIOS structure types, MCA (i think it's memory correction algorithm), and
other fixes.

J

-----Original Message-----
From: Keith Owens [mailto:kaos@melbourne.sgi.com]
Sent: Wednesday, March 07, 2001 1:12 AM
To: davidm@hpl.hp.com; Grover, Andrew; linux-ia64@linuxia64.org
Subject: Re: [Linux-ia64] ACPI problems in 2.4.2-ia64-010228


On Tue, 06 Mar 2001 12:30:55 +1100, 
Keith Owens <kaos@melbourne.sgi.com> wrote:
>BugSur 2 B1 cpus.  PAL 2213, BIOS W460GXBS2.86E.0070.B.200008150911.
>Kernel 2.4.2 + ia64-010228.  I am getting semi-random data in the acpi
>tables which more often than not will hang the machine during boot.

Upgraded to PAL 2215, W460GXBS2.86E.0084.P02.200010271750.  Still
getting the ACPI problems.  Currently EFI 0.99, is there a more recent
version version of EFI for BigSur?


_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

