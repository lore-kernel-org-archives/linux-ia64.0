From: "Theodore Ts'o" <tytso@mit.edu>
Date: Tue, 21 Sep 2004 17:25:46 +0000
Subject: Re: [ACPI] PATCH-ACPI based CPU hotplug[2/6]-ACPI Eject interfacesupport
Message-Id: <20040921172546.GA7077@thunk.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <3ACA40606221794F80A5670F0AF15F84059309EF@pdsmsx403> <1095735738.3920.29.camel@mythbox>
In-Reply-To: <1095735738.3920.29.camel@mythbox>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Williamson <alex.williamson@hp.com>
Cc: "Yu, Luming" <luming.yu@intel.com>, Dmitry Torokhov <dtor_core@ameritech.net>, acpi-devel@lists.sourceforge.net, "Keshavamurthy, Anil S" <anil.s.keshavamurthy@intel.com>, "Brown, Len" <len.brown@intel.com>, LHNS list <lhns-devel@lists.sourceforge.net>, Linux IA64 <linux-ia64@vger.kernel.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Mon, Sep 20, 2004 at 09:02:18PM -0600, Alex Williamson wrote:
> > But, some AML methods are risky to be called directly from user space,
> > Not only because the side effect of its execution, but also because
> > it could trigger potential AML method bug or interpreter bug, or even
> > architectural defect.  All of these headache is due to the AML method
> >  is NOT intended for being used by userspace program.
> 
>    I've made an attempt to hide the most obvious dangerous methods, but
> undoubtedly, there will be some.  Why are we any more likely to hit an
> AML method bug, interpreter bug or architectural bug by having a
> userspace interface?  

As long as the userspace interfaces are only available to the root
filesystem, I'm not sure it's worth it to hide any of the methods.
It's added complexity, and in any case, root can do untold amounts of
damage by writing to /dev/mem, trying to upload firmware to IDE
drives, etc., etc., etc.

As you have pointed out, if there are bugs in the interpret, et. al,
it is better to expose them sooner rather than to stick our heads in
the sand and pretend they don't exist.

							- Ted
