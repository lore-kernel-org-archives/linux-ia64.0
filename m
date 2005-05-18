From: Greg KH <greg@kroah.com>
Date: Wed, 18 May 2005 16:23:23 +0000
Subject: Re: [Pcihpd-discuss] [PATCH 5/6]: hotplug/ia64: SN Hotplug Driver - SN Hotplug Driver code
Message-Id: <20050518162323.GC16756@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200505131003.18143@bilbo.math.uni-mannheim.de>
In-Reply-To: <200505131003.18143@bilbo.math.uni-mannheim.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, May 18, 2005 at 09:57:13AM -0400, Prarit Bhargava wrote:
> On Altix, since the system can be cabled in a number of ways a pointer to 
> the rack ID is definately useful and helps to uniquely identify the slot.  
> I'm going to use a 2 digit rack id, followed by the DDDD:BB:SS value.

Again, what's wrong with the sysfs file for the rack id?  Don't clutter
up the slot name if you don't have to.  

DDDD:BB:SS should be unique on it's own, right?

thanks,

greg k-h
