From: Gustavo Niemeyer <niemeyer@conectiva.com>
Date: Sun, 15 Apr 2001 16:46:08 +0000
Subject: Re: [Linux-ia64] Linuxconf patch
Message-Id: <marc-linux-ia64-105590693005403@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005401@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005401@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[...]
> Please don't inline the syscall like that. We do support syscall() in
> glibc and it would be nicer (and future compatible) if you use that
> instead.

I'll do this. Thanks!

-- 
Gustavo Niemeyer

[ 2AAC 7928 0FBF 0299 5EB5  60E2 2253 B29A 6664 3A0C ]

