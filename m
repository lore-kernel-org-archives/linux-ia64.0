From: Alex Williamson <alex.williamson@hp.com>
Date: Tue, 21 Sep 2004 18:10:52 +0000
Subject: Re: [ACPI] PATCH-ACPI based CPU hotplug[2/6]-ACPI Eject
Message-Id: <1095790252.24751.41.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
References: <3ACA40606221794F80A5670F0AF15F84059309EF@pdsmsx403>
	 <1095735738.3920.29.camel@mythbox>  <20040921172546.GA7077@thunk.org>
In-Reply-To: <20040921172546.GA7077@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Theodore Ts'o <tytso@mit.edu>
Cc: "Yu, Luming" <luming.yu@intel.com>, Dmitry Torokhov <dtor_core@ameritech.net>, acpi-devel <acpi-devel@lists.sourceforge.net>, "Keshavamurthy, Anil S" <anil.s.keshavamurthy@intel.com>, "Brown, Len" <len.brown@intel.com>, LHNS list <lhns-devel@lists.sourceforge.net>, Linux IA64 <linux-ia64@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Tue, 2004-09-21 at 13:25 -0400, Theodore Ts'o wrote:
> On Mon, Sep 20, 2004 at 09:02:18PM -0600, Alex Williamson wrote:
> > > But, some AML methods are risky to be called directly from user space,
> > > Not only because the side effect of its execution, but also because
> > > it could trigger potential AML method bug or interpreter bug, or even
> > > architectural defect.  All of these headache is due to the AML method
> > >  is NOT intended for being used by userspace program.
> > 
> >    I've made an attempt to hide the most obvious dangerous methods, but
> > undoubtedly, there will be some.  Why are we any more likely to hit an
> > AML method bug, interpreter bug or architectural bug by having a
> > userspace interface?  
> 
> As long as the userspace interfaces are only available to the root
> filesystem, I'm not sure it's worth it to hide any of the methods.
> It's added complexity, and in any case, root can do untold amounts of
> damage by writing to /dev/mem, trying to upload firmware to IDE
> drives, etc., etc., etc.

   Yes, very true.  I think the difference is that in my current
implementation, objects are evaluated on read.  This makes it terribly
easy to do the wrong thing "Hmm, I wonder what that file does... oops".
Evaluating on write would set the bar a little higher, but still has
some of the same issues.  In theory, I definitely agree, the interface
shouldn't need to hide anything.  (I'm sure there are ACPI firmware
folks frightened by that idea)  Thanks,

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab

