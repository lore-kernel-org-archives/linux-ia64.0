From: Matt_Domsch@Dell.com
Date: Mon, 10 Jun 2002 15:56:38 +0000
Subject: RE: [Linux-ia64] CD-ROM I/O error
Message-Id: <marc-linux-ia64-105590701905661@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905659@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905659@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> when I do 'cat /dev/cdrom > disc.iso' on my Itanium box,
> I/O error happens on CD-ROM.

If you're trying to simply make an ISO with the right number of sectors, you
need to use 'isoinfo' to avoid these kinds of end-of-disc problems.
Something like (yes I use this quite often):

[mdomsch@humbolt mdomsch]$ more ~/check_cds
#!/bin/sh

CD=0

while [ 1 ]; do
      CD=`expr $CD + 1`
      echo "Insert CD #$CD.  What shall I name it?"
      read CDNAME
      SIZE=`isoinfo -d -i /dev/cdrom | grep "Volume size is: " | awk '{print
$4}'`
      dd if=/dev/cdrom bs=2k count=$SIZE of=$CDNAME
      mount /mnt/cdrom
      ls -lR /mnt/cdrom
      umount /mnt/cdrom
done


Thanks,
Matt

--
Matt Domsch
Sr. Software Engineer
Dell Linux Solutions www.dell.com/linux
Dell internal Linux lists @ http://insidelists.us.dell.com
Dell public Linux lists @ http://lists.us.dell.com
#1 US Linux Server provider for 2001 and Q1/2002! (IDC May 2002)

