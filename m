From: Matt Chapman <matthewc@cse.unsw.edu.au>
Date: Sat, 15 Nov 2003 04:36:41 +0000
Subject: Re: Update to Itanium Software Developer's Manual released
Message-Id: <marc-linux-ia64-106887104606023@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106883810409669@msgid-missing>
In-Reply-To: <marc-linux-ia64-106883810409669@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Tony,

I reported this around a year ago but it doesn't seem to have made it
into the SDM or the updates - maybe you can pass it on to the right
people.

I think the documentation for the "tak" instruction is misleading
and should be clarified.  It says:

  Translation Access Key
  Format:      (qp) tak r1 = r3
  Description: The protection key for a given virtual address is
  obtained and placed in GR r1.
  [...]
  GR[r1] = tlb_access_key(GR[r3], itype);

This suggests that you get the protection key in r1, whereas what
you actually get is the protection key shifted left by 8 bits (so
it lines up with where it is in the TLB and PKR insertion formats).

Matt


On Fri, Nov 14, 2003 at 11:27:10AM -0800, Luck, Tony wrote:
> This specification update contains updates to the Intel?
> Itanium? Architecture Software Developer's Manual, Volume
> 1-3. This document is a compilation of specification changes,
> specification clarifications, and documentation changes.
> This document does not cover errata descriptions.
> 
> Download from:
> 
> http://developer.intel.com/design/itanium/downloads/248699.htm
> 
> -Tony Luck
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
