From: Alex Williamson <alex.williamson@hp.com>
Date: Tue, 06 Jun 2006 18:16:59 +0000
Subject: RE: Montecito processor family
Message-Id: <1149617819.5920.44.camel@lappy>
List-Id: <linux-ia64.vger.kernel.org>
References: <42ADD890.1010406@free.fr>
In-Reply-To: <42ADD890.1010406@free.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2006-06-06 at 11:04 -0700, Chen, Kenneth W wrote:
> 
> I would also like to take this opportunity to revamp feature string.
> It is way too long, and should be either two or three letter acronym
> like x86:
> 
> X86 feature string: "flags : fpu vme de pse tsc msr pae mce ... "
> 
> - features   : branchlong, 16-byte atomic ops
> + features   : lb ao

   On the down side, I find that I sometimes have to go look in the code
to figure out which flags I care about on x86.  Are "lb" and "ao"
defined somewhere?

	Alex

-- 
Alex Williamson                             HP Open Source & Linux Org.

