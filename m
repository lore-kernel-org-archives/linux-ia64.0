From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Fri, 18 May 2001 05:41:33 +0000
Subject: Re: [Linux-ia64] make cross-gcc error use GNUPro ToolKit
Message-Id: <marc-linux-ia64-105590693005613@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005611@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005611@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

On Fri, May 18, 2001 at 09:43:52AM +0800, Minnow wrote:
> 
> I want to port some applications from IA32 to IA64. So I want to have a cross-gcc and get GNUPro ToolKit source and make,but some errors happened.If who knows ,Please help me.
> 
> My PC is PII 350 and OS is Redhat 7.1.
> the gcc is 2.96
> the glibc is glibc-devel-2.2.2-1
>  
Instead of going down that path, I would higly recommend that you use the
HP IA-64 Linux Development Kit (LDK) that is available for free downloads
from:

	http://software.hp.com/ia64linux

It includes a very nice environment to cross-develop and has the gcc cross-compiler
builtin. The other advantages is that you can also run the generated binary
on your Linux/PC because the kit incorporates the HP Ia-64 Ski simulator as well.
This simulator also provides source level debugging.

A new version of the kit which will include the latest stable gnupro and
the latest glibc2.2 should become available within the next few days.

--
-Stephane

