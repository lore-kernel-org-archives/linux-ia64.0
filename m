From: James E Wilson <wilson@tuliptree.org>
Date: Fri, 03 Mar 2006 01:13:45 +0000
Subject: Re: gas is overly conservative with itc instruction
Message-Id: <1141348425.2906.14.camel@aretha.corp.specifix.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-pv8E/bMhWBb/2Nhp7hTa"
List-Id: <linux-ia64.vger.kernel.org>
References: <B05667366EE6204181EABE9C1B1C0EB506C07A07@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B05667366EE6204181EABE9C1B1C0EB506C07A07@scsmsx401.amr.corp.intel.com>
To: linux-ia64@vger.kernel.org


--=-pv8E/bMhWBb/2Nhp7hTa
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Wed, 2006-03-01 at 10:59, Chen, Kenneth W wrote:
> The stop after first mmi bundle is unnecessary.  HJ, is it possible
> to get that relaxed a bit?

Yes.  The double stop bit here is a bug.  It is better to fix the kernel
assembly source, but the assembler should be fixed also.  I wrote and
checked in a patch to fix it.

I tested this with a kernel build, and the only difference with the
patch is that the one extra stop bit you complained about is gone.
There were no other changes to the kernel binary.

--=-pv8E/bMhWBb/2Nhp7hTa
Content-Disposition: attachment; filename=patch.last.stop
Content-Type: text/plain; name=patch.last.stop; charset=utf-8
Content-Transfer-Encoding: 7bit

2006-03-02  James E Wilson  <wilson@specifix.com>

	* config/tc-ia64.c (emit_one_bundle): For IA64_OPCODE_LAST, if we
	change the template, then clear md.slot[curr].end_of_insn_group.

Index: tc-ia64.c
===================================================================
RCS file: /cvs/src/src/gas/config/tc-ia64.c,v
retrieving revision 1.186
diff -p -p -r1.186 tc-ia64.c
*** tc-ia64.c	23 Feb 2006 21:36:17 -0000	1.186
--- tc-ia64.c	2 Mar 2006 22:32:53 -0000
*************** emit_one_bundle ()
*** 6855,6860 ****
--- 6855,6864 ----
  	         changing NOPs in front of this slot.  */
  	      for (j = i; j < 3; ++j)
  	        insn[j] = nop[ia64_templ_desc[required_template].exec_unit[j]];
+
+ 	      /* We just picked a template that includes the stop bit in the
+ 		 middle, so we don't need another one emitted later.  */
+ 	      md.slot[curr].end_of_insn_group = 0;
  	    }
  	  template = required_template;
  	}

--=-pv8E/bMhWBb/2Nhp7hTa--


