From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 26 Aug 2003 22:05:11 +0000
Subject: Re: [PATCH] ia64 oprofile support for 2.6.0-test4
Message-Id: <marc-linux-ia64-106193733214941@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106193081107734@msgid-missing>
In-Reply-To: <marc-linux-ia64-106193081107734@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 26 Aug 2003 17:51:15 -0400, Will Cohen <wcohen@redhat.com> said:

  Will> I have revised the patch based on the comments below: 1) use
  Will> ip instead of eip 2) multiply ri by 4, to get more compact
  Will> histograms

Hmmh, I'm not sure I like this patch better.  Like I mentioned in the
earlier mail, it does make sense to encode the slot number in bits 0
and 1 for instruction_pointer().  That is the canonical representation
used by IA-64 Linux (and ELF, gdb, etc.).  The traditional histogram
is a special case, because there it is more useful to get the slot
number bits close to the bundle-address bits, so I think we should
special-case this in ia64_do_profile() instead.  Perhaps something
along the lines of:

	ip = instruction_pointer(regs);
	/* for histogram, encode slot bits in address bits 2 and 3: */
	slot = ip & 3;
	ip = (ip & ~3UL) + 4*slot;

  --david
