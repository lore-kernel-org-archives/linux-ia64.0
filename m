From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Tue, 24 Jul 2001 00:20:33 +0000
Subject: Re: [Linux-ia64] gnu-efi-3.0/elilo-3.0 packages available
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Qxx1br4bt0+wmkIi"
Message-Id: <marc-linux-ia64-105590693005882@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005807@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005807@msgid-missing>
To: linux-ia64@vger.kernel.org

--Qxx1br4bt0+wmkIi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Jul 12, 2001 at 10:01:36AM +0100, Richard Hirst wrote:
> Hi
>   I'm working on the debian installer for ia64, and have just picked
> up elilo-3.0.  I'm trying to use it interactively, with an elilo.conf.
> At the fsX: prompt I type 'elilo' and hit return.  It shows me the device
> names and a prompt, but any key I press just drops me back to an fsX:
> prompt.  Is this a known problem, or is it more likely a local
> problem with my config or elilo build?
> 
The correct fix is attached at the end of this mail.

> I'm also interested in having elilo pick up kernel images from an
> ext2 partition, but can see the different naming schemes causing me
> real pain.  Is anyone working on an elilo naming scheme
> that more closely mirrors the kernel scheme?  I havn't experimented much
> yet, but say I have sda1 as my EFI partition, sda2 and /, sda3 as /boot,
> and I want to pick up kernels from /boot.  It seems to me that the
> elilo name for sda3 is going to change, depending on what partitions I
> happen to create on, say, sdd.  A new vfat partition on sdd1 would
> make the elilo name for sda3 change from, say scsi3 to scsi4, if I have
> understood correctly.

Well, that is a tough problem and maybe you looked at the README.devschemes
where I try to explain it. The default scheme in elilo-3.0 does have the
problem you mentioned above. But it is already better than the fsX: provided
by the EFI shell in that is does isolate the floppy/CDROM from the SCSI
disks. Clearly if you add partitions on your SCSI disks  then things
may shift even though the changes were on a different disk.

Now, I believe it is possible to write a device scheme that would mimic the
Linux way of doing things. However it is not a trivial piece of code.
The danger of course is to get small differences it we do not get this right.
And small differences are worse than something we know upfront is different.
Also the other issue is that it would create a new dependency between the
bootloader and the kernel, if anything changes if the way the kernel finds
and names devices, it would have to be propagated back to the boot loader. 
In the bootloader design, we have tried to minimize this as much as possible.

Anyway, if you are interested in building such a module for elilo, I am very
supportive of it and I am willing to help you. I am not sure I'll get the
resources to do this anytime soon...

Thanks.

-- 
-Stephane

--Qxx1br4bt0+wmkIi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="elilo-010723.diff"

--- elilo-3.0/util.c	Mon Jul  2 00:57:29 2001
+++ elilo-3.1/util.c	Mon Jul 23 16:01:34 2001
@@ -135,7 +135,7 @@
 
 	BS->CloseEvent(timer);
 
-	return idx ? -1 : 0;
+	return idx ? 1 : 0;
 }
 
 INTN

--Qxx1br4bt0+wmkIi--

