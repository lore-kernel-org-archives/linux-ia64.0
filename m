From: Matt_Domsch@Dell.com
Date: Tue, 26 Jun 2001 02:34:47 +0000
Subject: RE: [Linux-ia64] Red Hat Installer cannot find the hard drive
Message-Id: <marc-linux-ia64-105590693005767@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005762@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005762@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> Partiition(s)) do not end on cylinder boundary:
> I got the same problem. You can try to do the low-level format for the
> harddrive and rest, go through the installation process. That 
> should resolve
> the error. At least it worked for me.

You don't have to low-level the drive, just write zeros to the first sector,
or erase the partition table.  Much faster...

Intel's fdisk.efi doesn't cylinder-align the EFI System Partition, which
often causes this problem.  If you use fdisk from within the installer,
delete the first partition, and write the empty partition table out, then
restart the installer, it'll work fine.

Thanks,
Matt

-- 
Matt Domsch
Sr. Software Engineer
Dell Linux Solutions
www.dell.com/linux


