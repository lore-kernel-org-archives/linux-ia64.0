From: Alan Modra <amodra@bigpond.net.au>
Date: Sat, 05 Jan 2002 02:11:01 +0000
Subject: Re: [Linux-ia64] Compiling kernel 2.4.17 fails at link stage
Message-Id: <marc-linux-ia64-105590698805744@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805743@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805743@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jan 04, 2002 at 05:31:24PM -0800, Grant Grundler wrote:
> Alan Modra wrote:
> > It's a kernel bug exposed by recent binutils.  You can either fix the
> > kernel by making the references weak, or hack around the problem by
> > adding -fnoinhibit-exec to the ld command line.
> 
> I had added "-fnoinhibit-exec" to LINKFLAGS in linux/arch/ia64/Makefile
> and got:

Sorry, typo.  --noinhibit-exec

> So how do I "make references weak"?

extern int foo __attribute__ ((weak));


