From: Matt_Domsch@Dell.com
Date: Wed, 17 Apr 2002 22:54:23 +0000
Subject: RE: [Linux-ia64] Kickstart help?
Message-Id: <marc-linux-ia64-105590701905480@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905479@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905479@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Also, any tips for making Kickstart do EFI partitions?  I've tried
> "part --size 100 --ondisk sda /boot/efi --type ef" but KS 
> doesn't appear to format it correctly.

If the partition already exists (was created by other tools):
part /boot/efi --ondisk=sda --onpart=sda1 --size0 --fstype=vfat
--noformat


Otherwise to create it:
part /boot/efi --size 100  --ondisk sda --type#9 --onprimary 1

--type takes a base-10 integer (so 0xEF would be --type#9).

The partitioning code underlying Anaconda changed significantly between RHL
7.1 and 7.2 (note addition of --fstype in 7.2).  I don't recall all the
changes so you'll have to play with it some.

Also, note that a disk with no partition table already will be made with
GPT.  If it has a DOS partition table, it will stay DOS, and if it has a
GPT, it stays GPT.


Thanks,
Matt

-- 
Matt Domsch
Sr. Software Engineer
Dell Linux Solutions www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com
#1 US Linux Server provider for 2001! (IDC Mar 2002)

