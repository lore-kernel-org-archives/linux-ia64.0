From: "H. J. Lu" <hjl@lucon.org>
Date: Wed, 15 Oct 2003 23:51:44 +0000
Subject: Re: WAW dependency messages
Message-Id: <marc-linux-ia64-106626192222924@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106625678318659@msgid-missing>
In-Reply-To: <marc-linux-ia64-106625678318659@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Oct 15, 2003 at 04:14:16PM -0700, Jesse Barnes wrote:
> On Wed, Oct 15, 2003 at 03:53:35PM -0700, H. J. Lu wrote:
> > On Wed, Oct 15, 2003 at 03:24:34PM -0700, Jesse Barnes wrote:
> > > In case anyone's interested, I just found a gcc bugzilla bug for the
> > > dependency violation stuff that always gets printed when we compile the
> > > kernel.  I've added some information to it.  The bug number is 12287,
> > > and you can see the whole thing at
> > > http://gcc.gnu.org/bugzilla/show_bug.cgi?id287.
> > > 
> > 
> > I am working on some DV problems in assembler. With the new assembler,
> > there are fewer DV warnings when compiling 2.4.21 kernel. If someone
> > sends me small asm testcases, I will look into them.
> 
> There's a testcase in the bug, but what prompted me to look was all of

That testcase should be fixed in the next binutils.

> the messages that get printed out when compiling a 2.6 kernel.  Does

Kernel is a totally different issue. You can send me small asm
testcases. I will see what I can do.

> binutils 2.14.90.0.6 contain the fixes you're talking about?  That's
> what I'm using...
> 

I am working on 2.14.90.0.7 which should have the fix.


H.J.
