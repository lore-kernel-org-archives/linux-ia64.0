From: Stephane Eranian <eranian@hpl.hp.com>
Date: Thu, 27 May 2004 18:31:31 +0000
Subject: Re: a elilo.conf question
Message-Id: <20040527183131.GD22140@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.GSO.4.58.0405271410140.660@tokyo.cc.gatech.edu>
In-Reply-To: <Pine.GSO.4.58.0405271410140.660@tokyo.cc.gatech.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

On Thu, May 27, 2004 at 02:21:52PM -0400, Younggyun Koh wrote:
> Hi,
> 
> i got the kernel image but still struggling booting...
> 
> elilo.conf entry i set is
> 
> image=/efi/redhat/vmlinuz-2.6.6.gz
> 	label=linux2.6.6
> 	root=/dev/sda3
> 	read-only
> 
> but when kernel being loaded, i got this error message...
> 
> VFS:Cannot open root device "sda3" or unknown-block(0,0)
> Please append a currect "root=" boot option
> Kernel panic: VFS: Unable to mount root fs on unknown-block(0,0)
> 
> (/dev/sda3 is mounted to / in the kernel 2.4)
> 
> the itanium 2 machine i'm using is hp zx6000
> 

Most likely your kernel does not have the SCSI driver you need compiled in. 

You have two options:
	- compile the SCSI driver (Fusion) into the kernel

	- compile the driver as a module, and put it into an initrd.
	  the initrd file must be in the EFI partition. You need to 
	  add one line to the above elilo.conf entry: initrd=initrd_file_name

-- 
-Stephane
