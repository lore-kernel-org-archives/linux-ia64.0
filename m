From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 03 Nov 2004 17:04:23 +0000
Subject: Re: [PATCH] top level scheduler domain for ia64
Message-Id: <200411030904.23911.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200410191427.27336.jbarnes@engr.sgi.com>
In-Reply-To: <200410191427.27336.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday, November 3, 2004 8:57 am, Luck, Tony wrote:
> >> > Is '6' a reasonable default if the parameter is not set?
> >>
> >> Maybe for Altix.  I guess the only user of this domain split
> >> is Altix, so it's ok ;)
> >
> >Yep, looks good to me.  Thanks.
>
> So tell me who wants a value other than 6, and what is the value
> that they want?  I was hoping for some more specific advice in
> the kernel-parameters.txt file.  What's a good choice for a 16-node
> machine?  For a 128-node machine?

I don't know.  The original value I chose was 4, but I think Nick changed it 
to 6 to get more overlap.  Any ideas John?

Jesse
