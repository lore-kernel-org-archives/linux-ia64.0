From: Andrew Morton <akpm@osdl.org>
Date: Wed, 06 Apr 2005 22:43:16 +0000
Subject: Re: [03/08] fix ia64 syscall auditing
Message-Id: <20050406154316.0b3b3f01.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050405164539.GA17299@kroah.com>
	<20050405164647.GD17299@kroah.com>
	<16978.62622.80542.462568@napali.hpl.hp.com>
	<1112734158.468.0.camel@localhost.localdomain>
	<20050405234602.GC4800@mythryan2.michonline.com>
In-Reply-To: <20050405234602.GC4800@mythryan2.michonline.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ryan Anderson <ryan@michonline.com>
Cc: gregkh@suse.de, davidm@hpl.hp.com, linux-kernel@vger.kernel.org, stable@kernel.org, amy.griffis@hp.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, dwmw2@infradead.org

Ryan Anderson <ryan@michonline.com> wrote:
>
> On Tue, Apr 05, 2005 at 01:49:18PM -0700, Greg KH wrote:
> > On Tue, 2005-04-05 at 13:27 -0700, David Mosberger wrote:
> > > >>>>> On Tue, 5 Apr 2005 09:46:48 -0700, Greg KH <gregkh@suse.de> said:
> > > 
> > >   Greg> -stable review patch.  If anyone has any objections, please
> > >   Greg> let us know.
> > > 
> > > Nitpick: the patch introduces trailing whitespace.
> > 
> > Sorry about that, I've removed it from the patch now.
> > 
> > > Why doesn't everybody use emacs and enable show-trailing-whitespace? ;-)
> > 
> > Because some of us use vim and ":set list" to see it, when we remember
> > to... :)
> 
> Try adding this to your .vimrc:
> 
> highlight WhitespaceEOL ctermbg=red guibg=red
> match WhitespaceEOL /\s\+$/
> 
> Then you'll have to resist the urge to fix whitespace issues instead of
> not seeing them at all.
> 

Yeah, that's a risk.  But gratuitous trailing whitespace changes shouldn't
cause a lot of downstream problems due to `patch -l'.

What I do is to ensure that we never _add_ trailing whitespace.  So
anything which matches

	^+.*[tab or space]$

gets trimmed.  My theory is that after 10 years of this, all the trailing
whitespace will be gone.  Problem is, I also see the hundreds of lines of
code in the bk patches which add trailing whitespace :(

Larry sent me a little bk script which would spam the user if they tried to
commit something which adds trailing whitespace, but maybe that's a bit
academic right now.

