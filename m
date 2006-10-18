From: David Howells <dhowells@redhat.com>
Date: Wed, 18 Oct 2006 10:10:57 +0000
Subject: Re: [patch 2.6.19-rc2] Correct definition of handle_IPI
Message-Id: <20900.1161166257@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <8916.1161149809@kao2.melbourne.sgi.com>
In-Reply-To: <8916.1161149809@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Keith Owens <kaos@sgi.com> wrote:

> The declaration of handle_IPI should really be in a header file instead
> of a .c file, but which one?  Adding
> 
>   extern irqreturn_t handle_IPI(int irq, void *dev_id);

Stick it in arch/ia64/kernel/internal.h.  That way it'll not be directly
exposed to the rest of the kernel.  Then #include that file from interested
parties in that directory.

Otherwise your patch looks reasonable.

Acked-By: David Howells <dhowells@redhat.com>
