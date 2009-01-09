From: Sam Ravnborg <sam@ravnborg.org>
Date: Fri, 09 Jan 2009 20:05:14 +0000
Subject: Re: [PATCH 1/6]Make recordmcount destinct module compile
Message-Id: <20090109200514.GA24634@uranus.ravnborg.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1231468368.10683.100.camel@sli10-desk.sh.intel.com> <alpine.DEB.1.10.0901082142510.18713@gandalf.stny.rr.com> <20090109192841.GA19482@uranus.ravnborg.org> <alpine.DEB.1.10.0901091456390.17378@gandalf.stny.rr.com>
In-Reply-To: <alpine.DEB.1.10.0901091456390.17378@gandalf.stny.rr.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Shaohua Li <shaohua.li@intel.com>, ia64 <linux-ia64@vger.kernel.org>, "Luck, Tony" <tony.luck@intel.com>, Ingo Molnar <mingo@elte.hu>, linux-kbuild@vger.kernel.org

On Fri, Jan 09, 2009 at 02:57:38PM -0500, Steven Rostedt wrote:
> 
> On Fri, 9 Jan 2009, Sam Ravnborg wrote:
> > So we duplicate the cases where we identify "this .o file
> > is used in a module".
> > This is not good.
> > 
> > Also there is no reason to do this for the .i, .s and .lst
> > targets as they do not invode recordmcount.pl anyway.
> > 
> > If your build your patch on top of the following we avoid
> > the duplicated list.
> > 
> > 	Sam
> 
> Thanks Sam,
> 
> Can I add this on top of Shaohua's and put your Signed-off-by, as well
> as an Acked-by on Shaohua's?

My patch was made on top of -linus so you
need to use the flag in the call to recordmount.pl.

Please feel free to put my Acked-by: on the patch,
but as this does not originate from me it would be the
wrong documentation trail to add my Sigend-off-by
as I just gave an improvement proposal.

	Sam
