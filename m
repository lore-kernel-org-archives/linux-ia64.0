From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 23 Jul 2004 17:15:44 +0000
Subject: Re: [PATCH] - Update function prototype for sn_io_addr
Message-Id: <16641.18368.354629.689992@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040723122907.GA7308@sgi.com>
In-Reply-To: <20040723122907.GA7308@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 23 Jul 2004 07:29:08 -0500, Jack Steiner <steiner@sgi.com> said:

  Jack> Add "const" to function prototype for sn_io_addr. Cuts boot
  Jack> time on simulator in half.

  Jack> Signed-off-by: Jack Steiner <steiner@sgi.com>

  Jack> __attribute__ ((__const__));

I think you're supposed to use __attribute_const__.

	--david
