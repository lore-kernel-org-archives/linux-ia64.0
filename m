From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 19 Oct 2006 00:03:30 +0000
Subject: RE: [PATCH] - Fix get_model_name() for mixed cpu type systems
Message-Id: <617E1C2C70743745A92448908E030B2AAE0FAF@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061018212559.GA2965@sgi.com>
In-Reply-To: <20061018212559.GA2965@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


+	for (i = 0; i < MAX_BRANDS; i++)
+		if (brandname[i][0] = '\0')
+			return strcpy(brandname[i], brand);
+	BUG();

BUG seems a bit drastic ... the brandname is just an informational
thing that shows in /proc/cpuinfo (and seems hard to parse ... so
unlikely to be used much.

-Tony
