From: Tony Luck <tony.luck@gmail.com>
Date: Sat, 17 Sep 2005 15:47:03 +0000
Subject: Re: 2.6.14-rc1 breaks tg3 on ia64
Message-Id: <12c511ca05091708476aa136cd@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050913065937.GA7849@kroah.com>
	 <25288.1126596450@kao2.melbourne.sgi.com>
In-Reply-To: <25288.1126596450@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Keith Owens <kaos@sgi.com>
Cc: Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>

> >So does reverting this patch solve the problem?
> 
> I reversing
> http://kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h4b53dbcc977dbf2753a67c2b8fc1c061d74f21,
> which appears to be the latest version of this patch.  There was a
> patch reject in sparc64, but the common code was reverted.  IA64 (SGI
> Altix) with that patch reverted now boots 2.6.14-rc1.

Anyone know anything more about this problem?  I'm not seeing it
on any of my systems ... so perhaps it only affects cards with a
PCI bridge on them, or cards that haven't already been initialized
by EFI.

-Tony
