From: Matt Domsch <Matt_Domsch@dell.com>
Date: Thu, 15 Jan 2004 03:40:34 +0000
Subject: Re: [patch] efivars update for 2.6.1
Message-Id: <Pine.LNX.4.44.0401142137540.24355-100000@iguana.domsch.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <16389.51280.731508.513970@napali.hpl.hp.com>
References: <200401131824.i0DIOMcA031105@snoqualmie.dp.intel.com>
In-Reply-To: <200401131824.i0DIOMcA031105@snoqualmie.dp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davidm@hpl.hp.com
Cc: Andrew Morton <akpm@osdl.org>, Matt Tolentino <metolent@snoqualmie.dp.intel.com>, davidm@napali.hpl.hp.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, matthew.e.tolentino@intel.com

> Matt is the owner of efivars so if he is OK with it, that's fine with
> me.  My only request is that if/when the patch is accepted that there
> is some documentation that makes it clear where one can can get an
> updated/matching efibootmgr from.

Andrew found a spinlock use bug in efivars_exit that needs to get fixed 
first.  Then I'm fine with it.

efibootmgr 0.5.0-test1 is available at 
http://domsch.com/linux/ia64/efibootmgr/testing/efibootmgr-0.5.0-test1.tar.gz

which supports both /proc-style and sysfs-style accesses.  With additional 
feedback that it works as expected for several people, I'll remove the 
'test' moniker.

Thanks,
Matt

-- 
Matt Domsch
Sr. Software Engineer, Lead Engineer
Dell Linux Solutions www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com

