From: Keith Owens <kaos@ocs.com.au>
Date: Mon, 23 Jul 2001 14:24:56 +0000
Subject: Re: [Linux-ia64] XFS / IA64 system call conflict
Message-Id: <marc-linux-ia64-105590693005872@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005867@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005867@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 23 Jul 2001 16:09:19 +0200, 
Jes Sorensen <jes@sunsite.dk> wrote:
>Please don't do this. If you want to use temporary numbers, bump them
>out of range so we don't clash with them in the next kernel
>release. I'd say pick something like 8000 for now.

The tables only go up to 1279 so I picked an arbitrary number in the
middle.


