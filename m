From: dannf@ldl.fc.hp.com (dann)
Date: Sat, 10 Aug 2002 18:15:08 +0000
Subject: Re: [Linux-ia64] setting GUIDs
Message-Id: <marc-linux-ia64-105590701905930@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905928@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905928@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Aug 09, 2002 at 09:32:24PM -0500, Matt_Domsch@Dell.com wrote:
> 
> parted mkpart generates a new GUID for the partition it creates.
> parted set flag xxxxx sets the partition type GUID to one of: boot, raid
> (for Linux SW RAID), LVM, or basic data (any file system).  If you put a
> file system or swap on the partition, it gets set to basic data or swap
> respectively.
> 

that's just what i needed - thanks Matt!

-- 
---------------------------
dann frazier
Hewlett-Packard
Linux Development Lab
dannf@ldl.fc.hp.com
(970) 898-0800

