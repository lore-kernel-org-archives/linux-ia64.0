From: Don Dugger <n0ano@valinux.com>
Date: Wed, 05 Sep 2001 20:53:11 +0000
Subject: [Linux-ia64] Location of absolute IA32 shared objects.
Message-Id: <marc-linux-ia64-105590698805127@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805122@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805122@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I think there are two issues here, both important, but I was only trying
to address the second question:

1)  Exactly where do we put IA32 objects.  Personally I don't care,
to me this is just an arbitrary character string that needs to be added
to path names and I use which ever one everybody agrees to.  Unfortunately
the Itanium specific ABI suggests where to put them but it doesn't
explicitly specify where.  The ABI only talks about IA64 objects, it
doesn't explicitly deal with IA32 objects.  A quick read of section
5.3.1 would say to me that `/usr/lib/ia32', `/usr/lib/ia32l32',
`/usr/lib/ia32l' or `/usr/lib/l32' are all possible interpretations of
where IA32 objects are placed.  Again, I don't care, pick one.  Doug
is right, this is something that should be coordinated with the LSB.

2)  How do we deal with absolute path names in IA32 binaries?  This is
the question I'm concerned with right now.  The sad reality of life is
that there are rogue (I use the term `rogue' with tongue firmly planted
in check) IA32 binaries that have hard coded absolute paths to certain
libraries.  I think we all agree that `standard' libraries  must be IA64
objects and, therefore, we need to find a way to deal with these
rogue IA32 programs if we want them to run.

I have a proposed solution to 2 but it's not perfect.  I was kind of hoping
that someone had a better idea but it doesn't look like it.  Unless someone
comes up with a brainstorm I'll implement my idea and at least we should
be able to run the rogue IA32 programs we know about.

On Sep 05, 2001 at 12:20:01PM -0700, Sunil Saxena wrote:
> Have you folks looked at the "UNIX System V Application Binary Interface" at
> http://developer.intel.com/design/IA-64/ ?  Section 5.3.1 suggests locations
> for the libraries.
> 
> Thanks
> Sunil
> 
> -----Original Message-----
> From: Doug Beattie [mailto:dbb@caldera.com]
> Sent: Wednesday, September 05, 2001 10:57 AM
> To: Don Dugger
> Cc: Bill Nottingham; ia64-list@redhat.com; linux-ia64@linuxia64.org
> Subject: Re: [Linux-ia64] Re: Wolverine RPMs
> 
> 
> Don and others:
> 
> Let's not forget what might need to be considered to allow LSB 32 bit
> compliant apps on IA64. Even though no one may ever certify for this,
> it would be nice to find out and follow a convention that would
> benefit all.
> 
> Doug
> 

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@valinux.com
Ph: 303/938-9838

