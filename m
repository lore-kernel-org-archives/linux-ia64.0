From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 02 Nov 2006 09:22:05 +0000
Subject: RE: [PATCH]IA64 trap code 16 bytes atomic copy on montecito, take 2
Message-Id: <000401c6fe60$5e3624c0$bf80030a@amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <454961EE.4070608@intel.com>
In-Reply-To: <454961EE.4070608@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Mao, Bibo wrote on Thursday, November 02, 2006 1:06 AM
> Chen, Kenneth W wrote:
> > Mao, Bibo wrote on Wednesday, November 01, 2006 11:53 PM
> >> else means that current cpu does not support 16 byte atomic operation.
> >> If kprobe address is on slot 0/2, then memcpy still can execute.
> > 
> > Do you allow kprobe insertion on "L+X" instruction?  It looks like so.
> > Then how do you maintain atomic update to L and X instruction right
> > now with memcpy?
> 
> From the code, It allows kprobes insertion on "L+X" instruction, and put
> BREAK code on the slot 2. IA64 manual says that "the X slot may encode
> break.i and nop.i in addition to any X-unit instruction".
> It seems that for MLX, BREAK opcode should insert the higher 8 bytes firstly.

That's exactly what I'm saying in the 2nd paragraph.


> > "atomic update" is not really the exact word I want to use here.  Don't
> > you want to write the upper 8-byte first so that break opcode is jammed
> > in there before updating the remaining 41-bit immediate value? Otherwise,
> > writing lower 8-byte first will end up with a small window that original
> > opcode seeing corrupted immediate value.

And same logic extends to inserting probe on slot 1 instruction.  The key is
to jam in break opcode, before updating the remaining unused immediate value.

