From: Keith Owens <kaos@ocs.com.au>
Date: Fri, 10 Nov 2000 04:40:40 +0000
Subject: [Linux-ia64] ACPI always recompiles
Message-Id: <marc-linux-ia64-105590678205677@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Whenever I compile 2.4.0-xxx for IA64, all of the ACPI subdirectories
recompile everything, even if they have not been affected by any
changes since the last compile.  I know what the problem is but before
fixing the ACPI makefiles I want to know which way ACPI for IA64 is
going.  LInus's 2.4.0-xxx ACPI uses a different makefile structure and
does not have this problem.  Is IA64 ACPI going to replace the ACPI
code in Linus's 2.4.0-xxx tree or vice versa?


