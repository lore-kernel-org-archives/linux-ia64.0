From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 03 Oct 2002 15:15:30 +0000
Subject: Re: [Linux-ia64] Problem to write a tape ..
Message-Id: <marc-linux-ia64-105590701906084@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701906083@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701906083@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 03 Oct 2002 11:47:41 +0200, Jean-Philippe BATTU <jean-philippe.battu@bull.net> said:

  Jean-Philippe> Hi I am trying to do some backups on an old exabyte
  Jean-Philippe> 8505XL on my IA64 system running with redhat 7.2

  Jean-Philippe> My device is the only one device on the scsi chain. I
  Jean-Philippe> have a terminator on this chain.

  Jean-Philippe> I can write little files (tar cvf /dev/st0
  Jean-Philippe> /etc/passwd) but when I write large files (dump 0f
  Jean-Philippe> /dev/st0 /dev/sda3) I get an error on the dump or tar
  Jean-Philippe> command :

  Jean-Philippe>   DUMP: estimated 3323762 tape blocks.  DUMP: Volume
  Jean-Philippe> 1 started with block 1 at: Thu Oct 3 10:42:06 2002
  Jean-Philippe> DUMP: dumping (Pass III) [directories] DUMP: dumping
  Jean-Philippe> (Pass IV) [regular files] DUMP: write error 49000
  Jean-Philippe> blocks into volume 1: Input/output error

  Jean-Philippe> with on the log message files : kernel: st0: Error
  Jean-Philippe> 27070000 (sugg. bt 0x20, driver bt 0x7, host bt 0x7)

  Jean-Philippe> I encountered this problem on redhat 7.1 but the
  Jean-Philippe> problem seems persisted in redhat 7.2

This won't be of immediate help, but just fyi: I'm using an old hp
surestore 6000 (DDS-2) tape drive to back up my i2000 (aka big sur).
Each backup is usually ~8GB in size and I haven't seen any problems so
far (I also use dump/restore).

  Jean-Philippe> I looked for some informations about this error
  Jean-Philippe> messages but all the documents I found where about
  Jean-Philippe> the termination string, and all is ok

  Jean-Philippe> Could you help me ?  Any suggestions would be greatly
  Jean-Philippe> appreciated

Can't help with deciphering the error message.  I vaguely recall that
there may have been a problem with early versions of "dump".  The one
I'm using is 0.4b27/libext2fs v1.27 as shipped by Debian/ia64.

	--david

