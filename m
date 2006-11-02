From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 02 Nov 2006 20:29:56 +0000
Subject: RE: [PATCH]IA64 trap code 16 bytes atomic copy on montecito, take 2
Message-Id: <000101c6febd$a8f23f00$ff0da8c0@amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <454961EE.4070608@intel.com>
In-Reply-To: <454961EE.4070608@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote on Thursday, November 02, 2006 11:58 AM
> > But seriously, considering patch slot 1 instruction with bits slot1[40:18]
> > (which is nicely contained within the upper 8-byte of a bundle). The encoding
> > for break instruction takes [40:27], and it left you with 9 bits to encode
> > immediate value (actually 10 because bit 36 is also part of immediate value).
> > With that, kprobe on slot1 can be extended to all CPU, not just montecito.
> 
> Sounds like with some careful trickery (and choice of break value ranges) you
> might well be able to *insert* the breakpoint in slot1 with only 8-byte atomic
> operations.
> 
> But I can't see how you plan to *remove* the breakpoint and restore the
> original instruction.

Why not?  Restore the lower [17:0] bits first, then restore the upper [40:18].
I don't see a problem though.  There is a race window where the break probe
seeing a combined [17:0] from original instruction with its own value from
[26:18]. But why would that matter?  Insertion has the same challenge that
break will see a mixed immediate value between original and its own.  The
solution is to insert upper bits first, then the lower bits. Along with
teaching break handler to ignore all lower bits. I don't see how restore is
any different from insertion except the order in memory updates.

What matters is the opcode.  As long as the opcode is done in one operation,
the operand doesn't make much difference given the simplicity of break
instruction.

Would that work?  I could very well missed something, but haven't seen that
yet.

