From: "David S. Miller" <davem@redhat.com>
Date: Thu, 25 Apr 2002 00:43:18 +0000
Subject: [Linux-ia64] Re: PCI DAC routines for SN
Message-Id: <marc-linux-ia64-105590701905523@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905493@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905493@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   From: Jesse Barnes <jbarnes@sgi.com>
   Date: Wed, 24 Apr 2002 17:36:52 -0700

   Ok, so there's no performance argument against adding the call.
   You're just saying that since there are enough 32 bit mappings to go
   around, using 64 bit mappings is silly.  Right?

We don't add things to Linux that we "might need" we add things
we actually need.  It is a slight performance problem too.

I don't think the hardware folks would be happy to hear that you're
willing to sacrifice real hardware cycles just for some DAC nirvana
or whatever it is you have for this issue.


