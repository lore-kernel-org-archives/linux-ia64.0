From: Ryan Anderson <ryan@michonline.com>
Date: Tue, 05 Apr 2005 23:46:02 +0000
Subject: Re: [03/08] fix ia64 syscall auditing
Message-Id: <20050405234602.GC4800@mythryan2.michonline.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050405164539.GA17299@kroah.com> <20050405164647.GD17299@kroah.com> <16978.62622.80542.462568@napali.hpl.hp.com> <1112734158.468.0.camel@localhost.localdomain>
In-Reply-To: <1112734158.468.0.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg KH <gregkh@suse.de>
Cc: davidm@hpl.hp.com, linux-kernel@vger.kernel.org, stable@kernel.org, amy.griffis@hp.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, dwmw2@infradead.org

On Tue, Apr 05, 2005 at 01:49:18PM -0700, Greg KH wrote:
> On Tue, 2005-04-05 at 13:27 -0700, David Mosberger wrote:
> > >>>>> On Tue, 5 Apr 2005 09:46:48 -0700, Greg KH <gregkh@suse.de> said:
> > 
> >   Greg> -stable review patch.  If anyone has any objections, please
> >   Greg> let us know.
> > 
> > Nitpick: the patch introduces trailing whitespace.
> 
> Sorry about that, I've removed it from the patch now.
> 
> > Why doesn't everybody use emacs and enable show-trailing-whitespace? ;-)
> 
> Because some of us use vim and ":set list" to see it, when we remember
> to... :)

Try adding this to your .vimrc:

highlight WhitespaceEOL ctermbg=red guibg=red
match WhitespaceEOL /\s\+$/

Then you'll have to resist the urge to fix whitespace issues instead of
not seeing them at all.

-- 

Ryan Anderson
  sometimes Pug Majere
