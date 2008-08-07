From: Joerg Roedel <joro@8bytes.org>
Date: Thu, 07 Aug 2008 16:12:22 +0000
Subject: Re: [IA64] defconfig build failure in current linus.git
Message-Id: <20080807161222.GT31439@8bytes.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080807101015.GB4342@8bytes.org> <20080807143303.GA9692@cs181140183.pp.htv.fi>
In-Reply-To: <20080807143303.GA9692@cs181140183.pp.htv.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Adrian Bunk <bunk@kernel.org>
Cc: Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Aug 07, 2008 at 05:33:04PM +0300, Adrian Bunk wrote:
> On Thu, Aug 07, 2008 at 12:10:15PM +0200, Joerg Roedel wrote:
> > Hi,
> > 
> > I just tried to build the current linus.git kernel for IA64 and got the
> > following build errors:
> > 
> >   CC      drivers/acpi/utils.o
> > In file included from /data2/repos/tip/linux.trees.git/include/acpi/acpi.h:54,
> >                  from /data2/repos/tip/linux.trees.git/include/acpi/acpi_bus.h:31,
> >                  from /data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:30:
> > /data2/repos/tip/linux.trees.git/include/acpi/platform/acenv.h:175:1: warning: "COMPILER_DEPENDENT_INT64" redefined
> >...
> 
> If you get this error your compiler does not define __linux__ .
> 
> What compiler are you using?

Its a self-build gcc-4.3.1 cross compiler on amd64. In the meantime it
worked with a gcc 3.4.5. I will check if my self-build compiler is
messed up.

Joerg

