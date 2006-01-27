From: Jes Sorensen <jes@sgi.com>
Date: Fri, 27 Jan 2006 09:57:18 +0000
Subject: Re: [patch 5/5] fix sn rw_mmr.h to use intrinsic
Message-Id: <yq04q3qhu2p.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601270137.k0R1big21236@unix-os.sc.intel.com>
In-Reply-To: <200601270137.k0R1big21236@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Kenneth" = Chen, Kenneth W <kenneth.w.chen@intel.com> writes:

Kenneth> Use ia64 intrinsic for functions in sn/rw_mmr.h.
Kenneth> Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>

Hi Ken,

I'll have to test this. However it really doesn't matter much as we
won't be building the SN kernel with ICC.

Kenneth> By the way, for my learning purpose, why does
Kenneth> pio_atomic_phys_write_mmrs() need to turn off psr.ic bit?

No idea, maybe Jack knows?

Cheers,
Jes
