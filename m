From: Michael Madore <mmadore@turbolinux.com>
Date: Tue, 27 Feb 2001 00:26:21 +0000
Subject: Re: [Linux-ia64] IA64 Boot/Installer CD
MIME-Version: 1
Content-Type: multipart/mixed; boundary="cNdxnHkX5QqsyA0e"
Message-Id: <marc-linux-ia64-105590693005210@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005208@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005208@msgid-missing>
To: linux-ia64@vger.kernel.org

--cNdxnHkX5QqsyA0e
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

Here is how we do it.

1) Create a directory called cdroot.  Create a subdirectory called boot.

2) Inside the boot directory, place your kernel and your initial ramdisk.  
You will also want to put any efi apps or shell scripts that you might need.

3) From inside the cdroot directory, run the attached "mkboot" script.  This
will create a boot image for your cd.

4) Run the attached "mkiso" script to build the cd image.

5) Run the attached "mkcd" script to burn the image onto the CD.  The "mkcd"
script is used with an IDE CD-ROM burner, so you may need to adjust cdrecord
command for your hardware.


On Mon, Feb 26, 2001 at 03:07:08PM -0800, Nick Pollitt wrote:
> Could someone explain what the bare minimum requirements are for a bootable
> CD on IA64.  I have a kernel and an initrd ready, but I'm not sure how to 
> package them up.
> 
> Thanks,
> Nick
> 
> -- 
> Nick Pollitt                                   phone: 650.933.7406
> Scalable Linux Project                           fax: 650.933.3542
> SGI                                               npollitt@sgi.com
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Mike Madore
Software Engineer
TurboLinux, Inc.

--cNdxnHkX5QqsyA0e
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=mkboot

dd if=/dev/zero of=boot.img bs=1024k count=18
/sbin/mkdosfs boot.img 
mkdir dos
mount -t msdos -o loop boot.img dos
cp -av boot/* dos/
df dos
umount dos
rmdir dos


--cNdxnHkX5QqsyA0e
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=mkiso

mkisofs  -no-emul-boot -b boot.img -c boot.catalog -R -T -J -o ../cdrom.img .

--cNdxnHkX5QqsyA0e
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=mkcd

#!/bin/bash
if [ $# -lt 1 ]
then
   echo "usage: mkcd [-speed #] <image file>"
   exit 1
fi
#default speed
speed=8
case $1 in
-speed)  shift;
         speed=$1
         shift;;
esac
image=$1
cdrecord fs=8196k speed=$speed dev=2,0,0 -v -eject $image

--cNdxnHkX5QqsyA0e--

