From: Ted Logan <tlogan@spatial.com>
Date: Thu, 31 Aug 2000 15:22:50 +0000
Subject: [Linux-ia64] gcc warnings on truncations?
Message-Id: <marc-linux-ia64-105590678205426@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Is there a way to get gcc to warn (or ideally, error) on truncations to
shorter types? ie:

	int len = strlen(blah);

should warn because strlen returns a size_t, which on 64-bit platforms
is 8 bits and ints are 4. This would be a nice sanity check in our
porting effort to make sure there's no possibility of loosing data. I've
poked through the docs and nothing seemed to do it.

Ted Logan
Spatial Technology

