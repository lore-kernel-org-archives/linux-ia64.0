From: Prarit Bhargava <prarit@sgi.com>
Date: Tue, 17 May 2005 15:41:01 +0000
Subject: Re: [Pcihpd-discuss] [PATCH 5/6]: hotplug/ia64: SN Hotplug Driver
Message-Id: <428A108D.8010703@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200505131003.18143@bilbo.math.uni-mannheim.de>
In-Reply-To: <200505131003.18143@bilbo.math.uni-mannheim.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Eike,

Thanks for the comments -- I'm going through them now.

Rolf Eike Beer wrote:

> 
>>+	sprintf(bss_hotplug_slot->name, "module_%c%c%c%c%.2d_b_%d_s_%d",
>>+		'0'+RACK_GET_CLASS(MODULE_GET_RACK(pcibus_info->pbi_moduleid)),
>>+		'0'+RACK_GET_GROUP(MODULE_GET_RACK(pcibus_info->pbi_moduleid)),
>>+		'0'+RACK_GET_NUM(MODULE_GET_RACK(pcibus_info->pbi_moduleid)),
>>+		MODULE_GET_BTCHAR(pcibus_info->pbi_moduleid),
>>+		MODULE_GET_BPOS(pcibus_info->pbi_moduleid),
>>+		((int)pcibus_info->pbi_buscommon.bs_persist_busnum) & 0xf,
>>+		device + 1);
> 
> 
> *eek* Sorry, but that looks really ugly. Wouldn't it be enough do name it like 
> the device that would be in slot, something like DOMAIN_BUS_SLOT and maybe 
> one extra number?
> 
> 

Unfortunately, yes, the longer name is prefered in this case.  The rack class
ID, etc., are need to identify locations on the Altix platform.

>>+	if (action = PCI_REQ_SLOT_ELIGIBLE && rc = PCI_SLOT_ALREADY_DOWN) {
> 
>I would feel better if you add extra braces around the tests, but I'm probably 
>just a bit paranoid about this things. Greg?

I was asked to remove the braces in an earlier version.  I too would prefer
to have them but am going with current comments on the code.

P.

