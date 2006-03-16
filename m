From: Grant Grundler <iod00d@hp.com>
Date: Thu, 16 Mar 2006 23:41:18 +0000
Subject: Re: [PATCH] (-mm) drivers/pci/msi: explicit declaration of msi_register
Message-Id: <20060316234118.GB9746@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44172F0E.6070708@ce.jp.nec.com> <20060314134535.72eb7243.akpm@osdl.org> <44176502.9050109@ce.jp.nec.com> <20060315235544.GA6504@suse.de> <44198210.6090109@ce.jp.nec.com> <20060316181934.GM13666@sgi.com>
In-Reply-To: <20060316181934.GM13666@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mark Maule <maule@sgi.com>
Cc: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, Greg KH <gregkh@suse.de>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, shaohua.li@intel.com

On Thu, Mar 16, 2006 at 12:19:34PM -0600, Mark Maule wrote:
> If there's objectins to having struct msi_ops declared in pci.h, then I guess
> we need to come up with another solution.

There are other transaction based interrupt subsystems that are typically
arch specific (e.g. GSC device interrupts on PA-RISC). So far, MSI is the
only generic one and that is clearly part of the PCI spec. 

grant
