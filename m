From: Alex Williamson <alex.williamson@hp.com>
Date: Tue, 01 Jun 2004 16:40:47 +0000
Subject: Re: Real time clock on ia64 platforms
Message-Id: <1086108046.4700.69.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
References: <40BC3558.7040606@hob.de>
In-Reply-To: <40BC3558.7040606@hob.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2004-06-01 at 01:50, Christian Hildner wrote:
> Hi,
> 
> someone may know what kind of RTC device the ia64 platforms (HP ZX 6000 
> + i2000) use. I want to access it directly, without using EFI calls.

   This is strongly not recommended.  On HP chipset boxes, the devices
are only designed to be accessed via the EFI calls (and yes, EFI
firmware can and does work around bugs in the RTC).  There's also no
architected way to find the real RTC in the address map.  Why do you
need to poke it directly?

	Alex

