From: "G\\351raud Krawezik" <gk@scali.no>
Date: Thu, 03 Aug 2000 09:05:33 +0000
Subject: RE: [Linux-ia64] Problem installing Linux on a dual-itanium
Message-Id: <marc-linux-ia64-105590678205264@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205263@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205263@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It finally worked, but quite 'magically'.
Anyway I had to redo the installation procedure 10 times before this
result. Patience may be the correct attitude...

To those that may face the same problem, here follow the different steps I
faced:

- impossible to find ELI
- ELI found, but while booting we get a 'read error'
- Everything is OK.

I could not figure out what went wrong before, maybe a HW problem.

Geraud



On Wed, 2 Aug 2000 Jonathan_Kwahk@Dell.com wrote:

> Check your path by using the "set" command in the EFI shell.
> 
> J
> 
> -----Original Message-----
> From: G\351raud Krawezik [mailto:gk@scali.no]
> Sent: Wednesday, August 02, 2000 4:33 AM
> To: linux-ia64@linuxia64.org
> Subject: [Linux-ia64] Problem installing Linux on a dual-itanium
> 
> 
> Hello,
> 
> I am experiencing several problems installing linux (kernel 2.4.0-test1)
> on a dual-cpu ia64.
> The machine is an intel SDV.
> 
> When running the installation from the CD, there's no probleand everything
> works fine.
> - We create the three partitions on the HD
> - Let things go...
> 
> After rebooting, when I use the EFI shell and type 'ELI', I get a 'ELI not
> found'.
> 
> If I use the other item (for advanced booting mode), and try to boot
> directly on the correct partition, then it starts booting, but ends up
> into 'vmlinux-2.4.0.0-8smp: read failed: Device Error'
> 
> Has anyone got a tip about this?
> 
> 
> ps: I installed the same system on a single cpu SDV with no problem, but
> this one had got the previous bios...
> 
> Geraud
> 
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 



