From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 09 Dec 2002 22:59:30 +0000
Subject: RE: [Linux-ia64] unalinged access by loadpair instruction
Message-Id: <marc-linux-ia64-105590709805529@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805518@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805518@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

You do recall correctly ... checking the archives, I posted a
patch on October 16, 2001.  I did fix the floating point case
back then too ... in fact my post claims to include the patch
for both integer and FP.  But I must have attached the wrong
patch file.  I've long since deleted all my 2.4.10 trees, so
I'd have to reconstruct from scratch (can't do it from memory,
those neurons have been re-assigned :-(

-Tony

-----Original Message-----
From: David Mosberger [mailto:davidm@napali.hpl.hp.com]
Sent: Monday, December 09, 2002 1:42 PM
To: Hideki Yamamoto
Cc: linux-ia64@linuxia64.org
Subject: Re: [Linux-ia64] unalinged access by loadpair instruction


It looks to me like getfpreg() and setfpreg() are pretty obviously
broken: they doesn't take rotation into account at all.  Seems this
was missed when the integer-side was fixed (by Tony, IIRC).  Anyone
want to take a shot at fixing this?

	--david

>>>>> On Mon, 09 Dec 2002 23:28:45 +0900, "Hideki Yamamoto" <hideki@hpc.bs1.fc.nec.co.jp> said:

  Hideki>  Hi everyone,

  Hideki>  When unaligned access is happened by loadpair instruction,
  Hideki> reloading by kernel is wrong.
 
  Hideki>  When unalined access is happeded by loadpair instruction in
  Hideki> NORMAL loop, it is no problem.  Please try to run the
  Hideki> attached programs(c.c and a.s) compiled by gcc.

  Hideki>  However, When it is happned by loadpair instruction in SWP
  Hideki> loop, it fails to reload the data.  Please try to run the
  Hideki> attached programs(c.c and aa.s) compiled by gcc. aa.s is
  Hideki> included loadpair in SWP loop.  If there is no happening,
  Hideki> please change the n parameter to bigger number.

  Hideki>  Sorry, I could not isolate whether or not it is caused by
  Hideki> HW bug or Kernel problem.

  Hideki>  Let me know somebody understood the cause why it is
  Hideki> happened.


_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

