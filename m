From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 13 Apr 2002 01:57:11 +0000
Subject: Re: [Linux-ia64] Missing EXPORT_SYMBOL memset
Message-Id: <marc-linux-ia64-105590701905446@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905441@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905441@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 12 Apr 2002 17:05:37 +0200, Andreas Schwab <schwab@suse.de> said:

  Andreas> GCC 3 may generate calls to memset, so we need to export it
  Andreas> to modules.  For example, lvm requires it now, referenced
  Andreas> from lvm.c:lvm_do_vg_rename.

Yes.  Thanks for the patch.

	--david

