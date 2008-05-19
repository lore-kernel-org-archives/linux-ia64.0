From: Jes Sorensen <jes@sgi.com>
Date: Mon, 19 May 2008 12:25:51 +0000
Subject: Re: ld2.acq - sign extension?
Message-Id: <483171CF.5060701@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq0wslqiqyp.fsf@jaguar.mkp.net>
In-Reply-To: <yq0wslqiqyp.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Matthew Chapman wrote:
> Jes,
> 
> You mentioned that you're running on KVM... while I don't know much
> about how KVM works, is that load instruction being intercepted and
> emulated by any chance?  (Considering that it looks like something that
> would be accessing hardware registers on a real machine.)  A bug in that
> emulation could explain why it's behaving strangely...

Hi Matt,

That has to be the reason - I was sitting here being convinced it
wasn't emulated because it's not a priviledged instruction, but
obviously it is given it's accessing the emulated registers.

Next I need to figure out how thats handled, whether it's a KVM bug
a hypervisor bug ..... all this fun we are having.

Cheers,
Jes
