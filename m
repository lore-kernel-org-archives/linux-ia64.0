From: Matt_Domsch@Dell.com
Date: Sat, 10 Aug 2002 02:32:24 +0000
Subject: RE: [Linux-ia64] setting GUIDs
Message-Id: <marc-linux-ia64-105590701905929@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905928@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905928@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>   Is there a userspace command i can use to set the GUID of a 
> GPT partition
> under linux?  I asked google, but google didn't know, and i didn't see
> it described in the parted man page.

Which GUID? :-)

parted mkpart generates a new GUID for the partition it creates.
parted set flag xxxxx sets the partition type GUID to one of: boot, raid
(for Linux SW RAID), LVM, or basic data (any file system).  If you put a
file system or swap on the partition, it gets set to basic data or swap
respectively.

That's it.  No other support exists to write your own GUIDs to either field
of the partition, or to the disk_guid.  efibootmgr and parted both know how
to parse the table right, so if you need to write your own app you may want
to start there.

Thanks,
Matt

--
Matt Domsch
Sr. Software Engineer, Lead Engineer, Architect
Dell Linux Solutions www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com
#1 US Linux Server provider for 2001 and Q1/2002! (IDC May 2002)


