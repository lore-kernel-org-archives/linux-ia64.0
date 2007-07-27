From: Al Viro <viro@ftp.linux.org.uk>
Date: Fri, 27 Jul 2007 04:36:14 +0000
Subject: Re: [PATCH] ia64: fix a few section mismatch warnings
Message-Id: <20070727043614.GS27237@ftp.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070726210141.GA7266@uranus.ravnborg.org> <20070727011813.GQ27237@ftp.linux.org.uk> <20070727042744.GA10144@uranus.ravnborg.org>
In-Reply-To: <20070727042744.GA10144@uranus.ravnborg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sam Ravnborg <sam@ravnborg.org>
Cc: "Luck, Tony" <tony.luck@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

On Fri, Jul 27, 2007 at 06:27:44AM +0200, Sam Ravnborg wrote:
> On Fri, Jul 27, 2007 at 02:18:13AM +0100, Al Viro wrote:
> > On Thu, Jul 26, 2007 at 11:01:41PM +0200, Sam Ravnborg wrote:
> >   
> > > +static void *__init_refok alloc_rte(unsigned long size)
> > > +{
> > > +	return alloc_bootmem(size);
> > > +}
> > 
> > That makes no sense at all.  If we ever call that after freeing initmem,
> > we are screwed, period.  Sounds like __init fodder.
> 
> The call site has logic to prevent this from being called after init.
> And the call site cannot be made __init and to limit the scope of
> the __init_refok a small function is used.
> 
> So unless I mis-understood something the above should be OK.

Then the call site must be __init_refok, AFAICS.  The point is,
the callers of alloc_rte() are where the analysis belongs; use of
__init_refok means that you assert that all calls of __init *from*
*it* are safe.  Otherwise it just becomes "make modpost STFU and
let's hope that code is really OK".
