From: Matthew Wilcox <willy@debian.org>
Date: Wed, 16 Jul 2003 11:13:30 +0000
Subject: Re: 2.5.75 out
Message-Id: <marc-linux-ia64-105835409921447@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105788013113852@msgid-missing>
In-Reply-To: <marc-linux-ia64-105788013113852@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jul 16, 2003 at 11:16:12AM +0800, Yu, Luming wrote:
> Is patch for PCI domain-releated stuff ready? (I'm not sure),

Yes, PCI domain support patches have ben trickling into the kernel
since about 2.5.72 and I think we're now done as far as arch/ia64 and
drivers/acpi are concerned.  I'm now turning my attention to drivers I
need to care about.  Right now, that means the sym2 driver...

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
