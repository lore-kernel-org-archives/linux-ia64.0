From: Martin Pool <mbp@samba.org>
Date: Mon, 28 Apr 2003 23:03:08 +0000
Subject: Re: [Linux-ia64] building an ia64 cross toolchain on debian?
Message-Id: <marc-linux-ia64-105590723705619@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705612@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705612@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 28 Apr 2003, "Wichmann, Mats D" <mats.d.wichmann@intel.com> wrote:

> > Please feel free to edit the WiKi with any workarounds you needed.
> > The bad version of flex was released after I last tested the
> > instructions -- I've logged a bug against binutils, as the native
> > driver can't build either at present.

OK, thanks.  

I'm just trying to get a whole toolchain up and running first so that
I can be sure I'm documenting the right thing.

In fact I later discovered that since the kernel requires(?) a
cvs-head version of binutils to build, using the debian toolchain
package won't help me anyhow.  I might add another page about how to
do a plain source build.

> ??? there hasn't been a release of flex source since 1997,
> according to the date stamps in ftp.gnu.org/non-gnu/flex.
> Does this mean that there's a bad build floating around?

Debian have 2.5.4a-24 (which can build the toolchain) and 2.5.31-3
(which cannot). 

  http://packages.debian.org/flex

According to the changelog for the new one:

lex (2.5.31-1) unstable; urgency=low
 * New upstream release. 
-- Manoj Srivastava <srivasta@debian.org>  Wed,  9 Apr 2003 14:12:18 -0500

According to the source tarball, the new site is
<http://lex.sourceforge.net/> not gnu.org which as you say only has
older versions.

The ldlex.l source says "FIXME: We should not be using a flex internal
interface in the first place!" (although not in reference to the
particular line that fails.)  So it looks like ld depends on an older
version of flex.  (Perhaps it forked from GNU?)

Thanks,
-- 
Martin 

