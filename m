From: Keith Owens <kaos@ocs.com.au>
Date: Tue, 23 Jul 2002 01:00:14 +0000
Subject: Re: [Linux-ia64] kernel update (relative to v2.4.18)
Message-Id: <marc-linux-ia64-105590701905806@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 22 Jul 2002 11:05:50 -0700, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>I just uploaded a new patch:
>
>	linux-2.4.18-ia64-020722.diff.gz
>
>It goes back to the more drastic solution of turning off "xconfig"
>alltogether (it tells you to use "menuconfig" instead).  I don't care
>about "xconfig" myself, but of course will welcome patches that fix
>the problems for real.
>
>The new patch also has the additional #define's needed for the tg3 driver.

020722 is identical to 020719, except that the Changelog at the start
has been removed.  If you can wait for a couple of hours, I will have
the real fix for the ia64 xconfig problem.


