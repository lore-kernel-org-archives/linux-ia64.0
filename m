From: Matt Chapman <matthewc@cse.unsw.edu.au>
Date: Fri, 17 Oct 2003 15:11:04 +0000
Subject: Re: load-store emulation with SIGSEGV
Message-Id: <marc-linux-ia64-106640366417855@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106634457403703@msgid-missing>
In-Reply-To: <marc-linux-ia64-106634457403703@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Oct 16, 2003 at 11:51:16PM +0100, R. Lake wrote:
> 
> A simple test to decode the instruction, locate and modify the operand
> register in the sigcontext or backing store, then increment sc_ip shows the
> expected behaviour.

Yep, I do similar things in a virtual machine that I wrote.  Here are some
notes in case you've overlooked some of the finer details (and perhaps I've
overlooked some of the finer details as well :)).

Incrementing the IP:
sc->sc_ip += ((sc->sc_ip & 0xf) = 2) ? 0xe : 1;

Register 0:
Read returns 0, write faults. When reading don't rely on sc_gr[0] being 0.

Register 1-3,8-31:
Simply read/write sc_gr[n].
Upon read check NaT bit, upon write clear NaT bit through sc_nat.

Register 4-7:
Preserved registers - read/write live value at entry to signal handler
(really would need to unwind to do this completely safely, but just using
the live value should do).  gcc rarely uses these registers so I just
assert here :)

Register 32-127:
If using sigaltstack, bsp = sc->sc_rbs_base + (sc->sc_loadrs >> 16),
else bsp = sc->sc_ar_bsp.
Read: ;;flushrs;; to write back
      read address = ia64_rse_skip_regs(bsp, -(sc->sc_cfm & 0x7f) + (regno - 32));
Write: ;;mov ar.rsc=0;;flushrs;;loadrs;; to go lazy, write back, invalidate
       write address as before
       ;;mov ar.rsc=3;; to allow eager loads again
       Strictly should check/clear the NaT bits as well (more fun working out
       the addresses), I haven't bothered to do this yet.

Also beware that old kernels (pre about 2.5.60?) report the wrong si_addr for
accesses to the NULL page (the instruction address instead of the fault address).
I'm not sure when this was fixed in the 2.4 tree.

Matt


