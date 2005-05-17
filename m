From: Greg KH <greg@kroah.com>
Date: Tue, 17 May 2005 20:17:25 +0000
Subject: Re: [Pcihpd-discuss] [PATCH 5/6]: hotplug/ia64: SN Hotplug Driver - SN Hotplug Driver code
Message-Id: <20050517201725.GA27184@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200505131003.18143@bilbo.math.uni-mannheim.de>
In-Reply-To: <200505131003.18143@bilbo.math.uni-mannheim.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, May 17, 2005 at 11:41:01AM -0400, Prarit Bhargava wrote:
> Rolf Eike Beer wrote:
> >
> >>+	sprintf(bss_hotplug_slot->name, "module_%c%c%c%c%.2d_b_%d_s_%d",
> >>+	 '0'+RACK_GET_CLASS(MODULE_GET_RACK(pcibus_info->pbi_moduleid)),
> >>+	 '0'+RACK_GET_GROUP(MODULE_GET_RACK(pcibus_info->pbi_moduleid)),
> >>+		'0'+RACK_GET_NUM(MODULE_GET_RACK(pcibus_info->pbi_moduleid)),
> >>+		MODULE_GET_BTCHAR(pcibus_info->pbi_moduleid),
> >>+		MODULE_GET_BPOS(pcibus_info->pbi_moduleid),
> >>+		((int)pcibus_info->pbi_buscommon.bs_persist_busnum) & 0xf,
> >>+		device + 1);
> >
> >
> >*eek* Sorry, but that looks really ugly. Wouldn't it be enough do name it 
> >like the device that would be in slot, something like DOMAIN_BUS_SLOT and 
> >maybe one extra number?
> 
> Unfortunately, yes, the longer name is prefered in this case.  The rack 
> class
> ID, etc., are need to identify locations on the Altix platform.

No, use additional sysfs files if you need to export this kind of
information to the user somehow.  I think IBM already does this in their
drivers in a sane manner (so you might want to copy them, as they have
already modified the userspace code to handle those sysfs files...)

> >>+	if (action = PCI_REQ_SLOT_ELIGIBLE && rc = PCI_SLOT_ALREADY_DOWN) {
> >
> >I would feel better if you add extra braces around the tests, but I'm 
> >probably just a bit paranoid about this things. Greg?
> 
> I was asked to remove the braces in an earlier version.  I too would prefer
> to have them but am going with current comments on the code.

Who asked you to remove the extra braces?  It was not me.  If you like
them, please add them, I feel more comfortable with them too.

thanks,

greg k-h
