From: Keith Owens <kaos@sgi.com>
Date: Wed, 28 Aug 2002 05:38:39 +0000
Subject: Re: [Linux-ia64] PATCH: 2.5 kconfig synchronise banners 4 (fwd)
Message-Id: <marc-linux-ia64-105590701905990@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905989@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905989@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 28 Aug 2002 00:19:05 -0500 (CDT), 
Kai Germaschewski <kai-germaschewski@uiowa.edu> wrote:
>
>[Maybe someone here knows an answer? If not, I'll just remove the SN 
>specific special casing of devfs]
>
>Hi,
>
>is there any specific reason that SN1/2 have non-standard behavior with 
>respect to devfs? If not, I'd prefer to just throw away that special case 
>entirely.

SN1/2 require devfs.  Already fixed in 2.4.19-ia64-020821 patch.


