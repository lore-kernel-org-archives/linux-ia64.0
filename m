From: Horms <horms@verge.net.au>
Date: Mon, 02 Oct 2006 04:09:44 +0000
Subject: Re: kexec/kdump and the ia64 test tree
Message-Id: <20061002040942.GA3034@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200609292146.k8TLkNex005603@agluck-lia64.sc.intel.com>
In-Reply-To: <200609292146.k8TLkNex005603@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Oct 02, 2006 at 10:11:08AM +0900, Horms wrote:
> On Fri, Sep 29, 2006 at 02:46:23PM -0700, Tony Luck wrote:
> > The kexec/kdump patch in my test tree is very stale, plus it is time
> > for some git maintenance on the test tree (to clean away all the
> > "Auto-update from upstream" commits that my workflow generates). So
> > I'm planning on resetting my "test" branch to Linus-latest + kdump/kexec
> > (so git pull/fetch will barf on my test tree, you'll need to re-clone).
> > 
> > Below I've include what I believe to be the latest version of the
> > patch produced by:
> > 
> > 1) Take 2.6.18
> > 2) Apply Nan Hai patch for 2.6.18 (posted Sept 20th)
> > 3) Pull in Linus-latest (c972398b ...) and resolve conflicts in smp.h, sysctl.h
> > 4) Apply Nan hai's "Fix OS_INIT" patch that fixed Indou-san's deadlock issue (Sept 28th)
> > 5) Fix a few warnings:
> > 	arch/ia64/kernel/iosapic.c:
> > 		`vec' may be used before set in kexec_disable_iosapic() ... I'm
> > 		not totally confident that I fixed this right. Please look closely
> > 		at what I did.
> > 	arch/ia64/kernel/smp.c:
> > 		Trivial fixes to stop compiler complaining that kdump_smp_send_stop()
> > 		and kdump_smp_send_init() definitions were not prototypes.
> > 6) Lots of white-space cleanup (mostly multiple spaces that should be tabs, but I
> >    also threw the whole kdump_find_rsvd_region() in arch/ia64/kernel/efi.c through
> >    scripts/Lindent as it was only using two-spaces for indentation.)
> > 
> > Let me know if I've goofed up the patch during this process.
> > 
> > I'm planning to reset my test tree on Monday (Oct 2nd).
> 
> Hi Tony,
> 
> overall that plan seems fine to me - though I would have prefred
> a more incremental approach. I will spend some time today checking
> over your patch and see if I can spot any insanity.
> 
> On a related note, does/did your ia64-test branch have anything
> of significance in it other than kexec/kdump?

I looked over these patches and they seem fine. In order to make the
check easier for my mind to get around I split the changes out into
three separate patches, relative to Nan Hai's latest patch (the 20th
September one) + the OS_INIT fix + Linus' tree (d834c16516d..., a bit
later than yours but nothing of significance).

1. Remove ioc_iova_disable()

   This looks fine as its not called anywhere. I didn't go back
   and track its history, but presumably just dead code.

2. Make sure vec is initialised in kexec_disable_iosapic()

   To be honest I'm not sure if your fix is correct either,
   but the original code is definately a problem.

3. Whitespace and reformating.

   I didn't actually check all of these. What I did was to ask
   diff to eliminate whitespace-only changes, and then check
   what was left by hand. Actually, thats how I broke out 1 and 2.

In all, this seems fine. I don't think there are any spurious changes.
And the code executes fine (well as fine as any version I have seen)
on my Tiger 2.

As I broke out the patches in the course of checking this I have
posted them each as a follup to this post, just for reference.

I have also placed them in a tempoary kexec-tony-luck branch of
my git tree. Which is Linus's tree (again d834c16516d) + Nan Hai's
patches, including the OS_INIT fix. I plan to merge your changes into the
master branch once they are finalised.

git://www.kernel.org//pub/scm/linux/kernel/git/horms/kexec-ia64-2.6/
http://www.kernel.org/git/?p=linux/kernel/git/horms/kexec-ia64-2.6.git;a=summary

