From: "Refah, Azita" <azita.refah@intel.com>
Date: Thu, 31 Jan 2002 17:14:23 +0000
Subject: RE: [Linux-ia64] Pseudo-ops: IAS versus ia64-hp-linux-as
Message-Id: <marc-linux-ia64-105590698805974@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805959@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805959@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following explanation is from the developer of IAS:
--------------

The ld8.mov and the ltoff22x linker operator are the way to implement link
time optimization.

The problem:
To get the address of a symbol it takes 3 cycles for an arbitrary symbol and
1 cycle for a symbol in the short section (close to the GP). But if we
define all the symbols in the short section we may overflow the short
section and it will fail in link time.

The solution:
Mark certain symbols as potential for placement in the short section and the
linker will decide if there is enough space there.

The regular code:
	addl r15 = @ltoff(SYM), gp ;;
	ld8 r16 = [r15]			<== r16 holds the address of SYM

The optimized code:
	addl r16 = @gprel(SYM), gp	<== r16 holds the address of SYM

The code with ld8.mov and ltoff22X:
	addl r15 = @ltoffx(SYM), gp ;;
	ld8.mov r16 = [r15]		<== r16 holds the address of SYM

In the case that the linker decide to place SYM in the short section the
ltoff will actually be gprel and the ld8 will be converted to mov. If the
linker decide not to place SYM in the short section it becomes that same as
the regular case.

Note: that the two must come together and the need for linker support. As
far as I know GNU linker does not support this.



-----Original Message-----
From: Christian Hildner [mailto:christian.hildner@hob.de]
Sent: Wed, January 30, 2002 10:12 PM
To: linux-ia64@linuxia64.org; harish_prabhu@mobmit.com
Subject: Re: [Linux-ia64] Pseudo-ops: IAS versus ia64-hp-linux-as


>

Harish,

for reference use IA-64 Software Developer's Manual Vol. 3 Intel-No.
245319-002 (also as pdf).
But I didn't find ld8.mov. Do you want to load a register from storage or do
you want to move
from one register to another?

Christian

>
> Hello
>   Does the ia64-hp-linux-as assembler which comes with the
>  Ski/NUE support all pseudo-ops as done by the
>  Intel Assembler IAS , [ as given in the Assembler Users Guide]
>  ?
>  The Guide is unclear about what the ld8.mov instruction
>  does. Can somebody explain this to me ?


_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

