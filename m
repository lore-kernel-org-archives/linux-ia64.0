From: "Bob Picco" <bob.picco@hp.com>
Date: Mon, 30 Oct 2006 22:25:47 +0000
Subject: Re: cross-compiling ia64 kernels?
Message-Id: <20061030222547.GD4276@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2AB91DF8@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2AB91DF8@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

luck wrote:	[Mon Oct 30 2006, 04:20:50PM EST]
> Does anyone have a recipe for tools & scripts to cross-compile
> a current ia64 kernel?  I have lots of machines sitting in the
> lab waiting for me to run native builds so I've never bothered
> to look into cross environments.  But I've had some inquiries
> on how to cross-build from some people with less h/w ready to
> do their bidding.
> 
> -Tony
Tony,

I build all my arches on x86_64 with crosstool. My current tool chain
for x86 and ia64 is derived from gcc-3.4.1-glibc-2.3.2.  For powerpc
I'm using  gcc-3.4.2-glibc-2.3.3. It doesn't require significant effort
after downloading Dan Kegel's crosstool source and build tools at:
http://www.kegel.com/crosstool/
. Select the tool chain gcc revision and
binutil revision in Dan's arch specific script file and build. Then one
only has to add the installed compiler path to your shell environment path.
For example ia64 for me is 
/usr/local/crosstool/gcc-3.4.1-glibc-2.3.2/ia64-unknown-linux-gnu/bin.
After that 
	make ARCH=ia64 CROSS_COMPILE=ia64-unknown-linux-gnu- whatever
should work just fine.

I'm not certain whether this is all the information you require:

bob
