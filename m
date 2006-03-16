From: "Jun'ichi Nomura" <j-nomura@ce.jp.nec.com>
Date: Thu, 16 Mar 2006 19:32:52 +0000
Subject: Re: [PATCH] (-mm) drivers/pci/msi: explicit declaration of msi_register
Message-Id: <4419BD64.5070705@ce.jp.nec.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44172F0E.6070708@ce.jp.nec.com> <20060314134535.72eb7243.akpm@osdl.org> <44176502.9050109@ce.jp.nec.com> <20060315235544.GA6504@suse.de> <44198210.6090109@ce.jp.nec.com> <20060316181934.GM13666@sgi.com>
In-Reply-To: <20060316181934.GM13666@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mark Maule <maule@sgi.com>
Cc: Greg KH <gregkh@suse.de>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, shaohua.li@intel.com

Hi Mark,

Thanks for the reply.

Mark Maule wrote:
>>There is another problem that CONFIG_IA64_GENERIC still doesn't
>>build due to error in SGI SN specific code.
>>It needs additional fix.
> 
> Ok, looking back at some of my original patches, it seems like the
> declaration of msi_ops got moved from pci.h to and some forward declarations
> in ia64/msi.h were removed.  This patch corrects the build problems.

But,

Greg said:
> these are core pci things that no one else should care about.

Andrew said:
> a declaration for msi_register(), in drivers/pci/pci.h.
 > We don't want to add a duplicated declaration like this.

I think the idea already gets objections.

> The reason for putting struct msi_ops in pci.h is so that msi code that
> resides outside of drivers/pci can use the declaration without having to
> reach down into drivers/pci.

The code in arch/ia64/sn/pci/msi.c looks much like
drivers/pci/msi-apic.c.
Why don't you move them to drivers/pci/msi-sgi-sn.c or something?

Thanks,
-- 
Jun'ichi Nomura, NEC Solutions (America), Inc.
