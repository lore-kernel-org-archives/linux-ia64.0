From: Andrew Morton <akpm@osdl.org>
Date: Wed, 15 Oct 2003 06:28:33 +0000
Subject: Re: IA64 ino_t incorrectly sized?
Message-Id: <marc-linux-ia64-106619913020876@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106378281914262@msgid-missing>
In-Reply-To: <marc-linux-ia64-106378281914262@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Nathan Scott <nathans@sgi.com> wrote:
>
>  One alternate approach would be to introduce __kernel_ustatino_t
>  and __kernel_nfsdino_t into every architecture's posix_types.h
>  (defining them as __kernel_ino_t everywhere but IA64, where they
>  would be unsigned int).  This would do away with any conditional
>  code in headers, but I'm not sure its the right approach at this
>  stage?

Sounds overly elaborate to me.  The patch which you had looked liveable-with.

