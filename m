From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 10 Sep 2008 00:06:01 +0000
Subject: RE: [PATCH] fix compile failure with non modular builds
Message-Id: <57C9024A16AD2D4C97DC78E552063EA30A147EC5@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1221001008.23271.12.camel@localhost.localdomain>
In-Reply-To: <1221001008.23271.12.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Git grumbled about the trailing whitespace on this line:

+/*
+ * format for entries in the Global Offset Table
+ */

But apart from that (which I will fix) it all applied
nicely ... and allnoconfig now builds without error.

%pF still works too.

Thanks James

-Tony

