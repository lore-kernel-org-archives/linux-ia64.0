From: Randolph Chung <randolph@tausq.org>
Date: Fri, 21 Feb 2003 08:14:22 +0000
Subject: Re: [Linux-ia64] ski and gcc-3.x
Message-Id: <marc-linux-ia64-105590709805899@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805894@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805894@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I'm afraid you'll be out of luck without X: you _can_ run in
> batch-mode without X, but then you don't get the debugger.  If you
> want the debugger, there must be a way to create a simulated console
> and that's done by starting a slave xterm.  Without X, that's hard to
> do.  If I work remotely, I use ssh X forwarding to prevent this
> problem.

ah, ok... Matt's fake-xterm program was very useful too...

now i just have to figure out what i'm doing wrong and why it doesn't
see the simulated scsi disk... :(

I'm running ski with:
ski linux-2.5.60/bootloader linux-2.5.60/vmlinux simscsi=/var/ski-disks/sd

and all i see is:

scsi0 : simulated SCSI host adapter
NET4: Linux TCP/IP 1.0 for NET4.0
IP: routing cache hash table of 1024 buckets, 8Kbytes
TCP: Hash tables configured (established 16384 bind 16384)
NET4: Unix domain sockets 1.0/SMP for Linux NET4.0.
VFS: Cannot open root device "" or 08:01
Please append a correct "root=" boot option
Kernel panic: VFS: Unable to mount root fs on 08:01

confused,
randolph
-- 
Randolph Chung
Debian GNU/Linux Developer, hppa/ia64 ports
http://www.tausq.org/

