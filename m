From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 26 Sep 2003 20:32:45 +0000
Subject: Re: [PATCH] always print note when trimming EFI memory map
Message-Id: <marc-linux-ia64-106460850320409@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106444761123807@msgid-missing>
In-Reply-To: <marc-linux-ia64-106444761123807@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 24 Sep 2003 17:53:14 -0600, Bjorn Helgaas <bjorn.helgaas@hp.com> said:

  Bjorn> I think it would be a good idea to always print a note when
  Bjorn> trimming the EFI memory map, even if it's not "available"
  Bjorn> memory.

  Bjorn> I just debugged a problem where we trimmed out some memory
  Bjorn> that contained ACPI tables.  When we went to look at a table
  Bjorn> later, we used the wrong attribute because we couldn't find
  Bjorn> its address in the EFI memory map.  This caused an MCA
  Bjorn> (uncached access to memory).  Straightforward to debug, but
  Bjorn> the note would have made it quicker.

The intention was to give the user an idea how much real & available
memory is lost due to the trimming.  When reporting unavailable
memory, you'll lose that info.  However, maybe we should be more
verbose if EFI_DEBUG is enabled?

	--david
