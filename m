From: Keith Owens <kaos@sgi.com>
Date: Mon, 24 Jan 2005 13:22:16 +0000
Subject: Re: optimize __gp location
Message-Id: <9120.1106572936@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <B05667366EE6204181EABE9C1B1C0EB50589FCE9@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B05667366EE6204181EABE9C1B1C0EB50589FCE9@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 24 Jan 2005 08:51:17 +0100, 
Christian Hildner <christian.hildner@hob.de> wrote:
>Chen, Kenneth W schrieb:
>>Can we position the __gp somewhat more optimally, to cover more of these
>>symbols? Something like the following patch would make all of them fall
>>into the 22-bit immediate offset relative to gp.
>>
>Did you have benchmarks? Or at least a comparison of the resulting code 
>size. The code size should shrink when more items can be addressed 
>directly. Furthermore the code size should be a good indicator for the 
>performance gain you could achive.

The IA64 ABI supports link time rewriting of instructions if the linker
can determine that the field being loaded can be access via __gp
instead of via the linkage offset table.  One of the restrictions of
link time rewriting is that the code offsets cannot change, which means
that the code size cannot change either.  This code snippet will result
in two different run time sequences, depending on whether jiffies can
be referenced via __gp or not.

    addl r20=0,r1;;	// LTOFF22X  jiffies
    ld8 r16=[r20];;	// LDXMOV    jiffies
    ld8.acq r23=[r16]	// value of jiffies

When jiffies is within 22 bit range of __gp, the linker writes the
sequence as

    addl r20=offset_of(jiffies,__gp),r1;;
    mov r16=r20;;
    ld8.acq r23=[r16]	// value of jiffies

When jiffies is outside 22 bit range of __gp, the linker writes the
sequence as

    addl r20=offset_of(pointer_to_jiffies,__gp),r1;;
    ld8 r16=[r20];;	// load pointer_to_jiffies from linkage offset table
    ld8.acq r23=[r16]	// value of jiffies

Exactly the same code size, but the second form requires an extra
memory reference which is always going to be slower.

gcc emits LTOFF22X/LDXMOV if it might be able to use __gp addressing
and save the memory access, but gcc does not know at compile time if
jiffies will be in range of __gp or not.  So gcc has to use the worst
case three instruction code sequence and let the linker remove the
slow memory reference at link time.

If jiffies was defined as section .sdata then gcc would know at compile
time that jiffies was in range of __gp so gcc would use this shorter
code sequence.  Enough changes like that would shrink the code size.

    addl r16=offset_of(jiffies,__gp),r1;;
    ld8.acq r23=[r16]	// value of jiffies

Unfortunately marking jiffies and similar small but high usage
variables as section .sbss or .sdata requires changes to common code.
It might be worth doing, but the change would have to be structured so
it worked on all architectures.

