From: Matt_Domsch@Dell.com
Date: Mon, 12 Aug 2002 18:40:50 +0000
Subject: [Linux-ia64] RE: efibootmgr commands + kickstart
Message-Id: <marc-linux-ia64-105590701905933@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> For some reason the following commands fail in the post 
> section of a kickstart
> for installation:
> ---
> /usr/sbin/efibootmgr -w -c -d /dev/sdb -L "RedHat Linux (efi 
> backup )" > /dev/ttyS0
> /usr/sbin/efibootmgr -w -c -d /dev/sda -L "RedHat Linux"  > /dev/ttyS0

Do you have a relatively new firmware? :-(
(you can tell by switching to VT2 and doing a 'ls /proc/efi/vars'.  If
there's no 'Efi-{some-big-GUID}' there, then you need a new copy of
efibootmgr to handle the fact that that entry disappeared from the firmware,
and efibootmgr prior to 0.4.0 requires it to exist...

If this is it, you'll need to grab a new copy of efibootmgr from
http://domsch.com/linux/ia64/efibootmgr/ ,  build it, and drop the resultant
binary in place of the existing one.

Thanks,
Matt

--
Matt Domsch
Sr. Software Engineer, Lead Engineer, Architect
Dell Linux Solutions www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com
#1 US Linux Server provider for 2001 and Q1/2002! (IDC May 2002)


