From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 08 Oct 2003 23:57:01 +0000
Subject: patch suggestion (was Re: [PATCH] move find_memory())
Message-Id: <marc-linux-ia64-106565756509670@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 8 Oct 2003 16:20:22 -0700, jbarnes@sgi.com (Jesse Barnes) said:

  Jesse> Now that the ACPI table parsing stuff has been fixed we can
  Jesse> move find_memory() back where it belongs--after the SRAT
  Jesse> table has been parsed.

Quick suggestion: when you submit patches for 2.6.0, it would be a
good idea to explain what kind of bug this fixes, so that Linus can
see easily that it's a bug fix.

(Jess, don't worry about this particular patch, I'll update the
changelog myself.)

	--david
