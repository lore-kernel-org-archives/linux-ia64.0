From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 22 Nov 2002 18:27:26 +0000
Subject: RE: [Linux-ia64] New rev 2.1 SDM for Itanium published
Message-Id: <marc-linux-ia64-105590709805475@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805465@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805465@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 22 Nov 2002 10:08:39 -0800, "Jim Hull" <jim_hull@hp.com> said:

  >> If so, should this be noted somewhere so that naive
  >> people who read the manuals don't assume that it's implemented?

  Jim> There is a new "ao" bit in CPUID[4], which as described on p. 1:32, will
  Jim> be 1 only if the new larger atomic ops are implemented.  Do you think
  Jim> this is insufficient?

The ao bit seems to have gotten lost in the final version of SDM2.1.
It's mentioned (indirectly) in the Document Revision history, but in
the CPUID[4] description, only "branchlong" and "spontaneous deferral"
show up.

	--david

