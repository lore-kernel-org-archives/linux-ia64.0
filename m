From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 05 Feb 2008 23:34:16 +0000
Subject: RE: [RFC][PATCH] kprobes: kprobe-booster for ia64
Message-Id: <1FE6DD409037234FAB833C420AA843EC84804C@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <47A8E995.1090400@redhat.com>
In-Reply-To: <47A8E995.1090400@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masami Hiramatsu <mhiramat@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@us.ibm.com>, "Li, Shaohua" <shaohua.li@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, ia64 <linux-ia64@vger.kernel.org>, systemtap-ml <systemtap@sources.redhat.com>

+/* Insert a long branch code */
+static void __kprobes set_brl_inst(void *from, void *to)
+{
+	s64 rel = ((s64) to - (s64) from) >> 4;
+	bundle_t *brl;
+	brl = (bundle_t *) ((u64) from & ~0xf);
+	brl->quad0.template = 0x05;	/* [MLX](stop) */
+	brl->quad0.slot0 = NOP_M_INST;	/* nop.m 0x0 */
+	brl->quad0.slot1_p0 = ((rel >> 20) & 0x7fffffffff) << 2;
+	brl->quad1.slot1_p1 = (((rel >> 20) & 0x7fffffffff) << 2) >> (64 - 46);
+	/* brl.cond.sptk.many.clr rel<<4 (qp=0) */
+	brl->quad1.slot2 = BRL_INST(rel >> 59, rel & 0xfffff);
+}

Is this function operating directly on the instruction bundle in the
kernel code?  If so, the bundle will contain some "interesting"
intermediate values as each of the "brl->xxx = yyy;" are processed.
If another cpu should try to execute this bundle while the modifications
are in progress, then the results will be not what you want.

On cpu models that support st16 you could construct the brl instruction
and use a single st16 to update the whole bundle atomically.

-Tony
