From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 22 Sep 2003 21:01:03 +0000
Subject: Re: [HELP] latest discontig
Message-Id: <marc-linux-ia64-106426487829948@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106305453930076@msgid-missing>
In-Reply-To: <marc-linux-ia64-106305453930076@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 22 Sep 2003 13:31:15 -0700, jbarnes@sgi.com (Jesse Barnes) said:

  >> I'm sorry, but until some of these criteria are met, there is no
  >> way I'm going to apply this patch.  As for the breakage: as far
  >> as I can see, the patch moves the bootmem initialization back to
  >> the old place, which means that drivers/acpi/tables.c will fail
  >> to allocate memory for the SDT again.

  Jesse> Len Brown already took the change to fix tables.c.

Perhaps I'm missing something, but I see this in Linus' tree:

Age      Author    Rev  Comments
 7 weeks len.brown 1.15 match 2.4 -- more info in RSDT, nix some build warnings
11 weeks agrover   1.14 ACPI: Dynamically allocate SDT list (suggested by Andi Kleen)

No SDT fixes are far as I can see.

	--david
