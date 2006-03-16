From: Grant Grundler <iod00d@hp.com>
Date: Thu, 16 Mar 2006 23:45:21 +0000
Subject: Re: [PATCH] (-mm) drivers/pci/msi: explicit declaration of msi_register
Message-Id: <20060316234521.GC9746@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44172F0E.6070708@ce.jp.nec.com> <20060314134535.72eb7243.akpm@osdl.org> <44176502.9050109@ce.jp.nec.com> <20060315235544.GA6504@suse.de> <44198210.6090109@ce.jp.nec.com> <20060316181934.GM13666@sgi.com> <4419BD64.5070705@ce.jp.nec.com> <20060316194155.GP13666@sgi.com> <20060316232837.GA12408@suse.de> <adalkvaneq5.fsf@cisco.com>
In-Reply-To: <adalkvaneq5.fsf@cisco.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Roland Dreier <rdreier@cisco.com>
Cc: Greg KH <gregkh@suse.de>, Mark Maule <maule@sgi.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, shaohua.li@intel.com

On Thu, Mar 16, 2006 at 03:37:22PM -0800, Roland Dreier wrote:
> I think we really want to make drivers/pci/msi.c less platform-specific.
> Both powerpc and sparc64 are starting to pay attention to MSI, so we
> should really be trying to move things in the direction of a clean
> separation of generic MSI handling and Intel-specific bits.

Matthew Wilcox and I have previously volunteered to get MSI working
on parisc arch. parisc, like systems with Local SAPIC, only
operates on transaction based interrupts at the CPU level.

We need an arch hook to set the target address of the CPU
instead of looking at ID/EID bits but haven't proposed
anything concrete yet. My understanding is SGI needs the
same thing for Altix/SN2 platforms.

thanks,
grant
