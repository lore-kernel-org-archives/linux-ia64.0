From: "Hoeflinger, Jay P" <jay.p.hoeflinger@intel.com>
Date: Fri, 11 Apr 2003 21:55:15 +0000
Subject: RE: [Linux-ia64] ias and stack unwind
Message-Id: <marc-linux-ia64-105590723705480@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705471@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705471@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I don't think that explains it in my case.  I'm using ecc version 7.1.
Did you have to use any special options?  

Jay

-----Original Message-----
From: David Mosberger [mailto:davidm@napali.hpl.hp.com]
Sent: Friday, April 11, 2003 4:06 PM
To: Hoeflinger, Jay P
Cc: linux-ia64@linuxia64.org
Subject: Re: [Linux-ia64] ias and stack unwind


>>>>> On Fri, 11 Apr 2003 12:05:30 -0700, "Hoeflinger, Jay P" <jay.p.hoeflinger@intel.com> said:

  Jay> Has anyone had any problems with the stack unwind directives and ias?
  Jay> For some reason when I put the unwind directives in my assembler code,
  Jay> then do a "readelf -u", it says that the assembly routine has version 2
  Jay> unwind info and can't list it.  libunwind seems to have similar problems
  Jay> and can't unwind from the assembly routine.  For all the C routines in
  Jay> the program, the unwind info version is 1, as the IA64 Software Conventions
  Jay> and Runtime Architecture Guide indicates it should be.

  Jay> Any pointers for getting ias to use version 1 would be appreciated.

Recently, I have tested libunwind (and readelf -u) with Intel ECC v7.0
and it worked fine.  I'm told earlier versions may have generated bad
(incompatible) unwind info, but I haven't verified that myself.  Could
this explain it?

	--david

