From: "Bjorn Helgaas" <bjorn.helgaas@hp.com>
Date: Mon, 10 Jan 2005 04:27:44 +0000
Subject: Re: [PATCH] ia64: reset console_loglevel so INIT output always
Message-Id: <1749.24.9.197.67.1105331264.squirrel@24.9.197.67>
List-Id: <linux-ia64.vger.kernel.org>
References: <1105140871.25267.50.camel@eeyore>
In-Reply-To: <1105140871.25267.50.camel@eeyore>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> As Keith pointed out, we are working on returning from an INIT.
>
> Would it be reasonable to save the current console_loglevel,
> set console_loglevel up to 15, call init_handler_platform(), and
> then set console_loglevel back to the original level?
>
> Right now init_handler_platform() never returns.  When the code
> is improved to return, the console_loglevel will get restored
> to the correct level.

Sure.  I expect that we will one day be able to continue after
an INIT, and I considered doing the save/restore in the current
patch.  But I preferred the simplest possible patch, partly because
this is an issue for distributions, and I'd like to see them
pick this up quickly

