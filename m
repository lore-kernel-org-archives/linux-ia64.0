From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 18 Jan 2003 02:30:26 +0000
Subject: RE: [Linux-ia64] Re: gas generates incorrect ia64 unwind rlen val
Message-Id: <marc-linux-ia64-105590709805723@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805569@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805569@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 19 Dec 2002 17:46:54 -0800, "Patil, Harish" <harish.patil@intel.com> said:

  >> From: David Mosberger [mailto:davidm@napali.hpl.hp.com]
  >> Sent: Thursday, December 19, 2002 3:19 PM
  >> To: Patil, Harish
  >> Cc: 'davidm@hpl.hp.com'; 'linux-ia64@linuxia64.org'
  >> Subject: Re: [Linux-ia64] Re: gas generates incorrect ia64 unwind rlen
  >> values

  >> Is your script fully automatic?  If so, perhaps we could add it to the
  >> kernel sources and run it as part of "make check".  I'd love to have
  >> better unwind-info checking tools.  Actually, it's even more important
  >> to use such tools to verify the correctness of the user-level unwind
  >> info.

  Harish> Yes, the script is fully automatic and is included below (requires a
  Harish> 'readelf' that understands "-u" option).

OK, I checked this script into arch/ia64/scripts/unwcheck.sh now.  I
had to hack it a bit because readelf v2.13.90.0.10 generates the
code-ranges in the format:

	[0xe000000004408000-0xe000000004408230],

Which isn't what the script expected.

I also fixed the handful of problems it pointed out.  I agree that
those are really gas bugs (except perhaps for the unwind info in
gate.S, which was a bit clunky).  But for now, I fixed things by
adding explicit nop's and commenting out .align directives.  The
removal of .align may cost us a cycle or two in some routines, but I
don't it's noticable in practice.

Thanks,

	--david

