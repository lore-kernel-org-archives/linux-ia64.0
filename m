From: Dean Nelson <dcn@sgi.com>
Date: Fri, 03 Jun 2005 19:14:21 +0000
Subject: Re: [PATCH] fix setting of sn_hub_info->shub_1_1_found
Message-Id: <20050603191421.GA23827@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42A04C38.mailxA351PB0RI@aqua.americas.sgi.com>
In-Reply-To: <42A04C38.mailxA351PB0RI@aqua.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jun 03, 2005 at 11:50:55AM -0700, Luck, Tony wrote:
> >This explains why XPC has been so troublesome to load on older systems.
> >Thanks Dean!
> >
> >Tony, can this still get into 2.6.12?
> 
> Probably ... but the first hunk of the patch looks like a no-op,
> and contravenes some style guidlines about initializing global
> variables to 0.
> 
> -static int shub_1_1_found __initdata;
> +static int __initdata shub_1_1_found = 0;

It was my understanding from linux/Documentation/DocBook/kernel-hacking.tmpl
that '__initdata' meant that the variable shub_1_1_found was not initialized
to anything (unlike ordinary static data).

Perhaps that is no longer (or never was) true? If so, then indeed ignore
the first hunk.

> Presumably you'd still like the second hunk?

But definitely apply the second hunk.

Thanks,
Dean
