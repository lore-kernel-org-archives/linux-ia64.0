From: David Miller <davem@davemloft.net>
Date: Wed, 30 Dec 2009 17:15:20 +0000
Subject: Re: [PATCH] simeth.c: use %pM to shown MAC address
Message-Id: <20091230.091520.193699933.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <BD79186B4FD85F4B8E60E381CAEE19090200F4B7@mi8nycmail19.Mi8.com>
In-Reply-To: <BD79186B4FD85F4B8E60E381CAEE19090200F4B7@mi8nycmail19.Mi8.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hartleys@visionengravers.com
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

From: "H Hartley Sweeten" <hartleys@visionengravers.com>
Date: Mon, 28 Dec 2009 17:24:38 -0500

> Use the %pM kernel extension to display the HwAddr.
> 
> The only difference in the output is that the MAC address is
> shown in the usual colon-separated hex notation instead of
> space-separated.
> 
> Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>

Applied.
