From: Linus Torvalds <torvalds@osdl.org>
Date: Thu, 07 Sep 2006 15:17:04 +0000
Subject: Re: [PATCH] IA64,sparc: local DoS with corrupted ELFs
Message-Id: <Pine.LNX.4.64.0609070816170.27779@g5.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <44FC193C.4080205@openvz.org> <Pine.LNX.4.64.0609061120430.27779@g5.osdl.org>
 <44FFF1A0.2060907@openvz.org>
In-Reply-To: <44FFF1A0.2060907@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kirill Korotaev <dev@openvz.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Fernando Vazquez <fernando@oss.ntt.co.jp>, "David S. Miller" <davem@davemloft.net>, tony.luck@intel.com, linux-ia64@vger.kernel.org, stable@kernel.org, xemul@openvz.org, devel@openvz.org



On Thu, 7 Sep 2006, Kirill Korotaev wrote:
> 
> Does the patch below looks better?

Yes. 

Apart from the whitespace corruption, that is.

I don't know how to get mozilla to not screw up whitespace.

		Linus
