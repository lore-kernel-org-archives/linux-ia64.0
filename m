From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 17 Nov 2004 18:59:03 +0000
Subject: RE: [patch] per cpu MCA/INIT save areas (take 2)
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02680B23@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200411122327.iACNRR5h131335@ben.americas.sgi.com>
In-Reply-To: <200411122327.iACNRR5h131335@ben.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>One technical concern is that the routine uses r16, r17, r18, r19, r20.
>Optimizing is may squeeze out a couple but the bigger question is what
>scratch registers are available?  Specificly, ia64_os_mca_proc_state_dump
>saves off r16+ registers, so it would be good not to trash >them before they
>are saved.

In most cases the MCA/INIT is taken when PSR.bn is 1, so in these cases
you have just switched to bank 0, and all of r16-r31 are available as
scratch.  If PSR.bn was zero when the MCA/INIT occurred, then you will
trample on values that might be useful.  Now you will need some registers
to get running, so the best you can do is limit the damage by using as
few registers as possible before the 'save everything' code kicks in.
  
>
>Other than that issue, it looks like a macro could be used 
>instead of k3.

I'm not a big fan of dozen line macros with weird calling/register
conventions.  I'd prefer k3.

-Tony
