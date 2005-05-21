From: Greg KH <greg@kroah.com>
Date: Sat, 21 May 2005 03:59:10 +0000
Subject: Re: [Pcihpd-discuss] [PATCH 5/6]: hotplug/ia64: SN Hotplug Driver - SN Hotplug Driver code
Message-Id: <20050521035910.GA22858@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200505131003.18143@bilbo.math.uni-mannheim.de>
In-Reply-To: <200505131003.18143@bilbo.math.uni-mannheim.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, May 20, 2005 at 08:24:09PM -0400, Prarit Bhargava wrote:
> +	list_for_each(list, &sn_sysdata_list) {
> +		element = list_entry(list, struct sysdata_el, entry);

All instances of list_for_each() and then a list_entry() call can be
replaced with list_for_each_entry().

thanks,

greg k-h
