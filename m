From: Matthew Wilcox <matthew@wil.cx>
Date: Fri, 17 Mar 2006 21:52:49 +0000
Subject: Re: PATCH: Fix gnu-efi-3.0b-041222 for ia32
Message-Id: <20060317215249.GB8980@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060317202301.GA20807@lucon.org>
In-Reply-To: <20060317202301.GA20807@lucon.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Mar 17, 2006 at 01:46:57PM -0800, H. J. Lu wrote:
> On Fri, Mar 17, 2006 at 12:53:24PM -0800, James E Wilson wrote:
> > On Fri, 2006-03-17 at 12:45, James E Wilson wrote:
> > > That should be .text.*, not .text*.
> > 
> > And because .text.* doesn't match .text, this actually needs to be
> >     *(.text .text.*)
> 
> I don't think so. linker calls fnmatch to match section names by
> patterns.  According to my man page:
> 
> DESCRIPTION
>        The  fnmatch()  function checks whether the string argument
> matches the
>        pattern argument, which is a shell wildcard pattern.
> 
> ".text*" should work as a shell wildcard pattern.

I believe his point is that .text* matches .textual and .texterific and
many other sections which shouldn't be matched.  So you need to match
.text and .text.*, not just .text*
