From: Horms <horms@verge.net.au>
Date: Tue, 12 Dec 2006 09:31:57 +0000
Subject: Re: [Fastboot] [PATCH]send slave cpus to SAL slave loop on crash (IA64)
Message-Id: <20061212093156.GM18377@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061201060852.GA13622@verge.net.au>
In-Reply-To: <20061201060852.GA13622@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Dec 01, 2006 at 03:08:53PM +0900, Horms wrote:
> On Tue, Nov 21, 2006 at 07:13:56AM +0800, Zou Nan hai wrote:
> > This patch make normal "kexec -l" first try physical address suggested
> > by vmlinux. 
> > 
> > If there is no enough memory, kexec tools will search /proc/iomem and
> > find a place to put the new kernel.
> > 
> > This is necessary for "kexec -l" to work on SN platform.
> > 
> > Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>
> > 
> 
> Hi Nan hai, 
> 
> sorry for not responding sooner.
> 
> I have take a look at your patch with an eye to including it into 
> kexec-tools-testing. It does seem like a good feature.
> 
> Below is an updated version of the patch that cleans up your
> implementation a little. In particular.
> 
> * update_loaded_segments() returns -1 on error, 0 on success
>   - amongst other things the previous incarnation could return nothing
>     at all in once case.
> * else { if () { ; } } -> else if () { ; }
> * < 80 columns wide
> * removed trailing whitespace
> 
> Is it ok to apply this incarntation of the patch?
> I can make my changes a second patch if you prefer.
> 
> Signed-off-by: Simon Horman <horms@verge.net.au>

Hi,

I have applied your patch, and then my changes as a second patch
to kexec-tools-testing.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

