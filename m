From: Jim Wilson <wilson@cygnus.com>
Date: Fri, 18 Jan 2002 20:32:25 +0000
Subject: Re: [Linux-ia64] Fwd: Bug#129641: mozilla illegal instruction fault on IA64 (with a fix)
Message-Id: <marc-linux-ia64-105590698805883@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805877@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805877@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>This seems to be because in recent versions of g++ - since 3.0.2 according to
>the ChangeLog - class vtables are arrays of function descriptors (which are
>(code address, gp value) pairs) rather than arrays of function pointers (which
>are pointers to function descriptors).

This change was required by the C++ ABI.  If was always the intent to do
things this way, it just took a while to get around to it because there was
more compiler work than people available to do it.

Jim


