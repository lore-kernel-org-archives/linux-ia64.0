From: Bill Nottingham <notting@redhat.com>
Date: Thu, 07 Dec 2000 14:37:47 +0000
Subject: [Linux-ia64] Re: fail to mount LS120 drive
Message-Id: <marc-linux-ia64-105590678205811@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205809@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205809@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Francis Galiegue (fg@mandrakesoft.com) said: 
> If not, what does a fdisk -l /dev/hdb give on an LS120 floppy? And in general,
> can LS120 floppies be partitioned? I doubt it...

Yes, they can be. It's kind of odd, but it's necessary if
you want to use the same boot image for a disk and for
the CD (unless you try and fit an ia64 boot image into
a normal floppy size, which would be rather tight.)

Bill

