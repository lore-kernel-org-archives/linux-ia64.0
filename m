From: tony.luck@intel.com
Date: Tue, 30 Aug 2005 21:49:39 +0000
Subject: RE: As of 2.6.13-rc1 Fusion-MPT very slow
Message-Id: <200508302149.j7ULndxS013113@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <91888D455306F94EBD4D168954A9457C037B0557@nacos172.co.lsil.com>
In-Reply-To: <200508301528.j7UFS0J2009272@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Holger Kiehl <Holger.Kiehl@dwd.de>
Cc: "Moore, Eric Dean" <Eric.Moore@lsil.com>

> This is alive and well in 2.6.13 (final) on ia64.

Or perhaps not.  When I went into the machine room to take
a look at this machine, I found that the disk drive in
question was making some very bad noises.  A few minutes
later it stopped responding at all.

Putting in a new drive, I see a consistent 51 MB/s on /dev/sdb

Sorry for the noise.

-Tony
