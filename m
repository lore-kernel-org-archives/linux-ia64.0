From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 06 Jun 2006 18:04:32 +0000
Subject: RE: Montecito processor family
Message-Id: <000001c68993$ac26f570$e534030a@amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42ADD890.1010406@free.fr>
In-Reply-To: <42ADD890.1010406@free.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote on Thursday, June 01, 2006 9:33 AM
> > Why not have "model name" with the text name, like on ia32?
> > 
> > vendor_id       : GenuineIntel
> > cpu family      : 15
> > model           : 4
> > model name      : Intel(R) Pentium(R) 4 CPU 2.80GHz
> > stepping        : 1
> 
> This sounds like an excellent plan.  We can even use the new
> (in SDM2.2 p. 2:345) PAL_BRAND_INFO call to get the right
> (Intel marketting/legal approved) string.  For older systems
> that don't implement PAL_BRAND_INFO we could have some fallback
> code that decodes family/model to Merced/McKinley/Madison.


I would also like to take this opportunity to revamp feature string.
It is way too long, and should be either two or three letter acronym
like x86:

X86 feature string: "flags : fpu vme de pse tsc msr pae mce ... "

- features   : branchlong, 16-byte atomic ops
+ features   : lb ao

