From: Stephen Hemminger <shemminger@osdl.org>
Date: Wed, 24 Sep 2003 16:30:44 +0000
Subject: Re: [Lse-tech] CPUSET Proposal
Message-Id: <marc-linux-ia64-106442121824485@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Looks good, but you aren't likely to get much acceptance or testing if
it only works on ia64.  You need to make a version for i386 as well.


Also, don't send your patch as base64 encode attachment, it makes working
with text tools harder.
