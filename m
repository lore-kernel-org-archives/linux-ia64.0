From: Florian Weimer <fw@deneb.enyo.de>
Date: Sun, 26 Dec 2004 23:02:33 +0000
Subject: Re: Prezeroing V2 [3/4]: Add support for ZEROED and NOT_ZEROED free maps
Message-Id: <87wtv464ty.fsf@deneb.enyo.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <fa.n0l29ap.1nqg39@ifi.uio.no> <fa.n04s9ar.17sg3f@ifi.uio.no>
	<E1ChwhG-00011c-00@be1.7eggert.dyndns.org>
In-Reply-To: <E1ChwhG-00011c-00@be1.7eggert.dyndns.org> (Bodo Eggert's message
	of "Fri, 24 Dec 2004 22:10:02 +0100")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 7eggert@gmx.de
Cc: Christoph Lameter <clameter@sgi.com>, akpm@osdl.org, linux-ia64@vger.kernel.org, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

* Bodo Eggert:

> Christoph Lameter wrote:
>
>> o Add scrub daemon
>
> Please use names a simple user may understand.
>
> What about memcleand or zeropaged instead?

But overwritting with zeros is commonly called "scrubbing", as in
"password scrubbing".
