From: Paul Bolle <pebolle@tiscali.nl>
Date: Wed, 28 May 2014 22:46:27 +0000
Subject: Re: ia64: CONFIG_PARAVIRT_GUEST_ASM_CLOBBER_CHECK?
Message-Id: <1401317187.6186.36.camel@x220>
List-Id: <linux-ia64.vger.kernel.org>
References: <1400748416.16832.7.camel@x220>
In-Reply-To: <1400748416.16832.7.camel@x220>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2014-05-28 at 22:34 +0000, Luck, Tony wrote:
> > Was this macro intended to be set through the kconfig tools? Or was it
> > perhaps intended to be set manually whenever one wanted to use it?
> > Either way, is that macro and the code currently hidden behind it still
> > needed?
> 
> I think it may be moot.  Xen support was ripped out in December last
> year by commit d52eefb47d4 ... so this even if this PARAVIRT piece
> one did something, it is all history now.

Should I draft an (untested, I'm afraid) patch to remove
CONFIG_PARAVIRT_GUEST_ASM_CLOBBER_CHECK and everything hidden behind it?
Or would you prefer to do that yourself?

Thanks,


Paul Bolle

