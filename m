From: Matt Domsch <Matt_Domsch@Dell.com>
Date: Sat, 09 Aug 2003 04:48:23 +0000
Subject: Re: [patch] move efivars to drivers/efi
Message-Id: <marc-linux-ia64-106040454109554@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106039247003678@msgid-missing>
In-Reply-To: <marc-linux-ia64-106039247003678@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Yes - have you considered doing a sysfs interface instead of procfs? :)

It's crossed my mind, but I haven't had much time to spend on IA-64 the
past year, and that isn't likely to change soon...  I think the only tool
that uses /proc/efi/vars is efibootmgr, which would also need to learn of
a move to /sys.  Your binary-blob interface for sysfs is exactly the right
thing to use for it though.

Anyone want to take a stab at switching it, or do you want to wait for me
to have time?

Thanks,
Matt

-- 
Matt Domsch
Sr. Software Engineer, Lead Engineer
Dell Linux Solutions www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com

