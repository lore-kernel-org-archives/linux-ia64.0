From: Greg KH <greg@kroah.com>
Date: Wed, 18 May 2005 17:06:11 +0000
Subject: Re: [Pcihpd-discuss] [PATCH 5/6]: hotplug/ia64: SN Hotplug Driver - SN Hotplug Driver code
Message-Id: <20050518170611.GB17747@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200505131003.18143@bilbo.math.uni-mannheim.de>
In-Reply-To: <200505131003.18143@bilbo.math.uni-mannheim.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, May 18, 2005 at 12:52:59PM -0400, Prarit Bhargava wrote:
> Greg KH wrote:
> >On Wed, May 18, 2005 at 09:57:13AM -0400, Prarit Bhargava wrote:
> 
> >
> >DDDD:BB:SS should be unique on it's own, right?
> 
> Greg,
> 
> I'm looking at the latest 2.6.12-rc4 sources and the IBM php code but don't 
> see any references to additional sysfs files.

IBM has 2 drivers in the tree, you were probably looking at the other
one :)

Look at the rpaphp_slot.c:rpaphp_sysfs_add_attr_location() function.

thanks,

greg k-h
