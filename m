From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 06 Feb 2008 00:00:09 +0000
Subject: RE: [patch] Fix large MCA bootmem allocation
Message-Id: <1FE6DD409037234FAB833C420AA843EC8480C3@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080205193232.GA8834@sgi.com>
In-Reply-To: <20080205193232.GA8834@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Given that ia64_mca_cpu_init() does not get called in
> the hot-plug path

Surely it must be ... you even have code in it to cope
with this case.  The:

	if (__per_cpu_mca[cpu]) {

test can only be true if we are back in this code for a
second run through if the cpu was taken offline and added
again. Just like it says in the comment above this test.

-Tony
