From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Mon, 13 Mar 2006 20:14:19 +0000
Subject: RE: accessed/dirty bit handler tuning
Message-Id: <200603132014.k2DKEHg25250@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44157CF1.5060902@bull.net>
In-Reply-To: <44157CF1.5060902@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote on Monday, March 13, 2006 12:05 PM
> >Hmm, I think another alternative is to rip out all the itc insertion
> >code and let the hardware page walker do the "dirty" job.  Because it
> >is known and architected to be atomic-read-and-insert and is also
> >known to honor ptc.g while atomic-read-and-insert is in-flight (i.e.,
> >won't insert tlb entry).
> 
> Can we get some perf. numbers ... this will take each dirty fault twice
> (though the second should be fast if VHPT does it's job).  This might
> be slower than putting in the srlz.d that Zoltan wants.

I don't have any numbers ...  Though I've measured 5 cycles hpw insert
latency. It ought be faster than srlz.d.

On the other hand, the behavior of itc with respect to ptc.g is still up
in the air pending an query from ia64 hardware architects.  But the more
I read the SDM, the more it looks like a statement of actual processor
behavior instead of a statement for software requirement.

So going either way is a pre-matured decision, I guess.

- Ken

