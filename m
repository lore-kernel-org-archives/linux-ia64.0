From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 29 Aug 2003 00:08:32 +0000
Subject: Re: [PATCH 2.4 and 2.6] trim.bottom trims the wrong entry
Message-Id: <marc-linux-ia64-106211684707744@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106208671402725@msgid-missing>
In-Reply-To: <marc-linux-ia64-106208671402725@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 28 Aug 2003 09:04:13 -0700, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> This was a fun one to track down.

Ouch.  I can only imagine...

  Tony> The problem is that efi_memmap_walk() repeatedly trims the
  Tony> same entry, instead of trimming each of the entries in the
  Tony> granule.

Applied.

Thanks,

	--david
