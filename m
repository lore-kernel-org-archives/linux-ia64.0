From: Greg KH <greg@kroah.com>
Date: Fri, 20 May 2005 18:26:59 +0000
Subject: Re: [Pcihpd-discuss] [PATCH 5/6]: hotplug/ia64: SN Hotplug Driver - SN Hotplug Driver code
Message-Id: <20050520182659.GA14281@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200505131003.18143@bilbo.math.uni-mannheim.de>
In-Reply-To: <200505131003.18143@bilbo.math.uni-mannheim.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, May 20, 2005 at 08:11:30AM -0400, Prarit Bhargava wrote:
> +static struct hotplug_slot_attribute sn_slot_attrs[] = {
> +	__ATTR_RO(path),
> +	__ATTR_NULL
> +};

Why are you having an array with only 1 attribute?  Just define the one,
and live with it.  That way you can get rid of all of your odd loops.

And if you do want to stick with an array, use the proper sysfs call to
register and unregister all of them at once, don't roll your own code to
do this.

greg k-h
