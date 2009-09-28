From: "Boehm, Hans" <hans.boehm@hp.com>
Date: Mon, 28 Sep 2009 19:02:51 +0000
Subject: RE: [git pull] ia64 changes
Message-Id: <238A96A773B3934685A7269CC8A8D042577C608549@GVW0436EXB.americas.hpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> From: Linus Torvalds
> Sent: Saturday, September 26, 2009 10:19 PM
> 
> On Sat, 26 Sep 2009, Luck, Tony wrote:
> 
> > However, when I ran the generated code with the .acq in 
> here past one 
> > of the Itanium h/w architects, he said that it actually 
> wasn't needed 
> > because the cmp/branch would also prevent accesses from inside the 
> > protected region from leaking out.
> 
> That seems to be purely an implementation (as opposed to 
> architectural) detail.
> 
> But it looks like it is unlikely that we'll ever see an OoO 
> ia64 implementation, so I suspect that the implementations we 
> have are all that matter.
> 
FWIW -

My reading of the Itanium architecture manual is that this is probably actually guaranteed at the level of the hardware.  The hardware explicitly enforces memory ordering based on dependence ordering (II-2.2.1.7 in the architecture manual and 3.3.4 (Data-Flow Dependence) in http://download.intel.com/design/Itanium/Downloads/25142901.pdf).  It is somewhere between challenging and impossible to efficiently implement Java on machines that don't provide some variant of this guarantee, at least for simple data dependences.

However, it may be difficult to guarantee that the compiler won't somehow manage to break such dependences, e.g. by speculatively performing a load from the critical section before the wait loop.

Hans 
