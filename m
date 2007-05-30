From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Wed, 30 May 2007 23:34:13 +0000
Subject: Re: BUG: sleeping function called from invalid context at
Message-Id: <20070530163413.87ecfe18.randy.dunlap@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A01929C15@scsmsx411.amr.corp.intel.com>
	<Pine.LNX.4.64.0705301630360.3568@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0705301630360.3568@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, David Chinner <dgc@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Sam Ravnborg <sam@ravnborg.org>

On Wed, 30 May 2007 16:31:35 -0700 (PDT) Christoph Lameter wrote:

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

Maybe 'objdump drivers/built-in.o and then grep that output (file)
for /exit.text/ ...


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
