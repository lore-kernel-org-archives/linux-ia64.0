From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 10 Nov 2000 06:39:41 +0000
Subject: Re: [Linux-ia64] ACPI always recompiles
Message-Id: <marc-linux-ia64-105590678205678@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205677@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205677@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I don't see this happening anymore since the test10 patch (since the
second ACPI driver update).  Are you still seeing this with the latest
kernel?

	--david

>>>>> On Fri, 10 Nov 2000 15:40:40 +1100, Keith Owens <kaos@ocs.com.au> said:

  Keith> Whenever I compile 2.4.0-xxx for IA64, all of the ACPI
  Keith> subdirectories recompile everything, even if they have not
  Keith> been affected by any changes since the last compile.  I know
  Keith> what the problem is but before fixing the ACPI makefiles I
  Keith> want to know which way ACPI for IA64 is going.  LInus's
  Keith> 2.4.0-xxx ACPI uses a different makefile structure and does
  Keith> not have this problem.  Is IA64 ACPI going to replace the
  Keith> ACPI code in Linus's 2.4.0-xxx tree or vice versa?

