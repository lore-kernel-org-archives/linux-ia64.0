From: Jack Steiner <steiner@sgi.com>
Date: Mon, 23 Oct 2006 15:15:58 +0000
Subject: Re: [patch 0/5] Physical mode SAL calls
Message-Id: <20061023151558.GA18595@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061023084840.730815639@tabatha.lab.ultramonkey.org>
In-Reply-To: <20061023084840.730815639@tabatha.lab.ultramonkey.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

SN systems support additional vendor-specific SAL calls. Some
of these pass kernel addresses to SAL for input or output buffers.
At a minimum, these buffer addresses need to be converted to 
physical addresses if SAL is run in physical mode.

In addition, I think there may be additional problems with our SAL
if we try to run only in physical mode. I'll take a look.....


-- jack
