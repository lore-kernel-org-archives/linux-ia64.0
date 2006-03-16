From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 16 Mar 2006 19:12:39 +0000
Subject: RE: accessed/dirty bit handler tuning
Message-Id: <200603161912.k2GJCeg02194@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44157CF1.5060902@bull.net>
In-Reply-To: <44157CF1.5060902@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zoltan Menyhart wrote on Thursday, March 16, 2006 1:57 AM
> > It is still not clear whether srlz.d is required or not, right?  Wording
> > in SDM is vague.
> 
> We have quoted several times the SDM:
> 
> "The visibility of the itc instruction to generated purges (ptc.g, ptc.ga)
> must occur before subsequent memory operations. From a software perspective,
> this is similar to acquire semantics. Serialization is still required to
> observe the side-effects of the translation being present."
> 
> What do you think the statement "Serialization is still required..." means
> if not a "srlz.d" (or "rfi") ?


This is a rat hole, until we get some clarification from the ia64 architects,
nobody should take a strong position one way or the other. You persistently
post patches that adds srlz and I'm countering that with persistent reminder
of ambiguity.  For dirty/access fault handler, the srlz probably costs
nothing because itc latency is already hidden behind cmpxchg.  However, I
don't want that become a de-facto and then subsequently leak into vhpt_miss
handler.


> > Do you have any performance data showing that nta is a win?
> 
> I have already admitted that I cannot measure the difference.
> (We do not hit very frequently these trap routines.)
> 
> Let us put the question in another way:
> 
> There is a sequence with "nta"-s.
> This sequence is not longer than the one w/o "nta"-s.
> According to the doc. it *may* run faster.
> Why should not we use it?


This is another rat hole.  The whole reason you want to use nta is you know
it is going to be used only once.  In the dirty handler, it's not "use once"
scenario.  It is used 3 times! The 2nd and 3rd access will see full L3 latency
if the data is indeed a cache miss on the 1st load.  The original question is:
prove nta is an overall win given the penalty of 2nd and 3rd pte access. It
*may not* run faster than what you think.

- Ken

