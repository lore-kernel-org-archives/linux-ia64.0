From: Cary Coutant <cary@cup.hp.com>
Date: Wed, 27 Feb 2002 19:19:30 +0000
Subject: Re: [Linux-ia64] problem with unwind info for .init/.fini sections
Message-Id: <marc-linux-ia64-105590701905194@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905179@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905179@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>I can think of two approaches:
>...
>Anybody else have a better idea or other comments?

(3) Use the .init_array and .fini_array sections instead.

-cary

