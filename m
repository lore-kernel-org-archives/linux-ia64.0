From: Christian Cotte-Barrot <Christian.Cotte-Barrot@bull.net>
Date: Fri, 24 Jan 2003 15:15:52 +0000
Subject: Re: [Linux-ia64] Epca patches
Message-Id: <marc-linux-ia64-105590709805745@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805740@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805740@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bjorn Helgaas wrote:
> 
> > The first, epca-1.50-1.diff.gz, is against the Digiboard software package
> >   It contains modifications for both driver and supporting tools,
> >   mainly the digiDload command.
> 
> I don't know who maintains the Digiboard software package, but this
> patch doesn't look ia64-related.  This list is primarily for ia64 kernel
> issues.
> 
> > The second, epca-1.50-1_ia-64_2.4.19.diff.gz, is against 2.4.19 kernel tree
> 
> This patch is not ia64-specific in the sense that it doesn't touch
> anything under arch/ia64 or include/asm-ia64.  It does have a
> number of IA64 ifdefs, but they don't appear to be real dependencies
> on ia64-only features, so I think this should be sent to the Digi
> epca driver maintainer.  Here's the entry from the MAINTAINERS file:
> 
>     DIGI INTL. EPCA DRIVER
>     P:      Chad Schwartz
>     M:      support@dgii.com
>     M:      chads@dgii.com
>     L:      digilnux@dgii.com
>     S:      Maintained
> 
> Actually, Chad would probably be a good place to send the Digiboard
> patch, too.
> 
> Bjorn

Agree that all the modifications are not ia64-specific.
However, some of them are 64 bits specific and are related to 64 port:
  - struct board_chan (digiFep1.h, describes a fragment of I/O memory space
    shared between driver and firmware) must be of 128 bytes long exactly.
  - driver's data definitions and insmod MODULE_PARM declarations
    must be consistent.
  - ioremapped memory base addresses data must be long (64 bits).
  - epca module in the kernel sources is not 64 bits
    epca.c
      #if BITS_PER_LONG != 32
      #  error FIXME: this driver only works on 32-bit platforms
      #endif

It guess that the epca module sources from the Digiboard software package
and from the kernel sources have a common ancestor somewhere in the past.
Then the subsequent versions of the two codes diverged because the
former was interested to implement Digiboard's specific modifications
(new board type, bug fixes, ...) and the latter Linux's peculiarities
(kernel pci API, ...)
It seems to me that the end result is that lot of Digiboard's features
are missing in the epca module kernel sources.
For internal needs we are using this epca module and each time we get
a new kernel release we must port Digiboard sources to that
kernel sources.
So it would be better to find in the kernel sources an epca module
version closer to the Digiboard one following the kernel modifications.

Christian.

