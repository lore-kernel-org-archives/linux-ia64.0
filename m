From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 15 Feb 2005 19:46:21 +0000
Subject: Re: [PATCH] Convert pgtable cache to slab
Message-Id: <16914.20877.384048.731316@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1wtxnprkq.fsf@wilson.mkp.net>
In-Reply-To: <yq1wtxnprkq.fsf@wilson.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 15 Feb 2005 13:31:48 -0600, Robin Holt <holt@sgi.com> said:

  Robin> Is there a strong objection to implementing 4 levels of 16k
  Robin> page tables for now and then, if someone else sees a need,
  Robin> convert to using long page table format and adjust page
  Robin> tables as needed at that point in time.

I certainly don't want to switch my machines to 4-levels.  There is
zero need for that on the machines I use, so why pay the overhead of
an extra level?

BTW: why do you want 4-level/16KB over 3-level/64KB?

	--david
