From: Ulrich Drepper <drepper@redhat.com>
Date: Thu, 27 Sep 2001 00:18:43 +0000
Subject: [Linux-ia64] Re: umode_t?
Message-Id: <marc-linux-ia64-105590698805262@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805261@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805261@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Eric Gillespie <epg@progeny.com> writes:

> OK, glibc people:  Why don't you get umode_t by including sys/types.h?
> As far as i can tell, you have to include asm/types.h to get it;
> clearly not an option for an autoconf macro.

It's none of your business to use this type in user-level code.  This
is a kernel type.

-- 
---------------.                          ,-.   1325 Chesapeake Terrace
Ulrich Drepper  \    ,-------------------'   \  Sunnyvale, CA 94089 USA
Red Hat          `--' drepper at redhat.com   `------------------------

