From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 05 Jan 2004 21:10:58 +0000
Subject: Re: Cleanup EXPORT_SYMBOL usage
Message-Id: <16377.53986.241513.594008@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <jer7yemdr9.fsf@sykes.suse.de>
In-Reply-To: <jer7yemdr9.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


  Andreas> Andreas Schwab <schwab@suse.de> writes:
  >> This cleans up the use of EXPORT_SYMBOL in ia64_ksyms.c by moving
  >> most of them to the place where the symbol is defined.  Ideally,
  >> only symbols defined in assembler sources should remain here, but
  >> there are some cases where an EXPORT_SYMBOL is missing outside
  >> the arch/ia64 tree.  I did not change them for now.  Also,
  >> EXPORT_SYMBOL_NOVERS is obsolete.

  Andreas> There was a compilation failure for certain configurations,
  Andreas> here is a new patch.

Looks good to me.  It's in the to-linus-2.5 tree now.

Thanks!

	--david
