From: Jim Wilson <wilson@cygnus.com>
Date: Thu, 18 Jan 2001 00:56:32 +0000
Subject: Re: [Linux-ia64] two ICEs with current compiler
Message-Id: <marc-linux-ia64-105590693005072@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005066@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005066@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>gcc -O2 -c lexer.c 
>...
>lexer.c: In function `yylook':
>lexer.c:2138: warning: cast from pointer to integer of different size
>lexer.c:2148: warning: cast from pointer to integer of different size
>lexer.c:2239: Internal compiler error in `find_auto_inc', at flow.c:5032

For the second problem, there was a little bit of code looking for a register
when we actually had a slightly more complicated expression.  The code needed
to fail instead of aborting if it didn't find the register it was looking for.

Thu Aug  3 01:05:32 2000  Jeffrey A Law  (law@cygnus.com)

	* flow.c (find_auto_inc): Verify that we've got a REG before
	peeking at its regno.  Fail, don't abort if we can't find
	the increment of the desired register.

Index: flow.c
=================================RCS file: /cvs/cvsfiles/devo/gcc/flow.c,v
retrieving revision 1.234.2.7
diff -p -r1.234.2.7 flow.c
*** flow.c	2000/11/16 20:24:38	1.234.2.7
--- flow.c	2001/01/18 00:47:56
*************** find_auto_inc (pbi, x, insn)
*** 5024,5035 ****
    if (GET_CODE (y) != PLUS)
      return;
  
!   if (REGNO (XEXP (y, 0)) = REGNO (addr))
      inc_val = XEXP (y, 1);
!   else if (REGNO (XEXP (y, 1)) = REGNO (addr))
      inc_val = XEXP (y, 0);
    else
!     abort ();
  
    if (GET_CODE (inc_val) = CONST_INT)
      {
--- 5024,5035 ----
    if (GET_CODE (y) != PLUS)
      return;
  
!   if (REG_P (XEXP (y, 0)) && REGNO (XEXP (y, 0)) = REGNO (addr))
      inc_val = XEXP (y, 1);
!   else if (REG_P (XEXP (y, 1)) && REGNO (XEXP (y, 1)) = REGNO (addr))
      inc_val = XEXP (y, 0);
    else
!     return;
  
    if (GET_CODE (inc_val) = CONST_INT)
      {


