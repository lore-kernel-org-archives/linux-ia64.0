From: Keith Owens <kaos@ocs.com.au>
Date: Wed, 13 Jun 2001 07:59:32 +0000
Subject: Re: [Linux-ia64] xfs
Message-Id: <marc-linux-ia64-105590693005725@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005724@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005724@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 13 Jun 2001 09:14:55 +0200 (CEST), 
Martin Wilck <Martin.Wilck@fujitsu-siemens.com> wrote:
>Somebody posted recently that xfs works on Linux/IA64.
>However, there are no kernel patches against 2.4.4/5 on oss.sgi.com.
>Can anybody tell whether the patches they offer work with newer kernels as
>well?

The XFS Release 1.0 files are against 2.4.2 and do not fit very well on
recent kernels.  There have been some ad-hoc patches released for later
kernels, but no official release.  You are better off getting XFS from
CVS (which is now up to 2.4.6-pre3) and applying the IA64 patch on top
of that.


