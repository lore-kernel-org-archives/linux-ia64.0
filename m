From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Mon, 13 Feb 2006 20:13:06 +0000
Subject: RE: PMU and timer interrupts
Message-Id: <200602132013.k1DKD6g13617@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060209171648.GA26865@frankl.hpl.hp.com>
In-Reply-To: <20060209171648.GA26865@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Stephane Eranian wrote on Monday, February 13, 2006 12:02 PM
> On Fri, Feb 10, 2006 at 03:04:57PM -0800, Chen, Kenneth W wrote:
> > In fact, most of the interrupts having SA_INTERRUPT flag set.  So the
> > blind spots you worried about for PMU is a lot wider.  For example, on
> > my system, serial, e1000, mpt fusion, qla2300 interrupts all have that
> > flag set. Looks like kernel executes these handlers with irq disabled
> > all the way through.
> > 
> Looking at my 2.6.16-rc1, it appears that neither e1000 nor mpt fusion
> are using SA_INTERRUPT anymore. The qla2xxx still does, though.

Yeah, I think you are correct.

- Ken

