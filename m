From: Doug Beattie <dbb@caldera.com>
Date: Fri, 19 Oct 2001 18:12:21 +0000
Subject: Re: [Linux-ia64] Driver development document
Message-Id: <marc-linux-ia64-105590698805374@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805372@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805372@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

FWIW - It may be good, for someone in the real know, to document how
to modify or write a driver source so it would detect whether it was
running on ia32 or ia64 or even other type system and thereby be able
to take advantage of larger memory models.

From what I understand, many of the current drivers go through
copydown when used in the ia64 architecture and could be improved
upon.

My $0.02 worth of thoughts on this discussion.

n0ano@indstorage.com wrote:
> 
> Gururaj-
> 
> The same document that explains how to write IA32 drivers :-)
> 
> Seriously, all of the kernel interfaces you should need should
> be the same between IA32 and IA64.  It's amazing how many IA64
> drivers were created by just re-compiling the IA32 versiion with
> no source code changes.
> 
> I would recommend starting with the book `Linux Device Drivers'
> by Rubini.  It's kind of out of date (written for the 2.0 kernel)
> but it gives you a good idea about the basics.
> 
> On Fri, Oct 19, 2001 at 10:00:13AM -0700, Gururaj Ananthateerta wrote:
> > I am newbie to Linux.
> > Is there any document which explains howto write linux network drivers for
> > ia-64.?
> >
> > Thanks
> >
> >
> >
> >
> >
> > _______________________________________________
> > Linux-IA64 mailing list
> > Linux-IA64@linuxia64.org
> > http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 
> --
> Don Dugger
> "Censeo Toto nos in Kansa esse decisse." - D. Gale
> n0ano@indstorage.com
> Ph: 303/652-0870x117
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

