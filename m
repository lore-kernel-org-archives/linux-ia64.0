From: Keith Fish <kaf@fc.hp.com>
Date: Wed, 10 Oct 2001 20:42:04 +0000
Subject: Re: [Linux-ia64] Re: prctl patch for fpu faults
Message-Id: <marc-linux-ia64-105590698805321@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805302@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805302@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"Mallick, Asit K" wrote:
> 
> David/Jesse,
> 
> I would like the default to be noprint. As Jack mentioned that there are
> applications that will generate lots of these messages. These messages are
> ok for development systems and debugging applications but for production
> systems this creates problem. Most of the users want to run the applications
> (production) that do not require changing the configuration. We have seen
> people running applications on top of Linux and complaining about the
> performance compared to other OSes. The performance difference is due to the
> logging of these messages.

Really?  I would have thought the rate-limiting mode would reduce the logging
(printing) to noise relative to the (huge) overhead of the traps.

