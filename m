From: Matt_Domsch@Dell.com
Date: Sat, 18 Nov 2000 02:06:20 +0000
Subject: RE: [Linux-ia64] FAT32 file system not mounting on IA-64
Message-Id: <marc-linux-ia64-105590678205747@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205745@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205745@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Chris, thanks for investigating further.  Glad to hear you can reproduce the
problem there.

w/o the -F 32, it makes a FAT16 file system, which supports long file names
and the vfat type, just as Windows NT FAT16 file systems support long file
names.   If you mount with:  mount -ofat  or with -ofat2, you'll see it
force the choice, and then you can see if the kernel thinks it's a FAT16 or
FAT32.

Thanks,
Matt


-----Original Message-----
From: Ahna, Christopher J [mailto:christopher.j.ahna@intel.com]
Sent: Friday, November 17, 2000 7:25 PM
Subject: RE: [Linux-ia64] FAT32 file system not mounting on IA-64


Matt,

I looked a little more and think you're probably onto something.  I believe
there is a problem with 'mkdosfs -F 32'.  I ran this program on a 100MB file
I built with dd and got the errors you reported when I tried to mount it.
Doing the same thing without the '-F 32' switch built a mountable filesystem
which looks for all the world like FAT32 (for example, it doesn't have a
problem with arbitrarily long filenames and mounted successfully with 'mount
-t vfat').

Somebody might want to look into this if they have time.  Thanks,

Chris


