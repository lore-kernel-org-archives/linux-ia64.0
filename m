From: Johannes Erdfelt <jerdfelt@valinux.com>
Date: Tue, 13 Jun 2000 02:34:29 +0000
Subject: [Linux-ia64] ELI updates
Message-Id: <marc-linux-ia64-105590678205131@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

There's a new version of ELI in CVS which fixes a couple of bugs and
finally correctly handles memory allocation.

I've merged in the 3 patches posted to the lists:
- Off by one allocation problem for eli.cfg
- ACPI AML scope parsing bug
- initrd patches

I've spent some time testing the code, but I haven't test it completely.
For one, I haven't tried the initrd code since I reorganized some of the
code.

I'll make a new release soon after I spend some more time testing the
code and possibly add some more ACPI support needed for the NEC guys.

JE



