From: Nathan Straz <nstraz@sgi.com>
Date: Fri, 11 Jul 2003 14:15:08 +0000
Subject: Re: clone testcases in LTP
Message-Id: <marc-linux-ia64-105793295522404@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105778639326638@msgid-missing>
In-Reply-To: <marc-linux-ia64-105778639326638@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jul 11, 2003 at 11:57:30AM +0200, Andreas Schwab wrote:
> Peter Chubb <peter@chubb.wattle.id.au> writes:
> |> I'm not finding that clone2() works -- We get a segfault in the cloned
> |> process when it returns.
> 
> You can't return from the function, only exit() or _exit() works.

That seems really odd that you can't return from the function.  The
clone man page (dated 2001-06-26) says either way is an option.  I did
test it with the explicit exit() call and that does clean up the
SIGSEGV.
-- 
Nate Straz                                              nstraz@sgi.com
sgi, inc                                           http://www.sgi.com/
Linux Test Project                                  http://ltp.sf.net/
