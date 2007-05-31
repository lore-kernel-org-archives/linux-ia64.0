From: Sam Ravnborg <sam@ravnborg.org>
Date: Thu, 31 May 2007 19:54:07 +0000
Subject: Re: BUG: sleeping function called from invalid context at kernel/fork.c:385
Message-Id: <20070531195407.GA27203@uranus.ravnborg.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A01929DD3@scsmsx411.amr.corp.intel.com> <Pine.LNX.4.64.0705302019040.5583@schroedinger.engr.sgi.com> <465EE7BB.4050605@redhat.com>
In-Reply-To: <465EE7BB.4050605@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Prarit Bhargava <prarit@redhat.com>
Cc: Christoph Lameter <clameter@sgi.com>, "Luck, Tony" <tony.luck@intel.com>, Randy Dunlap <randy.dunlap@oracle.com>, David Chinner <dgc@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

On Thu, May 31, 2007 at 11:20:27AM -0400, Prarit Bhargava wrote:
> 
> 
> Christoph Lameter wrote:
> >On Wed, 30 May 2007, Luck, Tony wrote:
> >
> >  
> >>>Ahh okay. cscope will do that too.... But all have __exit.
> >>>      
> >>The trick is that one of them *shouldn't* have __exit.  With cscope
> >>you'll have to use the "Find functions calling this function:"
> >>mode to try and find the __init function that is calling an
> >>__exit function.
> >>    
> >
> >Urgh... Does it have to be that difficult?
> >-
> >  
> 
> 
> Sometimes yes ... but in this case no.
> 
> I flipped config options on and off until I tracked the problem down 
> into the loopback driver, and then manually ran modpost on 
> drivers/block/built-in.o to reveal:
> 
> ....Nothing. 
> 
> Something is borken in modpost because I found a bug in the loopback 
> code which is a _REAL_ bug.

In the initial version of the section mismatch check code
I ignored references to .exit.text from .init.text code.
Today I do not see why this should be allowed.
So unless an allmodconfig build for i386 + maybe a few more archs
does not show any significant regressions I will enable this check.

My initial i386 allmodconfig build pointed out a number of places
where this happened (I lost the warnings and are doing a rebuild now)A
.
One such place is microcode.c where we has

static int __init microcode_init (void)
{
	...

	if (IS_ERR(microcode_pdev)) {
		microcode_dev_exit();
		return PTR_ERR(microcode_pdev);
	}

And:
static void __exit microcode_dev_exit (void)
{
	misc_deregister(&microcode_dev);
}

I assume this is a real bug that we have not triggered
during testing becasue this is in an error-path.

The linker will not error out because .exit.text are discarded
at run-time at least for i386.

	Sam
