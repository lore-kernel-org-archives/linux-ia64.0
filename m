From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Mon, 30 Oct 2006 22:30:27 +0000
Subject: Re: cross-compiling ia64 kernels?
Message-Id: <20061030223027.GK15116@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2AB91DF8@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2AB91DF8@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Oct 30, 2006 at 01:20:50PM -0800, Luck, Tony wrote:
> Does anyone have a recipe for tools & scripts to cross-compile
> a current ia64 kernel?

Yes

Start at [1]; there are links to about 3 different ways to do it
there.  You can try crosstool from [2] as well

If you use Debian, I have some pre-built .debs which may work for you,
see [3], but it's pretty easy to build your own; see [4].

What I usually do is from an IA64 host use distcc to remote machines
with IA64 cross compilers.

-i

[1] http://www.gelato.unsw.edu.au/IA64wiki/CrossCompilation
[2] http://www.kegel.com/crosstool/
[3] http://www.gelato.unsw.edu.au/IA64wiki/GelatoDebianRepository
[4] http://www.gelato.unsw.edu.au/IA64wiki/DebianCrossCompiler
