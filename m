From: Joel GUILLET <Joel.Guillet@bull.net>
Date: Wed, 05 Feb 2003 17:03:26 +0000
Subject: Re: [Linux-ia64] Preempt problems
Message-Id: <marc-linux-ia64-105590709805816@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805801@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805801@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

I've just found a problem when using preemption patch with SMP on a
2.5.59 kernel. (with my version of the _raw_write_trylock() macro)

It seems, that the SCSI driver have some problems (at boot time):
As a result, sometimes, one of my partition (type ext3) can not be
mounted.
Here is the only related message in the log file :

Feb  5 17:54:13 zli22 kernel: scsi: Underflow detected - retrying command.


Sometimes, the partition is "half-mounted". I can only read one part of
the files. If I try to mount it again or to unmount it, I've got a message
saying that the device is busy.

		> mount /dev/sda4
		umount: /home: device is busy


It seems to me, that it is a deadlock. But it's not easy to identify it
because, it doesn't happen every time I boot the machine (about 1/2, with
my machines that have 2 cpus))

It could be a problem in the  "_raw_write_trylock()", but I have made some
tests, and it seems that the macro "returns" the good value.


---------------
> ... because the rw_lock value is composed with :
> - 1 bit for the write "flag" (the most significant bit of a _long_ value)

  Oh... I meant MSB of an _int_ value !

> - 31 bits for the read flags


Regards

---------
  Joel




