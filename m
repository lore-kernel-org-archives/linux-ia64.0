From: Keith Owens <kaos@sgi.com>
Date: Sat, 08 Jan 2005 01:32:26 +0000
Subject: Re: [PATCH] ia64: reset console_loglevel so INIT output always goes to console
Message-Id: <4704.1105147946@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <1105140871.25267.50.camel@eeyore>
In-Reply-To: <1105140871.25267.50.camel@eeyore>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 07 Jan 2005 16:34:31 -0700, 
Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:
>Reset console_loglevel early in INIT handler.  Otherwise, if
>it has been turned down (i.e., with "dmesg -n1"), the user may
>see no effect at all from issuing an INIT.  We're never going
>to run any more user code, so there won't be any opportunity for
>anything to collect the output from the dmesg buffer.

That is fine for the current code base.  It will have to be revisited
when we get per cpu INIT stacks and the slave INIT handler actually
does something.

We are slowly but steadily moving to recovery from some MCA events.  If
one of the cpus is spinning disabled when an MCA occurs then the
disabled cpu will get a slave INIT event as part of the MCA rendezvous.
If the MCA is recoverable then the slave INIT event will also be
recoverable and will eventually return to user space.

That change is still some way off, but bear it in mind when changing
the existing code.

