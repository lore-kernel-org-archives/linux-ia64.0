From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 11 Jan 2002 00:19:55 +0000
Subject: RE: [Linux-ia64] latest MCA logging patch
Message-Id: <marc-linux-ia64-105590698805806@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805745@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805745@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 10 Jan 2002 16:16:33 -0800, "Hall, Jenna S" <jenna.s.hall@intel.com> said:

  Jenna> OK I've made the local_irq_save() change and here is the new
  Jenna> patch.  As per the latest (July 2001) SAL spec, all SAL calls
  Jenna> used in the Linux kernel are re-entrant, except some called
  Jenna> by the bootstrap processor during boot time.  See table 9-2.

My understanding is that there is firmware out there that's not fully
re-entrant.  As long as this is the case, I don't believe this change
is safe.

	--david

