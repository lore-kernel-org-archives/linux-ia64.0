From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 16 Nov 2004 02:03:45 +0000
Subject: Re: [PATCH] fix phys. address conversion in ia64_pal_tr_read
Message-Id: <16793.24577.845209.764555@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200411151722.41157.jbarnes@engr.sgi.com>
In-Reply-To: <200411151722.41157.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 15 Nov 2004 17:22:41 -0800, Jesse Barnes <jbarnes@engr.sgi.com> said:

  Jesse> The palinfo module may call ia64_pal_tr_read using an IPI.
  Jesse> If the processor receiving the IPI is idle, the call will
  Jesse> fail since the idle process stack is in region 5 and
  Jesse> ia64_pal_tr_read uses __pa rather than ia64_tpa.  This small
  Jesse> patch fixes the problem by making it use ia64_tpa instead.

Perhaps its worthwhile to do any audit for this kind of problems?  It
may not be very difficult to hack sparse to add a check for __pa()
calls on (stack-)local variables.

	--david
