From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 19 Oct 2004 20:52:35 +0000
Subject: RE: [Patch] Altix patch 012-huberror for 2.6.10
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02363CB1@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.SGI.3.96.1041019151446.144128E-100000@fsgi900.americas.sgi.com>
In-Reply-To: <Pine.SGI.3.96.1041019151446.144128E-100000@fsgi900.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>It looks like 2.6.10 is beginning. Do you still want us to spool our
>mods to the oss site or just send them as we normally would ?
>
>
>This is 012-huberror on the oss site.

We can go back to the tried and true method of patches
(with a Changelog and Signed-off-by) in e-mail messages
to the linux-ia64 mailing list.  The ftp site was a temporary
think because your 001 and 002 patches were too big to be
mailed.

I've applied up to and including the 012 patch and pushed
the whole thing up to the new tree on bkbits:

 http://lia64.bkbits.net/linux-ia64-release-2.6.10

So you should pull from there and make sure it all builds
for you before I send the "please do a bk pull" message to
Linus.  Please send me an ACK when you've tested it.

-Tony
