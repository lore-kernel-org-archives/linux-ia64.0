From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 18 Feb 2004 19:16:50 +0000
Subject: Re: [PATCH] possible memory leak fix
Message-Id: <16435.47650.38997.551878@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040218.164327.74757142.maeda@jp.fujitsu.com>
In-Reply-To: <20040218.164327.74757142.maeda@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 18 Feb 2004 16:43:27 +0900 (JST), MAEDA Naoaki <maeda.naoaki@jp.fujitsu.com> said:

  Naoaki> I found a possible memory leak problem in alloc_resource().
  Naoaki> The following patch against 2.6.3 fix the problem.

Looks correct to me.  Applied.

Thanks,

	--david
