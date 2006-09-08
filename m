From: Kirill Korotaev <dev@sw.ru>
Date: Fri, 08 Sep 2006 15:15:41 +0000
Subject: Re: [PATCH] IA64,sparc: local DoS with corrupted ELFs
Message-Id: <4501891D.5090607@sw.ru>
List-Id: <linux-ia64.vger.kernel.org>
References: <44FC193C.4080205@openvz.org> <Pine.LNX.4.64.0609061120430.27779@g5.osdl.org> <44FFF1A0.2060907@openvz.org> <Pine.LNX.4.64.0609070816170.27779@g5.osdl.org>
In-Reply-To: <Pine.LNX.4.64.0609070816170.27779@g5.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@osdl.org>
Cc: Kirill Korotaev <dev@openvz.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Fernando Vazquez <fernando@oss.ntt.co.jp>, "David S. Miller" <davem@davemloft.net>, tony.luck@intel.com, linux-ia64@vger.kernel.org, stable@kernel.org, xemul@openvz.org, devel@openvz.org

Linus Torvalds wrote:

>>Does the patch below looks better?
> 
> 
> Yes. 
> 
> Apart from the whitespace corruption, that is.
> 
> I don't know how to get mozilla to not screw up whitespace.

What is funny is that mozilla doesn't screw up whitespaces.
2 people checked that patch from the email applies to the kernel.

I even checked the email myself and the only difference between "good"
patches and mine is that mine has "format=flowed" in
Content-Type: text/plain; charset=us-ascii; format=flowed

It looks like some mailers replace TABs with spaces when format=flowed
is specified. So are you sure that the problem is in mozilla?

Thanks,
Kirill

