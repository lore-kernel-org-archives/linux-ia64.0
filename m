From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 26 Jan 2005 05:20:05 +0000
Subject: any point to CONFIG_IA64_PRINT_HAZARDS?
Message-Id: <16887.10373.892466.257345@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Is there any point to keeping CONFIG_IA64_PRINT_HAZARDS?  I always
have it on and I don't know why you'd ever want to turn it off.  I
vaguely remember that there may have been an issue with turning it on
for early Merced silicon but I really doubt any silicon in use today
needs that (and even if it did, it should be made dependent on a
model/stepping-based option, not a separate thing).

	--david
