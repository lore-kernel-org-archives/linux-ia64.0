From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 19 Nov 2001 21:40:24 +0000
Subject: Re: [Linux-ia64] PATCH: Fix for 4KB kernel corruption
Message-Id: <marc-linux-ia64-105590698805535@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805523@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805523@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 15 Nov 2001 18:05:47 -0800, "Siddha, Suresh B" <suresh.b.siddha@intel.com> said:

  Suresh> Hi, 4KB page size kernel is broken on Lion with 8GB
  Suresh> memory. ia64_boot_param structure was getting
  Suresh> corrupted. Appended patch fixes this problem.

Thanks I applied the patch and also make sure the end address is page
aligned.  It's not strictly needed, but it's cleaner that way (since
the bootmap size is measured as a page count).

	--david

