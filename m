From: Doug Beattie <dbb@caldera.com>
Date: Wed, 05 Sep 2001 17:57:11 +0000
Subject: Re: [Linux-ia64] Re: Wolverine RPMs
Message-Id: <marc-linux-ia64-105590698805124@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805121@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805121@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Don and others:

Let's not forget what might need to be considered to allow LSB 32 bit
compliant apps on IA64. Even though no one may ever certify for this,
it would be nice to find out and follow a convention that would
benefit all.

Doug

Don Dugger wrote:
> 
> Bill raises an interesting problem.  I'd like to suggest a solution and see
> what everyone thinks.  Since all of the shared objects are loaded by code
> in `ld-linux.so' I can modify the IA32 version of that library to first try
> an absolute path and, if that fails, because it's missing or has the wrong
> architecture, to then tack on a unique prefix, either something like
> `/usr/ia32' or the contents of an environment variable like `LD_IA32_PATH'.
> 
> This is a little ugly since all of the distro's would have to install s
> special version of `ld-linux.so' but at least this is just one library
> so that cuts the pain down a little bit.
> 
> Does anyone have a better idea?
> 
> On Wed, Sep 05, 2001 at 11:59:31AM -0400, Bill Nottingham wrote:
> >
> > The biggest problem I've seen is with programs that have hardcoded paths
> > for shared objects they dlopen(). Obviously this fails pretty badly when
> > the ia32 binary trys to dlopen() an ia64 library.
> >
> > Notably, this affects GTK+ when trying to use themes, and anything that
> > uses PAM.
> >
> > Bill
> >
> >
> >
> > _______________________________________________
> > ia64-list mailing list
> > ia64-list@redhat.com
> > https://listman.redhat.com/mailman/listinfo/ia64-list
> 
> --
> Don Dugger
> "Censeo Toto nos in Kansa esse decisse." - D. Gale
> n0ano@valinux.com
> Ph: 303/938-9838
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Douglas B. Beattie
------------------
Linux Test Architect - Caldera, Inc.
dbb@caldera.com

