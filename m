From: Keith Owens <kaos@sgi.com>
Date: Mon, 09 Dec 2002 08:35:03 +0000
Subject: [Linux-ia64] Unwind can load wrong data from pt_regs
Message-Id: <marc-linux-ia64-105590709805516@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

2.4.19-ia64-020821/arch/ia64/kernel/unwind.c, compile_reg() contains

  case UNW_WHERE_FR:
    if (rval <= 5)
	    val = unw.preg_index[UNW_REG_F2  + (rval -  1)];
    else if (rval >= 16 && rval <= 31)
	    val = unw.preg_index[UNW_REG_F16 + (rval - 16)];
    else {
	    opc = UNW_INSN_ADD_SP;
	    val = -sizeof(struct pt_regs);
	    if (rval <= 9)
		    val += struct_offset(struct pt_regs, f6) + 16*(rval - 6);
	    else
		    dprintk("unwind: kernel may not touch f%lu\n", rval);
    }
    break;

    case UNW_WHERE_BR:
      if (rval >= 1 && rval <= 5)
	      val = unw.preg_index[UNW_REG_B1 + (rval - 1)];
      else {
	      opc = UNW_INSN_ADD_SP;
	      val = -sizeof(struct pt_regs);
	      if (rval = 0)
		      val += struct_offset(struct pt_regs, b0);
	      else if (rval = 6)
		      val += struct_offset(struct pt_regs, b6);
	      else
		      val += struct_offset(struct pt_regs, b7);
      }
      break;

This implicitly assumes that when a fr or br register is required from
pt_regs, info->sp is pointing to pt_regs.  But info->sp is modified as
the code unwinds through each function.  The above code only gives
correct results for register lookups from the failing function.
Unwinding and accessing a fr or br register from earlier functions
loads incorrect values for those registers.


