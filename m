From: Venkatesh Ramamurthy <Venkateshr@ami.com>
Date: Thu, 24 Feb 2000 17:10:06 +0000
Subject: RE: [Linux-ia64] Getting a copy of the CD
Message-Id: <marc-linux-ia64-105590678204967@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678204966@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678204966@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

did u try booting from efi shell like these

goto the cdrom filesystem eg fs0:
fs0:\> eli vmlinux root=ROOT rescue 

where ROOT= the device node for IDE CDROM ... say eg /dev/hdb if its primary
slave

then you have to fdisk the hard disk , create partitions and copy all files
& directories manually from the cdrom into the newly created partitions....
create  one partition as FAT, so that EFI SHELL can see it . copy the
contents of /boot directory into this FAT partition...

next time you boot the system go to the FAT filesystem that you have created
fs0:\> eli vmlinux root=/dev/hda1   

where /dev/hda1 is the primary master HDD

Venkatesh
American Megatrends Inc

On Thursday, February 24, 2000 11:58 AM, Eugene Dale Tyler
[SMTP:edt@world.std.com] wrote:
| Hello,
| 
| I work for a company that makes a hardware debugger targeted at
| IA-32 and IA-64 systems. 
| 
| We have a Lion Debug Chasis and are looking to load linux on it
| so that we can get the IA-64 debugging environment up to snuff.
| I am the firmare engineer responsible for the code that controls
| the IA-64 platform and a Linux fan. So, it is in my interest to
| get Linux running on the platform prior to Win2K ;->>
| 
| I downloaded the sources from kernel.org and the tool chain from
| Cygnus, but am going through the same pain as some others I see here.
| If the CD from Linux World will work enough to get to a shell, then
| we can make sure our VHPT and other code is running well.
| 
| I can be reached at 949/360-1717 or by e-mail.
| 
| Thanks in advance for any help you all can provide.
| 
| Regards,
| Dale
| PGP Public Key Fingerprint =  41 88 59 D9 B2 A7 27 99  F7 EB 1F 0E AD CA
F1 26 
| 
| 
| 
| 
| _______________________________________________
| Linux-IA64 mailing list
| Linux-IA64@linuxia64.org
| http://lists.linuxia64.org/lists/listinfo/linux-ia64


