From: "Jim Hull" <jim_hull@hp.com>
Date: Fri, 22 Nov 2002 19:02:24 +0000
Subject: RE: [Linux-ia64] New rev 2.1 SDM for Itanium published
Message-Id: <marc-linux-ia64-105590709805478@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805465@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805465@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David wrote:

> The ao bit seems to have gotten lost in the final version of SDM2.1.
> It's mentioned (indirectly) in the Document Revision history, but in
> the CPUID[4] description, only "branchlong" and "spontaneous deferral"
> show up.

You're right, the "ao" bit is missing from the final public SDM 2.1.  I
wonder how that happened.  I'll check into this and see if I can get it
fixed.

 -- Jim


