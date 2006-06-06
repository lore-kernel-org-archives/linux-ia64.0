From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 06 Jun 2006 18:59:57 +0000
Subject: RE: Montecito processor family
Message-Id: <000101c6899b$67c1d410$e534030a@amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42ADD890.1010406@free.fr>
In-Reply-To: <42ADD890.1010406@free.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Alex Williamson wrote on Tuesday, June 06, 2006 11:17 AM
> On Tue, 2006-06-06 at 11:04 -0700, Chen, Kenneth W wrote:
> > 
> > I would also like to take this opportunity to revamp feature string.
> > It is way too long, and should be either two or three letter acronym
> > like x86:
> > 
> > X86 feature string: "flags : fpu vme de pse tsc msr pae mce ... "
> > 
> > - features   : branchlong, 16-byte atomic ops
> > + features   : lb ao
> 
>    On the down side, I find that I sometimes have to go look in the
> code to figure out which flags I care about on x86.  Are "lb" and "ao"
> defined somewhere?


I thought the x86 acronym was taken straight out of SDM, refer to CPUID
instruction detail there. We should do the same on ia64.

Section 3.1.11 out of SDM volume 1:

field bit description
lb    0   long branch (brl) instructions.
sd    1   spontaneous deferral
ao    2   16-byte atomic operations
rv    63:3 Reserved.


It's only my wishful thinking. The acronym should be improved a bit to
be more creative and meaningful in its current form.  Oh well.

