From: Eric Desjardins <eric.desjardins@discreet.com>
Date: Thu, 10 Feb 2005 15:05:04 +0000
Subject: Re: Porting driver from x86
Message-Id: <1108047904.29380.11.camel@oshawa.rd.discreet.qc.ca>
List-Id: <linux-ia64.vger.kernel.org>
References: <1108041115.29380.6.camel@oshawa.rd.discreet.qc.ca>
In-Reply-To: <1108041115.29380.6.camel@oshawa.rd.discreet.qc.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The drivers want's to know if it has been put to sleep or not. It's not
used often. It's not my code and the reasons seems a bit obscure to me.

It is possible to do it anyway?

Eric

On Thu, 2005-02-10 at 10:06, Matthew Wilcox wrote:
> On Thu, Feb 10, 2005 at 08:11:55AM -0500, Eric Desjardins wrote:
> > I'm not to familiar with kernel code but I'm trying to port a kernel
> > driver from x86 to ia64.
> > 
> > I was just wondering how should I translate that:
> > 
> > static int interrupts_blocked()
> 
> Drivers shouldn't need to know whether interrupts are blocked or not.
> What are you trying to do?
-- 
Eric Desjardins <eric.desjardins@discreet.com>
