From: Rik van Riel <riel@conectiva.com.br>
Date: Sun, 24 Jun 2001 15:20:18 +0000
Subject: Re: [Linux-ia64] IO/TLB bounce buffer space
Message-Id: <marc-linux-ia64-105590693005753@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005716@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005716@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 22 Jun 2001, Rich Altmaier wrote:

> This is just a note to comment on the mention of:
>   Thus, worst case buffer usage would be 8kB * 253 * 16 * 4 = 126 MB only
>   for this driver! Of course it is highly unlikely that all these buffers
>   will be in use simultaneously.

> This leaves no room for statistical analysis!

Yup. Even though it may be the architecture formerly
known as Itanic, people still CARE ABOUT STABILITY.

Coding device drivers or the OS in such a way that
kernel memory resources can be overcommitted is just
irresponsible and foolish.

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)


