From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 14 Mar 2003 19:26:41 +0000
Subject: Re: [Linux-ia64] [patch] 2.4.21-pre5 ia64 unwind.c - allow unw_access_gr(r0)
Message-Id: <marc-linux-ia64-105590709806108@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806091@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806091@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 14 Mar 2003 15:37:46 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> Patch is against 2.4.21-pre5 + ia64-021210 + unwind patches
  Keith> from bk tree (it would be nice to have a released
  Keith> 2.4.21-pre5-ia64 version).  The patch allows unw_access_gr()
  Keith> to read from r0, to support unwind directives such as .save
  Keith> ar.pfs,r0 and .save rp,r0.

I applied this patch in the 2.5 tree.

Thanks,

	--david

