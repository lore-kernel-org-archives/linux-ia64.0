From: Greg KH <gregkh@suse.de>
Date: Tue, 05 Apr 2005 20:49:18 +0000
Subject: Re: [03/08] fix ia64 syscall auditing
Message-Id: <1112734158.468.0.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050405164539.GA17299@kroah.com>
	 <20050405164647.GD17299@kroah.com>
	 <16978.62622.80542.462568@napali.hpl.hp.com>
In-Reply-To: <16978.62622.80542.462568@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davidm@hpl.hp.com
Cc: linux-kernel@vger.kernel.org, stable@kernel.org, amy.griffis@hp.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, dwmw2@infradead.org

On Tue, 2005-04-05 at 13:27 -0700, David Mosberger wrote:
> >>>>> On Tue, 5 Apr 2005 09:46:48 -0700, Greg KH <gregkh@suse.de> said:
> 
>   Greg> -stable review patch.  If anyone has any objections, please
>   Greg> let us know.
> 
> Nitpick: the patch introduces trailing whitespace.

Sorry about that, I've removed it from the patch now.

> Why doesn't everybody use emacs and enable show-trailing-whitespace? ;-)

Because some of us use vim and ":set list" to see it, when we remember
to... :)

thanks,

greg k-h

