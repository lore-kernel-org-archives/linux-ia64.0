From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 15 Sep 2003 22:14:27 +0000
Subject: Re: [RFC][PATCH] efivars move to drivers/efi, efibootmgr-0.5.0-test1
Message-Id: <marc-linux-ia64-106366423525055@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106313960719815@msgid-missing>
In-Reply-To: <marc-linux-ia64-106313960719815@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 9 Sep 2003 15:03:38 -0500 (CDT), Matt Domsch <Matt_Domsch@dell.com> said:

  Matt> Matt Tolentino posted a patch a couple weeks ago moving
  Matt> arch/ia64/efivars.c to drivers/efi and converting it to use
  Matt> sysfs.  He did a pretty good job, but there were some things I
  Matt> wanted cleaned up with that.  He's out of the office for a few
  Matt> days being a new father (Congrats!), so I took a stab at
  Matt> finishing the job.

  Matt> First, the move and conversion (appended):
  Matt> http://domsch.com/linux/ia64/linux-2.6.0-test5-efivars-sysfs-20030909.patch
  Matt> http://domsch.com/linux/ia64/linux-2.6.0-test5-efivars-sysfs-20030909.patch.asc

  Matt> arch/ia64/Kconfig          |   10 
  Matt> arch/ia64/defconfig        |    1 
  Matt> arch/ia64/kernel/Makefile  |    1 
  Matt> arch/ia64/kernel/efi.c     |   19 -
  Matt> arch/ia64/kernel/efivars.c |  508 --------------------------------
  Matt> drivers/Makefile           |    1 
  Matt> drivers/efi/Kconfig        |   23 +
  Matt> drivers/efi/Makefile       |    4 
  Matt> drivers/efi/efivars.c      |  695 +++++++++++++++++++++++++++++++++++++++++++++
  Matt> include/linux/efi.h        |    1 
  Matt> 10 files changed, 726 insertions, 537 deletions

I'm fine with the ia64-specific changes, but I can't apply them
until/unless the generic changes are in.  Perhaps the best thing to do
would be to send the entire patch to Linus (with my approval for the
ia64-specific changes).  That way, all files get updated "atomically".

	--david
