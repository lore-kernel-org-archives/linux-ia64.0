From: Roman Hodek <roman@ns.caldera.de>
Date: Wed, 24 Oct 2001 12:14:14 +0000
Subject: Re: [Linux-ia64] framebuffer console
Message-Id: <marc-linux-ia64-105590698805381@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805378@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805378@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> This patch solves the problem. Still surprised that cached accesses
> to the video memory crash the machine though..

I've seen similar, really hard crashes already, too. IMHO it seems
that the AGP bridge in the chipset doesn't like wide accesses
generated when filling or writing out cache lines.

Roman

