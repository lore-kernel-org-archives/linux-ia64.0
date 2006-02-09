From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 09 Feb 2006 00:35:12 +0000
Subject: RE: [PATCH] registration for new system call unshare
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05AA11A5@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1139440466.2535.2.camel@hobbes.atlanta.ibm.com>
In-Reply-To: <1139440466.2535.2.camel@hobbes.atlanta.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Just an idea, can we recycle some of old unused syscall number?
>9-10'ish in arch/ia64.

It would save eight bytes to recycle an unused number, but there
is some maintenance benefit in adding the new ones at the end
in the same order (makes it easy to see which ones I'm missing
by comparing against i386).

-Tony
