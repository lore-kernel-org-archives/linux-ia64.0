From: Arun Sharma <arun.sharma@intel.com>
Date: Fri, 27 Aug 2004 17:15:35 +0000
Subject: Re: Long Format VHPT patches
Message-Id: <412F6C37.1070301@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040825023439.GA15782@cse.unsw.EDU.AU>
In-Reply-To: <20040825023439.GA15782@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 8/26/2004 2:20 PM, Peter Chubb wrote:

>>>>>> "Christoph" = Christoph Lameter <christoph@lameter.com> writes:
> 
> Christoph> One issue that bothers me is that it is no longer possible
> Christoph> to swap pte, pmd and pgd entries via cmpxchg. My page fault
> Christoph> scalability patches are based on that ability. The Itanium
> Christoph> can only do a cmpxchg with a 64 bit value.  The long VHPT
> Christoph> entries are 32 bytes long.
> 
> I don't think that that's an issue at present: in our patch, the
> hardware-walked long format VHPT is used as a cache of the existing
> linux 3-level table, kind of like a software loaded TLB.  Thus your
> cmpxchg stuff on the pagetables will still work.
> 

And long format VHPTs are per CPU. So no cmpxchg should be necessary.

	-Arun


