From: Grant Grundler <grundler@parisc-linux.org>
Date: Thu, 11 Oct 2007 05:16:31 +0000
Subject: Re: compile 2.6.23 for zx2000?
Message-Id: <20071011051631.GC26641@colo.lackof.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071010063532.GA15655@colo.lackof.org>
In-Reply-To: <20071010063532.GA15655@colo.lackof.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Oct 10, 2007 at 11:08:31AM +0200, Andreas Schwab wrote:
> Grant Grundler <grundler@parisc-linux.org> writes:
> 
> > 2) But I'm getting this error:
> >   CC [M]  drivers/char/ipmi/ipmi_si_intf.o
> > drivers/char/ipmi/ipmi_si_intf.c:1095: error: __param_hotmod causes a section type conflict
> 
> This is probably the same as
> <http://gcc.gnu.org/bugzilla/show_bug.cgi?id1490>.

Yup - looks like the same symptom at least.
Does Debian have a gcc 4.2 or later compiler with that fixed?

I'd be happy to test it by building/running a 2.6.23 kernel if
given a .deb to install.

thanks,
grant
