From: Richard Hirst <rhirst@linuxcare.com>
Date: Thu, 12 Jul 2001 09:01:36 +0000
Subject: Re: [Linux-ia64] gnu-efi-3.0/elilo-3.0 packages available
Message-Id: <marc-linux-ia64-105590693005845@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005807@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005807@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi
  I'm working on the debian installer for ia64, and have just picked
up elilo-3.0.  I'm trying to use it interactively, with an elilo.conf.
At the fsX: prompt I type 'elilo' and hit return.  It shows me the device
names and a prompt, but any key I press just drops me back to an fsX:
prompt.  Is this a known problem, or is it more likely a local
problem with my config or elilo build?

I'm also interested in having elilo pick up kernel images from an
ext2 partition, but can see the different naming schemes causing me
real pain.  Is anyone working on an elilo naming scheme
that more closely mirrors the kernel scheme?  I havn't experimented much
yet, but say I have sda1 as my EFI partition, sda2 and /, sda3 as /boot,
and I want to pick up kernels from /boot.  It seems to me that the
elilo name for sda3 is going to change, depending on what partitions I
happen to create on, say, sdd.  A new vfat partition on sdd1 would
make the elilo name for sda3 change from, say scsi3 to scsi4, if I have
understood correctly.

Thanks,
  Richard


