From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 04 Feb 2005 01:05:17 +0000
Subject: Re: PATCH: Fix unwind info in arch/ia64/lib/memset.S
Message-Id: <16898.51789.326196.53121@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050203233854.GA30223@lucon.org>
In-Reply-To: <20050203233854.GA30223@lucon.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 3 Feb 2005 15:38:54 -0800, "H. J. Lu" <hjl@lucon.org> said:

  HJ> I got
  HJ> arch/ia64/lib/memset.S:62: Warning: .save outside of prologue

Good catch!

	--david
