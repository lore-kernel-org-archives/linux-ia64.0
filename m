From: "Jessica Han" <jessica@cup.hp.com>
Date: Tue, 04 Sep 2001 20:33:04 +0000
Subject: [Linux-ia64] Re: optimization/3783
Message-Id: <marc-linux-ia64-105590698805119@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

http://gcc.gnu.org/cgi-bin/gnatsweb.pl?cmd=view%26pr783%26database=gcc
 It seems this problem occurs only when we have POST_INC addressing mode.
With POST_INC, for rtl "set reg351, reg328 PLUS 1", attempt_auto_inc
(flow.c) will change reg328 into reg351 as an operand of POST_INC, but leave
the "PLUS" as is. Thus the RTL becomes "set reg 351, reg351 PLUS 1" and
causes the infinite recursion in canon_rtx. If I substitute "reg328 PLUS 1"
with POST_INC reg351, the testcase attached in GNAT will pass at compile
time.
   The fix I did is in attempt_auto_inc:
  <       validate_change (incr, &XEXP (y, opnum), q, 1);
  ---
  >       validate_change (incr, &y, inc, 1);
Is this the right thing to do? Thanks.



