From: Greg KH <gregkh@suse.de>
Date: Wed, 15 Mar 2006 23:55:45 +0000
Subject: Re: [PATCH] (-mm) drivers/pci/msi: explicit declaration of msi_register
Message-Id: <20060315235544.GA6504@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <44172F0E.6070708@ce.jp.nec.com> <20060314134535.72eb7243.akpm@osdl.org> <44176502.9050109@ce.jp.nec.com>
In-Reply-To: <44176502.9050109@ce.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, maule@sgi.com

On Tue, Mar 14, 2006 at 07:51:14PM -0500, Jun'ichi Nomura wrote:
> Hi Andrew,
> 
> Andrew Morton wrote:
> >One option might be to create inclued/linux/msi.h, put this declaration in
> >there then include <asm/msi.h>.  Possibly some other declarations should be
> >moved into linux/msi.h as well.
> 
> How about the attached one?
> Build tested on ia64 with both CONFIG_PCI_MSI y and n.

No, we don't need a linux/msi.h, these are core pci things that no one
else should care about.  The other arches handle this just fine, let's
not mess everything up just because ia64 can't get it right :)

thanks,

greg k-h
