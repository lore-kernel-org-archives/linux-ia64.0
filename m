From: Francis Galiegue <fg@mandrakesoft.com>
Date: Thu, 07 Dec 2000 14:38:41 +0000
Subject: Re: [Linux-ia64] fail to mount LS120 drive
Message-Id: <marc-linux-ia64-105590678205810@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205808@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205808@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 7 Dec 2000, Einar Saltnes wrote:

> 
> Hi,
> I'm trying to mount the LS120 drive on BigSur, but fail getting
> the following message:
> 
> [root@scali9-12 linux-2.4.0-test10]# mount /mnt/floppy
> /dev/hdb1: Invalid argument
> mount: /dev/hdb1 has wrong major or minor number
> 
> Same result with floppy and LS120 floppy.
> 

Try with /dev/hdb. Is it any better? At least, it Works For Me(tm).

If not, what does a fdisk -l /dev/hdb give on an LS120 floppy? And in general,
can LS120 floppies be partitioned? I doubt it...

-- 
Francis Galiegue, fg@mandrakesoft.com
"Programming is a race between programmers, who try and make more and more
idiot-proof software, and universe, which produces more and more remarkable
idiots. Until now, universe leads the race"  -- R. Cook


