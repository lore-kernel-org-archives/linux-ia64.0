From: Uros Prestor <uros@turbolinux.com>
Date: Tue, 09 Jan 2001 20:05:57 +0000
Subject: Re: [Linux-ia64] IA-64 Linux TODO list
Message-Id: <marc-linux-ia64-105590678205898@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205896@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205896@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:

>  - verify that all on-board hardware is supported and working:
>         - does cs4281 sound driver work reliably now?

Yes, we use it as a module and it works w/o problems.  You need an updated
mpg123 and/or xmms RPM, though.

> If you can think of anything else, please let me know---I'll try keep
> the list uptodate for now.

What's the status of kernel AGP support?  Also, the DRI module for ATI Rage128
would be nice.

Uros

--
Uros Prestor
uros@turbolinux.com




