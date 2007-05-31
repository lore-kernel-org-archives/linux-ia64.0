From: Sam Ravnborg <sam@ravnborg.org>
Date: Thu, 31 May 2007 04:43:14 +0000
Subject: Re: BUG: sleeping function called from invalid context at kernel/fork.c:385
Message-Id: <20070531044314.GA20795@uranus.ravnborg.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A01929C15@scsmsx411.amr.corp.intel.com> <Pine.LNX.4.64.0705301630360.3568@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0705301630360.3568@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, David Chinner <dgc@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

On Wed, May 30, 2007 at 04:31:35PM -0700, Christoph Lameter wrote:
> On Wed, 30 May 2007, Luck, Tony wrote:
> 
> > 
> > > `.exit.text' referenced in section `.init.text' of drivers/built-in.o: 
> > > defined in discarded section `.exit.text' of drivers/built-in.o
> > 
> > 
> > This one is a fatal error ... the code is trying to call a function
> > that has been marked __exit in a driver that has been built-in, instead
> > of as a module.  Since a builtin driver can never be unloaded, the kernel
> > has thrown away all the __exit routines (at link time).
> > 
> > The error message appears less than helpful in tracking down which
> > routine in which driver is the problem though.
> 
> Right. I have no idea where to look. The function has no name? Or is the 
> segment .exit.text referenced by namne in .init.text?
Unfortunately modpost does not alows know how to resolve symbol names
from addresses. Lately it has been improves by adding support for 
addends in ELF. But that is beyond my ELF knowledge atm so
I cannot improve it.

What you can do (apart from the cscope trick as Randy suggest) is
to run modpost manual on all .o files in drivers/

If the cross reference happens in a single .o file you will get
a hit there.
And if it is say in scsi then you will get a hit in scsi/built-in.o

Hope this helps.

	Sam
