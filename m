From: Grant Grundler <iod00d@hp.com>
Date: Tue, 23 Sep 2003 20:38:19 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106435005618770@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Sep 23, 2003 at 11:51:22AM -0700, David S. Miller wrote:
> > Even x86 pays at least a one cycle penalty for every misaligned access.
> 
> Yes, one cycle, and it's completely lost in the noise when it happens.

Depends on the app - for the networking stack, I agree.

To revisit Ben's comment: if we know something is likely to be misaligned,
a RISC processor can efficiently load both parts and merge them (one cycle
penalty vs a regular aligned load). Given misaligned accesses are infrequent
enough to affect performance, it makes sense to do this in SW because
it reduces cost of the HW design/test/mfg cycles.

...
> It is an unavoidable axoim in the kernel networking.  Unaligned accesses
> will happen, and they aren't a bug and therefore not worthy of mention
> in the kernel logs any more than "page was freed" :-)

Ok. If the kernel networking stack used get_unaligned() in the one place
Peter originally found, x86/sparc64?/et al wouldn't see a difference.
It would avoid traps on ia64 and parisc.  Bad idea?
Any other arches it might help/hurt on?

grant
