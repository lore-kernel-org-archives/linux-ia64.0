From: Eric Gillespie <epg@progeny.com>
Date: Thu, 27 Sep 2001 16:09:56 +0000
Subject: [Linux-ia64] Re: umode_t?
Message-Id: <marc-linux-ia64-105590698805268@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805261@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805261@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ulrich Drepper writes:

> It's none of your business to use this type in user-level code.
> This is a kernel type.

OK, that's fine with me.  I'll send the curves people a patch to drop
the use of umode_t.

Thanks.

-- 
Eric Gillespie, Jr. <*> epg@progeny.com
Software Developer
Progeny Linux Systems - http://progeny.com
"I don't know what a Sawfish Window Manager is."

