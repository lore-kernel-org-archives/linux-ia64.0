From: Grant Grundler <grundler@cup.hp.com>
Date: Wed, 30 Jan 2002 17:49:15 +0000
Subject: Re: [Linux-ia64] What's taking all the system time..?
Message-Id: <marc-linux-ia64-105590698805964@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805950@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805950@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

duraid@fl.net.au wrote:
> it once declared upon high that longs shall always be 32 bits, long longs
> shall always be 64 bits, and ints shall be Whatever Length Is Most
> Efficiently Dealt With By The Hardware(tm)?

I believe the "long long" was a non-standard implementation for
32-bit compilers to declare/access 64-bit data structures.

And for LP64, ints are guaranteed to be 32-bits or it would have been
called ILP64.

grant

