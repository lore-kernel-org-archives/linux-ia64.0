From: Jes Sorensen <jes@sgi.com>
Date: Tue, 22 Apr 2008 13:55:54 +0000
Subject: Re: [PATCH 04/15] ia64/pv_ops: introduce pv_info which describes
Message-Id: <480DEE6A.8050408@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <12077165491881-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12077165491881-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Dong, Eddie wrote:
> My understanding is that code such as IVT table are well tuned and you
> are really 
> difficult to pursuade people to replace those privilege resource access
> instruction
> to use vdso or something equalvalent such as mov GRx=CRy.  For those C
> code
> previlige resource access, like Isaku mentioned, we need to consider
> native too.

Hi Eddie,

I think binary patching of the ivt makes a lot of sense, I am certainly
not opposed to that. I was more thinking in terms of calls out of the
regular C code.

Cheers,
Jes
