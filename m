From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 05 Mar 2003 02:19:13 +0000
Subject: [Linux-ia64] Re: [patch] 2.4.20-021210 misaligned sal error record
Message-Id: <marc-linux-ia64-105590709805972@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805971@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805971@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 05 Mar 2003 13:11:19 +1100, Keith Owens <kaos@sgi.com> said:

  >> +	 ((char *) _l + ((_l->valid.num_cache_check + _l->valid.num_tlb_check
  >                ^^  must be &_l->info

Ah, yes, indeed.  Thanks for catching that.


  Keith> With that change, kdb v4.0 gets accurate backtraces from INIT monarch.

Very nice!

  Keith> BTW, your patch does not fit 2.4.20-ia64-021210, looks like it is
  Keith> against 2.5.

Yes, I only do 2.5 these days.  Bjorn does 2.4.  Sorry if that wasn't
clear.

Speaking of which, sure would be nice to have an up-to-date 2.5 kdb
patch. ;-)

	--david

