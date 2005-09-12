From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Mon, 12 Sep 2005 06:59:04 +0000
Subject: [RFC] SAL_MC_RENDEZ logic
Message-Id: <43252738.8030303@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi all,

I'm now testing the MCA codes on brand-new system,
and bump into a problem that slave processors infinitely
loop in ia64_mca_wakeup_ipi_wait().

The cause was that the SAL clears the IRR bit just after its
spin in SAL_MC_RENDEZ procedure, and OS spins again until the
IRR bit be set in ia64_mca_wakeup_ipi_wait().

According to the SAL spec, it says:
   (SAL_MC_RENDEZ:)
   When this procedure returns, it is the responsibility of the
   operating system to clear the IRR bits for the MC_rendezvous
   interrupt and the wake up interrupt, if any.

I'm not sure but it seems "if any" means that SAL can clear
the IRR bits on behalf of OS.  So OS shouldn't expect the IRR
always be set on returning from SAL_MC_RENDEZ, is this right?

I found a archive 2 years ago, from Keith:
   http://marc.theaimsgroup.com/?l=linux-ia64&m5590709805820
However there was no responce...

I don't know whether there is any old SAL never spins in
SAL_MC_RENDEZ or not.  Or is this the beginning of nightmare,
having different MCA codes depend on the SAL version?

Thanks,
H.Seto

