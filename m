From: Chris Wright <chrisw@sous-sol.org>
Date: Fri, 31 Mar 2006 06:10:37 +0000
Subject: Re: Synchronizing Bit operations V2
Message-Id: <20060331061037.GD14724@sorel.sous-sol.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603301300430.1014@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com> <ed5aea430603301642t283174f6wa0587089920ca3a8@mail.gmail.com>
In-Reply-To: <ed5aea430603301642t283174f6wa0587089920ca3a8@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Mosberger-Tang <David.Mosberger@acm.org>
Cc: Christoph Lameter <clameter@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Zoltan Menyhart <Zoltan.Menyhart@bull.net>, "Boehm, Hans" <hans.boehm@hp.com>, "Grundler, Grant G" <grant.grundler@hp.com>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

* David Mosberger-Tang (David.Mosberger@acm.org) wrote:
> I have to agree with Hans and I'd much prefer making the mode part of
> the operation's
> name and not a parameter.  Besides being The Right Thing, it saves a
> lot of typing.
> For example:
> 
> +       set_bit_mode(nr, addr, MODE_ATOMIC);
> 
> would simply become
> 
> +       set_bit_atomic(nr, addr);

That's the approach Xen took as well.

thanks,
-chris
