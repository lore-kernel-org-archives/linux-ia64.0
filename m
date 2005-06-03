From: Dean Nelson <dcn@sgi.com>
Date: Fri, 03 Jun 2005 19:43:41 +0000
Subject: Re: [PATCH] fix setting of sn_hub_info->shub_1_1_found
Message-Id: <20050603194341.GA24711@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42A04C38.mailxA351PB0RI@aqua.americas.sgi.com>
In-Reply-To: <42A04C38.mailxA351PB0RI@aqua.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jun 03, 2005 at 12:36:07PM -0700, Luck, Tony wrote:
> >It was my understanding from linux/Documentation/DocBook/kernel-hacking.tmpl
> >that '__initdata' meant that the variable shub_1_1_found was not initialized
> >to anything (unlike ordinary static data).
> 
> I'd never noticed that ... but it does make sense.  I wonder whether there
> are any other __initdata declarations, written by people as clueless as me,
> that are wrong?

I'd assume there are other uninitialized uses of __initdata declarations.
This one had been.

I'm assuming that you will be keeping my first hunk.


