From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 31 Mar 2006 00:49:22 +0000
Subject: Re: Synchronizing Bit operations V2
Message-Id: <Pine.LNX.4.64.0603301645370.2068@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603301300430.1014@schroedinger.engr.sgi.com> 
 <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com>
 <ed5aea430603301642t283174f6wa0587089920ca3a8@mail.gmail.com>
In-Reply-To: <ed5aea430603301642t283174f6wa0587089920ca3a8@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Mosberger-Tang <David.Mosberger@acm.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Zoltan Menyhart <Zoltan.Menyhart@bull.net>, "Boehm, Hans" <hans.boehm@hp.com>, "Grundler, Grant G" <grant.grundler@hp.com>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Thu, 30 Mar 2006, David Mosberger-Tang wrote:

> I have to agree with Hans and I'd much prefer making the mode part of
> the operation's
> name and not a parameter.  Besides being The Right Thing, it saves a
> lot of typing.

IMHO It reduces the flexibility of the scheme and makes it not extendable. 
Leads to a large quantity of macros that are difficult to manage. 

Also some higher level functions may want to have the mode passed to them 
as parameters. See f.e. include/linux/buffer_head.h. Without the 
parameters you will have to maintain farms of definitions for all cases.



