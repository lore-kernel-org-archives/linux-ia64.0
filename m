From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 21 Feb 2003 16:06:29 +0000
Subject: Re: [Linux-ia64] ski and gcc-3.x
Message-Id: <marc-linux-ia64-105590709805900@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805894@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805894@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 21 Feb 2003 00:14:22 -0800, Randolph Chung <randolph@tausq.org> said:

  Randolph> now i just have to figure out what i'm doing wrong and why
  Randolph> it doesn't see the simulated scsi disk... :(

  Randolph> I'm running ski with: ski linux-2.5.60/bootloader
  Randolph> linux-2.5.60/vmlinux simscsi=/var/ski-disks/sd

  Randolph> and all i see is:

  Randolph> VFS: Cannot open root device "" or 08:01

Did you verify that you have write access on /var/ski-disks/sda?

	--david

