From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Sat, 17 Jan 2004 00:03:55 +0000
Subject: Re: [PATCH] Kconfig cleanup, part 1
Message-Id: <200401161703.55813.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200401161136.37066.bjorn.helgaas@hp.com>
In-Reply-To: <200401161136.37066.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday 16 January 2004 4:35 pm, Matthew Wilcox wrote:
> I'm working towards this on several architectures.  A large part of this
> is marking options as "depends on PCI" and "depends on X86" so that the
> simulator targets (Ski, uml, etc) can use the generic drivers/Kconfig.
> That work's going in through the kernel-janitors tree at the moment.

OK, I'll wait for that.  Sounds like it will at least become much easier,
and maybe you'll even do it for me ;-)

