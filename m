From: Greg KH <greg@kroah.com>
Date: Thu, 19 May 2005 15:13:53 +0000
Subject: Re: [Pcihpd-discuss] [PATCH 5/6]: hotplug/ia64: SN Hotplug Driver - SN Hotplug Driver code
Message-Id: <20050519151353.GA29434@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200505131003.18143@bilbo.math.uni-mannheim.de>
In-Reply-To: <200505131003.18143@bilbo.math.uni-mannheim.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, May 19, 2005 at 09:05:47AM -0400, Prarit Bhargava wrote:
> +static struct hotplug_slot_attribute sn_slot_attr_path = {
> +	.attr = {.name = "path", .mode = S_IFREG | S_IRUGO},
> +	.show = sn_read_path_file,
> +};

No, you did not properly initialize all of the attribute fields, so your
module could be unloaded when the sysfs file is open :(

Please use the proper macro for this: __ATTR_RO()

greg k-h
