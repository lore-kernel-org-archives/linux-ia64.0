From: Kevin Buettner <kev@primenet.com>
Date: Fri, 03 Nov 2000 21:32:10 +0000
Subject: Re: [Linux-ia64] Re: gdb null ptr
Message-Id: <marc-linux-ia64-105590678205651@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205647@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205647@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Nov 3,  8:32am, Pete Wyckoff wrote:

> wilson@cygnus.com said:
> > I don't see how this can happen from looking at the source.  We only cache
> > a type in dwarf2_cached_types if it has a DW_AT_name attribute, and if it
> > does have such an attribute, then the type should have a name or tag name.
> > 
> > Can you provide me with a testcase?  A binary that I can run under gdb should
> > be sufficient.  You could put it in ftp.cygnus.com/incoming and then mail
> > the file name to me.
> > 
> > Since this doesn't appear to be an ia64 specific problem, if I don't have a
> > testcase then I will just punt to the gdb developers
> > 	 http://sources.redhat.com/gdb/#bugs
> 
> It may very well be a gdb bug.  Anyway, I put a huge executable in
> the incoming dir as pw-gdb-bug-ex.
> 
>     3078a3f848cba6d1f76fbfe3707b0464  pw-gdb-bug-ex

Peter,

Thanks for sending us this test case.

I think this problem is arising because the dwarf2 reader had
problems earlier on.  I.e, I see

During symbol reading, non-constant array bounds form 'DW_FORM_ref4' ignored.
During symbol reading, unsupported tag: 'DW_TAG_constant'.

My guess is that when these (at the moment) unsupported cases arise,
the reader fails to properly initialize a name or tag name.

I'll look into it some more and get back to you when I understand the
problem better.

Thanks again,

Kevin

