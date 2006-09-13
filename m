From: "Randy.Dunlap" <rdunlap@xenotime.net>
Date: Wed, 13 Sep 2006 15:46:19 +0000
Subject: Re: [PATCH] IA64,sparc: local DoS with corrupted ELFs
Message-Id: <20060913084619.05b5f04f.rdunlap@xenotime.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <44FC193C.4080205@openvz.org>
	<Pine.LNX.4.64.0609061120430.27779@g5.osdl.org>
	<44FFF1A0.2060907@openvz.org>
	<Pine.LNX.4.64.0609070816170.27779@g5.osdl.org>
	<4501891D.5090607@sw.ru>
	<Pine.LNX.4.64.0609080831530.27779@g5.osdl.org>
	<450195B2.8000004@sw.ru>
In-Reply-To: <450195B2.8000004@sw.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kirill Korotaev <dev@sw.ru>
Cc: Linus Torvalds <torvalds@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Fernando Vazquez <fernando@oss.ntt.co.jp>, "David S. Miller" <davem@davemloft.net>, tony.luck@intel.com, linux-ia64@vger.kernel.org, stable@kernel.org, xemul@openvz.org, devel@openvz.org

On Fri, 08 Sep 2006 20:09:22 +0400 Kirill Korotaev wrote:

> Linus Torvalds wrote:
> > 
> > On Fri, 8 Sep 2006, Kirill Korotaev wrote:
> > 
> >>I even checked the email myself and the only difference between "good"
> >>patches and mine is that mine has "format=flowed" in
> >>Content-Type: text/plain; charset=us-ascii; format=flowed
> >>
> >>It looks like some mailers replace TABs with spaces when format=flowed
> >>is specified. So are you sure that the problem is in mozilla?
> > 
> > 
> > Hey, what do you know? Good call. I can actually just "S"ave the message 
> > to a file, and it is a perfectly fine patch. But when I view it in my mail 
> > reader, your "format=flowed" means that it _shows_ it as being corrupted 
> > (ie word wrapping and missing spaces at the beginning of lines).
> Oh, I finally found how to tune Mozilla and fix it:
> 
> One need to edit defaults/pref/mailnews.js file to have:
> pref("mailnews.send_plaintext_flowed", false); // RFC 2646===> pref("mailnews.display.disable_format_flowed_support", true);
> 
> This makes Mozilla to send emails w/o "format=flowed".
> 
> Thanks a lot for your patience :)

Here is some (similar) info for thunderbird:
  http://mbligh.org/linuxdocs/Email/Clients/Thunderbird

---
~Randy
