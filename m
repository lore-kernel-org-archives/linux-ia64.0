From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Date: Fri, 02 Mar 2018 08:22:57 +0000
Subject: Re: [RFC 2/5] ia64/sn/hwperf: use seq_open_data
Message-Id: <CAKwiHFguCbT_0i3XWen-c58vzNNPESij9jO8Ou3PdK=_N4kYfA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180301233724.20440-1-linux@rasmusvillemoes.dk> <20180301233724.20440-2-linux@rasmusvillemoes.dk>
In-Reply-To: <20180301233724.20440-2-linux@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On 2 March 2018 at 00:37, Rasmus Villemoes <linux@rasmusvillemoes.dk> wrote:
> This code should check the return value of seq_open(); if it failed,
> file->private_data is NULL. But we can avoid the issue entirely and
> simplify the code by letting seq_open_data() set the ->private member
> to objbuf.
>
>         if ((e = sn_hwperf_enum_objects(&nobj, &objbuf)) = 0) {
> -               e = seq_open(file, &sn_topology_seq_ops);
> -               seq = file->private_data;
> -               seq->private = objbuf;
> +               e = seq_open_data(file, &sn_topology_seq_ops, objbuf);
>         }

Well, this turns a NULL deref into a resource leak; we still need to
add a check of the return value and vfree(objbuf) on failure.

Rasmus
