From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 14 Jan 2004 22:53:04 +0000
Subject: Re: [patch] efivars update for 2.6.1
Message-Id: <16389.51280.731508.513970@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200401131824.i0DIOMcA031105@snoqualmie.dp.intel.com>
	<20040113191015.20415de3.akpm@osdl.org>
In-Reply-To: <20040113191015.20415de3.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: Matt Tolentino <metolent@snoqualmie.dp.intel.com>, davidm@napali.hpl.hp.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, matthew.e.tolentino@intel.com

>>>>> On Tue, 13 Jan 2004 19:10:15 -0800, Andrew Morton <akpm@osdl.org> said:

  >> Essentially, it converts efivars (i.e. Matt Domsch's driver that
  >> provides access to the EFI variable runtime services) to export
  >> variable information and systab info via sysfs.

  Andrew> I'd need confirmation from David M-T and if poss a quick
  Andrew> review from Greg K-H.

Matt is the owner of efivars so if he is OK with it, that's fine with
me.  My only request is that if/when the patch is accepted that there
is some documentation that makes it clear where one can can get an
updated/matching efibootmgr from.

	--david
