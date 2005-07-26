From: Andrew Morton <akpm@osdl.org>
Date: Tue, 26 Jul 2005 19:10:19 +0000
Subject: Re: [patch] properly stop devices before poweroff
Message-Id: <20050726121019.0248801c.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F03FCF24C@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F03FCF24C@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: kaneshige.kenji@jp.fujitsu.com, ambx1@neo.rr.com, greg@kroah.org, pavel@ucw.cz, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

"Luck, Tony" <tony.luck@intel.com> wrote:
>
> I started on my OLS homework from Andrew ... and began looking
> into what is going on here.
> 

Thanks ;) I guess we'll end up with a better kernel, even though you appear
to be an innocent victim here.

> 
> Andrew: How did you get the squitty font on ia64?  The stack trace
> from the oops flies off the top of the screen.  I've tried a few
> "vga=0x0f07" type options, but I keep getting a big font.

I put

SYSFONT="iso08.08"

in /etc/sysconfig/i18n
