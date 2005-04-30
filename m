From: Pavel Machek <pavel@ucw.cz>
Date: Sat, 30 Apr 2005 13:40:47 +0000
Subject: Re: [patch] properly stop devices before poweroff
Message-Id: <20050430134046.GD585@openzaurus.ucw.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050421111346.GA21421@elf.ucw.cz> <20050429061825.36f98cc0.akpm@osdl.org> <Pine.LNX.4.61.0504290734220.30771@montezuma.fsmlabs.com> <20050430024748.19d44a8d.akpm@osdl.org>
In-Reply-To: <20050430024748.19d44a8d.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: Zwane Mwaikambo <zwane@arm.linux.org.uk>, pavel@ucw.cz, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Hi!

> > It looks like the device 
> > being suspended never went through pci_device_enable() (e.g. ethernet 
> > interface wasn't up). It's harmless right now.
> 
> Everything's up.  Perhaps we're trying to disable devices more than once?

Maybe userspace ifconfigs eth0 down, then we device_suspend it?
-- 
64 bytes from 195.113.31.123: icmp_seq( ttlQ timeD8769.1 ms         

