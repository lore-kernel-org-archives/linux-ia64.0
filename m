From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Fri, 31 Jan 2003 03:31:43 +0000
Subject: Re: [Linux-ia64] Script for decoding PSR in oopses
Message-Id: <marc-linux-ia64-105590709805787@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805784@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805784@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:

>>>>> On Fri, 31 Jan 2003 13:10:58 +1100, Keith Owens <kaos@ocs.com.au> said:
Keith> On Fri, 31 Jan 2003 12:46:00 +1100, Peter Chubb
Keith> <peter@chubb.wattle.id.au> wrote:

>>> I find trying to work out what the PSR is after an oops to be a
>>> bit of a pain, so here's an awk script to do it for you.

>>> Usage is decode_psr hex_number if you save the script as
>>> decode_psr.

Keith> Below are Perl ia64_psr and ia64_isr.  Run as echo hex_number |
Keith> ia64_[pi]sr

David> OK, now where is the Python version?? ;-))

Who cares?  Once you've got a script you can use it.  

BTW, there's a bug in the AWK script:
--- decode_psr-old 2003-01-31 13:33:51.000000000 +1100
+++ decode_psr	   2003-01-31 13:11:13.000000000 +1100
@@ -77,7 +77,7 @@
 	psr = int(psr / 2)
 	if (psr % 2 = 1)
 	   decoded = decoded "rt "
-	psr = int(psr / 16)
+	psr = int(psr / 32)
  
 	cpl = psr % 4;
 	decoded = decoded "cpl=" cpl " "


