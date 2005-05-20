From: Prarit Bhargava <prarit@sgi.com>
Date: Fri, 20 May 2005 23:47:34 +0000
Subject: Re: [Pcihpd-discuss] [PATCH 5/6]: hotplug/ia64: SN Hotplug Driver
Message-Id: <428E7716.3000007@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200505131003.18143@bilbo.math.uni-mannheim.de>
In-Reply-To: <200505131003.18143@bilbo.math.uni-mannheim.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Greg KH wrote:
> On Fri, May 20, 2005 at 08:11:30AM -0400, Prarit Bhargava wrote:
> 
>>+static struct hotplug_slot_attribute sn_slot_attrs[] = {
>>+	__ATTR_RO(path),
>>+	__ATTR_NULL
>>+};
> 
> 
> Why are you having an array with only 1 attribute?  Just define the one,
> and live with it.  That way you can get rid of all of your odd loops.

Sorry -- all the examples I found used __ATTR_RO in an array.  I thought 
  that was the way you wanted the attributes defined.  I would prefer to 
have a single attribute as well.

I'll modify and retest ...

Thanks,

P.


