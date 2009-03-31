From: Ingo Molnar <mingo@elte.hu>
Date: Tue, 31 Mar 2009 10:17:03 +0000
Subject: Re: [GIT PULL] percpu, cpumask, x86 updates for v2.6.30
Message-Id: <20090331101703.GA20904@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <alpine.LFD.2.00.0903281341100.3994@localhost.localdomain>
In-Reply-To: <alpine.LFD.2.00.0903281341100.3994@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


* Luck, Tony <tony.luck@intel.com> wrote:

> Ingo,
> 
> Thanks for looking at this ... I'll try to do some sanity checks
> on the IRQ stats to make sure that they make sense.
> 
> I do question this part:
> 
> > It didnt crash though: this commit has been in linux-next for 2 
> > months.
> 
> I've been building linux-next for ia64 at least a couple of times 
> a week ... and I didn't see the build error from these changes 
> there.  First time I saw it was when it showed up in Linus' tree.  
> Can you check that all of your trees are in the list to pull into 
> linux-next?  Perhaps this one got missed?

They are and were all there. There was no build problem here AFAICS 
- just a conflict which Linus saw and resolved [correctly AFAICS].

( And i build ia64 daily, against our full tree, so i'd have noticed
  any build breakage. )

If there was something here that shouldnt have happened then let me 
know and i'll trace back exactly how it happened and will prevent it 
in the future.

	Ingo
